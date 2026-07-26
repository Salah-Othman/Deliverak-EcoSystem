import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import '../../../../shared/widgets/product_card.dart';

class VendorDetailScreen extends StatefulWidget {
  final VendorModel vendor;

  const VendorDetailScreen({super.key, required this.vendor});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts(
          vendorId: widget.vendor.vendorId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildVendorInfo(),
          ),
          SliverToBoxAdapter(
            child: _buildCategoryFilters(),
          ),
          _buildProductList(),
        ],
      ),
      bottomNavigationBar: _buildCartBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: widget.vendor.image.isNotEmpty
            ? Image.network(
                widget.vendor.image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.grey200,
                  child: const Icon(
                    Icons.store,
                    size: 64,
                    color: AppColors.grey500,
                  ),
                ),
              )
            : Container(
                color: AppColors.grey200,
                child: const Icon(
                  Icons.store,
                  size: 64,
                  color: AppColors.grey500,
                ),
              ),
        title: Text(
          widget.vendor.name,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildVendorInfo() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: widget.vendor.isOpen
                      ? AppColors.successLight
                      : AppColors.errorLight,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Text(
                  widget.vendor.isOpen ? 'Open' : 'Closed',
                  style: AppTypography.labelMedium.copyWith(
                    color: widget.vendor.isOpen
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Text(
                  widget.vendor.category.displayName,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.vendor.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.star, size: 20, color: AppColors.warning),
              const SizedBox(width: AppSpacing.xs),
              Text(
                Formatters.rating(widget.vendor.rating),
                style: AppTypography.titleMedium,
              ),
              const SizedBox(width: AppSpacing.lg),
              const Icon(Icons.shopping_bag_outlined,
                  size: 18, color: AppColors.grey500),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${widget.vendor.totalOrders} orders',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 18, color: AppColors.grey500),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  widget.vendor.address,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is! ProductsLoaded) return const SizedBox.shrink();

        final categories = state.products
            .map((p) => p.category)
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        if (categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              _FilterChip(
                label: 'All',
                isSelected: _selectedCategory == null,
                onTap: () {
                  setState(() => _selectedCategory = null);
                  context.read<ProductCubit>().loadProducts(
                        vendorId: widget.vendor.vendorId,
                      );
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              ...categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _FilterChip(
                      label: cat,
                      isSelected: _selectedCategory == cat,
                      onTap: () {
                        setState(() => _selectedCategory = cat);
                        context.read<ProductCubit>().loadProducts(
                              vendorId: widget.vendor.vendorId,
                              category: cat,
                            );
                      },
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductList() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const SliverFillRemaining(
            child: AppShimmerList(),
          );
        }

        if (state is ProductError) {
          return SliverFillRemaining(
            child: ErrorState(
              message: state.message,
              isRetryable: state.isRetryable,
              onRetry: () => context.read<ProductCubit>().loadProducts(
                    vendorId: widget.vendor.vendorId,
                  ),
            ),
          );
        }

        if (state is ProductsLoaded) {
          if (state.products.isEmpty) {
            return const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No products yet',
                subtitle: 'This vendor hasn\'t added any products',
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = state.products[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ProductCard(
                      product: product,
                      onAddToCart: product.isAvailable
                          ? () {
                              context.read<CartCubit>().addItem(
                                    productId: product.productId,
                                    name: product.name,
                                    price: product.discountPrice ?? product.price,
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} added to cart'),
                                  duration: const Duration(seconds: 1),
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    textColor: AppColors.primary,
                                    onPressed: () {
                                      // Switch to cart tab
                                    },
                                  ),
                                ),
                              );
                            }
                          : null,
                    ),
                  );
                },
                childCount: state.products.length,
              ),
            ),
          );
        }

        return const SliverFillRemaining(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildCartBar() {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state is! CartLoaded || state.items.isEmpty) {
          return const SizedBox.shrink();
        }

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
            child: AppButton(
              label:
                  'View Cart (${state.items.length} items) - ${Formatters.currency(state.totalAmount + state.deliveryFee)}',
              onPressed: () {
                // Switch to cart tab
              },
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: AppRadius.borderRadiusFull,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.grey700,
          ),
        ),
      ),
    );
  }
}
