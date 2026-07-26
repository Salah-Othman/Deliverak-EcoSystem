import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NotificationCubit extends Cubit<NotificationState> {
  final INotificationRepository _notificationRepository;
  StreamSubscription<List<NotificationModel>>? _notificationsSubscription;

  NotificationCubit({required INotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
        super(NotificationInitial());

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }

  Future<void> loadNotifications(String userId) async {
    emit(NotificationLoading());
    try {
      final notifications = await _notificationRepository.getNotifications(userId);
      final unreadCount = await _notificationRepository.getUnreadCount(userId);
      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(message: mapExceptionToMessage(e)));
    }
  }

  void watchNotifications(String userId) {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = _notificationRepository
        .watchNotifications(userId)
        .listen(
      (notifications) {
        _notificationRepository.getUnreadCount(userId).then((unreadCount) {
          emit(NotificationsLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          ));
        });
      },
      onError: (e) {
        emit(NotificationError(message: mapExceptionToMessage(e)));
      },
    );
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      await _notificationRepository.markAsRead(notificationId);
      await loadNotifications(userId);
    } catch (e) {
      emit(NotificationError(message: mapExceptionToMessage(e)));
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _notificationRepository.markAllAsRead(userId);
      await loadNotifications(userId);
    } catch (e) {
      emit(NotificationError(message: mapExceptionToMessage(e)));
    }
  }
}
