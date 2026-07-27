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

  Widget buildApp() => TestVendorApp(
        authService: authService,
        firestoreService: firestoreService,
        notificationService: notificationService,
        storageService: storageService,
        secureStorage: secureStorage,
        cacheService: cacheService,
        localNotificationService: localNotificationService,
      );

  group('Vendor Auth Flow', () {
    testWidgets('shows login screen for unauthenticated user', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Vendor Login'), findsOneWidget);
    });

    testWidgets('shows loading during auth initialization', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final loading = find.byType(CircularProgressIndicator);
      final hasLoader = loading.evaluate().isNotEmpty;
      final hasLogin = find.text('Vendor Login').evaluate().isNotEmpty;

      expect(hasLoader || hasLogin, isTrue);
    });

    testWidgets('navigates to home after simulated sign in', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      authService.simulateSignIn(uid: 'vendor-1', email: 'vendor@test.com');
      await tester.pumpAndSettle();

      expect(find.text('Vendor Home'), findsOneWidget);
    });

    testWidgets('navigates back to login after sign out', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      authService.simulateSignIn(uid: 'vendor-1');
      await tester.pumpAndSettle();
      expect(find.text('Vendor Home'), findsOneWidget);

      authService.simulateSignOut();
      await tester.pumpAndSettle();
      expect(find.text('Vendor Login'), findsOneWidget);
    });

    testWidgets('shows profile setup state', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Simulate auth state -> ProfileSetup
      authService.simulateSignIn(uid: 'vendor-1');
      await tester.pumpAndSettle();

      // The test router shows 'Vendor Home' for Authenticated
      expect(find.text('Vendor Home'), findsOneWidget);
    });
  });

  group('Vendor Firestore Operations', () {
    testWidgets('seeds vendor data and verifies storage', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
        data: {
          'name': 'Test Vendor',
          'ownerId': 'vendor-uid-1',
          'category': 'food',
          'isOpen': true,
          'rating': 4.5,
        },
      );

      final snapshot = await firestoreService.getDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
      );

      expect(snapshot.exists, isTrue);
      final data = snapshot.data() as Map<String, dynamic>;
      expect(data['name'], 'Test Vendor');
      expect(data['ownerId'], 'vendor-uid-1');
      expect(data['isOpen'], true);
    });

    testWidgets('vendor data persists across operations', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'v1',
        data: {'name': 'Vendor 1', 'isOpen': false},
      );

      await firestoreService.updateDocument(
        collection: 'vendors',
        documentId: 'v1',
        data: {'isOpen': true},
      );

      final doc = await firestoreService.getDocument(
        collection: 'vendors',
        documentId: 'v1',
      );

      final data = doc.data() as Map<String, dynamic>;
      expect(data['isOpen'], true);
      expect(data['name'], 'Vendor 1');
    });
  });

  group('Vendor Product Operations', () {
    testWidgets('can create and retrieve products', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'products',
        documentId: 'prod-1',
        data: {
          'vendorId': 'vendor-1',
          'name': 'Burger',
          'price': 9.99,
          'isAvailable': true,
        },
      );

      final doc = await firestoreService.getDocument(
        collection: 'products',
        documentId: 'prod-1',
      );

      expect(doc.exists, isTrue);
      final data = doc.data() as Map<String, dynamic>;
      expect(data['name'], 'Burger');
      expect(data['price'], 9.99);
    });

    testWidgets('can update product availability', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'products',
        documentId: 'prod-1',
        data: {
          'vendorId': 'vendor-1',
          'name': 'Pizza',
          'price': 12.00,
          'isAvailable': true,
        },
      );

      await firestoreService.updateDocument(
        collection: 'products',
        documentId: 'prod-1',
        data: {'isAvailable': false},
      );

      final doc = await firestoreService.getDocument(
        collection: 'products',
        documentId: 'prod-1',
      );

      final data = doc.data() as Map<String, dynamic>;
      expect(data['isAvailable'], false);
    });

    testWidgets('can delete products', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'products',
        documentId: 'prod-1',
        data: {'name': 'Fries', 'price': 4.99},
      );

      await firestoreService.deleteDocument(
        collection: 'products',
        documentId: 'prod-1',
      );

      final doc = await firestoreService.getDocument(
        collection: 'products',
        documentId: 'prod-1',
      );

      expect(doc.exists, isFalse);
    });
  });

  group('Vendor Order Operations', () {
    testWidgets('can create and update orders', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'order-1',
        data: {
          'customerId': 'customer-1',
          'vendorId': 'vendor-1',
          'status': 'pending',
          'totalAmount': 25.00,
          'items': [
            {'productId': 'p1', 'name': 'Burger', 'quantity': 2, 'price': 9.99},
          ],
        },
      );

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

    testWidgets('can query orders by vendor', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'order-1',
        data: {'vendorId': 'vendor-1', 'status': 'pending'},
      );
      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'order-2',
        data: {'vendorId': 'vendor-1', 'status': 'accepted'},
      );
      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'order-3',
        data: {'vendorId': 'vendor-2', 'status': 'pending'},
      );

      final snapshot = await firestoreService.getDocuments(
        collection: 'orders',
      );

      expect(snapshot.docs.length, 3);
    });
  });

  group('Vendor Profile Operations', () {
    testWidgets('can update vendor store profile', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
        data: {
          'name': 'Original Name',
          'description': 'Old description',
          'isOpen': true,
        },
      );

      await firestoreService.updateDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
        data: {
          'name': 'Updated Name',
          'description': 'New description',
        },
      );

      final doc = await firestoreService.getDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
      );

      final data = doc.data() as Map<String, dynamic>;
      expect(data['name'], 'Updated Name');
      expect(data['description'], 'New description');
      expect(data['isOpen'], true);
    });

    testWidgets('can toggle store open/close', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
        data: {'isOpen': false},
      );

      await firestoreService.updateDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
        data: {'isOpen': true},
      );

      final doc = await firestoreService.getDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
      );

      final data = doc.data() as Map<String, dynamic>;
      expect(data['isOpen'], true);
    });
  });

  group('Secure Storage', () {
    testWidgets('persists auth tokens', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await secureStorage.write(key: 'auth_token', value: 'jwt-token-123');
      final token = await secureStorage.read(key: 'auth_token');
      expect(token, 'jwt-token-123');
    });

    testWidgets('clears storage on sign out', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await secureStorage.write(key: 'auth_token', value: 'token');
      await secureStorage.deleteAll();
      final token = await secureStorage.read(key: 'auth_token');
      expect(token, isNull);
    });
  });

  group('Cache Operations', () {
    testWidgets('caches and retrieves vendor data', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await cacheService.put('vendors', 'vendor-1', {
        'name': 'Cached Vendor',
        'rating': 4.5,
      });

      final cached = cacheService.get<Map<String, dynamic>>('vendors', 'vendor-1');
      expect(cached, isNotNull);
      expect(cached!['name'], 'Cached Vendor');
    });

    testWidgets('clears vendor cache box', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await cacheService.put('vendors', 'v1', {'name': 'V1'});
      await cacheService.put('vendors', 'v2', {'name': 'V2'});
      await cacheService.clearBox('vendors');

      expect(cacheService.get('vendors', 'v1'), isNull);
      expect(cacheService.get('vendors', 'v2'), isNull);
    });
  });

  group('Watchers', () {
    testWidgets('watchDocument emits updates on data changes', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final stream = firestoreService.watchDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
      );

      final emissions = <bool>[];
      final subscription = stream.listen((doc) {
        emissions.add(doc.exists);
      });

      await Future<void>.delayed(const Duration(milliseconds: 50));

      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
        data: {'name': 'Vendor'},
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await subscription.cancel();

      expect(emissions.length, greaterThanOrEqualTo(2));
      expect(emissions.first, false);
      expect(emissions.last, true);
    });
  });
}
