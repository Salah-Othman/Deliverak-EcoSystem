import 'package:core/core.dart';

class OrderRepository implements IOrderRepository {
  final IFirestoreService _firestoreService;

  OrderRepository({required IFirestoreService firestoreService})
      : _firestoreService = firestoreService;

  @override
  Future<OrderModel> createOrder({
    required String customerId,
    required String vendorId,
    required List<OrderItem> items,
    required double totalAmount,
    required double deliveryFee,
    required DeliveryAddress deliveryAddress,
  }) async {
    final now = DateTime.now();
    final orderDocId = '${now.millisecondsSinceEpoch}_$customerId';

    final order = OrderModel(
      orderId: orderDocId,
      customerId: customerId,
      vendorId: vendorId,
      items: items,
      totalAmount: totalAmount,
      deliveryFee: deliveryFee,
      status: OrderStatus.pending,
      deliveryAddress: deliveryAddress,
      paymentMethod: 'cash',
      createdAt: now,
      updatedAt: now,
    );

    await _firestoreService.setDocument(
      collection: FirestorePaths.orders,
      documentId: orderDocId,
      data: order.toMap(),
    );

    return order;
  }

  @override
  Future<List<OrderModel>> getOrders({
    String? customerId,
    String? vendorId,
    String? driverId,
    OrderStatus? status,
  }) async {
    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.orders,
      orderBy: 'createdAt',
      descending: true,
    );

    return docs.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
        .where((order) {
      if (customerId != null && order.customerId != customerId) return false;
      if (vendorId != null && order.vendorId != vendorId) return false;
      if (driverId != null && order.driverId != driverId) return false;
      if (status != null && order.status != status) return false;
      return true;
    }).toList();
  }

  @override
  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _firestoreService.getDocument(
      collection: FirestorePaths.orders,
      documentId: orderId,
    );

    if (!doc.exists) return null;

    return OrderModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Stream<OrderModel?> watchOrder(String orderId) {
    return _firestoreService
        .watchDocument(
          collection: FirestorePaths.orders,
          documentId: orderId,
        )
        .map((doc) {
      if (!doc.exists) return null;
      return OrderModel.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  @override
  Stream<List<OrderModel>> watchOrders({
    String? customerId,
    String? vendorId,
    String? driverId,
    OrderStatus? status,
  }) {
    return _firestoreService
        .watchDocuments(
          collection: FirestorePaths.orders,
          orderBy: 'createdAt',
          descending: true,
        )
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                OrderModel.fromMap(doc.data() as Map<String, dynamic>))
            .where((order) {
          if (customerId != null && order.customerId != customerId) return false;
          if (vendorId != null && order.vendorId != vendorId) return false;
          if (driverId != null && order.driverId != driverId) return false;
          if (status != null && order.status != status) return false;
          return true;
        }).toList());
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestoreService.updateDocument(
      collection: FirestorePaths.orders,
      documentId: orderId,
      data: {
        'status': status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<void> assignDriver(String orderId, String driverId) async {
    await _firestoreService.updateDocument(
      collection: FirestorePaths.orders,
      documentId: orderId,
      data: {
        'driverId': driverId,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }
}
