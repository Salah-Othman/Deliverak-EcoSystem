import 'package:core/core.dart';

class UserModelFixture {
  UserModelFixture._();

  static UserModel create({
    String uid = 'test-uid',
    String name = 'John Doe',
    String email = 'john@example.com',
    String phone = '+1234567890',
    UserRole role = UserRole.customer,
    String? fcmToken = 'test-fcm-token',
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      fcmToken: fcmToken,
      profileImage: profileImage,
      createdAt: createdAt ?? DateTime(2024),
      updatedAt: updatedAt ?? DateTime(2024),
    );
  }
}

class VendorModelFixture {
  VendorModelFixture._();

  static VendorModel create({
    String vendorId = 'test-vendor-id',
    String name = 'Test Vendor',
    String description = 'A test vendor',
    String image = 'https://example.com/image.jpg',
    DeliveryType category = DeliveryType.food,
    double lat = 40.7128,
    double lng = -74.0060,
    String address = '123 Test St',
    double rating = 4.5,
    int totalOrders = 100,
    bool isOpen = true,
    String ownerId = 'owner-123',
    DateTime? createdAt,
  }) {
    return VendorModel(
      vendorId: vendorId,
      name: name,
      description: description,
      image: image,
      category: category,
      lat: lat,
      lng: lng,
      address: address,
      rating: rating,
      totalOrders: totalOrders,
      isOpen: isOpen,
      ownerId: ownerId,
      createdAt: createdAt ?? DateTime(2024),
    );
  }
}

class ProductModelFixture {
  ProductModelFixture._();

  static ProductModel create({
    String productId = 'test-product-id',
    String vendorId = 'test-vendor-id',
    String name = 'Test Product',
    String description = 'A test product',
    double price = 9.99,
    double? discountPrice,
    List<String> images = const ['https://example.com/product.jpg'],
    String category = 'Burgers',
    bool isAvailable = true,
    DateTime? createdAt,
  }) {
    return ProductModel(
      productId: productId,
      vendorId: vendorId,
      name: name,
      description: description,
      price: price,
      discountPrice: discountPrice,
      images: images,
      category: category,
      isAvailable: isAvailable,
      createdAt: createdAt ?? DateTime(2024),
    );
  }
}

class OrderModelFixture {
  OrderModelFixture._();

  static OrderItem createOrderItem({
    String productId = 'product-1',
    String name = 'Burger',
    int quantity = 2,
    double price = 9.99,
  }) {
    return OrderItem(
      productId: productId,
      name: name,
      quantity: quantity,
      price: price,
    );
  }

  static DeliveryAddress createDeliveryAddress({
    double lat = 40.7128,
    double lng = -74.0060,
    String address = '123 Main St',
    String name = 'John Doe',
    String phone = '+1234567890',
  }) {
    return DeliveryAddress(
      lat: lat,
      lng: lng,
      address: address,
      name: name,
      phone: phone,
    );
  }

  static OrderModel create({
    String orderId = 'order-123',
    String customerId = 'customer-1',
    String vendorId = 'vendor-1',
    String? driverId,
    List<OrderItem>? items,
    double totalAmount = 22.97,
    double deliveryFee = 2.99,
    OrderStatus status = OrderStatus.pending,
    DeliveryAddress? deliveryAddress,
    String paymentMethod = 'cash',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      orderId: orderId,
      customerId: customerId,
      vendorId: vendorId,
      driverId: driverId,
      items: items ?? [createOrderItem()],
      totalAmount: totalAmount,
      deliveryFee: deliveryFee,
      status: status,
      deliveryAddress: deliveryAddress ?? createDeliveryAddress(),
      paymentMethod: paymentMethod,
      createdAt: createdAt ?? DateTime(2024),
      updatedAt: updatedAt ?? DateTime(2024),
    );
  }
}

class DriverModelFixture {
  DriverModelFixture._();

  static DriverModel create({
    String driverId = 'driver-1',
    String userId = 'user-1',
    String vehicleType = 'motorcycle',
    String vehicleNumber = 'ABC-1234',
    String licenseNumber = 'DL-9876',
    bool isOnline = false,
    double currentLat = 40.7128,
    double currentLng = -74.0060,
    double rating = 4.5,
    int totalDeliveries = 10,
    DateTime? createdAt,
  }) {
    return DriverModel(
      driverId: driverId,
      userId: userId,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      licenseNumber: licenseNumber,
      isOnline: isOnline,
      currentLat: currentLat,
      currentLng: currentLng,
      rating: rating,
      totalDeliveries: totalDeliveries,
      createdAt: createdAt ?? DateTime(2024),
    );
  }
}

class NotificationModelFixture {
  NotificationModelFixture._();

  static NotificationModel create({
    String notificationId = 'notif-1',
    String userId = 'user-1',
    String title = 'Order Update',
    String body = 'Your order has been delivered',
    String type = 'order_update',
    String? referenceId = 'order-123',
    bool isRead = false,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      notificationId: notificationId,
      userId: userId,
      title: title,
      body: body,
      type: type,
      referenceId: referenceId,
      isRead: isRead,
      createdAt: createdAt ?? DateTime(2024),
    );
  }
}
