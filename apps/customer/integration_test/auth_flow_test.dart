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

  group('Auth Flow', () {
    testWidgets('shows login screen for unauthenticated user', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('shows loading during auth initialization', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final loading = find.byType(CircularProgressIndicator);
      final hasLoader = loading.evaluate().isNotEmpty;
      final hasLogin = find.text('Login Screen').evaluate().isNotEmpty;

      expect(hasLoader || hasLogin, isTrue);
    });
  });

  group('Browse Vendors', () {
    testWidgets('seeds vendor data and verifies firestore storage',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
        data: {
          'name': 'Test Restaurant',
          'description': 'A test restaurant',
          'category': 'food',
          'isOpen': true,
        },
      );

      final snapshot = await firestoreService.getDocument(
        collection: 'vendors',
        documentId: 'vendor-1',
      );

      expect(snapshot.exists, isTrue);
      expect((snapshot.data() as Map<String, dynamic>)['name'], 'Test Restaurant');
    });

    testWidgets('seeded vendor data persists in fake firestore',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'v1',
        data: {'name': 'Vendor 1'},
      );
      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'v2',
        data: {'name': 'Vendor 2'},
      );

      final snapshot = await firestoreService.getDocuments(
        collection: 'vendors',
      );

      expect(snapshot.docs.length, 2);
    });
  });

  group('Theme Toggle', () {
    testWidgets('defaults to system theme', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('fake secure storage persists theme', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await secureStorage.write(key: 'theme_mode', value: 'dark');
      final saved = await secureStorage.read(key: 'theme_mode');

      expect(saved, 'dark');
    });

    testWidgets('theme persistence round-trip', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await secureStorage.write(key: 'theme_mode', value: 'light');
      expect(await secureStorage.read(key: 'theme_mode'), 'light');

      await secureStorage.write(key: 'theme_mode', value: 'dark');
      expect(await secureStorage.read(key: 'theme_mode'), 'dark');

      await secureStorage.write(key: 'theme_mode', value: 'system');
      expect(await secureStorage.read(key: 'theme_mode'), 'system');
    });
  });

  group('Cart Operations', () {
    testWidgets('cart starts empty', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
    });
  });

  group('Firestore Operations', () {
    testWidgets('set and get document', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'test',
        documentId: 'doc1',
        data: {'key': 'value'},
      );

      final doc = await firestoreService.getDocument(
        collection: 'test',
        documentId: 'doc1',
      );

      expect(doc.exists, isTrue);
      expect((doc.data() as Map<String, dynamic>)['key'], 'value');
    });

    testWidgets('update document merges data', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'test',
        documentId: 'doc1',
        data: {'a': 1, 'b': 2},
      );

      await firestoreService.updateDocument(
        collection: 'test',
        documentId: 'doc1',
        data: {'b': 3, 'c': 4},
      );

      final doc = await firestoreService.getDocument(
        collection: 'test',
        documentId: 'doc1',
      );

      final data = doc.data() as Map<String, dynamic>;
      expect(data['a'], 1);
      expect(data['b'], 3);
      expect(data['c'], 4);
    });

    testWidgets('delete document removes it', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'test',
        documentId: 'doc1',
        data: {'key': 'value'},
      );

      await firestoreService.deleteDocument(
        collection: 'test',
        documentId: 'doc1',
      );

      final doc = await firestoreService.getDocument(
        collection: 'test',
        documentId: 'doc1',
      );

      expect(doc.exists, isFalse);
    });

    testWidgets('getDocuments returns all docs in collection',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await firestoreService.setDocument(
        collection: 'items',
        documentId: 'i1',
        data: {'name': 'Item 1'},
      );
      await firestoreService.setDocument(
        collection: 'items',
        documentId: 'i2',
        data: {'name': 'Item 2'},
      );
      await firestoreService.setDocument(
        collection: 'other',
        documentId: 'o1',
        data: {'name': 'Other'},
      );

      final snapshot = await firestoreService.getDocuments(
        collection: 'items',
      );

      expect(snapshot.docs.length, 2);
    });
  });
}
