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

  const VendorsLoaded(this.vendors);

  @override
  List<Object?> get props => [vendors];
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

  VendorCubit({required IVendorRepository vendorRepository})
      : _vendorRepository = vendorRepository,
        super(VendorInitial());

  Future<void> loadVendors({
    DeliveryType? category,
    bool? isOpen,
  }) async {
    emit(VendorLoading());
    try {
      final vendors = await _vendorRepository.getVendors(
        category: category,
        isOpen: isOpen,
      );
      emit(VendorsLoaded(vendors));
    } catch (e) {
      emit(VendorError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> searchVendors(String query) async {
    emit(VendorLoading());
    try {
      final vendors = await _vendorRepository.searchVendors(query);
      emit(VendorsLoaded(vendors));
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
