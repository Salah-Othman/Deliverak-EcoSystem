import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService implements ILocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<int> _tapController =
      StreamController<int>.broadcast();
  final StreamController<String?> _payloadController =
      Stream<String?>.broadcast();

  @override
  Future<void> initialize({
    required String androidChannelId,
    required String androidChannelName,
    String? androidChannelDescription,
  }) async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          AndroidNotificationChannel(
            androidChannelId,
            androidChannelName,
            description: androidChannelDescription ?? androidChannelName,
            importance: Importance.high,
          ),
        );
      }
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.id != null) {
      _tapController.add(response.id!);
    }
    if (response.payload != null) {
      _payloadController.add(response.payload);
    }
  }

  @override
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'deliverak_default',
      'Deliverak Notifications',
      channelDescription: 'General notifications from Deliverak',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  @override
  Stream<int> get onNotificationTap => _tapController.stream;

  @override
  Stream<String?> get onNotificationPayloadTap => _payloadController.stream;

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  @override
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  void dispose() {
    _tapController.close();
    _payloadController.close();
  }
}
