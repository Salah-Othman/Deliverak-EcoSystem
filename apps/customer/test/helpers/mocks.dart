import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import '../fixtures/test_data.dart';

class MockAuthService extends Mock implements IAuthService {}
class MockFirestoreService extends Mock implements IFirestoreService {}
class MockNotificationService extends Mock implements INotificationService {}
class MockStorageService extends Mock implements IStorageService {}
class MockSecureStorageService extends Mock implements ISecureStorageService {}
class MockCacheService extends Mock implements ICacheService {}
class MockAuthRepository extends Mock implements IAuthRepository {}
class MockVendorRepository extends Mock implements IVendorRepository {}
class MockProductRepository extends Mock implements IProductRepository {}
class MockOrderRepository implements IOrderRepository {
  List<OrderModel> watchOrdersResult = [];
  OrderModel? watchOrderResult;

  @override
  Future<OrderModel> createOrder({
    required String customerId,
    required String vendorId,
    required List<OrderItem> items,
    required double totalAmount,
    required double deliveryFee,
    required DeliveryAddress deliveryAddress,
  }) async => watchOrderResult ?? TestData.order;

  @override
  Future<List<OrderModel>> getOrders({
    String? customerId,
    String? vendorId,
    String? driverId,
    OrderStatus? status,
  }) async => watchOrdersResult;

  @override
  Future<OrderModel?> getOrder(String orderId) async => watchOrderResult;

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {}

  @override
  Future<void> assignDriver(String orderId, String driverId) async {}

  @override
  Stream<List<OrderModel>> watchOrders({
    String? customerId,
    String? vendorId,
    String? driverId,
    OrderStatus? status,
  }) => Stream.value(watchOrdersResult);

  @override
  Stream<OrderModel?> watchOrder(String orderId) => Stream.value(watchOrderResult);
}

class MockDriverRepository extends Mock implements IDriverRepository {}
class MockNotificationRepository implements INotificationRepository {
  @override
  Future<List<NotificationModel>> getNotifications(String userId) async => [];

  @override
  Stream<List<NotificationModel>> watchNotifications(String userId) =>
      const Stream.empty();

  @override
  Future<void> markAsRead(String notificationId) async {}

  @override
  Future<void> markAllAsRead(String userId) async {}

  @override
  Future<int> getUnreadCount(String userId) async => 0;
}
