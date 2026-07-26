// ignore_for_file: subtype_of_sealed_class
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:repositories/repositories.dart';

class MockFirestoreService extends Mock implements IFirestoreService {}

class MockCacheService extends Mock implements ICacheService {}

class FakeDocumentSnapshot extends Fake implements DocumentSnapshot {
  final Map<String, dynamic> _data;
  final bool _exists;
  final String _id;

  FakeDocumentSnapshot(this._data, {String? id, bool exists = true})
      : _exists = exists,
        _id = id ?? (_data['uid'] ?? 'unknown');

  @override
  bool get exists => _exists;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  String get id => _id;
}

class FakeQueryDocumentSnapshot extends Fake
    implements QueryDocumentSnapshot {
  final Map<String, dynamic> _data;
  final String _id;

  FakeQueryDocumentSnapshot(this._data, {String? id})
      : _id = id ?? (_data['uid'] ?? 'unknown');

  @override
  Map<String, dynamic> data() => _data;

  @override
  String get id => _id;

  @override
  bool get exists => true;
}

class FakeQuerySnapshot extends Fake implements QuerySnapshot {
  final List<QueryDocumentSnapshot> _docs;

  FakeQuerySnapshot(List<DocumentSnapshot> docs)
      : _docs = docs
            .map((d) => FakeQueryDocumentSnapshot(
                  d.data() as Map<String, dynamic>,
                  id: d.id,
                ))
            .toList();

  @override
  List<QueryDocumentSnapshot> get docs => _docs;

  @override
  int get size => _docs.length;
}

void main() {
  late MockFirestoreService mockFirestoreService;
  late MockCacheService mockCacheService;
  late OrderRepository orderRepository;

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    mockCacheService = MockCacheService();
    orderRepository = OrderRepository(
      firestoreService: mockFirestoreService,
      cacheService: mockCacheService,
    );
  });

  setUpAll(() {
    registerFallbackValue(const QueryCondition(field: 'test', value: 'test'));
    registerFallbackValue(<String, dynamic>{});
  });

  DeliveryAddress testAddress() => const DeliveryAddress(
        lat: 1.0,
        lng: 2.0,
        address: '123 Test St',
        name: 'Test User',
        phone: '+1234567890',
      );

  List<OrderItem> testItems() => const [
        OrderItem(productId: 'p1', name: 'Item 1', quantity: 2, price: 10.0),
      ];

  Map<String, dynamic> orderMap({
    String orderId = 'o1',
    String customerId = 'c1',
    String vendorId = 'v1',
    String? driverId,
    String status = 'pending',
  }) {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'vendorId': vendorId,
      'driverId': driverId,
      'items': [
        {'productId': 'p1', 'name': 'Item 1', 'quantity': 2, 'price': 10.0}
      ],
      'totalAmount': 20.0,
      'deliveryFee': 5.0,
      'status': status,
      'deliveryAddress': {
        'lat': 1.0,
        'lng': 2.0,
        'address': '123 Test St',
        'name': 'Test User',
        'phone': '+1234567890',
      },
      'paymentMethod': 'cash',
      'createdAt': DateTime(2024).toIso8601String(),
      'updatedAt': DateTime(2024).toIso8601String(),
    };
  }

  group('OrderRepository', () {
    group('createOrder', () {
      test('creates order with pending status and cash payment', () async {
        when(() => mockFirestoreService.setDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            )).thenAnswer((_) async {});
        when(() => mockCacheService.delete(any(), any()))
            .thenAnswer((_) async {});

        final order = await orderRepository.createOrder(
          customerId: 'c1',
          vendorId: 'v1',
          items: testItems(),
          totalAmount: 20.0,
          deliveryFee: 5.0,
          deliveryAddress: testAddress(),
        );

        expect(order.customerId, 'c1');
        expect(order.vendorId, 'v1');
        expect(order.status, OrderStatus.pending);
        expect(order.paymentMethod, 'cash');
        expect(order.totalAmount, 20.0);
        expect(order.deliveryFee, 5.0);
        verify(() => mockFirestoreService.setDocument(
              collection: FirestorePaths.orders,
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            )).called(1);
        verify(() => mockCacheService.delete(any(), 'orders_c1')).called(1);
      });
    });

    group('getOrders', () {
      test('returns orders from Firestore', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(null);
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(orderMap(orderId: 'o1', customerId: 'c1'),
                id: 'o1'),
            FakeDocumentSnapshot(orderMap(orderId: 'o2', customerId: 'c2'),
                id: 'o2'),
          ]),
        );
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});

        final orders = await orderRepository.getOrders();

        expect(orders.length, 2);
        expect(orders[0].orderId, 'o1');
        expect(orders[1].orderId, 'o2');
      });

      test('returns orders from cache', () async {
        when(() => mockCacheService.get<String>(any(), any())).thenReturn(
          jsonEncode([
            orderMap(orderId: 'o1'),
            orderMap(orderId: 'o2'),
          ]),
        );

        final orders = await orderRepository.getOrders();

        expect(orders.length, 2);
        verifyNever(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
            ));
      });

      test('filters by customerId', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(null);
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(orderMap(orderId: 'o1', customerId: 'c1'),
                id: 'o1'),
            FakeDocumentSnapshot(orderMap(orderId: 'o2', customerId: 'c2'),
                id: 'o2'),
            FakeDocumentSnapshot(orderMap(orderId: 'o3', customerId: 'c1'),
                id: 'o3'),
          ]),
        );
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});

        final orders = await orderRepository.getOrders(customerId: 'c1');

        expect(orders.length, 2);
        expect(orders.every((o) => o.customerId == 'c1'), isTrue);
      });

      test('filters by status', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(null);
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(
                orderMap(orderId: 'o1', status: 'pending'),
                id: 'o1'),
            FakeDocumentSnapshot(
                orderMap(orderId: 'o2', status: 'delivered'),
                id: 'o2'),
          ]),
        );
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});

        final orders =
            await orderRepository.getOrders(status: OrderStatus.pending);

        expect(orders.length, 1);
        expect(orders[0].status, OrderStatus.pending);
      });
    });

    group('getOrder', () {
      test('returns order when document exists', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(null);
        when(() => mockFirestoreService.getDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            )).thenAnswer(
          (_) async => FakeDocumentSnapshot(orderMap(orderId: 'o1'), id: 'o1'),
        );
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});

        final order = await orderRepository.getOrder('o1');

        expect(order, isNotNull);
        expect(order!.orderId, 'o1');
      });

      test('returns null when document does not exist', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(null);
        when(() => mockFirestoreService.getDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            )).thenAnswer(
          (_) async => FakeDocumentSnapshot({}, exists: false),
        );

        final order = await orderRepository.getOrder('nonexistent');

        expect(order, isNull);
      });

      test('returns order from cache', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(jsonEncode(orderMap(orderId: 'o1')));

        final order = await orderRepository.getOrder('o1');

        expect(order, isNotNull);
        expect(order!.orderId, 'o1');
        verifyNever(() => mockFirestoreService.getDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            ));
      });
    });

    group('updateOrderStatus', () {
      test('calls Firestore updateDocument with status and updatedAt',
          () async {
        when(() => mockFirestoreService.updateDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            )).thenAnswer((_) async {});
        when(() => mockCacheService.delete(any(), any()))
            .thenAnswer((_) async {});

        await orderRepository.updateOrderStatus('o1', OrderStatus.delivered);

        final captured = verify(() => mockFirestoreService.updateDocument(
              collection: FirestorePaths.orders,
              documentId: 'o1',
              data: captureAny(named: 'data'),
            )).captured;
        final data = captured.last as Map<String, dynamic>;
        expect(data['status'], 'delivered');
        expect(data.containsKey('updatedAt'), isTrue);
        verify(() => mockCacheService.delete(any(), 'order_o1')).called(1);
      });
    });

    group('assignDriver', () {
      test('calls Firestore updateDocument with driverId', () async {
        when(() => mockFirestoreService.updateDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            )).thenAnswer((_) async {});
        when(() => mockCacheService.delete(any(), any()))
            .thenAnswer((_) async {});

        await orderRepository.assignDriver('o1', 'd1');

        final captured = verify(() => mockFirestoreService.updateDocument(
              collection: FirestorePaths.orders,
              documentId: 'o1',
              data: captureAny(named: 'data'),
            )).captured;
        final data = captured.last as Map<String, dynamic>;
        expect(data['driverId'], 'd1');
        expect(data.containsKey('updatedAt'), isTrue);
        verify(() => mockCacheService.delete(any(), 'order_o1')).called(1);
      });
    });
  });
}
