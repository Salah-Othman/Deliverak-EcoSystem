import * as admin from "firebase-admin";

const db = admin.firestore();

// ── Status transitions ──────────────────────────────────
// Maps each status to the set of statuses it can transition TO.
const VALID_TRANSITIONS: Record<string, string[]> = {
  pending: ["accepted", "cancelled"],
  accepted: ["preparing", "cancelled"],
  preparing: ["picked_up", "cancelled"],
  pickedUp: ["inTransit"],
  inTransit: ["delivered"],
  delivered: [],
  cancelled: [],
};

// Firestore uses underscores in status values
const VALID_STATUSES = [
  "pending",
  "accepted",
  "preparing",
  "picked_up",
  "in_transit",
  "delivered",
  "cancelled",
];

// ── Order validation ────────────────────────────────────

export interface OrderData {
  customerId: string;
  vendorId: string;
  driverId?: string;
  items: Array<{ productId: string; name: string; quantity: number; price: number }>;
  totalAmount: number;
  deliveryFee: number;
  status: string;
  deliveryAddress: { lat: number; lng: number; address: string; name: string; phone: string };
  paymentMethod: string;
  createdAt: admin.firestore.FieldValue;
  updatedAt?: admin.firestore.FieldValue;
}

export interface ValidationError {
  field: string;
  message: string;
}

/**
 * Validates the structure and values of an order on creation.
 * Returns an array of errors (empty = valid).
 */
export function validateOrderCreate(data: Record<string, unknown>): ValidationError[] {
  const errors: ValidationError[] = [];

  if (!data.customerId || typeof data.customerId !== "string") {
    errors.push({ field: "customerId", message: "Must be a non-empty string" });
  }

  if (!data.vendorId || typeof data.vendorId !== "string") {
    errors.push({ field: "vendorId", message: "Must be a non-empty string" });
  }

  if (!Array.isArray(data.items) || data.items.length === 0) {
    errors.push({ field: "items", message: "Must be a non-empty array" });
  } else {
    for (let i = 0; i < data.items.length; i++) {
      const item = data.items[i] as Record<string, unknown>;
      if (!item.productId || typeof item.productId !== "string") {
        errors.push({ field: `items[${i}].productId`, message: "Must be a non-empty string" });
      }
      if (!item.name || typeof item.name !== "string") {
        errors.push({ field: `items[${i}].name`, message: "Must be a non-empty string" });
      }
      if (typeof item.quantity !== "number" || item.quantity < 1 || item.quantity > 99) {
        errors.push({ field: `items[${i}].quantity`, message: "Must be 1–99" });
      }
      if (typeof item.price !== "number" || item.price < 0) {
        errors.push({ field: `items[${i}].price`, message: "Must be non-negative" });
      }
    }
  }

  if (typeof data.totalAmount !== "number" || data.totalAmount <= 0) {
    errors.push({ field: "totalAmount", message: "Must be > 0" });
  }

  if (typeof data.deliveryFee !== "number" || data.deliveryFee < 0) {
    errors.push({ field: "deliveryFee", message: "Must be non-negative" });
  }

  if (data.status !== "pending") {
    errors.push({ field: "status", message: 'Must be "pending" on creation' });
  }

  if (!data.deliveryAddress || typeof data.deliveryAddress !== "object") {
    errors.push({ field: "deliveryAddress", message: "Must be an object" });
  } else {
    const addr = data.deliveryAddress as Record<string, unknown>;
    if (typeof addr.address !== "string" || !addr.address) {
      errors.push({ field: "deliveryAddress.address", message: "Must be a non-empty string" });
    }
    if (typeof addr.lat !== "number" || typeof addr.lng !== "number") {
      errors.push({ field: "deliveryAddress.lat/lng", message: "Must be numbers" });
    }
  }

  if (data.paymentMethod !== "cash") {
    errors.push({ field: "paymentMethod", message: 'Only "cash" is supported' });
  }

  return errors;
}

/**
 * Validates that the order total matches the computed sum.
 * Must be called after Firestore write — reads item prices from the document.
 */
export async function validateOrderTotal(
  orderId: string,
  data: Record<string, unknown>
): Promise<ValidationError[]> {
  const errors: ValidationError[] = [];

  const items = data.items as Array<Record<string, unknown>> | undefined;
  if (!Array.isArray(items) || items.length === 0) {
    errors.push({ field: "items", message: "Order has no items" });
    return errors;
  }

  // Compute expected total from item prices (server-trusted prices)
  let computedSubtotal = 0;
  for (const item of items) {
    const productId = item.productId as string;
    const quantity = item.quantity as number;

    // Fetch current product price from Firestore (authoritative source)
    const productDoc = await db.collection("products").doc(productId).get();
    const productData = productDoc.data();

    if (!productData) {
      errors.push({ field: `items.${productId}`, message: "Product not found" });
      continue;
    }

    const unitPrice = productData.discountPrice ?? productData.price;
    if (typeof unitPrice !== "number" || unitPrice < 0) {
      errors.push({ field: `items.${productId}.price`, message: "Invalid product price" });
      continue;
    }

    computedSubtotal += unitPrice * quantity;
  }

  const deliveryFee = (data.deliveryFee as number) || 0;
  const expectedTotal = computedSubtotal + deliveryFee;
  const tolerance = 0.01; // Allow 1 cent floating-point tolerance
  const totalAmount = data.totalAmount as number;

  if (Math.abs(totalAmount - expectedTotal) > tolerance) {
    errors.push({
      field: "totalAmount",
      message: `Expected ${expectedTotal.toFixed(2)}, got ${totalAmount.toFixed(2)}`,
    });
  }

  return errors;
}

// ── Status transition validation ────────────────────────

/**
 * Validates that a status transition is allowed.
 * Returns null if valid, or an error message if invalid.
 */
export function validateStatusTransition(
  fromStatus: string,
  toStatus: string
): string | null {
  if (!VALID_STATUSES.includes(toStatus)) {
    return `Invalid status "${toStatus}". Valid: ${VALID_STATUSES.join(", ")}`;
  }

  const allowed = VALID_TRANSITIONS[fromStatus];
  if (!allowed) {
    return `Unknown current status "${fromStatus}"`;
  }

  if (!allowed.includes(toStatus)) {
    return `Cannot transition from "${fromStatus}" to "${toStatus}". Allowed: ${allowed.join(", ") || "(none)"}`;
  }

  return null;
}

/**
 * Validates that the caller is authorized to change the order status.
 * - Customer: can only cancel
 * - Vendor owner: can accept / prepare
 * - Driver: can pick_up / in_transit / delivered
 * - Admin: any transition
 */
export async function validateStatusAuthorization(
  orderData: Record<string, unknown>,
  callerUid: string,
  newStatus: string
): Promise<{ authorized: boolean; reason?: string }> {
  const customerId = orderData.customerId as string;
  const vendorId = orderData.vendorId as string;
  const driverId = orderData.driverId as string | undefined;

  // Check if caller is admin
  const callerDoc = await db.collection("users").doc(callerUid).get();
  const callerData = callerDoc.data();
  if (callerData?.role === "admin") {
    return { authorized: true };
  }

  // Customer can only cancel their own order
  if (callerUid === customerId) {
    if (newStatus !== "cancelled") {
      return { authorized: false, reason: "Customers can only cancel orders" };
    }
    return { authorized: true };
  }

  // Vendor can accept / prepare
  if (vendorId) {
    const vendorDoc = await db.collection("vendors").doc(vendorId).get();
    const vendorData = vendorDoc.data();
    if (vendorData?.ownerId === callerUid) {
      if (!["accepted", "preparing"].includes(newStatus)) {
        return { authorized: false, reason: "Vendors can only set status to accepted or preparing" };
      }
      return { authorized: true };
    }
  }

  // Driver can pick_up / in_transit / delivered
  if (driverId && callerUid === driverId) {
    if (!["picked_up", "in_transit", "delivered"].includes(newStatus)) {
      return { authorized: false, reason: "Drivers can only set status to picked_up, in_transit, or delivered" };
    }
    return { authorized: true };
  }

  // Also check drivers/{driverId}.userId for driver matching
  if (driverId) {
    const driverDoc = await db.collection("drivers").doc(driverId).get();
    const driverData = driverDoc.data();
    if (driverData?.userId === callerUid) {
      if (!["picked_up", "in_transit", "delivered"].includes(newStatus)) {
        return { authorized: false, reason: "Drivers can only set status to picked_up, in_transit, or delivered" };
      }
      return { authorized: true };
    }
  }

  return { authorized: false, reason: "User is not authorized to change this order's status" };
}

// ── Generic field validators ────────────────────────────

export function isNonEmptyString(val: unknown): val is string {
  return typeof val === "string" && val.trim().length > 0;
}

export function isPositiveNumber(val: unknown): val is number {
  return typeof val === "number" && val > 0;
}

export function isValidFcmToken(token: unknown): token is string {
  return typeof token === "string" && token.length > 0 && token.length <= 512;
}
