import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

abstract class VendorState extends Equatable {
  const VendorState();

  @override
  List<Object?> get props => [];
}

class VendorInitial extends VendorState {}

class VendorLoading extends VendorState {}

class VendorsLoaded extends VendorState {
  final List<VendorModel> vendors;
  final bool hasMore;
  final bool isLoadingMore;
  final String? loadMoreError;

  const VendorsLoaded({
    required this.vendors,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  @override
  List<Object?> get props => [vendors, hasMore, isLoadingMore, loadMoreError];
}

class VendorError extends VendorState {
  final String message;
  final bool isRetryable;

  const VendorError({
    required this.message,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, isRetryable];
}

class VendorCubit extends Cubit<VendorState> {
  final IVendorRepository _vendorRepository;
  DocumentSnapshot? _lastDocument;
  DeliveryType? _currentCategory;
  bool _currentIsOpen = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  VendorCubit({required IVendorRepository vendorRepository})
      : _vendorRepository = vendorRepository,
        super(VendorInitial());

  Future<void> loadVendors({
    DeliveryType? category,
    bool? isOpen,
  }) async {
    emit(VendorLoading());
    _currentCategory = category;
    _currentIsOpen = isOpen ?? false;
    _lastDocument = null;
    _hasMore = true;

    try {
      final result = await retryWithBackoff(() => _vendorRepository.getVendorsPaginated(
        category: category,
        isOpen: isOpen,
        limit: _pageSize,
      ));
      _lastDocument = result.lastDocument;
      _hasMore = result.hasMore;
      emit(VendorsLoaded(
        vendors: result.items,
        hasMore: _hasMore,
      ));
    } catch (e) {
      emit(VendorError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! VendorsLoaded) return;
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    emit(VendorsLoaded(
      vendors: currentState.vendors,
      hasMore: _hasMore,
      isLoadingMore: true,
    ));

    try {
      final result = await _vendorRepository.getVendorsPaginated(
        category: _currentCategory,
        isOpen: _currentIsOpen,
        lastDocument: _lastDocument,
        limit: _pageSize,
      );
      _lastDocument = result.lastDocument;
      _hasMore = result.hasMore;

      emit(VendorsLoaded(
        vendors: [...currentState.vendors, ...result.items],
        hasMore: _hasMore,
      ));
    } catch (e) {
      emit(VendorsLoaded(
        vendors: currentState.vendors,
        hasMore: _hasMore,
        loadMoreError: mapExceptionToMessage(e),
      ));
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> searchVendors(String query) async {
    emit(VendorLoading());
    _hasMore = false;
    try {
      final vendors = await _vendorRepository.searchVendors(query);
      emit(VendorsLoaded(vendors: vendors));
    } catch (e) {
      emit(VendorError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> loadVendorsByCategory(DeliveryType category) async {
    await loadVendors(category: category);
  }
}
