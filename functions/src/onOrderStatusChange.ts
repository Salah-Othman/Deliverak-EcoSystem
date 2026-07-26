import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();
const messaging = admin.messaging();

const STATUS_MESSAGES: Record<string, { title: string; bodyPrefix: string }> = {
  accepted: { title: "Order Accepted", bodyPrefix: "Your order has been accepted by the vendor" },
  preparing: { title: "Order Being Prepared", bodyPrefix: "Your order is now being prepared" },
  pickedUp: { title: "Ready for Pickup", bodyPrefix: "Your order is ready and waiting for driver pickup" },
  in_transit: { title: "Out for Delivery", bodyPrefix: "Your order is on its way!" },
  delivered: { title: "Order Delivered", bodyPrefix: "Your order has been delivered. Enjoy!" },
  cancelled: { title: "Order Cancelled", bodyPrefix: "Your order has been cancelled" },
};

export const onOrderStatusChange = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === after.status) return;

    const { orderId, customerId, driverId, vendorId } = after;
    const newStatus = after.status as string;

    const statusInfo = STATUS_MESSAGES[newStatus];
    if (!statusInfo) return;

    const shortId = orderId.slice(-8);

    try {
      const recipients: string[] = [];

      if (customerId) recipients.push(customerId);

      if (newStatus === "picked_up" && driverId) {
        recipients.push(driverId);
      }

      for (const userId of recipients) {
        const userDoc = await db.collection("users").doc(userId).get();
        const userData = userDoc.data();

        if (userData?.fcmToken) {
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
        }

        await db.collection("notifications").add({
          userId,
          title: statusInfo.title,
          body: `Order #${shortId} — ${statusInfo.bodyPrefix}`,
          type: `order_${newStatus}`,
          referenceId: orderId,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      if (newStatus === "accepted" && vendorId) {
        const vendorDoc = await db.collection("vendors").doc(vendorId).get();
        const vendorData = vendorDoc.data();
        if (vendorData?.ownerId) {
          const ownerDoc = await db.collection("users").doc(vendorData.ownerId).get();
          const ownerData = ownerDoc.data();
          if (ownerData?.fcmToken) {
            await messaging.send({
              token: ownerData.fcmToken,
              notification: {
                title: statusInfo.title,
                body: `Order #${shortId} — ${statusInfo.bodyPrefix}`,
              },
              data: {
                type: `order_${newStatus}`,
                referenceId: orderId,
              },
            });
          }
        }
      }

      functions.logger.info(`Order ${orderId} status changed to ${newStatus}`);
    } catch (error) {
      functions.logger.error("Error sending status change notification:", error);
    }
  });
