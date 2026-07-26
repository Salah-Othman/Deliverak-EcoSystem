import 'package:flutter/material.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

class ProductItemCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onToggleAvailability;

  const ProductItemCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: product.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: AppRadius.borderRadiusSm,
                    child: Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.restaurant,
                        color: AppColors.grey500,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.restaurant,
                    color: AppColors.grey500,
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTypography.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      Formatters.currency(product.price),
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (product.discountPrice != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        Formatters.currency(product.discountPrice!),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.grey500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Text(
                    product.category.isNotEmpty ? product.category : 'General',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: product.isAvailable,
            onChanged: (_) => onToggleAvailability(),
          ),
        ],
      ),
    );
  }
}
