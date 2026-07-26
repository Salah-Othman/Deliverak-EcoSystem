import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import '../../../orders/presentation/screens/vendor_order_detail_screen.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorProfileCubit, VendorProfileState>(
      builder: (context, profileState) {
        final vendor =
            profileState is VendorProfileLoaded ? profileState.vendor : null;

        return BlocBuilder<VendorOrderCubit, VendorOrderState>(
          builder: (context, orderState) {
            int pendingCount = 0;
            int activeCount = 0;
            List<OrderModel> recentOrders = [];

            if (orderState is VendorOrdersLoaded) {
              pendingCount = orderState.pendingOrders.length;
              activeCount = orderState.activeOrders.length;
              recentOrders = [
                ...orderState.pendingOrders,
                ...orderState.activeOrders,
                ...orderState.completedOrders,
              ].take(5).toList();
            }

            return RefreshIndicator(
              onRefresh: () async {},
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStoreHeader(vendor),
                    const SizedBox(height: AppSpacing.md),
                    _buildOpenCloseToggle(context, vendor),
                    const SizedBox(height: AppSpacing.lg),
                    _buildStatCards(pendingCount, activeCount),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Recent Orders', style: AppTypography.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    if (recentOrders.isEmpty)
                      const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No orders yet',
                        subtitle: 'Orders from customers will appear here',
                      )
                    else
                      ...recentOrders.map((order) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _RecentOrderCard(
                              order: order,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => VendorOrderDetailScreen(
                                        orderId: order.orderId),
                                  ),
                                );
                              },
                            ),
                          )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStoreHeader(VendorModel? vendor) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.grey200,
            shape: BoxShape.circle,
          ),
          child: vendor != null && vendor.image.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    vendor.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.store,
                      color: AppColors.grey500,
                    ),
                  ),
                )
              : const Icon(
                  Icons.store,
                  color: AppColors.grey500,
                ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vendor?.name ?? 'Your Store',
                style: AppTypography.titleLarge,
              ),
              Text(
                vendor?.category.displayName ?? '',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOpenCloseToggle(BuildContext context, VendorModel? vendor) {
    if (vendor == null) return const SizedBox.shrink();

    return AppCard(
      child: SwitchListTile(
        title: Text(
          vendor.isOpen ? 'Store is Open' : 'Store is Closed',
          style: AppTypography.titleMedium.copyWith(
            color: vendor.isOpen ? AppColors.success : AppColors.error,
          ),
        ),
        subtitle: Text(
          vendor.isOpen
              ? 'Accepting new orders'
              : 'Not accepting orders',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.grey600,
          ),
        ),
        value: vendor.isOpen,
        onChanged: (_) {
          context.read<VendorProfileCubit>().toggleOpenClose(vendor);
        },
        secondary: Icon(
          vendor.isOpen ? Icons.store : Icons.store_outlined,
          color: vendor.isOpen ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  Widget _buildStatCards(int pendingCount, int activeCount) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.pending_actions,
            label: 'Pending',
            value: '$pendingCount',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.autorenew,
            label: 'Active',
            value: '$activeCount',
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.headlineLarge.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}

class _RecentOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _RecentOrderCard({
    required this.order,
    required this.onTap,
  });

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
                Text(
                  'Order #${order.orderId.length > 8 ? order.orderId.substring(order.orderId.length - 8) : order.orderId}',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${order.items.length} items - ${Formatters.currency(order.totalAmount + order.deliveryFee)}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusChip(order.status),
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
