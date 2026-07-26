import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<NotificationCubit>()
        ..loadNotifications(authState.user.uid)
        ..watchNotifications(authState.user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    final authState = context.read<AuthCubit>().state;
                    if (authState is Authenticated) {
                      context
                          .read<NotificationCubit>()
                          .markAllAsRead(authState.user.uid);
                    }
                  },
                  child: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const AppShimmerList(itemCount: 5, itemHeight: 72);
          }

          if (state is NotificationError) {
            return ErrorState(
              message: state.message,
              onRetry: _loadNotifications,
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const EmptyState(
                icon: Icons.notifications_none_outlined,
                title: 'No notifications',
                subtitle: 'You\'ll see order updates and alerts here',
              );
            }

            return _buildNotificationList(state.notifications);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    return RefreshIndicator(
      onRefresh: () async => _loadNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: notifications.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _NotificationTile(
            notification: notification,
            onTap: () {
              context
                  .read<NotificationCubit>()
                  .markAsRead(notification.notificationId, notification.userId);
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  IconData _iconForType() {
    switch (notification.type) {
      case 'order_created':
        return Icons.shopping_bag_outlined;
      case 'order_accepted':
        return Icons.check_circle_outline;
      case 'order_preparing':
        return Icons.restaurant_outlined;
      case 'order_picked_up':
        return Icons.delivery_dining_outlined;
      case 'order_in_transit':
        return Icons.local_shipping_outlined;
      case 'order_delivered':
        return Icons.done_all_outlined;
      case 'order_cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.grey100
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: AppRadius.borderRadiusSm,
        ),
        child: Icon(
          _iconForType(),
          color: notification.isRead ? AppColors.grey500 : AppColors.primary,
          size: 22,
        ),
      ),
      title: Text(
        notification.title,
        style: AppTypography.titleMedium.copyWith(
          fontWeight:
              notification.isRead ? FontWeight.normal : FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        notification.body,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.grey600,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        Formatters.dateTime(notification.createdAt),
        style: AppTypography.caption.copyWith(color: AppColors.grey500),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
    );
  }
}
