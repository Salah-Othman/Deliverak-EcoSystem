import 'package:flutter/material.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

class VendorOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const VendorOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  String get _shortOrderId {
    return order.orderId.length > 8
        ? order.orderId.substring(order.orderId.length - 8)
        : order.orderId;
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #$_shortOrderId',
                      style: AppTypography.titleMedium,
                    ),
                    _buildStatusChip(order.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  order.deliveryAddress.name,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.items.length} items - ${Formatters.currency(order.totalAmount + order.deliveryFee)}',
                      style: AppTypography.bodyMedium,
                    ),
                    Text(
                      _timeAgo(order.createdAt),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right, color: AppColors.grey400),
        ],
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
      case OrderStatus.accepted:
      case OrderStatus.preparing:
      case OrderStatus.pickedUp:
      case OrderStatus.inTransit:
        color = AppColors.primary;
      case OrderStatus.delivered:
        color = AppColors.success;
      case OrderStatus.cancelled:
        color = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Text(
        status.displayName,
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
