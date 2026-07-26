import 'package:firebase_messaging/firebase_messaging.dart';

abstract class INotificationService {
  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  Future<void> subscribeToTopic(String topic);

  Future<void> unsubscribeFromTopic(String topic);

  Future<void> requestPermission();

  Stream<RemoteMessage> get onMessage;

  Stream<RemoteMessage> get onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage();
}
