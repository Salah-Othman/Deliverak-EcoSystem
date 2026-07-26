import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

class AvailableOrdersScreen extends StatefulWidget {
  const AvailableOrdersScreen({super.key});

  @override
  State<AvailableOrdersScreen> createState() => _AvailableOrdersScreenState();
}

class _AvailableOrdersScreenState extends State<AvailableOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverOrderCubit>().watchAvailableOrders();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverOrderCubit, DriverOrderState>(
      builder: (context, state) {
        if (state is DriverOrderLoading) {
          return const Center(child: AppLoader());
        }

        if (state is DriverOrderError) {
          return ErrorState(
            message: state.message,
            isRetryable: state.isRetryable,
            onRetry: () =>
                context.read<DriverOrderCubit>().watchAvailableOrders(),
          );
        }

        if (state is AvailableOrdersLoaded) {
          if (state.orders.isEmpty) {
            return const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No available orders',
              subtitle: 'New orders will appear here when vendors accept them',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DriverOrderCubit>().watchAvailableOrders();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _AvailableOrderCard(
                    order: order,
                    onAccept: () => _acceptOrder(order),
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _acceptOrder(OrderModel order) {
    final driverState = context.read<DriverCubit>().state;
    if (driverState is! DriverLoaded) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Order'),
        content: Text(
          'Accept delivery for order #${_shortId(order.orderId)}?\n\n'
          'Delivery fee: \$${order.deliveryFee.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Decline'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DriverOrderCubit>().acceptOrder(
                    order.orderId,
                    driverState.driver.driverId,
                  );
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  String _shortId(String id) => id.length <= 8 ? id : id.substring(id.length - 8);
}

class _AvailableOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onAccept;

  const _AvailableOrderCard({
    required this.order,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${_shortId(order.orderId)}',
                style: AppTypography.titleMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successLight.withValues(alpha: 0.2),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Text(
                  '\$${order.deliveryFee.toStringAsFixed(2)}',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.grey500),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  order.deliveryAddress.address,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.grey600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _InfoChip(
                icon: Icons.shopping_bag_outlined,
                label: '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
              ),
              const SizedBox(width: AppSpacing.sm),
              _InfoChip(
                icon: Icons.attach_money,
                label: '\$${order.totalAmount.toStringAsFixed(2)}',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAccept,
              child: const Text('Accept Delivery'),
            ),
          ),
        ],
      ),
    );
  }

  String _shortId(String id) => id.length <= 8 ? id : id.substring(id.length - 8);
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.grey500),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.grey600),
        ),
      ],
    );
  }
}
