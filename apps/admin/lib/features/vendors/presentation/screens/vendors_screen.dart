import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  DeliveryType? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<VendorCubit>().loadVendors();
  }

  List<VendorModel> _filterVendors(List<VendorModel> vendors) {
    return vendors.where((vendor) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!vendor.name.toLowerCase().contains(query) &&
            !vendor.address.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vendors',
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFilters(),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _buildVendorList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search by name or address...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        ChoiceChip(
          label: const Text('All'),
          selected: _selectedCategory == null,
          onSelected: (_) {
            setState(() => _selectedCategory = null);
            context.read<VendorCubit>().loadVendors();
          },
        ),
        const SizedBox(width: AppSpacing.sm),
        ...DeliveryType.values.map((type) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(type.displayName),
                selected: _selectedCategory == type,
                onSelected: (_) {
                  setState(() => _selectedCategory = type);
                  context.read<VendorCubit>().loadVendorsByCategory(type);
                },
              ),
            )),
      ],
    );
  }

  Widget _buildVendorList() {
    return BlocBuilder<VendorCubit, VendorState>(
      builder: (context, state) {
        if (state is VendorLoading) {
          return const AppLoader();
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
          final filtered = _filterVendors(state.vendors);
          if (filtered.isEmpty) {
            return const EmptyState(
              icon: Icons.store_outlined,
              title: 'No vendors found',
              subtitle: 'No vendors match your current filters',
            );
          }

          return Card(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final vendor = filtered[index];
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
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
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.store,
                                color: AppColors.grey500,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.store,
                            color: AppColors.grey500,
                          ),
                  ),
                  title: Text(
                    vendor.name,
                    style: AppTypography.labelLarge,
                  ),
                  subtitle: Text(
                    '${vendor.category.displayName} - ${vendor.address}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _OpenStatusChip(isOpen: vendor.isOpen),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        icon: const Icon(Icons.info_outline, size: 20),
                        onPressed: () => _showVendorDetail(vendor),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showVendorDetail(VendorModel vendor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vendor.name),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vendor.image.isNotEmpty)
                ClipRRect(
                  borderRadius: AppRadius.borderRadiusMd,
                  child: Image.network(
                    vendor.image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 150,
                      color: AppColors.grey200,
                      child: const Icon(Icons.store, size: 48),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              _detailRow('ID', vendor.vendorId),
              _detailRow('Category', vendor.category.displayName),
              _detailRow('Address', vendor.address),
              _detailRow('Rating', vendor.rating.toStringAsFixed(1)),
              _detailRow('Total Orders', '${vendor.totalOrders}'),
              _detailRow('Status', vendor.isOpen ? 'Open' : 'Closed'),
              _detailRow('Owner ID', vendor.ownerId),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.grey500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenStatusChip extends StatelessWidget {
  final bool isOpen;

  const _OpenStatusChip({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: (isOpen ? AppColors.success : AppColors.error)
            .withValues(alpha: 0.1),
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: AppTypography.caption.copyWith(
          color: isOpen ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
