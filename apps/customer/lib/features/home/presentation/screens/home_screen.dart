import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import '../../../vendor_detail/presentation/screens/vendor_detail_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../orders/presentation/screens/order_history_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  DeliveryType? _selectedCategory;
  final ScrollController _vendorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<VendorCubit>().loadVendors();
    _loadNotifications();
  }

  @override
  void dispose() {
    _vendorScrollController.dispose();
    super.dispose();
  }

  void _loadNotifications() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<NotificationCubit>()
        ..loadNotifications(authState.user.uid)
        ..watchNotifications(authState.user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 ? _buildHomeAppBar() : null,
      body: AdaptiveScaffold(
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
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            const SearchScreen(),
            const CartScreen(),
            const OrderHistoryScreen(),
            const Center(child: Text('Profile')),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        _buildCategoryChips(),
        Expanded(child: _buildVendorList()),
      ],
    );
  }

  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      title: const Text('Deliverak'),
      actions: [
        BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            final unreadCount =
                state is NotificationsLoaded ? state.unreadCount : 0;

            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          AppFilterChip(
            label: 'All',
            isSelected: _selectedCategory == null,
            onTap: () {
              setState(() => _selectedCategory = null);
              context.read<VendorCubit>().loadVendors();
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          ...DeliveryType.values.map((type) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: AppFilterChip(
                  label: type.displayName,
                  isSelected: _selectedCategory == type,
                  onTap: () {
                    setState(() => _selectedCategory = type);
                    context.read<VendorCubit>().loadVendorsByCategory(type);
                  },
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildVendorList() {
    return BlocBuilder<VendorCubit, VendorState>(
      builder: (context, state) {
        if (state is VendorLoading) {
          return const AppShimmerList();
        }

        if (state is VendorError) {
          return ErrorState(
            message: state.message,
            isRetryable: state.isRetryable,
            onRetry: () => context.read<VendorCubit>().loadVendors(
                  category: _selectedCategory,
                ),
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

          final isTablet = Breakpoints.isTabletOrWider(context);

          return PaginatedList(
            items: state.vendors,
            scrollController: _vendorScrollController,
            hasMore: state.hasMore,
            isLoadingMore: state.isLoadingMore,
            onLoadMore: () => context.read<VendorCubit>().loadMore(),
            padding: EdgeInsets.all(
              isTablet ? AppSpacing.lg : AppSpacing.md,
            ),
            itemBuilder: (context, vendor, index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: AppSpacing.sm,
                ),
                child: _VendorCard(
                  vendor: vendor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VendorDetailScreen(vendor: vendor),
                      ),
                    );
                  },
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

class _VendorCard extends StatelessWidget {
  final VendorModel vendor;
  final VoidCallback onTap;

  const _VendorCard({
    required this.vendor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
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
                ? CachedImage(
                    url: vendor.image,
                    width: 80,
                    height: 80,
                    borderRadius: AppRadius.borderRadiusSm,
                    errorWidget: const Icon(
                      Icons.store,
                      color: AppColors.grey500,
                    ),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        vendor.name,
                        style: AppTypography.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!vendor.isOpen)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: AppRadius.borderRadiusSm,
                        ),
                        child: Text(
                          'Closed',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
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
                    const SizedBox(width: AppSpacing.md),
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 14,
                      color: AppColors.grey500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${vendor.totalOrders} orders',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.chevron_right,
            color: AppColors.grey400,
          ),
        ],
      ),
    );
  }
}
