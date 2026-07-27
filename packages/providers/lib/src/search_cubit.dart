import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchIdle extends SearchState {}

class SearchLoading extends SearchState {}

class SearchResults extends SearchState {
  final List<VendorModel> vendors;
  final String query;

  const SearchResults({required this.vendors, required this.query});

  @override
  List<Object?> get props => [vendors, query];
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}

class SearchError extends SearchState {
  final String message;
  final String query;
  final String? code;
  final bool isRetryable;

  const SearchError({
    required this.message,
    required this.query,
    this.code,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, query, code, isRetryable];
}

class SearchCubit extends Cubit<SearchState> {
  final IVendorRepository _vendorRepository;
  Timer? _debounce;

  SearchCubit({required IVendorRepository vendorRepository})
      : _vendorRepository = vendorRepository,
        super(SearchIdle());

  void search(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      emit(SearchIdle());
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      emit(SearchLoading());
      try {
        final vendors = await retryWithBackoff(() => _vendorRepository.searchVendors(query.trim()));
        if (vendors.isEmpty) {
          emit(SearchEmpty(query: query.trim()));
        } else {
          emit(SearchResults(vendors: vendors, query: query.trim()));
        }
      } catch (e) {
        emit(SearchError(
          message: mapExceptionToMessage(e),
          query: query.trim(),
          code: e is AppException ? e.code : null,
          isRetryable: isRetryableError(e),
        ));
      }
    });
  }

  void clear() {
    _debounce?.cancel();
    emit(SearchIdle());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
