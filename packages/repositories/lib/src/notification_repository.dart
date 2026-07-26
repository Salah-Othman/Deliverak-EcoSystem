import 'dart:convert';

import 'package:core/core.dart';

const _kNotificationsBox = 'notifications_box';

class NotificationRepository implements INotificationRepository {
  final IFirestoreService _firestoreService;
  final ICacheService _cacheService;

  NotificationRepository({
    required IFirestoreService firestoreService,
    required ICacheService cacheService,
  })  : _firestoreService = firestoreService,
        _cacheService = cacheService;

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final cacheKey = 'notifications_$userId';
    final cached = _cacheService.get<String>(_kNotificationsBox, cacheKey);
    if (cached != null) {
      return (jsonDecode(cached) as List)
          .map((e) => NotificationModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.notifications,
      orderBy: 'createdAt',
      descending: true,
    );

    final notifications = docs.docs
        .map((doc) =>
            NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
        .where((notification) => notification.userId == userId)
        .toList();

    await _cacheService.put<String>(
      _kNotificationsBox,
      cacheKey,
      jsonEncode(notifications.map((n) => n.toMap()).toList()),
    );

    return notifications;
  }

  @override
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _firestoreService
        .watchDocuments(
          collection: FirestorePaths.notifications,
          orderBy: 'createdAt',
          descending: true,
        )
        .map((snapshot) {
      final notifications = snapshot.docs
          .map((doc) =>
              NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((notification) => notification.userId == userId)
          .toList();

      _cacheService.put<String>(
        _kNotificationsBox,
        'notifications_$userId',
        jsonEncode(notifications.map((n) => n.toMap()).toList()),
      );

      return notifications;
    });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _firestoreService.updateDocument(
      collection: FirestorePaths.notifications,
      documentId: notificationId,
      data: {
        'isRead': true,
      },
    );
    await _cacheService.clearBox(_kNotificationsBox);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.notifications,
      where: [['userId', userId], ['isRead', false]],
    );

    for (final doc in docs.docs) {
      await _firestoreService.updateDocument(
        collection: FirestorePaths.notifications,
        documentId: doc.id,
        data: {
          'isRead': true,
        },
      );
    }
    await _cacheService.clearBox(_kNotificationsBox);
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.notifications,
      where: [['userId', userId], ['isRead', false]],
    );

    return docs.docs.length;
  }
}
