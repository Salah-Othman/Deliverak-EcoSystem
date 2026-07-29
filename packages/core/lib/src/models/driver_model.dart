import 'package:freezed_annotation/freezed_annotation.dart';

import '../exceptions/app_exception.dart';

part 'driver_model.freezed.dart';
part 'driver_model.g.dart';

DateTime _driverDateTimeFromJson(String value) => DateTime.parse(value);
String _driverDateTimeToJson(DateTime value) => value.toIso8601String();

@freezed
abstract class DriverModel with _$DriverModel {
  const factory DriverModel({
    @Default('') String driverId,
    @Default('') String userId,
    @Default('') String vehicleType,
    @Default('') String vehicleNumber,
    @Default('') String licenseNumber,
    @Default(false) bool isOnline,
    @Default(0.0) double currentLat,
    @Default(0.0) double currentLng,
    @Default(0.0) double rating,
    @Default(0) int totalDeliveries,
    @JsonKey(toJson: _driverDateTimeToJson, fromJson: _driverDateTimeFromJson)
    required DateTime createdAt,
  }) = _DriverModel;

  const DriverModel._();

  factory DriverModel.fromJson(Map<String, dynamic> json) =>
      _$DriverModelFromJson(json);

  static DriverModel fromMap(Map<String, dynamic> map) {
    return DriverModel.fromJson({
      'createdAt': DateTime.now().toIso8601String(),
      ...map,
    });
  }

  Map<String, dynamic> toMap() => toJson();

  void validate() {
    if (driverId.trim().isEmpty) {
      throw const ValidationException(message: 'Driver ID is required');
    }
    if (userId.trim().isEmpty) {
      throw const ValidationException(message: 'User ID is required');
    }
    if (vehicleType.trim().isEmpty) {
      throw const ValidationException(message: 'Vehicle type is required');
    }
    if (vehicleNumber.trim().isEmpty || vehicleNumber.trim().length > 20) {
      throw const ValidationException(
        message: 'Vehicle number must be 1–20 characters',
      );
    }
    if (licenseNumber.trim().isEmpty || licenseNumber.trim().length > 30) {
      throw const ValidationException(
        message: 'License number must be 1–30 characters',
      );
    }
  }
}
