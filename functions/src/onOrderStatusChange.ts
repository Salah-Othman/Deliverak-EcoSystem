import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { validateStatusTransition, isValidFcmToken } from "./validators";

const db = admin.firestore();
const messaging = admin.messaging();

const STATUS_NOTIFICATIONS: Record<string, { title: string; bodyPrefix: string }> = {
  accepted: { title: "Order Accepted", bodyPrefix: "Your order has been accepted by the vendor" },
  preparing: { title: "Order Being Prepared", bodyPrefix: "Your order is now being prepared" },
  picked_up: { title: "Ready for Pickup", bodyPrefix: "Your order is ready and waiting for driver pickup" },
  in_transit: { title: "Out for Delivery", bodyPrefix: "Your order is on its way!" },
  delivered: { title: "Order Delivered", bodyPrefix: "Your order has been delivered. Enjoy!" },
  cancelled: { title: "Order Cancelled", bodyPrefix: "Your order has been cancelled" },
};

export const onOrderStatusChange = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // No status change → nothing to do
    if (before.status === after.status) return;

    const orderId = context.params.orderId;
    const newStatus = after.status as string;
    const previousStatus = before.status as string;

    // ── 1. Validate status transition is legal ──────────
    const transitionError = validateStatusTransition(previousStatus, newStatus);
    if (transitionError) {
      functions.logger.error(`Order ${orderId}: Invalid transition — ${transitionError}`);
      // Revert the illegal status change
      await change.after.ref.update({ status: previousStatus });
      return;
    }

    // ── 2. Validate notification info exists ────────────
    const statusInfo = STATUS_NOTIFICATIONS[newStatus];
    if (!statusInfo) {
      functions.logger.warn(`Order ${orderId}: No notification defined for status "${newStatus}"`);
      return;
    }

    const { customerId, driverId, vendorId } = after;
    const shortId = orderId.slice(-8);

    try {
      // ── 3. Notify customer ──────────────────────────
      if (customerId) {
        await notifyUser(customerId, statusInfo, orderId, shortId, newStatus);
      }

      // ── 4. Notify driver (on picked_up) ─────────────
      if (newStatus === "picked_up" && driverId) {
        const driverDoc = await db.collection("drivers").doc(driverId).get();
        const driverData = driverDoc.data();
        if (driverData?.userId) {
          await notifyUser(driverData.userId, statusInfo, orderId, shortId, newStatus);
        }
      }

      // ── 5. Notify vendor owner (on accepted) ────────
      if (newStatus === "accepted" && vendorId) {
        const vendorDoc = await db.collection("vendors").doc(vendorId).get();
        const vendorData = vendorDoc.data();
        if (vendorData?.ownerId) {
          await notifyUser(vendorData.ownerId, statusInfo, orderId, shortId, newStatus);
        }
      }

      functions.logger.info(`Order ${orderId} status: ${previousStatus} → ${newStatus}`);
    } catch (error) {
      functions.logger.error(`Error processing status change for order ${orderId}:`, error);
    }
  });

/**
 * Sends FCM notification + writes notification document for a user.
 * Silently skips if user has no valid FCM token.
 */
async function notifyUser(
  userId: string,
  statusInfo: { title: string; bodyPrefix: string },
  orderId: string,
  shortId: string,
  newStatus: string
): Promise<void> {
  const userDoc = await db.collection("users").doc(userId).get();
  const userData = userDoc.data();

  if (!userData) {
    functions.logger.warn(`notifyUser: User ${userId} not found`);
    return;
  }

  // Write notification document (always, even without FCM token)
  await db.collection("notifications").add({
    userId,
    title: statusInfo.title,
    body: `Order #${shortId} — ${statusInfo.bodyPrefix}`,
    type: `order_${newStatus}`,
    referenceId: orderId,
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Send FCM if token is valid
  if (!isValidFcmToken(userData.fcmToken)) {
    functions.logger.warn(`notifyUser: User ${userId} has no valid FCM token`);
    return;
  }

  try {
    await messaging.send({
      token: userData.fcmToken,
      notification: {
        title: statusInfo.title,
        body: `Order #${shortId} — ${statusInfo.bodyPrefix}`,
      },
      data: {
        type: `order_${newStatus}`,
        referenceId: orderId,
      },
    });
  } catch (error: unknown) {
    // Token might be stale — log but don't crash
    const msg = error instanceof Error ? error.message : String(error);
    functions.logger.warn(`FCM send failed for user ${userId}: ${msg}`);
  }
}
