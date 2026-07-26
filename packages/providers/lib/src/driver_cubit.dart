import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

abstract class DriverState extends Equatable {
  const DriverState();

  @override
  List<Object?> get props => [];
}

class DriverInitial extends DriverState {}

class DriverLoading extends DriverState {}

class DriverLoaded extends DriverState {
  final DriverModel driver;

  const DriverLoaded(this.driver);

  @override
  List<Object?> get props => [driver];
}

class DriverNotRegistered extends DriverState {}

class DriverError extends DriverState {
  final String message;
  final bool isRetryable;

  const DriverError({
    required this.message,
    this.isRetryable = false,
  });

  @override
  List<Object?> get props => [message, isRetryable];
}

class DriverCubit extends Cubit<DriverState> {
  final IDriverRepository _driverRepository;
  final IAuthRepository _authRepository;
  StreamSubscription<DriverModel?>? _driverSubscription;

  DriverCubit({
    required IDriverRepository driverRepository,
    required IAuthRepository authRepository,
  })  : _driverRepository = driverRepository,
        _authRepository = authRepository,
        super(DriverInitial());

  @override
  Future<void> close() {
    _driverSubscription?.cancel();
    return super.close();
  }

  Future<void> loadDriver() async {
    emit(DriverLoading());
    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        emit(DriverNotRegistered());
        return;
      }

      final driver = await _driverRepository.getDriverByUserId(user.uid);
      if (driver == null) {
        emit(DriverNotRegistered());
        return;
      }

      emit(DriverLoaded(driver));
    } catch (e) {
      emit(DriverError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  void watchDriver(String driverId) {
    _driverSubscription?.cancel();
    _driverSubscription = _driverRepository.watchDriver(driverId).listen(
      (driver) {
        if (driver != null) {
          emit(DriverLoaded(driver));
        }
      },
      onError: (e) => emit(DriverError(message: mapExceptionToMessage(e))),
    );
  }

  Future<void> registerDriver({
    required String vehicleType,
    required String vehicleNumber,
    required String licenseNumber,
  }) async {
    emit(DriverLoading());
    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        emit(const DriverError(message: 'Not authenticated'));
        return;
      }

      final driver = await _driverRepository.createDriver(
        userId: user.uid,
        vehicleType: vehicleType,
        vehicleNumber: vehicleNumber,
        licenseNumber: licenseNumber,
      );

      emit(DriverLoaded(driver));
    } catch (e) {
      emit(DriverError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> goOnline() async {
    final currentState = state;
    if (currentState is! DriverLoaded) return;

    try {
      await _driverRepository.updateOnlineStatus(
        currentState.driver.driverId,
        true,
      );
    } catch (e) {
      emit(DriverError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> goOffline() async {
    final currentState = state;
    if (currentState is! DriverLoaded) return;

    try {
      await _driverRepository.updateOnlineStatus(
        currentState.driver.driverId,
        false,
      );
    } catch (e) {
      emit(DriverError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }

  Future<void> updateLocation(double lat, double lng) async {
    final currentState = state;
    if (currentState is! DriverLoaded) return;

    try {
      await _driverRepository.updateLocation(
        currentState.driver.driverId,
        lat,
        lng,
      );
    } catch (e) {
      // Silently fail location updates - don't disrupt UX
    }
  }

  Future<void> updateDriverProfile({
    String? vehicleType,
    String? vehicleNumber,
    String? licenseNumber,
  }) async {
    final currentState = state;
    if (currentState is! DriverLoaded) return;

    emit(DriverLoading());
    try {
      await _driverRepository.updateDriverProfile(
        driverId: currentState.driver.driverId,
        vehicleType: vehicleType,
        vehicleNumber: vehicleNumber,
        licenseNumber: licenseNumber,
      );

      final updated = await _driverRepository.getDriver(
        currentState.driver.driverId,
      );

      if (updated != null) {
        emit(DriverLoaded(updated));
      } else {
        emit(const DriverError(message: 'Failed to update profile'));
      }
    } catch (e) {
      emit(DriverError(
        message: mapExceptionToMessage(e),
        isRetryable: isRetryableError(e),
      ));
    }
  }
}
