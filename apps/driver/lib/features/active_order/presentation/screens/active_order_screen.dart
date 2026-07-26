import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

class ActiveOrderScreen extends StatefulWidget {
  final String driverId;

  const ActiveOrderScreen({super.key, required this.driverId});

  @override
  State<ActiveOrderScreen> createState() => _ActiveOrderScreenState();
}

class _ActiveOrderScreenState extends State<ActiveOrderScreen> {
  Timer? _locationTimer;
  bool _hasActiveOrder = false;

  @override
  void initState() {
    super.initState();
    context.read<DriverOrderCubit>().watchActiveOrder(widget.driverId);
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updateLocation();
    });
  }

  void _stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _updateLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        context.read<DriverCubit>().updateLocation(
              position.latitude,
              position.longitude,
            );
      }
    } catch (_) {
      // Silently handle location errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverOrderCubit, DriverOrderState>(
      listener: (context, state) {
        if (state is ActiveOrderLoaded) {
          if (!_hasActiveOrder) {
            _hasActiveOrder = true;
            _startLocationUpdates();
          }
        } else {
          if (_hasActiveOrder) {
            _hasActiveOrder = false;
            _stopLocationUpdates();
          }
        }

        if (state is DriverOrderActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DriverOrderLoading && !_hasActiveOrder) {
          return const Center(child: AppLoader());
        }

        if (state is ActiveOrderLoaded) {
          return _buildActiveOrder(state.order);
        }

        return const EmptyState(
          icon: Icons.local_shipping_outlined,
          title: 'No active delivery',
          subtitle: 'Accept an order from the Available tab to start delivering',
        );
      },
    );
  }

  Widget _buildActiveOrder(OrderModel order) {
    final isPickedUp = order.status == OrderStatus.pickedUp;
    final isInTransit = order.status == OrderStatus.inTransit;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusHeader(order),
          const SizedBox(height: AppSpacing.lg),
          _buildOrderInfo(order),
          const SizedBox(height: AppSpacing.lg),
          _buildDeliveryAddress(order),
          const SizedBox(height: AppSpacing.lg),
          _buildOrderItems(order),
          const SizedBox(height: AppSpacing.lg),
          _buildActionButtons(order, isPickedUp, isInTransit),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(OrderModel order) {
    Color statusColor;
    String statusText;

    switch (order.status) {
      case OrderStatus.pickedUp:
        statusColor = AppColors.primary;
        statusText = 'Ready for Pickup';
      case OrderStatus.inTransit:
        statusColor = AppColors.warning;
        statusText = 'In Transit';
      default:
        statusColor = AppColors.grey500;
        statusText = order.status.displayName;
    }

    return AppCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  order.status == OrderStatus.inTransit
                      ? Icons.delivery_dining
                      : Icons.store_outlined,
                  color: statusColor,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  statusText,
                  style: AppTypography.titleMedium.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(OrderModel order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Details', style: AppTypography.titleMedium),
          const Divider(),
          _InfoRow(
            label: 'Order ID',
            value: '#${_shortId(order.orderId)}',
          ),
          _InfoRow(
            label: 'Items',
            value: '${order.items.length}',
          ),
          _InfoRow(
            label: 'Total',
            value: '\$${order.totalAmount.toStringAsFixed(2)}',
          ),
          _InfoRow(
            label: 'Delivery Fee',
            value: '\$${order.deliveryFee.toStringAsFixed(2)}',
            valueColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(OrderModel order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery Address', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.deliveryAddress.name,
                      style: AppTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      order.deliveryAddress.phone,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.grey600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      order.deliveryAddress.address,
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(OrderModel order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Items', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
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
                      '\$${item.total.toStringAsFixed(2)}',
                      style: AppTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    OrderModel order,
    bool isPickedUp,
    bool isInTransit,
  ) {
    final cubit = context.read<DriverOrderCubit>();
    final isLoading = context.watch<DriverOrderCubit>().state is DriverOrderLoading;

    if (isPickedUp) {
      return AppButton(
        label: isLoading ? 'Starting...' : 'Start Delivery',
        isLoading: isLoading,
        backgroundColor: AppColors.primary,
        onPressed: isLoading
            ? null
            : () => cubit.startDelivery(order.orderId),
      );
    }

    if (isInTransit) {
      return AppButton(
        label: isLoading ? 'Completing...' : 'Complete Delivery',
        isLoading: isLoading,
        backgroundColor: AppColors.success,
        onPressed: isLoading
            ? null
            : () => cubit.completeDelivery(order.orderId, widget.driverId),
      );
    }

    return const SizedBox.shrink();
  }

  String _shortId(String id) => id.length <= 8 ? id : id.substring(id.length - 8);
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.grey600),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
