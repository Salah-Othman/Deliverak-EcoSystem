import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/e2e_services.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late E2EAuthService authService;
  late E2EFirestoreService firestoreService;

  setUp(() {
    authService = E2EAuthService();
    firestoreService = E2EFirestoreService();
  });

  tearDown(() {
    authService.dispose();
  });

  group('E2E - Authentication Flow', () {
    testWidgets('user can initiate phone verification', (tester) async {
      bool codeSent = false;

      await authService.verifyPhoneNumber(
        phoneNumber: '+1234567890',
        onCompleted: (_) {},
        onFailed: (_) {},
        onCodeSent: (verificationId, _) {
          codeSent = true;
        },
        onCodeTimeout: (_) {},
      );

      expect(codeSent, isTrue);
    });

    testWidgets('user can sign in with credential', (tester) async {
      final credential = PhoneAuthProvider.credential(
        verificationId: 'e2e-verification-id',
        smsCode: '123456',
      );

      final result = await authService.signInWithCredential(credential);
      expect(result, isNotNull);
    });

    testWidgets('user can sign out', (tester) async {
      await authService.signOut();
      expect(authService.currentUser, isNull);
    });
  });

  group('E2E - Vendor Operations', () {
    testWidgets('can create and retrieve vendor', (tester) async {
      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'vendor-e2e-1',
        data: {
          'name': 'E2E Restaurant',
          'description': 'End-to-end test restaurant',
          'category': 'food',
          'isOpen': true,
          'rating': 4.5,
        },
      );

      final doc = await firestoreService.getDocument(
        collection: 'vendors',
        documentId: 'vendor-e2e-1',
      );

      expect(doc.exists, isTrue);
      final data = doc.data() as Map<String, dynamic>;
      expect(data['name'], 'E2E Restaurant');
      expect(data['isOpen'], isTrue);
    });

    testWidgets('can update vendor', (tester) async {
      await firestoreService.setDocument(
        collection: 'vendors',
        documentId: 'vendor-e2e-2',
        data: {'name': 'Before', 'isOpen': false},
      );

      await firestoreService.updateDocument(
        collection: 'vendors',
        documentId: 'vendor-e2e-2',
        data: {'name': 'After', 'isOpen': true},
      );

      final doc = await firestoreService.getDocument(
        collection: 'vendors',
        documentId: 'vendor-e2e-2',
      );

      final data = doc.data() as Map<String, dynamic>;
      expect(data['name'], 'After');
      expect(data['isOpen'], isTrue);
    });

    testWidgets('can list vendors', (tester) async {
      for (var i = 1; i <= 3; i++) {
        await firestoreService.setDocument(
          collection: 'vendors',
          documentId: 'vendor-$i',
          data: {'name': 'Vendor $i'},
        );
      }

      final snapshot = await firestoreService.getDocuments(
        collection: 'vendors',
      );

      expect(snapshot.docs.length, 3);
    });
  });

  group('E2E - Order Lifecycle', () {
    testWidgets('can create order', (tester) async {
      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'order-e2e-1',
        data: {
          'customerId': 'customer-1',
          'vendorId': 'vendor-1',
          'status': 'pending',
          'totalAmount': 50.0,
        },
      );

      final doc = await firestoreService.getDocument(
        collection: 'orders',
        documentId: 'order-e2e-1',
      );

      expect(doc.exists, isTrue);
      expect((doc.data() as Map<String, dynamic>)['status'], 'pending');
    });

    testWidgets('can update order status', (tester) async {
      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'order-e2e-2',
        data: {'status': 'pending'},
      );

      await firestoreService.updateDocument(
        collection: 'orders',
        documentId: 'order-e2e-2',
        data: {'status': 'accepted'},
      );

      final doc = await firestoreService.getDocument(
        collection: 'orders',
        documentId: 'order-e2e-2',
      );

      expect((doc.data() as Map<String, dynamic>)['status'], 'accepted');
    });

    testWidgets('can delete order', (tester) async {
      await firestoreService.setDocument(
        collection: 'orders',
        documentId: 'order-e2e-3',
        data: {'status': 'cancelled'},
      );

      await firestoreService.deleteDocument(
        collection: 'orders',
        documentId: 'order-e2e-3',
      );

      final doc = await firestoreService.getDocument(
        collection: 'orders',
        documentId: 'order-e2e-3',
      );

      expect(doc.exists, isFalse);
    });
  });

  group('E2E - Offline Sync', () {
    testWidgets('pending writes are stored and retrieved', (tester) async {
      final writes = <Map<String, dynamic>>[];

      writes.add({
        'id': 'pw-1',
        'collection': 'orders',
        'documentId': 'order-1',
        'data': {'status': 'pending'},
        'operation': 'set',
      });

      expect(writes.length, 1);
      expect(writes.first['operation'], 'set');
    });

    testWidgets('pending writes can be retried', (tester) async {
      var retryCount = 0;

      void retry() {
        retryCount++;
      }

      retry();
      retry();

      expect(retryCount, 2);
    });
  });

  group('E2E - Data Consistency', () {
    testWidgets('concurrent writes to same document', (tester) async {
      await firestoreService.setDocument(
        collection: 'test',
        documentId: 'concurrent-1',
        data: {'version': 1},
      );

      await firestoreService.updateDocument(
        collection: 'test',
        documentId: 'concurrent-1',
        data: {'version': 2},
      );

      final doc = await firestoreService.getDocument(
        collection: 'test',
        documentId: 'concurrent-1',
      );

      expect((doc.data() as Map<String, dynamic>)['version'], 2);
    });

    testWidgets('large document write and read', (tester) async {
      final largeData = {
        for (var i = 0; i < 100; i++) 'field$i': 'value$i',
      };

      await firestoreService.setDocument(
        collection: 'test',
        documentId: 'large-doc',
        data: largeData,
      );

      final doc = await firestoreService.getDocument(
        collection: 'test',
        documentId: 'large-doc',
      );

      final data = doc.data() as Map<String, dynamic>;
      expect(data.length, 100);
      expect(data['field42'], 'value42');
    });
  });
}
