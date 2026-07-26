abstract class ILocalNotificationService {
  Future<void> initialize({
    required String androidChannelId,
    required String androidChannelName,
    String? androidChannelDescription,
  });

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  Stream<int> get onNotificationTap;

  Stream<String?> get onNotificationPayloadTap;

  Future<void> cancelAll();

  Future<void> cancel(int id);
}
