import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import '../../../../shared/widgets/admin_widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderStatus? _selectedStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().loadOrders();
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    return orders.where((order) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!order.orderId.toLowerCase().contains(query) &&
            !order.customerId.toLowerCase().contains(query) &&
            !order.vendorId.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Orders',
                style: AppTypography.headlineLarge,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  context.read<OrderCubit>().loadOrders(
                        status: _selectedStatus,
                      );
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFilters(),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _buildOrderList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search by order ID, customer, or vendor...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        ChoiceChip(
          label: const Text('All'),
          selected: _selectedStatus == null,
          onSelected: (_) {
            setState(() => _selectedStatus = null);
            context.read<OrderCubit>().loadOrders();
          },
        ),
        const SizedBox(width: AppSpacing.sm),
        ...OrderStatus.values.map((status) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(status.displayName),
                selected: _selectedStatus == status,
                onSelected: (_) {
                  setState(() => _selectedStatus = status);
                  context.read<OrderCubit>().loadOrders(status: status);
                },
              ),
            )),
      ],
    );
  }

  Widget _buildOrderList() {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const AppLoader();
        }

        if (state is OrderError) {
          return ErrorState(
            message: state.message,
            isRetryable: state.isRetryable,
            onRetry: () => context.read<OrderCubit>().loadOrders(
                  status: _selectedStatus,
                ),
          );
        }

        if (state is OrdersLoaded) {
          final filtered = _filterOrders(state.orders);
          if (filtered.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders found',
              subtitle: 'No orders match your current filters',
            );
          }

          return Card(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final order = filtered[index];
                return ListTile(
                  title: Row(
                    children: [
                      Text(
                        'Order #${order.orderId.length > 8 ? order.orderId.substring(0, 8) : order.orderId}',
                        style: AppTypography.labelLarge,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      OrderStatusChip(status: order.status),
                    ],
                  ),
                  subtitle: Text(
                    '${order.items.length} items - \$${order.totalAmount.toStringAsFixed(2)} - ${DateFormat.yMMMd().add_jm().format(order.createdAt)}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline, size: 20),
                    onPressed: () => _showOrderDetail(order),
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

  void _showOrderDetail(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.orderId.substring(0, 8)}'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailRow(label: 'Status', value: order.status.displayName),
                DetailRow(label: 'Customer ID', value: order.customerId),
                DetailRow(label: 'Vendor ID', value: order.vendorId),
                if (order.driverId != null)
                  DetailRow(label: 'Driver ID', value: order.driverId!),
                DetailRow(label: 'Payment', value: order.paymentMethod),
                DetailRow(
                  label: 'Total',
                  value: '\$${order.totalAmount.toStringAsFixed(2)}',
                ),
                DetailRow(
                  label: 'Delivery Fee',
                  value: '\$${order.deliveryFee.toStringAsFixed(2)}',
                ),
                DetailRow(
                  label: 'Created',
                  value: DateFormat.yMMMd().add_jm().format(order.createdAt),
                ),
                const Divider(),
                Text(
                  'Items',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.name} x${item.quantity}',
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                          Text(
                            '\$${item.total.toStringAsFixed(2)}',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
                const Divider(),
                Text(
                  'Delivery Address',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  order.deliveryAddress.address,
                  style: AppTypography.bodyMedium,
                ),
                DetailRow(label: 'Name', value: order.deliveryAddress.name),
                DetailRow(label: 'Phone', value: order.deliveryAddress.phone),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
