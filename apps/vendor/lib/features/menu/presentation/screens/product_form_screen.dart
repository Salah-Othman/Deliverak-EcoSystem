import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DeliveryType _selectedCategory = DeliveryType.food;
  List<String> _imageUrls = [];
  bool _isUploadingImage = false;
  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.product!;
      _nameController.text = p.name;
      _descriptionController.text = p.description;
      _priceController.text = p.price.toString();
      if (p.discountPrice != null) {
        _discountPriceController.text = p.discountPrice.toString();
      }
      _imageUrls = List.from(p.images);
      _selectedCategory = DeliveryType.values.firstWhere(
        (e) => e.name == p.category,
        orElse: () => DeliveryType.food,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    super.dispose();
  }

  String get _vendorId {
    final state = context.read<AuthCubit>().state;
    if (state is Authenticated) return state.user.uid;
    return '';
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final price = double.tryParse(_priceController.text) ?? 0;
    final discountPrice = _discountPriceController.text.isNotEmpty
        ? double.tryParse(_discountPriceController.text)
        : null;

    if (_isEditing) {
      final updated = widget.product!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        discountPrice: discountPrice,
        images: _imageUrls,
        category: _selectedCategory.name,
      );
      context.read<VendorProductCubit>().updateProduct(updated);
    } else {
      final product = ProductModel(
        productId: '',
        vendorId: _vendorId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        discountPrice: discountPrice,
        images: _imageUrls,
        category: _selectedCategory.name,
        isAvailable: true,
        createdAt: DateTime.now(),
      );
      context.read<VendorProductCubit>().createProduct(product);
    }

    Navigator.of(context).pop();
  }

  Future<void> _pickImage() async {
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
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() => _isUploadingImage = true);

    if (!mounted) return;
    final url = await context
        .read<VendorProductCubit>()
        .uploadImage(pickedFile.path, 'products');

    if (!mounted) return;
    setState(() => _isUploadingImage = false);

    if (url != null) {
      setState(() => _imageUrls.add(url));
    }
  }

  void _removeImage(int index) {
    setState(() => _imageUrls.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: BlocListener<VendorProductCubit, VendorProductState>(
        listener: (context, state) {
          if (state is VendorProductActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state is VendorProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageSection(),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    hintText: 'e.g. Chicken Burger',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a product name';
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
                    hintText: 'Describe your product...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value != null && value.length > 1000) {
                      return 'Description must be under 1000 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<DeliveryType>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: DeliveryType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixText: '\$ ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _discountPriceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Discount Price (optional)',
                    prefixText: '\$ ',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Please enter a valid price';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: _isEditing ? 'Update Product' : 'Create Product',
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Images', style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ..._imageUrls.asMap().entries.map((entry) {
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.borderRadiusSm,
                      color: AppColors.grey200,
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadius.borderRadiusSm,
                      child: Image.network(
                        entry.value,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.image,
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => _removeImage(entry.key),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 12,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            GestureDetector(
              onTap: _isUploadingImage ? null : _pickImage,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.borderRadiusSm,
                  border: Border.all(color: AppColors.grey300),
                  color: AppColors.grey100,
                ),
                child: _isUploadingImage
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.grey500,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteDialog() {
    AppDialog.show(
      context: context,
      title: 'Delete Product',
      content: 'Are you sure you want to delete this product?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
      onConfirm: () {
        context
            .read<VendorProductCubit>()
            .deleteProduct(widget.product!.productId);
        Navigator.of(context).pop();
      },
    );
  }
}
