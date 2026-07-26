import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import '../widgets/product_item_card.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<VendorProductCubit, VendorProductState>(
        builder: (context, state) {
          if (state is VendorProductLoading) {
            return const Center(child: AppLoader());
          }

          if (state is VendorProductError) {
            return ErrorState(
              message: state.message,
              isRetryable: state.isRetryable,
            );
          }

          if (state is VendorProductsLoaded) {
            if (state.products.isEmpty) {
              return const EmptyState(
                icon: Icons.restaurant_menu_outlined,
                title: 'No products yet',
                subtitle: 'Add your first product to get started',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ProductItemCard(
                    product: product,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductFormScreen(product: product),
                        ),
                      );
                    },
                    onToggleAvailability: () {
                      context
                          .read<VendorProductCubit>()
                          .toggleAvailability(product);
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ProductFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
