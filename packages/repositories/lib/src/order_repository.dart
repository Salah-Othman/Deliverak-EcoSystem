import 'dart:convert';

import 'package:core/core.dart';

const _kOrdersBox = 'orders_box';

class OrderRepository implements IOrderRepository {
  final IFirestoreService _firestoreService;
  final ICacheService _cacheService;

  OrderRepository({
    required IFirestoreService firestoreService,
    required ICacheService cacheService,
  })  : _firestoreService = firestoreService,
        _cacheService = cacheService;

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
    final orderDocId =
        '${now.millisecondsSinceEpoch}_${customerId.hashCode}';

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

    await _cacheService.delete(_kOrdersBox, 'orders_$customerId');

    return order;
  }

  @override
  Future<List<OrderModel>> getOrders({
    String? customerId,
    String? vendorId,
    String? driverId,
    OrderStatus? status,
  }) async {
    final cacheKey =
        'orders_c${customerId ?? ''}_v${vendorId ?? ''}_d${driverId ?? ''}';
    final cached = _cacheService.get<String>(_kOrdersBox, cacheKey);

    if (cached != null) {
      return (jsonDecode(cached) as List)
          .map((e) => OrderModel.fromMap(e as Map<String, dynamic>))
          .where((order) {
        if (customerId != null && order.customerId != customerId) return false;
        if (vendorId != null && order.vendorId != vendorId) return false;
        if (driverId != null && order.driverId != driverId) return false;
        if (status != null && order.status != status) return false;
        return true;
      }).toList();
    }

    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.orders,
      orderBy: 'createdAt',
      descending: true,
    );

    final orders = docs.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
        .where((order) {
      if (customerId != null && order.customerId != customerId) return false;
      if (vendorId != null && order.vendorId != vendorId) return false;
      if (driverId != null && order.driverId != driverId) return false;
      if (status != null && order.status != status) return false;
      return true;
    }).toList();

    await _cacheService.put<String>(
      _kOrdersBox,
      cacheKey,
      jsonEncode(orders.map((o) => o.toMap()).toList()),
    );

    return orders;
  }

  @override
  Future<OrderModel?> getOrder(String orderId) async {
    final cached = _cacheService.get<String>(_kOrdersBox, 'order_$orderId');
    if (cached != null) {
      return OrderModel.fromMap(jsonDecode(cached) as Map<String, dynamic>);
    }

    final doc = await _firestoreService.getDocument(
      collection: FirestorePaths.orders,
      documentId: orderId,
    );

    if (!doc.exists) return null;

    final order = OrderModel.fromMap(doc.data() as Map<String, dynamic>);
    await _cacheService.put<String>(
      _kOrdersBox,
      'order_$orderId',
      jsonEncode(order.toMap()),
    );
    return order;
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
      final order = OrderModel.fromMap(doc.data() as Map<String, dynamic>);
      _cacheService.put<String>(
        _kOrdersBox,
        'order_$orderId',
        jsonEncode(order.toMap()),
      );
      return order;
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
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) =>
              OrderModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((order) {
        if (customerId != null && order.customerId != customerId) return false;
        if (vendorId != null && order.vendorId != vendorId) return false;
        if (driverId != null && order.driverId != driverId) return false;
        if (status != null && order.status != status) return false;
        return true;
      }).toList();

      final cacheKey =
          'orders_c${customerId ?? ''}_v${vendorId ?? ''}_d${driverId ?? ''}';
      _cacheService.put<String>(
        _kOrdersBox,
        cacheKey,
        jsonEncode(orders.map((o) => o.toMap()).toList()),
      );

      return orders;
    });
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
    await _cacheService.delete(_kOrdersBox, 'order_$orderId');
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
    await _cacheService.delete(_kOrdersBox, 'order_$orderId');
  }
}
