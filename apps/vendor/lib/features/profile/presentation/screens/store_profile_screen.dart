import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

class StoreProfileScreen extends StatefulWidget {
  final String vendorId;

  const StoreProfileScreen({super.key, required this.vendorId});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initControllers(VendorModel vendor) {
    if (!_isInitialized) {
      _nameController.text = vendor.name;
      _descriptionController.text = vendor.description;
      _isInitialized = true;
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final state = context.read<VendorProfileCubit>().state;
    if (state is! VendorProfileLoaded) return;

    final vendor = state.vendor;
    final updated = vendor.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );
    context.read<VendorProfileCubit>().updateVendorProfile(updated);
  }

  Future<void> _pickImage() async {
    final state = context.read<VendorProfileCubit>().state;
    if (state is! VendorProfileLoaded) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    if (!mounted) return;
    final url = await context
        .read<VendorProfileCubit>()
        .uploadImage(pickedFile.path, 'vendors');

    if (url != null && mounted) {
      final updated = state.vendor.copyWith(image: url);
      context.read<VendorProfileCubit>().updateVendorProfile(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorProfileCubit, VendorProfileState>(
      builder: (context, state) {
        if (state is VendorProfileLoading) {
          return const Center(child: AppLoader());
        }

        if (state is VendorProfileError) {
          return ErrorState(
            message: state.message,
            isRetryable: state.isRetryable,
            onRetry: () => context
                .read<VendorProfileCubit>()
                .loadVendorProfile(widget.vendorId),
          );
        }

        if (state is VendorProfileLoaded) {
          _initControllers(state.vendor);
          return _buildProfile(state.vendor);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProfile(VendorModel vendor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStoreImage(vendor),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Store Name',
                prefixIcon: Icon(Icons.store_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your store name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<DeliveryType>(
              initialValue: vendor.category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: DeliveryType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      ))
                  .toList(),
              onChanged: null,
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: SwitchListTile(
                title: Text(
                  vendor.isOpen ? 'Store is Open' : 'Store is Closed',
                  style: AppTypography.titleMedium.copyWith(
                    color: vendor.isOpen ? AppColors.success : AppColors.error,
                  ),
                ),
                subtitle: Text(
                  vendor.isOpen
                      ? 'Accepting new orders'
                      : 'Not accepting orders',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                value: vendor.isOpen,
                onChanged: (_) {
                  context
                      .read<VendorProfileCubit>()
                      .toggleOpenClose(vendor);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.star, color: AppColors.warning),
                    title: const Text('Rating'),
                    trailing: Text(
                      Formatters.rating(vendor.rating),
                      style: AppTypography.titleMedium,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined,
                        color: AppColors.primary),
                    title: const Text('Total Orders'),
                    trailing: Text(
                      '${vendor.totalOrders}',
                      style: AppTypography.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Save Changes',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreImage(VendorModel vendor) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.grey200,
                shape: BoxShape.circle,
              ),
              child: vendor.image.isNotEmpty
                  ? ClipOval(
                      child: CachedImage(
                        url: vendor.image,
                        width: 120,
                        height: 120,
                        errorWidget: const Icon(
                          Icons.store,
                          size: 50,
                          color: AppColors.grey500,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.store,
                      size: 50,
                      color: AppColors.grey500,
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
