import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import '../../../vendor_detail/presentation/screens/vendor_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
      });
      context.read<VendorCubit>().loadVendors();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<VendorCubit>().searchVendors(query.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildResults()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search vendors...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                    _focusNode.unfocus();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (!_isSearching) {
      return _buildDefaultView();
    }

    return BlocBuilder<VendorCubit, VendorState>(
      builder: (context, state) {
        if (state is VendorLoading) {
          return const AppShimmerList();
        }

        if (state is VendorError) {
          return ErrorState(
            message: state.message,
            isRetryable: state.isRetryable,
            onRetry: () => context.read<VendorCubit>().searchVendors(
                  _searchController.text.trim(),
                ),
          );
        }

        if (state is VendorsLoaded) {
          if (state.vendors.isEmpty) {
            return EmptyState(
              icon: Icons.search_off,
              title: 'No results found',
              subtitle:
                  'No vendors match "${_searchController.text.trim()}"',
              actionLabel: 'Clear search',
              onAction: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            );
          }

          return _buildSearchResults(state.vendors);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDefaultView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: AppColors.grey300,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Search for vendors',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Find food, groceries, medicine & more',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<VendorModel> vendors) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: vendors.length,
      itemBuilder: (context, index) {
        final vendor = vendors[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProductCubit>(),
                    child: VendorDetailScreen(vendor: vendor),
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: vendor.image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: AppRadius.borderRadiusSm,
                          child: Image.network(
                            vendor.image,
                            fit: BoxFit.cover,
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
                      Text(
                        vendor.name,
                        style: AppTypography.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            Formatters.rating(vendor.rating),
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ],
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
          ),
        );
      },
    );
  }
}
