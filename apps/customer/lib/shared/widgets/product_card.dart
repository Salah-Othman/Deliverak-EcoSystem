import 'package:flutter/material.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! < product.price;
    final isUnavailable = !product.isAvailable;

    return AppCard(
      child: Row(
        children: [
          _buildImage(isUnavailable),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTypography.titleMedium.copyWith(
                    color: isUnavailable ? AppColors.grey500 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    product.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        Formatters.currency(product.price),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.grey500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        Formatters.currency(product.discountPrice!),
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else
                      Text(
                        Formatters.currency(product.price),
                        style: AppTypography.titleMedium.copyWith(
                          color: isUnavailable ? AppColors.grey500 : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (isUnavailable)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Text(
                'Unavailable',
                style: AppTypography.caption.copyWith(
                  color: AppColors.grey500,
                ),
              ),
            )
          else if (onAddToCart != null)
            _AddToCartButton(onTap: onAddToCart!),
        ],
      ),
    );
  }

  Widget _buildImage(bool isUnavailable) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: product.images.isNotEmpty
          ? CachedImage(
              url: product.images.first,
              width: 80,
              height: 80,
              borderRadius: AppRadius.borderRadiusSm,
              errorWidget: Icon(
                Icons.fastfood_outlined,
                color: isUnavailable ? AppColors.grey400 : AppColors.grey500,
              ),
            )
          : Icon(
              Icons.fastfood_outlined,
              color: isUnavailable ? AppColors.grey400 : AppColors.grey500,
            ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddToCartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.borderRadiusSm,
        ),
        child: const Icon(
          Icons.add,
          color: AppColors.white,
          size: 20,
        ),
      ),
    );
  }
}
