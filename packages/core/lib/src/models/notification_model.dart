import 'package:equatable/equatable.dart';

import '../exceptions/app_exception.dart';

class NotificationModel extends Equatable {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: map['notificationId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: map['type'] as String? ?? '',
      referenceId: map['referenceId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'referenceId': referenceId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      notificationId: notificationId,
      userId: userId,
      title: title,
      body: body,
      type: type,
      referenceId: referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [notificationId, userId, title, body, type, referenceId, isRead, createdAt];

  void validate() {
    if (notificationId.trim().isEmpty) {
      throw const ValidationException(message: 'Notification ID is required');
    }
    if (userId.trim().isEmpty) {
      throw const ValidationException(message: 'User ID is required');
    }
    if (title.trim().isEmpty || title.trim().length > 100) {
      throw const ValidationException(message: 'Notification title must be 1–100 characters');
    }
    if (body.trim().isEmpty || body.trim().length > 500) {
      throw const ValidationException(message: 'Notification body must be 1–500 characters');
    }
  }
}
