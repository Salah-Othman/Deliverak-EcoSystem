import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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
    if (customerId.trim().isEmpty) {
      throw const ValidationException(message: 'Customer ID is required');
    }
    if (vendorId.trim().isEmpty) {
      throw const ValidationException(message: 'Vendor ID is required');
    }
    if (items.isEmpty) {
      throw const ValidationException(message: 'Order must contain at least one item');
    }
    for (final item in items) {
      if (item.quantity < 1 || item.quantity > 99) {
        throw const ValidationException(message: 'Item quantity must be between 1 and 99');
      }
      if (item.price < 0) {
        throw const ValidationException(message: 'Item price cannot be negative');
      }
    }
    final itemsTotal = items.fold<double>(0, (total, item) => total + item.price * item.quantity);
    final expectedTotal = itemsTotal + deliveryFee;
    if ((totalAmount - expectedTotal).abs() > 0.01) {
      throw const ValidationException(message: 'Order total does not match items total plus delivery fee');
    }
    if (totalAmount < 0) {
      throw const ValidationException(message: 'Total amount cannot be negative');
    }
    if (deliveryFee < 0) {
      throw const ValidationException(message: 'Delivery fee cannot be negative');
    }
    if (deliveryAddress.address.trim().isEmpty) {
      throw const ValidationException(message: 'Delivery address is required');
    }
    if (deliveryAddress.name.trim().isEmpty) {
      throw const ValidationException(message: 'Recipient name is required');
    }
    if (deliveryAddress.phone.trim().isEmpty) {
      throw const ValidationException(message: 'Recipient phone is required');
    }

    final now = DateTime.now();
    final orderDocId = _firestoreService.newDocumentId(
      collection: FirestorePaths.orders,
    );

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

    final conditions = <QueryCondition>[];
    if (customerId != null) {
      conditions.add(QueryCondition(field: 'customerId', value: customerId));
    }
    if (vendorId != null) {
      conditions.add(QueryCondition(field: 'vendorId', value: vendorId));
    }
    if (driverId != null) {
      conditions.add(QueryCondition(field: 'driverId', value: driverId));
    }
    if (status != null) {
      conditions.add(QueryCondition(field: 'status', value: status.name));
    }

    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.orders,
      where: conditions.isNotEmpty ? conditions : null,
      orderBy: 'createdAt',
      descending: true,
    );

    final orders = docs.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    await _cacheService.put<String>(
      _kOrdersBox,
      cacheKey,
      jsonEncode(orders.map((o) => o.toMap()).toList()),
    );

    return orders;
  }

  @override
  Future<PaginatedResult<OrderModel>> getOrdersPaginated({
    String? customerId,
    String? vendorId,
    String? driverId,
    OrderStatus? status,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    final conditions = <QueryCondition>[];
    if (customerId != null) {
      conditions.add(QueryCondition(field: 'customerId', value: customerId));
    }
    if (vendorId != null) {
      conditions.add(QueryCondition(field: 'vendorId', value: vendorId));
    }
    if (driverId != null) {
      conditions.add(QueryCondition(field: 'driverId', value: driverId));
    }
    if (status != null) {
      conditions.add(QueryCondition(field: 'status', value: status.name));
    }

    final snapshot = await _firestoreService.getDocumentsFilteredPaginated(
      collection: FirestorePaths.orders,
      where: conditions.isNotEmpty ? conditions : null,
      orderBy: 'createdAt',
      descending: true,
      lastDocument: lastDocument,
      limit: limit,
    );

    final orders = snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return PaginatedResult<OrderModel>(
      items: orders,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
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
