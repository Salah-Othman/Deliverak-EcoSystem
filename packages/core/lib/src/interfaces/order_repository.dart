import 'package:core/src/models/order_model.dart';
import 'package:core/src/enums/order_status.dart';

abstract class IOrderRepository {
  Future<OrderModel> createOrder({
    required String customerId,
    required String vendorId,
    required List<OrderItem> items,
    required double totalAmount,
    required double deliveryFee,
    required DeliveryAddress deliveryAddress,
  });

  Future<List<OrderModel>> getOrders({
    String? customerId,
    String? vendorId,
    String? driverId,
    OrderStatus? status,
  });

  Future<OrderModel?> getOrder(String orderId);

  Stream<OrderModel?> watchOrder(String orderId);

  Stream<List<OrderModel>> watchOrders({
    String? customerId,
    String? vendorId,
    String? driverId,
    OrderStatus? status,
  });

  Future<void> updateOrderStatus(String orderId, OrderStatus status);

  Future<void> assignDriver(String orderId, String driverId);
}
