import 'package:core/src/models/notification_model.dart';

abstract class INotificationRepository {
  Future<List<NotificationModel>> getNotifications(String userId);

  Stream<List<NotificationModel>> watchNotifications(String userId);

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead(String userId);

  Future<int> getUnreadCount(String userId);
}
