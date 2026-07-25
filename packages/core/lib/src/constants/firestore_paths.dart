abstract class FirestorePaths {
  static const String users = 'users';
  static const String vendors = 'vendors';
  static const String products = 'products';
  static const String orders = 'orders';
  static const String drivers = 'drivers';
  static const String categories = 'categories';
  static const String notifications = 'notifications';

  static String user(String uid) => '$users/$uid';
  static String vendor(String vendorId) => '$vendors/$vendorId';
  static String product(String productId) => '$products/$productId';
  static String order(String orderId) => '$orders/$orderId';
  static String driver(String driverId) => '$drivers/$driverId';
  static String category(String categoryId) => '$categories/$categoryId';
  static String notification(String notificationId) => '$notifications/$notificationId';
  static String vendorProducts(String vendorId) => '$vendors/$vendorId/products';
  static String userNotifications(String uid) => '$users/$uid/notifications';
}
