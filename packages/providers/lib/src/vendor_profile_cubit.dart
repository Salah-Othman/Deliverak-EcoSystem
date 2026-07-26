import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

abstract class VendorProfileState extends Equatable {
  const VendorProfileState();

  @override
  List<Object?> get props => [];
}

class VendorProfileInitial extends VendorProfileState {}

class VendorProfileLoading extends VendorProfileState {}

class VendorProfileLoaded extends VendorProfileState {
  final VendorModel vendor;

  const VendorProfileLoaded(this.vendor);

  @override
  List<Object?> get props => [vendor];
}

class VendorProfileError extends VendorProfileState {
  final String message;
  final bool isRetryable;

  const VendorProfileError({
    required this.message,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, isRetryable];
}

class VendorProfileCubit extends Cubit<VendorProfileState> {
  final IVendorRepository _vendorRepository;
  final IStorageService _storageService;
  StreamSubscription<VendorModel?>? _vendorSubscription;

  VendorProfileCubit({
    required IVendorRepository vendorRepository,
    required IStorageService storageService,
  })  : _vendorRepository = vendorRepository,
        _storageService = storageService,
        super(VendorProfileInitial());

  @override
  Future<void> close() {
    _vendorSubscription?.cancel();
    return super.close();
  }

  Future<void> loadVendorProfile(String vendorId) async {
    emit(VendorProfileLoading());
    try {
      final vendor = await _vendorRepository.getVendor(vendorId);
      if (vendor != null) {
        emit(VendorProfileLoaded(vendor));
      } else {
        emit(const VendorProfileError(message: 'Store profile not found.'));
      }
    } catch (e) {
      emit(VendorProfileError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  void watchVendorProfile(String vendorId) {
    _vendorSubscription?.cancel();
    _vendorSubscription = _vendorRepository.watchVendor(vendorId).listen(
      (vendor) {
        if (vendor != null) {
          emit(VendorProfileLoaded(vendor));
        }
      },
      onError: (e) =>
          emit(VendorProfileError(message: mapExceptionToMessage(e))),
    );
  }

  Future<void> updateVendorProfile(VendorModel vendor) async {
    try {
      await _vendorRepository.updateVendor(vendor);
      emit(VendorProfileLoaded(vendor));
    } catch (e) {
      emit(VendorProfileError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> toggleOpenClose(VendorModel vendor) async {
    try {
      final updated = vendor.copyWith(isOpen: !vendor.isOpen);
      await _vendorRepository.updateVendor(updated);
      emit(VendorProfileLoaded(updated));
    } catch (e) {
      emit(VendorProfileError(
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
      emit(VendorProfileError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
      return null;
    }
  }
}
