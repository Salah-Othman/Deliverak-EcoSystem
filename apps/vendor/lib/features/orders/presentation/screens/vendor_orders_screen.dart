import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import '../widgets/vendor_order_card.dart';
import 'vendor_order_detail_screen.dart';

class VendorOrdersScreen extends StatelessWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
          Expanded(
            child: BlocBuilder<VendorOrderCubit, VendorOrderState>(
              builder: (context, state) {
                if (state is VendorOrderLoading) {
                  return const Center(child: AppLoader());
                }

                if (state is VendorOrderError) {
                  return ErrorState(
                    message: state.message,
                    isRetryable: state.isRetryable,
                  );
                }

                if (state is VendorOrdersLoaded) {
                  return TabBarView(
                    children: [
                      _buildOrderList(
                        context,
                        state.pendingOrders,
                        emptyTitle: 'No pending orders',
                        emptySubtitle: 'New orders will appear here',
                      ),
                      _buildOrderList(
                        context,
                        state.activeOrders,
                        emptyTitle: 'No active orders',
                        emptySubtitle: 'Accepted orders appear here',
                      ),
                      _buildOrderList(
                        context,
                        state.completedOrders,
                        emptyTitle: 'No completed orders',
                        emptySubtitle: 'Past orders appear here',
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    List<OrderModel> orders, {
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    if (orders.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: VendorOrderCard(
            order: order,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      VendorOrderDetailScreen(orderId: order.orderId),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
