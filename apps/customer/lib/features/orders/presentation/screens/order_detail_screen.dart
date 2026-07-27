import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late final OrderCubit _orderCubit;

  @override
  void initState() {
    super.initState();
    _orderCubit = OrderCubit(
      orderRepository: context.read<IOrderRepository>(),
    )..watchOrder(widget.orderId);
  }

  @override
  void dispose() {
    _orderCubit.close();
    super.dispose();
  }

  String _shortOrderId(String orderId) {
    return orderId.length <= 8 ? orderId : orderId.substring(orderId.length - 8);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _orderCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
        ),
        body: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            if (state is OrderInitial || state is OrderLoading) {
              return const Center(child: AppLoader());
            }

            if (state is OrderError) {
              return ErrorState(
                message: state.message,
                isRetryable: state.isRetryable,
                onRetry: () =>
                    _orderCubit.watchOrder(widget.orderId),
              );
            }

            if (state is OrderDetailLoaded) {
              return _buildOrderDetail(state.order);
            }

            return const Center(child: Text('Order not found'));
          },
        ),
      ),
    );
  }

  Widget _buildOrderDetail(OrderModel order) {
    final isTablet = Breakpoints.isTabletOrWider(context);

    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(order),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatusStepper(order.status),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDeliveryInfo(order),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPaymentInfo(order),
                  if (order.status.isActive) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildCancelButton(order),
                  ],
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _buildOrderItems(order),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(order),
          const SizedBox(height: AppSpacing.lg),
          _buildStatusStepper(order.status),
          const SizedBox(height: AppSpacing.lg),
          _buildOrderItems(order),
          const SizedBox(height: AppSpacing.lg),
          _buildDeliveryInfo(order),
          const SizedBox(height: AppSpacing.lg),
          _buildPaymentInfo(order),
          if (order.status.isActive) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildCancelButton(order),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order #${_shortOrderId(order.orderId)}',
              style: AppTypography.titleLarge,
            ),
            _buildStatusChip(order.status),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          Formatters.dateTime(order.createdAt),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.grey600),
        ),
      ],
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

  Widget _buildStatusStepper(OrderStatus currentStatus) {
    final steps = [
      OrderStatus.pending,
      OrderStatus.accepted,
      OrderStatus.preparing,
      OrderStatus.pickedUp,
      OrderStatus.inTransit,
      OrderStatus.delivered,
    ];

    final currentIndex = steps.indexOf(currentStatus);
    final isCancelled = currentStatus == OrderStatus.cancelled;

    return AppCard(
      child: Column(
        children: [
          if (isCancelled)
            Row(
              children: [
                const Icon(Icons.cancel_outlined,
                    color: AppColors.error, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Order Cancelled',
                  style: AppTypography.titleMedium
                      .copyWith(color: AppColors.error),
                ),
              ],
            )
          else
            ...List.generate(steps.length, (index) {
              final step = steps[index];
              final isCompleted = index < currentIndex;
              final isCurrent = index == currentIndex;
              final isLast = index == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted || isCurrent
                              ? AppColors.primary
                              : AppColors.grey200,
                          border: Border.all(
                            color: isCompleted || isCurrent
                                ? AppColors.primary
                                : AppColors.grey300,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check,
                                size: 14, color: AppColors.white)
                            : isCurrent
                                ? Container(
                                    margin: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.white,
                                    ),
                                  )
                                : null,
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 32,
                          color: isCompleted
                              ? AppColors.primary
                              : AppColors.grey200,
                        ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        step.displayName,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isCompleted || isCurrent
                              ? AppColors.grey800
                              : AppColors.grey500,
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildOrderItems(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Items', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            children: [
              ...order.items.map((item) => Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.name}',
                            style: AppTypography.bodyMedium,
                          ),
                        ),
                        Text(
                          Formatters.currency(item.total),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.grey600)),
                  Text(Formatters.currency(order.totalAmount),
                      style: AppTypography.bodyMedium),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery fee',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.grey600)),
                  Text(Formatters.currency(order.deliveryFee),
                      style: AppTypography.bodyMedium),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTypography.titleMedium),
                  Text(
                    Formatters.currency(
                        order.totalAmount + order.deliveryFee),
                    style: AppTypography.titleMedium
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Address', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.deliveryAddress.name,
                        style: AppTypography.titleMedium),
                    Text(order.deliveryAddress.phone,
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.grey600)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(order.deliveryAddress.address,
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.grey600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Row(
            children: [
              const Icon(Icons.money, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Text('Cash on Delivery', style: AppTypography.titleMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton(OrderModel order) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final isLoading = state is OrderLoading;
        return AppButton(
          label: isLoading ? 'Cancelling...' : 'Cancel Order',
          isOutlined: true,
          isLoading: isLoading,
          onPressed: isLoading ? null : () => _showCancelDialog(order),
        );
      },
    );
  }

  void _showCancelDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No, keep it'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<OrderCubit>().cancelOrder(order.orderId);
            },
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
  }
}
