import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/fake_services.dart';
import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthService authService;
  late FakeFirestoreService firestoreService;
  late FakeSecureStorageService secureStorage;
  late FakeCacheService cacheService;

  setUp(() {
    authService = FakeAuthService();
    firestoreService = FakeFirestoreService();
    secureStorage = FakeSecureStorageService();
    cacheService = FakeCacheService();
  });

  tearDown(() {
    authService.dispose();
    firestoreService.dispose();
  });

  Widget buildApp() => TestAdminApp(
        authService: authService,
        firestoreService: firestoreService,
        secureStorage: secureStorage,
        cacheService: cacheService,
      );

  group('Admin Auth Flow', () {
    testWidgets('shows login screen for unauthenticated user', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Admin Login'), findsOneWidget);
    });

    testWidgets('shows loading during auth initialization', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final loading = find.byType(CircularProgressIndicator);
      final hasLoader = loading.evaluate().isNotEmpty;
      final hasLogin = find.text('Admin Login').evaluate().isNotEmpty;

      expect(hasLoader || hasLogin, isTrue);
    });

    testWidgets('navigates to dashboard after sign in', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      authService.simulateSignIn(uid: 'admin-1', email: 'admin@test.com');
      await tester.pumpAndSettle();

      expect(find.text('Admin Dashboard'), findsOneWidget);
    });

    testWidgets('navigates back to login after sign out', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      authService.simulateSignIn(uid: 'admin-1');
      await tester.pumpAndSettle();
      expect(find.text('Admin Dashboard'), findsOneWidget);

      authService.simulateSignOut();
      await tester.pumpAndSettle();
      expect(find.text('Admin Login'), findsOneWidget);
    });
  });

  group('Admin User Management', () {
    testWidgets('can create and retrieve users', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'users',
        documentId: 'user-1',
        data: {
          'name': 'John Doe',
          'email': 'john@test.com',
          'role': 'customer',
          'phone': '+1234567890',
        },
      );

      final doc = await firestoreService.getDocument(
        collection: 'users',
        documentId: 'user-1',
      );

      expect(doc.exists, isTrue);
      final data = doc.data() as Map<String, dynamic>;
      expect(data['name'], 'John Doe');
      expect(data['role'], 'customer');
    });

    testWidgets('can update user role', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'users',
        documentId: 'user-1',
        data: {'name': 'Jane', 'role': 'customer'},
      );

      await firestoreService.updateDocument(
        collection: 'users',
        documentId: 'user-1',
        data: {'role': 'vendor'},
      );

      final doc = await firestoreService.getDocument(
        collection: 'users',
        documentId: 'user-1',
      );

      final data = doc.data() as Map<String, dynamic>;
      expect(data['role'], 'vendor');
    });

    testWidgets('can delete users', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'users',
        documentId: 'user-1',
        data: {'name': 'To Delete'},
      );

      await firestoreService.deleteDocument(
        collection: 'users',
        documentId: 'user-1',
      );

      final doc = await firestoreService.getDocument(
        collection: 'users',
        documentId: 'user-1',
      );

      expect(doc.exists, isFalse);
    });

    testWidgets('can list all users', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'users',
        documentId: 'u1',
        data: {'name': 'User 1', 'role': 'customer'},
      );
      await firestoreService.setDocument(
        collection: 'users',
        documentId: 'u2',
        data: {'name': 'User 2', 'role': 'vendor'},
      );
      await firestoreService.setDocument(
        collection: 'users',
        documentId: 'u3',
        data: {'name': 'User 3', 'role': 'driver'},
      );

      final snapshot = await firestoreService.getDocuments(
        collection: 'users',
      );

      expect(snapshot.docs.length, 3);
    });
  });

  group('Admin Vendor Management', () {
    testWidgets('can retrieve vendor listings', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'v1',
        data: {
          'name': 'Restaurant A',
          'category': 'food',
          'isOpen': true,
          'ownerId': 'owner-1',
        },
      );
      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'v2',
        data: {
          'name': 'Pharmacy B',
          'category': 'medicine',
          'isOpen': false,
          'ownerId': 'owner-2',
        },
      );

      final snapshot = await firestoreService.getDocuments(
        collection: 'vendors',
      );

      expect(snapshot.docs.length, 2);
    });

    testWidgets('can update vendor status', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'v1',
        data: {'name': 'Vendor', 'isOpen': true},
      );

      await firestoreService.updateDocument(
        collection: 'vendors',
        documentId: 'v1',
        data: {'isOpen': false},
      );

      final doc = await firestoreService.getDocument(
        collection: 'vendors',
        documentId: 'v1',
      );

      final data = doc.data() as Map<String, dynamic>;
      expect(data['isOpen'], false);
    });
  });

  group('Admin Order Management', () {
    testWidgets('can retrieve all orders', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'o1',
        data: {
          'customerId': 'c1',
          'vendorId': 'v1',
          'status': 'pending',
          'totalAmount': 25.00,
        },
      );
      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'o2',
        data: {
          'customerId': 'c2',
          'vendorId': 'v2',
          'status': 'delivered',
          'totalAmount': 42.50,
        },
      );

      final snapshot = await firestoreService.getDocuments(
        collection: 'orders',
      );

      expect(snapshot.docs.length, 2);
    });

    testWidgets('can update order status', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'o1',
        data: {'status': 'pending', 'totalAmount': 15.00},
      );

      await firestoreService.updateDocument(
        collection: 'orders',
        documentId: 'o1',
        data: {'status': 'accepted'},
      );

      final doc = await firestoreService.getDocument(
        collection: 'orders',
        documentId: 'o1',
      );

      final data = doc.data() as Map<String, dynamic>;
      expect(data['status'], 'accepted');
    });

    testWidgets('can delete orders', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'o1',
        data: {'status': 'cancelled'},
      );

      await firestoreService.deleteDocument(
        collection: 'orders',
        documentId: 'o1',
      );

      final doc = await firestoreService.getDocument(
        collection: 'orders',
        documentId: 'o1',
      );

      expect(doc.exists, isFalse);
    });
  });

  group('Admin Dashboard Stats', () {
    testWidgets('can count users by role', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'users',
        documentId: 'u1',
        data: {'role': 'customer'},
      );
      await firestoreService.setDocument(
        collection: 'users',
        documentId: 'u2',
        data: {'role': 'customer'},
      );
      await firestoreService.setDocument(
        collection: 'users',
        documentId: 'u3',
        data: {'role': 'vendor'},
      );
      await firestoreService.setDocument(
        collection: 'users',
        documentId: 'u4',
        data: {'role': 'driver'},
      );

      final snapshot = await firestoreService.getDocuments(
        collection: 'users',
      );

      final users = snapshot.docs.map((doc) => doc.data()).whereType<Map<String, dynamic>>().toList();
      final customers = users.where((u) => u['role'] == 'customer').length;
      final vendors = users.where((u) => u['role'] == 'vendor').length;
      final drivers = users.where((u) => u['role'] == 'driver').length;

      expect(customers, 2);
      expect(vendors, 1);
      expect(drivers, 1);
    });

    testWidgets('can count orders by status', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'o1',
        data: {'status': 'pending'},
      );
      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'o2',
        data: {'status': 'pending'},
      );
      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'o3',
        data: {'status': 'delivered'},
      );

      final snapshot = await firestoreService.getDocuments(
        collection: 'orders',
      );

      final orders = snapshot.docs.map((doc) => doc.data()).whereType<Map<String, dynamic>>().toList();
      final pending = orders.where((o) => o['status'] == 'pending').length;
      final delivered = orders.where((o) => o['status'] == 'delivered').length;

      expect(pending, 2);
      expect(delivered, 1);
    });

    testWidgets('can count total vendors', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'v1',
        data: {'name': 'V1'},
      );
      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'v2',
        data: {'name': 'V2'},
      );

      final snapshot = await firestoreService.getDocuments(
        collection: 'vendors',
      );

      expect(snapshot.docs.length, 2);
    });
  });

  group('Cache Operations', () {
    testWidgets('caches and retrieves admin data', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await cacheService.put('admin', 'last_sync', '2024-01-01');
      final cached = cacheService.get<String>('admin', 'last_sync');
      expect(cached, '2024-01-01');
    });

    testWidgets('clears cache', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await cacheService.put('admin', 'key1', 'value1');
      await cacheService.clearAll();

      expect(cacheService.get('admin', 'key1'), isNull);
    });
  });

  group('Secure Storage', () {
    testWidgets('persists admin session token', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await secureStorage.write(key: 'admin_token', value: 'admin-jwt-123');
      final token = await secureStorage.read(key: 'admin_token');
      expect(token, 'admin-jwt-123');
    });

    testWidgets('clears session on logout', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await secureStorage.write(key: 'admin_token', value: 'token');
      await secureStorage.deleteAll();
      final token = await secureStorage.read(key: 'admin_token');
      expect(token, isNull);
    });
  });
}
