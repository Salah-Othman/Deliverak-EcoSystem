import 'package:core/core.dart';

class NotificationRepository implements INotificationRepository {
  final IFirestoreService _firestoreService;

  NotificationRepository({required IFirestoreService firestoreService})
      : _firestoreService = firestoreService;

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.notifications,
      orderBy: 'createdAt',
      descending: true,
    );

    return docs.docs
        .map((doc) =>
            NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
        .where((notification) => notification.userId == userId)
        .toList();
  }

  @override
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _firestoreService
        .watchDocuments(
          collection: FirestorePaths.notifications,
          orderBy: 'createdAt',
          descending: true,
        )
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
            .where((notification) => notification.userId == userId)
            .toList());
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
