// ignore_for_file: subtype_of_sealed_class
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:repositories/repositories.dart';

import 'helpers/firestore_test_helpers.dart';

void main() {
  late MockFirestoreService mockFirestoreService;
  late MockCacheService mockCacheService;
  late NotificationRepository notificationRepository;

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    mockCacheService = MockCacheService();
    notificationRepository = NotificationRepository(
      firestoreService: mockFirestoreService,
      cacheService: mockCacheService,
    );
  });

  setUpAll(() {
    registerFallbackValue(const QueryCondition(field: 'test', value: 'test'));
    registerFallbackValue(<String, dynamic>{});
  });

  Map<String, dynamic> notificationMap({
    String notificationId = 'n1',
    String userId = 'u1',
    String title = 'Test Notification',
    String body = 'Test body',
    String type = 'order',
    bool isRead = false,
  }) {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'referenceId': null,
      'isRead': isRead,
      'createdAt': DateTime(2024).toIso8601String(),
    };
  }

  group('NotificationRepository', () {
    group('getNotifications', () {
      test('returns notifications from Firestore filtered by userId', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(null);
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              where: any(named: 'where'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(
                notificationMap(notificationId: 'n1', userId: 'u1'),
                id: 'n1'),
            FakeDocumentSnapshot(
                notificationMap(notificationId: 'n3', userId: 'u1'),
                id: 'n3'),
          ]),
        );
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});

        final notifications =
            await notificationRepository.getNotifications('u1');

        expect(notifications.length, 2);
        expect(notifications.every((n) => n.userId == 'u1'), isTrue);
      });

      test('returns notifications from cache', () async {
        when(() => mockCacheService.get<String>(any(), any())).thenReturn(
          jsonEncode([
            notificationMap(notificationId: 'n1', userId: 'u1'),
            notificationMap(notificationId: 'n2', userId: 'u1'),
          ]),
        );

        final notifications =
            await notificationRepository.getNotifications('u1');

        expect(notifications.length, 2);
        verifyNever(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
            ));
      });
    });

    group('markAsRead', () {
      test('calls Firestore updateDocument with isRead: true', () async {
        when(() => mockFirestoreService.updateDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            )).thenAnswer((_) async {});

        await notificationRepository.markAsRead('n1');

        verify(() => mockFirestoreService.updateDocument(
              collection: FirestorePaths.notifications,
              documentId: 'n1',
              data: {'isRead': true},
            )).called(1);
      });
    });

    group('markAllAsRead', () {
      test('queries unread notifications and updates each, clears cache',
          () async {
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              where: any(named: 'where'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(
                notificationMap(notificationId: 'n1', userId: 'u1'),
                id: 'n1'),
            FakeDocumentSnapshot(
                notificationMap(notificationId: 'n2', userId: 'u1'),
                id: 'n2'),
          ]),
        );
        when(() => mockFirestoreService.updateDocuments(
              collection: any(named: 'collection'),
              documentIds: any(named: 'documentIds'),
              data: any(named: 'data'),
            )).thenAnswer((_) async {});
        when(() => mockCacheService.delete(any(), any()))
            .thenAnswer((_) async {});

        await notificationRepository.markAllAsRead('u1');

        verify(() => mockFirestoreService.updateDocuments(
              collection: FirestorePaths.notifications,
              documentIds: ['n1', 'n2'],
              data: {'isRead': true},
            )).called(1);
        verify(() => mockCacheService.delete(any(), 'notifications_u1'))
            .called(1);
      });

      test('handles no unread notifications', () async {
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              where: any(named: 'where'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([]),
        );
        when(() => mockCacheService.delete(any(), any()))
            .thenAnswer((_) async {});

        await notificationRepository.markAllAsRead('u1');

        verifyNever(() => mockFirestoreService.updateDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            ));
        verify(() => mockCacheService.delete(any(), 'notifications_u1'))
            .called(1);
      });
    });

    group('getUnreadCount', () {
      test('returns count of unread notifications', () async {
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              where: any(named: 'where'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(
                notificationMap(notificationId: 'n1', userId: 'u1'),
                id: 'n1'),
            FakeDocumentSnapshot(
                notificationMap(notificationId: 'n2', userId: 'u1'),
                id: 'n2'),
          ]),
        );

        final count = await notificationRepository.getUnreadCount('u1');

        expect(count, 2);
      });

      test('returns zero when no unread notifications', () async {
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              where: any(named: 'where'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([]),
        );

        final count = await notificationRepository.getUnreadCount('u1');

        expect(count, 0);
      });
    });
  });
}
