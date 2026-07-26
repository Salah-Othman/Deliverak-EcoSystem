import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<OrderCubit>().loadOrders(customerId: authState.user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(child: AppLoader());
        }

        if (state is OrderError) {
          return ErrorState(
            message: state.message,
            isRetryable: state.isRetryable,
            onRetry: _loadOrders,
          );
        }

        if (state is OrdersLoaded) {
          if (state.orders.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              subtitle: 'Your order history will appear here',
            );
          }

          return _buildOrderList(state.orders);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    return RefreshIndicator(
      onRefresh: () async => _loadOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _OrderCard(order: order),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: order.orderId),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.orderId.substring(0, 8)}',
                style: AppTypography.titleMedium,
              ),
              _buildStatusChip(order.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            Formatters.date(order.createdAt),
            style: AppTypography.caption.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Formatters.currency(order.totalAmount + order.deliveryFee),
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.grey400),
            ],
          ),
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
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
