import 'package:flutter/material.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
      case OrderStatus.accepted:
      case OrderStatus.preparing:
        color = AppColors.primary;
      case OrderStatus.pickedUp:
      case OrderStatus.inTransit:
        color = Colors.blue;
      case OrderStatus.delivered:
        color = AppColors.success;
      case OrderStatus.cancelled:
        color = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Text(
        status.displayName,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class UserRoleChip extends StatelessWidget {
  final UserRole role;

  const UserRoleChip({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (role) {
      case UserRole.customer:
        color = AppColors.primary;
      case UserRole.driver:
        color = Colors.blue;
      case UserRole.vendor:
        color = AppColors.success;
      case UserRole.admin:
        color = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Text(
        role.displayName,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class OpenStatusChip extends StatelessWidget {
  final bool isOpen;

  const OpenStatusChip({super.key, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: (isOpen ? AppColors.success : AppColors.error)
            .withValues(alpha: 0.1),
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: AppTypography.caption.copyWith(
          color: isOpen ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.grey500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
