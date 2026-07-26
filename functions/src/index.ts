import * as admin from "firebase-admin";

admin.initializeApp();

export { onOrderCreated } from "./onOrderCreated";
export { onOrderStatusChange } from "./onOrderStatusChange";
