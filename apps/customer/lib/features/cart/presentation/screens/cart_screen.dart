import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import '../../../checkout/presentation/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state is CartLoaded && state.items.isNotEmpty) {
          return _buildCartContent(context, state);
        }

        return _buildEmptyCart();
      },
    );
  }

  Widget _buildEmptyCart() {
    return const EmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'Your cart is empty',
      subtitle: 'Add items from vendors to get started',
    );
  }

  Widget _buildCartContent(BuildContext context, CartLoaded state) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _CartItemCard(
                  item: item,
                  onQuantityChanged: (quantity) {
                    context.read<CartCubit>().updateQuantity(
                          item.productId,
                          quantity,
                        );
                  },
                  onRemove: () {
                    context.read<CartCubit>().removeItem(item.productId);
                  },
                ),
              );
            },
          ),
        ),
        _buildSummary(context, state),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, CartLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                Text(
                  Formatters.currency(state.totalAmount),
                  style: AppTypography.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery fee',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                Text(
                  Formatters.currency(state.deliveryFee),
                  style: AppTypography.bodyLarge,
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppTypography.headlineMedium,
                ),
                Text(
                  Formatters.currency(state.totalAmount + state.deliveryFee),
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Place Order',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      vendorId: state.vendorId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final OrderItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  void _showRemoveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove item'),
        content: Text('Remove ${item.name} from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRemove();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  Formatters.currency(item.price),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _QuantityButton(
                icon: item.quantity == 1 ? Icons.delete_outline : Icons.remove,
                onTap: item.quantity == 1
                    ? () => _showRemoveConfirmation(context)
                    : () => onQuantityChanged(item.quantity - 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                child: Text(
                  '${item.quantity}',
                  style: AppTypography.titleMedium,
                ),
              ),
              _QuantityButton(
                icon: Icons.add,
                onTap: () => onQuantityChanged(item.quantity + 1),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            Formatters.currency(item.total),
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: AppRadius.borderRadiusSm,
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.grey700,
        ),
      ),
    );
  }
}
