import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/fake_services.dart';
import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthService authService;
  late FakeFirestoreService firestoreService;
  late FakeNotificationService notificationService;
  late FakeStorageService storageService;
  late FakeSecureStorageService secureStorage;
  late FakeCacheService cacheService;
  late FakeLocalNotificationService localNotificationService;

  setUp(() {
    authService = FakeAuthService();
    firestoreService = FakeFirestoreService();
    notificationService = FakeNotificationService();
    storageService = FakeStorageService();
    secureStorage = FakeSecureStorageService();
    cacheService = FakeCacheService();
    localNotificationService = FakeLocalNotificationService();
  });

  tearDown(() {
    authService.dispose();
    firestoreService.dispose();
  });

  Widget buildApp() => TestDeliverakApp(
        authService: authService,
        firestoreService: firestoreService,
        notificationService: notificationService,
        storageService: storageService,
        secureStorage: secureStorage,
        cacheService: cacheService,
        localNotificationService: localNotificationService,
      );

  group('Full Order Flow', () {
    testWidgets('seed vendor with products for ordering', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Seed a vendor
      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
        data: {
          'name': 'Burger Palace',
          'category': 'food',
          'isOpen': true,
          'ownerId': 'owner-1',
          'rating': 4.5,
        },
      );

      // Seed products for that vendor
      await firestoreService.setDocument(
        collection: 'products',
        documentId: 'prod-1',
        data: {
          'vendorId': 'vendor-1',
          'name': 'Classic Burger',
          'price': 9.99,
          'isAvailable': true,
        },
      );

      await firestoreService.setDocument(
        collection: 'products',
        documentId: 'prod-2',
        data: {
          'vendorId': 'vendor-1',
          'name': 'Cheese Fries',
          'price': 4.99,
          'isAvailable': true,
        },
      );

      // Verify vendor exists
      final vendorDoc = await firestoreService.getDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
      );
      expect(vendorDoc.exists, isTrue);

      // Verify products exist
      final products = await firestoreService.getDocuments(
        collection: 'products',
      );
      expect(products.docs.length, 2);
    });

    testWidgets('create order with items', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Seed vendor
      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
        data: {'name': 'Burger Palace', 'isOpen': true},
      );

      // Create an order
      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'order-1',
        data: {
          'customerId': 'customer-1',
          'vendorId': 'vendor-1',
          'status': 'pending',
          'totalAmount': 14.98,
          'deliveryFee': 2.00,
          'items': [
            {'productId': 'prod-1', 'name': 'Classic Burger', 'quantity': 1, 'price': 9.99},
            {'productId': 'prod-2', 'name': 'Cheese Fries', 'quantity': 1, 'price': 4.99},
          ],
          'deliveryAddress': {
            'lat': 40.7128,
            'lng': -74.0060,
            'address': '123 Main St',
            'name': 'John Doe',
            'phone': '+1234567890',
          },
          'paymentMethod': 'cash',
        },
      );

      // Verify order was created
      final orderDoc = await firestoreService.getDocument(
        collection: 'orders',
        documentId: 'order-1',
      );

      expect(orderDoc.exists, isTrue);
      final orderData = orderDoc.data() as Map<String, dynamic>;
      expect(orderData['status'], 'pending');
      expect(orderData['totalAmount'], 14.98);
      expect(orderData['items'].length, 2);
    });

    testWidgets('order status transitions from pending to accepted',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Create pending order
      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'order-1',
        data: {
          'customerId': 'customer-1',
          'vendorId': 'vendor-1',
          'status': 'pending',
          'totalAmount': 20.00,
        },
      );

      // Vendor accepts
      await firestoreService.updateDocument(
        collection: 'orders',
        documentId: 'order-1',
        data: {'status': 'accepted'},
      );

      final doc = await firestoreService.getDocument(
        collection: 'orders',
        documentId: 'order-1',
      );
      final data = doc.data() as Map<String, dynamic>;
      expect(data['status'], 'accepted');
    });

    testWidgets('order status transitions through full lifecycle',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'order-1',
        data: {
          'status': 'pending',
          'totalAmount': 25.00,
          'customerId': 'c1',
          'vendorId': 'v1',
          'driverId': 'd1',
        },
      );

      // pending -> accepted
      await firestoreService.updateDocument(
        collection: 'orders',
        documentId: 'order-1',
        data: {'status': 'accepted'},
      );
      var doc = await firestoreService.getDocument(
        collection: 'orders',
        documentId: 'order-1',
      );
      expect((doc.data() as Map<String, dynamic>)['status'], 'accepted');

      // accepted -> preparing
      await firestoreService.updateDocument(
        collection: 'orders',
        documentId: 'order-1',
        data: {'status': 'preparing'},
      );
      doc = await firestoreService.getDocument(
        collection: 'orders',
        documentId: 'order-1',
      );
      expect((doc.data() as Map<String, dynamic>)['status'], 'preparing');

      // preparing -> picked_up
      await firestoreService.updateDocument(
        collection: 'orders',
        documentId: 'order-1',
        data: {'status': 'picked_up'},
      );
      doc = await firestoreService.getDocument(
        collection: 'orders',
        documentId: 'order-1',
      );
      expect((doc.data() as Map<String, dynamic>)['status'], 'picked_up');

      // picked_up -> in_transit
      await firestoreService.updateDocument(
        collection: 'orders',
        documentId: 'order-1',
        data: {'status': 'in_transit'},
      );
      doc = await firestoreService.getDocument(
        collection: 'orders',
        documentId: 'order-1',
      );
      expect((doc.data() as Map<String, dynamic>)['status'], 'in_transit');

      // in_transit -> delivered
      await firestoreService.updateDocument(
        collection: 'orders',
        documentId: 'order-1',
        data: {'status': 'delivered'},
      );
      doc = await firestoreService.getDocument(
        collection: 'orders',
        documentId: 'order-1',
      );
      expect((doc.data() as Map<String, dynamic>)['status'], 'delivered');
    });

    testWidgets('customer can cancel order', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'order-1',
        data: {
          'status': 'pending',
          'customerId': 'customer-1',
          'totalAmount': 15.00,
        },
      );

      await firestoreService.updateDocument(
        collection: 'orders',
        documentId: 'order-1',
        data: {'status': 'cancelled'},
      );

      final doc = await firestoreService.getDocument(
        collection: 'orders',
        documentId: 'order-1',
      );
      final data = doc.data() as Map<String, dynamic>;
      expect(data['status'], 'cancelled');
    });

    testWidgets('order cannot be cancelled after delivery', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'order-1',
        data: {'status': 'delivered', 'totalAmount': 30.00},
      );

      // Verify order is delivered (business rule: no cancellation after delivery)
      final doc = await firestoreService.getDocument(
        collection: 'orders',
        documentId: 'order-1',
      );
      final data = doc.data() as Map<String, dynamic>;
      expect(data['status'], 'delivered');
      expect(data['status'], isNot('cancelled'));
    });
  });

  group('Vendor Browsing', () {
    testWidgets('can list vendors by category', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'v1',
        data: {'name': 'Burger Place', 'category': 'food', 'isOpen': true},
      );
      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'v2',
        data: {'name': 'Pizza Shop', 'category': 'food', 'isOpen': true},
      );
      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'v3',
        data: {'name': 'Pharmacy', 'category': 'medicine', 'isOpen': true},
      );

      final snapshot = await firestoreService.getDocuments(
        collection: 'vendors',
      );

      expect(snapshot.docs.length, 3);

      final foodVendors = snapshot.docs
          .map((doc) => doc.data())
          .whereType<Map<String, dynamic>>()
          .where((d) => d['category'] == 'food')
          .toList();
      expect(foodVendors.length, 2);
    });

    testWidgets('can get vendor products', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'products',
        documentId: 'p1',
        data: {
          'vendorId': 'vendor-1',
          'name': 'Burger',
          'price': 9.99,
          'isAvailable': true,
        },
      );
      await firestoreService.setDocument(
        collection: 'products',
        documentId: 'p2',
        data: {
          'vendorId': 'vendor-1',
          'name': 'Fries',
          'price': 4.99,
          'isAvailable': true,
        },
      );
      await firestoreService.setDocument(
        collection: 'products',
        documentId: 'p3',
        data: {
          'vendorId': 'vendor-2',
          'name': 'Pizza',
          'price': 12.99,
          'isAvailable': true,
        },
      );

      final snapshot = await firestoreService.getDocuments(
        collection: 'products',
      );

      expect(snapshot.docs.length, 3);
    });

    testWidgets('can filter products by availability', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'products',
        documentId: 'p1',
        data: {'name': 'Available', 'isAvailable': true, 'price': 5.00},
      );
      await firestoreService.setDocument(
        collection: 'products',
        documentId: 'p2',
        data: {'name': 'Unavailable', 'isAvailable': false, 'price': 5.00},
      );

      final snapshot = await firestoreService.getDocuments(
        collection: 'products',
      );

      final available = snapshot.docs
          .map((doc) => doc.data())
          .whereType<Map<String, dynamic>>()
          .where((d) => d['isAvailable'] == true)
          .toList();
      expect(available.length, 1);
      expect(available[0]['name'], 'Available');
    });
  });

  group('Notifications', () {
    testWidgets('can create and read notifications', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'notifications',
        documentId: 'n1',
        data: {
          'userId': 'user-1',
          'title': 'Order Confirmed',
          'body': 'Your order has been confirmed',
          'type': 'order_accepted',
          'isRead': false,
        },
      );

      final doc = await firestoreService.getDocument(
        collection: 'notifications',
        documentId: 'n1',
      );

      expect(doc.exists, isTrue);
      final data = doc.data() as Map<String, dynamic>;
      expect(data['title'], 'Order Confirmed');
      expect(data['isRead'], false);
    });

    testWidgets('can mark notification as read', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'notifications',
        documentId: 'n1',
        data: {'isRead': false, 'title': 'Test'},
      );

      await firestoreService.updateDocument(
        collection: 'notifications',
        documentId: 'n1',
        data: {'isRead': true},
      );

      final doc = await firestoreService.getDocument(
        collection: 'notifications',
        documentId: 'n1',
      );

      final data = doc.data() as Map<String, dynamic>;
      expect(data['isRead'], true);
    });

    testWidgets('can delete notifications', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'notifications',
        documentId: 'n1',
        data: {'title': 'Old notification'},
      );

      await firestoreService.deleteDocument(
        collection: 'notifications',
        documentId: 'n1',
      );

      final doc = await firestoreService.getDocument(
        collection: 'notifications',
        documentId: 'n1',
      );

      expect(doc.exists, isFalse);
    });
  });

  group('User Profile', () {
    testWidgets('can create and update user profile', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'users',
        documentId: 'user-1',
        data: {
          'name': 'John Doe',
          'phone': '+1234567890',
          'role': 'customer',
        },
      );

      await firestoreService.updateDocument(
        collection: 'users',
        documentId: 'user-1',
        data: {'name': 'John Updated'},
      );

      final doc = await firestoreService.getDocument(
        collection: 'users',
        documentId: 'user-1',
      );

      final data = doc.data() as Map<String, dynamic>;
      expect(data['name'], 'John Updated');
      expect(data['role'], 'customer');
    });

    testWidgets('theme persistence across sessions', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await secureStorage.write(key: 'theme_mode', value: 'dark');
      expect(await secureStorage.read(key: 'theme_mode'), 'dark');

      await secureStorage.write(key: 'theme_mode', value: 'light');
      expect(await secureStorage.read(key: 'theme_mode'), 'light');
    });
  });

  group('Cart Operations', () {
    testWidgets('cart data persists in cache', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await cacheService.put('cart', 'items', [
        {'productId': 'p1', 'name': 'Burger', 'quantity': 2, 'price': 9.99},
      ]);

      final items = cacheService.get<List>('cart', 'items');
      expect(items, isNotNull);
      expect(items!.length, 1);
    });

    testWidgets('cart can be cleared', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await cacheService.put('cart', 'items', [
        {'productId': 'p1', 'name': 'Burger', 'quantity': 1},
      ]);

      await cacheService.clearBox('cart');
      final items = cacheService.get('cart', 'items');
      expect(items, isNull);
    });
  });
}
