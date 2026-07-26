import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import '../../../../shared/widgets/admin_widgets.dart';
import '../widgets/stats_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const AppLoader();
        }

        if (state is AdminError) {
          return ErrorState(
            message: state.message,
            isRetryable: state.isRetryable,
            onRetry: () => context.read<AdminCubit>().loadDashboard(),
          );
        }

        if (state is AdminDashboardLoaded) {
          return _buildDashboard(state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDashboard(AdminDashboardLoaded state) {
    return RefreshIndicator(
      onRefresh: () => context.read<AdminCubit>().loadDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: AppTypography.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatsGrid(state),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Orders by Status',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildOrdersByStatus(state),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Recent Orders',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildRecentOrders(state),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(AdminDashboardLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.5,
          children: [
            StatsCard(
              title: 'Total Users',
              value: '${state.totalUsers}',
              icon: Icons.people,
              color: AppColors.primary,
            ),
            StatsCard(
              title: 'Total Vendors',
              value: '${state.totalVendors}',
              icon: Icons.store,
              color: AppColors.success,
            ),
            StatsCard(
              title: 'Total Orders',
              value: '${state.totalOrders}',
              icon: Icons.receipt_long,
              color: AppColors.warning,
            ),
            StatsCard(
              title: 'Total Drivers',
              value: '${state.totalDrivers}',
              icon: Icons.delivery_dining,
              color: AppColors.secondary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrdersByStatus(AdminDashboardLoaded state) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: OrderStatus.values.map((status) {
        final count = state.ordersByStatus[status] ?? 0;
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                status.displayName,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentOrders(AdminDashboardLoaded state) {
    if (state.recentOrders.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No orders yet',
        subtitle: 'Orders will appear here once customers start ordering',
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.recentOrders.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final order = state.recentOrders[index];
          return ListTile(
            title: Text(
                    'Order #${order.orderId.length > 8 ? order.orderId.substring(0, 8) : order.orderId}',
              style: AppTypography.labelLarge,
            ),
            subtitle: Text(
              '${order.items.length} items - \$${order.totalAmount.toStringAsFixed(2)}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            trailing: OrderStatusChip(status: order.status),
          );
        },
      ),
    );
  }
}
