import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();
const messaging = admin.messaging();

export const onOrderCreated = functions.firestore
  .document("orders/{orderId}")
  .onCreate(async (snapshot, context) => {
    const order = snapshot.data();
    if (!order) return;

    const orderId = context.params.orderId;
    const { vendorId } = order;

    try {
      const vendorDoc = await db.collection("vendors").doc(vendorId).get();
      const vendorData = vendorDoc.data();

      if (!vendorData?.ownerId) {
        functions.logger.warn(`Vendor ${vendorId} has no owner`);
        return;
      }

      const ownerDoc = await db.collection("users").doc(vendorData.ownerId).get();
      const ownerData = ownerDoc.data();

      if (!ownerData?.fcmToken) {
        functions.logger.warn(`Vendor owner ${vendorData.ownerId} has no FCM token`);
        return;
      }

      await messaging.send({
        token: ownerData.fcmToken,
        notification: {
          title: "New Order Received!",
          body: `Order #${orderId.slice(-8)} — ${order.items.length} item(s), $${order.totalAmount.toStringAsFixed(2)}`,
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
