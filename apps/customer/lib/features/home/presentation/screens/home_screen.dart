import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<VendorCubit>().loadVendors();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
      },
      items: const [
        NavigationItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
        ),
        NavigationItem(
          icon: Icons.search_outlined,
          activeIcon: Icons.search,
          label: 'Search',
        ),
        NavigationItem(
          icon: Icons.shopping_cart_outlined,
          activeIcon: Icons.shopping_cart,
          label: 'Cart',
        ),
        NavigationItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'Orders',
        ),
        NavigationItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
        ),
      ],
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const Center(child: Text('Search'));
      case 2:
        return const Center(child: Text('Cart'));
      case 3:
        return const Center(child: Text('Orders'));
      case 4:
        return const Center(child: Text('Profile'));
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return BlocBuilder<VendorCubit, VendorState>(
      builder: (context, state) {
        if (state is VendorLoading) {
          return const AppShimmerList();
        }

        if (state is VendorError) {
          return ErrorState(
            message: state.message,
            isRetryable: state.isRetryable,
            onRetry: () => context.read<VendorCubit>().loadVendors(),
          );
        }

        if (state is VendorsLoaded) {
          if (state.vendors.isEmpty) {
            return const EmptyState(
              icon: Icons.store_outlined,
              title: 'No vendors nearby',
              subtitle: 'We couldn\'t find any vendors in your area',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: state.vendors.length,
            itemBuilder: (context, index) {
              final vendor = state.vendors[index];
              return AppCard(
                onTap: () {
                  // TODO: Navigate to vendor details
                },
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: vendor.image.isNotEmpty
                          ? Image.network(
                              vendor.image,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.store,
                              color: AppColors.grey500,
                            ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendor.name,
                            style: AppTypography.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            vendor.category.displayName,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                Formatters.rating(vendor.rating),
                                style: AppTypography.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
