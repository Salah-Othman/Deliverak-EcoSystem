import 'package:freezed_annotation/freezed_annotation.dart';

import '../exceptions/app_exception.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

DateTime _notifDateTimeFromJson(String value) => DateTime.parse(value);
String _notifDateTimeToJson(DateTime value) => value.toIso8601String();

@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    @Default('') String notificationId,
    @Default('') String userId,
    @Default('') String title,
    @Default('') String body,
    @Default('') String type,
    String? referenceId,
    @Default(false) bool isRead,
    @JsonKey(toJson: _notifDateTimeToJson, fromJson: _notifDateTimeFromJson)
    required DateTime createdAt,
  }) = _NotificationModel;

  const NotificationModel._();

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  static NotificationModel fromMap(Map<String, dynamic> map) {
    return NotificationModel.fromJson({
      'createdAt': DateTime.now().toIso8601String(),
      ...map,
    });
  }

  Map<String, dynamic> toMap() => toJson();

  void validate() {
    if (notificationId.trim().isEmpty) {
      throw const ValidationException(message: 'Notification ID is required');
    }
    if (userId.trim().isEmpty) {
      throw const ValidationException(message: 'User ID is required');
    }
    if (title.trim().isEmpty || title.trim().length > 100) {
      throw const ValidationException(
        message: 'Notification title must be 1–100 characters',
      );
    }
    if (body.trim().isEmpty || body.trim().length > 500) {
      throw const ValidationException(
        message: 'Notification body must be 1–500 characters',
      );
    }
  }
}
