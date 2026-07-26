import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

class EarningsScreen extends StatefulWidget {
  final String driverId;

  const EarningsScreen({super.key, required this.driverId});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverOrderCubit>().loadDeliveryHistory(widget.driverId);
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
            onRetry: () => context
                .read<DriverOrderCubit>()
                .loadDeliveryHistory(widget.driverId),
          );
        }

        if (state is DriverOrdersLoaded) {
          return _buildEarnings(state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEarnings(DriverOrdersLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        await context
            .read<DriverOrderCubit>()
            .loadDeliveryHistory(widget.driverId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEarningsSummary(state.totalEarnings, state.orders.length),
            const SizedBox(height: AppSpacing.lg),
            Text('Delivery History', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            if (state.orders.isEmpty)
              const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No deliveries yet',
                subtitle: 'Your completed deliveries will appear here',
              )
            else
              ...state.orders.map((order) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _DeliveryHistoryCard(order: order),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsSummary(double totalEarnings, int totalDeliveries) {
    return AppCard(
      backgroundColor: AppColors.primary,
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 40,
            color: AppColors.white,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Total Earnings',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Formatters.currency(totalEarnings),
            style: AppTypography.displayLarge.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$totalDeliveries delivery${totalDeliveries != 1 ? 'ies' : 'y'}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryHistoryCard extends StatelessWidget {
  final OrderModel order;

  const _DeliveryHistoryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${_shortId(order.orderId)}',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  Formatters.dateTime(order.updatedAt),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${Formatters.currency(order.deliveryFee)}',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _shortId(String id) => id.length <= 8 ? id : id.substring(id.length - 8);
}
