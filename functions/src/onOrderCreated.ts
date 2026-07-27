import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { validateOrderCreate, validateOrderTotal, isNonEmptyString } from "./validators";

const db = admin.firestore();
const messaging = admin.messaging();

export const onOrderCreated = functions.firestore
  .document("orders/{orderId}")
  .onCreate(async (snapshot, context) => {
    const order = snapshot.data();
    if (!order) return;

    const orderId = context.params.orderId;

    // ── 1. Validate order structure ──────────────────────
    const structuralErrors = validateOrderCreate(order as Record<string, unknown>);
    if (structuralErrors.length > 0) {
      functions.logger.error(`Order ${orderId} failed structural validation`, structuralErrors);
      // Delete the invalid order to prevent downstream issues
      await snapshot.ref.delete();
      return;
    }

    // ── 2. Validate total matches item prices ───────────
    const totalErrors = await validateOrderTotal(orderId, order);
    if (totalErrors.length > 0) {
      functions.logger.error(`Order ${orderId} failed total validation`, totalErrors);
      await snapshot.ref.delete();
      return;
    }

    // ── 3. Verify vendor exists and is open ─────────────
    const { vendorId, customerId } = order;

    const vendorDoc = await db.collection("vendors").doc(vendorId).get();
    const vendorData = vendorDoc.data();

    if (!vendorData) {
      functions.logger.error(`Order ${orderId}: Vendor ${vendorId} not found`);
      await snapshot.ref.delete();
      return;
    }

    if (vendorData.isOpen === false) {
      functions.logger.error(`Order ${orderId}: Vendor ${vendorId} is closed`);
      await snapshot.ref.delete();
      return;
    }

    if (!isNonEmptyString(vendorData.ownerId)) {
      functions.logger.warn(`Vendor ${vendorId} has no owner`);
      return;
    }

    // ── 4. Verify customer exists ───────────────────────
    const customerDoc = await db.collection("users").doc(customerId).get();
    if (!customerDoc.exists) {
      functions.logger.error(`Order ${orderId}: Customer ${customerId} not found`);
      await snapshot.ref.delete();
      return;
    }

    // ── 5. Notify vendor owner ──────────────────────────
    const ownerDoc = await db.collection("users").doc(vendorData.ownerId).get();
    const ownerData = ownerDoc.data();

    if (!ownerData?.fcmToken) {
      functions.logger.warn(`Vendor owner ${vendorData.ownerId} has no FCM token`);
      return;
    }

    try {
      await messaging.send({
        token: ownerData.fcmToken,
        notification: {
          title: "New Order Received!",
          body: `Order #${orderId.slice(-8)} — ${order.items.length} item(s), $${order.totalAmount.toFixed(2)}`,
        },
        data: {
          type: "order_created",
          referenceId: orderId,
        },
      });

      await db.collection("notifications").add({
        userId: vendorData.ownerId,
        title: "New Order Received!",
        body: `Order #${orderId.slice(-8)} — ${order.items.length} item(s)`,
        type: "order_created",
        referenceId: orderId,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info(`Notified vendor owner ${vendorData.ownerId} of order ${orderId}`);
    } catch (error) {
      functions.logger.error("Error sending order notification:", error);
    }
  });
