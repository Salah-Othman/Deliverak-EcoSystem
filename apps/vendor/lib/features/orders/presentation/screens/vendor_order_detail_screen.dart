import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

class VendorOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const VendorOrderDetailScreen({super.key, required this.orderId});

  @override
  State<VendorOrderDetailScreen> createState() =>
      _VendorOrderDetailScreenState();
}

class _VendorOrderDetailScreenState extends State<VendorOrderDetailScreen> {
  late final VendorOrderCubit _orderCubit;

  @override
  void initState() {
    super.initState();
    _orderCubit = VendorOrderCubit(
      orderRepository: context.read<IOrderRepository>(),
    )..watchOrder(widget.orderId);
  }

  @override
  void dispose() {
    _orderCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _orderCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
        ),
        body: BlocConsumer<VendorOrderCubit, VendorOrderState>(
          listener: (context, state) {
            if (state is VendorOrderActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              _orderCubit.watchOrder(widget.orderId);
            }
            if (state is VendorOrderError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is VendorOrderLoading && state is! VendorOrderDetailLoaded) {
              return const Center(child: AppLoader());
            }

            if (state is VendorOrderError && state is! VendorOrderDetailLoaded) {
              return ErrorState(
                message: state.message,
                isRetryable: state.isRetryable,
                onRetry: () => _orderCubit.watchOrder(widget.orderId),
              );
            }

            if (state is VendorOrderDetailLoaded) {
              return _buildOrderDetail(state.order);
            }

            return const Center(child: AppLoader());
          },
        ),
      ),
    );
  }

  Widget _buildOrderDetail(OrderModel order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(order),
          const SizedBox(height: AppSpacing.lg),
          _buildOrderItems(order),
          const SizedBox(height: AppSpacing.lg),
          _buildDeliveryInfo(order),
          const SizedBox(height: AppSpacing.lg),
          _buildPaymentInfo(order),
          const SizedBox(height: AppSpacing.lg),
          _buildStatusActions(order),
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
              'Order #${order.orderId.length > 8 ? order.orderId.substring(order.orderId.length - 8) : order.orderId}',
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

  Widget _buildStatusActions(OrderModel order) {
    final isLoading =
        context.watch<VendorOrderCubit>().state is VendorOrderLoading;

    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Reject',
                isOutlined: true,
                isLoading: isLoading,
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.error,
                onPressed: isLoading
                    ? null
                    : () => _showConfirmDialog(
                          context,
                          title: 'Reject Order',
                          content: 'Are you sure you want to reject this order?',
                          onConfirm: () {
                            _orderCubit.rejectOrder(order.orderId);
                          },
                        ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: 'Accept',
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () => _orderCubit.acceptOrder(order.orderId),
              ),
            ),
          ],
        );
      case OrderStatus.accepted:
        return AppButton(
          label: 'Start Preparing',
          isLoading: isLoading,
          onPressed: isLoading
              ? null
              : () => _orderCubit.markPreparing(order.orderId),
        );
      case OrderStatus.preparing:
        return AppButton(
          label: 'Mark Ready for Pickup',
          isLoading: isLoading,
          onPressed: isLoading
              ? null
              : () => _orderCubit.markReady(order.orderId),
        );
      case OrderStatus.pickedUp:
        return _buildInfoAction(
          Icons.local_shipping_outlined,
          'Waiting for driver to pick up',
          AppColors.primary,
        );
      case OrderStatus.inTransit:
        return _buildInfoAction(
          Icons.delivery_dining,
          'Out for delivery',
          AppColors.primary,
        );
      case OrderStatus.delivered:
        return _buildInfoAction(
          Icons.check_circle_outline,
          'Order Completed',
          AppColors.success,
        );
      case OrderStatus.cancelled:
        return _buildInfoAction(
          Icons.cancel_outlined,
          'Order Cancelled',
          AppColors.error,
        );
    }
  }

  Widget _buildInfoAction(IconData icon, String text, Color color) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: AppTypography.titleMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        content: content,
        confirmText: 'Confirm',
        cancelText: 'Cancel',
        onConfirm: () {
          Navigator.of(ctx).pop();
          onConfirm();
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }
}
