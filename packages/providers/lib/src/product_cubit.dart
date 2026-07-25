import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductModel> products;

  const ProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductError extends ProductState {
  final String message;
  final bool isRetryable;

  const ProductError({
    required this.message,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, isRetryable];
}

class ProductCubit extends Cubit<ProductState> {
  final IProductRepository _productRepository;

  ProductCubit({required IProductRepository productRepository})
      : _productRepository = productRepository,
        super(ProductInitial());

  Future<void> loadProducts({
    required String vendorId,
    String? category,
    bool? isAvailable,
  }) async {
    emit(ProductLoading());
    try {
      final products = await _productRepository.getProducts(
        vendorId: vendorId,
        category: category,
        isAvailable: isAvailable,
      );
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  void watchProducts(String vendorId) {
    _productRepository.watchProducts(vendorId).listen((products) {
      emit(ProductsLoaded(products));
    }).onError((e) {
      emit(ProductError(message: mapExceptionToMessage(e)));
    });
  }
}
