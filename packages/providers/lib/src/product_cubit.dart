import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  final bool hasMore;
  final bool isLoadingMore;

  const ProductsLoaded({
    required this.products,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [products, hasMore, isLoadingMore];
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
  StreamSubscription<List<ProductModel>>? _productsSubscription;
  DocumentSnapshot? _lastDocument;
  String? _currentVendorId;
  String? _currentCategory;
  bool? _currentIsAvailable;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  ProductCubit({required IProductRepository productRepository})
      : _productRepository = productRepository,
        super(ProductInitial());

  Future<void> loadProducts({
    required String vendorId,
    String? category,
    bool? isAvailable,
  }) async {
    emit(ProductLoading());
    _currentVendorId = vendorId;
    _currentCategory = category;
    _currentIsAvailable = isAvailable;
    _lastDocument = null;
    _hasMore = true;

    try {
      final result = await _productRepository.getProductsPaginated(
        vendorId: vendorId,
        category: category,
        isAvailable: isAvailable,
        limit: _pageSize,
      );
      _lastDocument = result.lastDocument;
      _hasMore = result.hasMore;
      emit(ProductsLoaded(
        products: result.items,
        hasMore: _hasMore,
      ));
    } catch (e) {
      emit(ProductError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! ProductsLoaded) return;
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    emit(ProductsLoaded(
      products: currentState.products,
      hasMore: _hasMore,
      isLoadingMore: true,
    ));

    try {
      final result = await _productRepository.getProductsPaginated(
        vendorId: _currentVendorId!,
        category: _currentCategory,
        isAvailable: _currentIsAvailable,
        lastDocument: _lastDocument,
        limit: _pageSize,
      );
      _lastDocument = result.lastDocument;
      _hasMore = result.hasMore;

      emit(ProductsLoaded(
        products: [...currentState.products, ...result.items],
        hasMore: _hasMore,
      ));
    } catch (e) {
      emit(ProductsLoaded(
        products: currentState.products,
        hasMore: _hasMore,
      ));
    } finally {
      _isLoadingMore = false;
    }
  }

  void watchProducts(String vendorId) {
    _productsSubscription?.cancel();
    _productsSubscription = _productRepository.watchProducts(vendorId).listen(
      (products) => emit(ProductsLoaded(products: products)),
      onError: (e) => emit(ProductError(message: mapExceptionToMessage(e))),
    );
  }

  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    return super.close();
  }
}
