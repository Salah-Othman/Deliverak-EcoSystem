import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

abstract class VendorProductState extends Equatable {
  const VendorProductState();

  @override
  List<Object?> get props => [];
}

class VendorProductInitial extends VendorProductState {}

class VendorProductLoading extends VendorProductState {}

class VendorProductsLoaded extends VendorProductState {
  final List<ProductModel> products;

  const VendorProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class VendorProductError extends VendorProductState {
  final String message;
  final bool isRetryable;

  const VendorProductError({
    required this.message,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, isRetryable];
}

class VendorProductActionSuccess extends VendorProductState {
  final String message;

  const VendorProductActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class VendorProductImageUploaded extends VendorProductState {
  final String url;

  const VendorProductImageUploaded(this.url);

  @override
  List<Object?> get props => [url];
}

class VendorProductCubit extends Cubit<VendorProductState> {
  final IProductRepository _productRepository;
  final IStorageService _storageService;
  StreamSubscription<List<ProductModel>>? _productsSubscription;

  VendorProductCubit({
    required IProductRepository productRepository,
    required IStorageService storageService,
  })  : _productRepository = productRepository,
        _storageService = storageService,
        super(VendorProductInitial());

  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    return super.close();
  }

  void watchProducts(String vendorId) {
    _productsSubscription?.cancel();
    _productsSubscription =
        _productRepository.watchProducts(vendorId).listen(
      (products) => emit(VendorProductsLoaded(products)),
      onError: (e) =>
          emit(VendorProductError(message: mapExceptionToMessage(e))),
    );
  }

  Future<void> createProduct(ProductModel product) async {
    emit(VendorProductLoading());
    try {
      await _productRepository.createProduct(product);
      emit(const VendorProductActionSuccess('Product created!'));
    } catch (e) {
      emit(VendorProductError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    emit(VendorProductLoading());
    try {
      await _productRepository.updateProduct(product);
      emit(const VendorProductActionSuccess('Product updated!'));
    } catch (e) {
      emit(VendorProductError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> deleteProduct(String productId) async {
    emit(VendorProductLoading());
    try {
      await _productRepository.deleteProduct(productId);
      emit(const VendorProductActionSuccess('Product deleted.'));
    } catch (e) {
      emit(VendorProductError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> toggleAvailability(ProductModel product) async {
    try {
      final updated = product.copyWith(isAvailable: !product.isAvailable);
      await _productRepository.updateProduct(updated);
    } catch (e) {
      emit(VendorProductError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<String?> uploadImage(String filePath, String folder) async {
    try {
      final result = await _storageService.uploadFile(
        filePath: filePath,
        folder: folder,
      );
      return result.secureUrl;
    } catch (e) {
      emit(VendorProductError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
      return null;
    }
  }
}
