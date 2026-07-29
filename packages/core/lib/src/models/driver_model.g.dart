// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverModel _$DriverModelFromJson(Map<String, dynamic> json) => _DriverModel(
  driverId: json['driverId'] as String? ?? '',
  userId: json['userId'] as String? ?? '',
  vehicleType: json['vehicleType'] as String? ?? '',
  vehicleNumber: json['vehicleNumber'] as String? ?? '',
  licenseNumber: json['licenseNumber'] as String? ?? '',
  isOnline: json['isOnline'] as bool? ?? false,
  currentLat: (json['currentLat'] as num?)?.toDouble() ?? 0.0,
  currentLng: (json['currentLng'] as num?)?.toDouble() ?? 0.0,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  totalDeliveries: (json['totalDeliveries'] as num?)?.toInt() ?? 0,
  createdAt: _driverDateTimeFromJson(json['createdAt'] as String),
);

Map<String, dynamic> _$DriverModelToJson(_DriverModel instance) =>
    <String, dynamic>{
      'driverId': instance.driverId,
      'userId': instance.userId,
      'vehicleType': instance.vehicleType,
      'vehicleNumber': instance.vehicleNumber,
      'licenseNumber': instance.licenseNumber,
      'isOnline': instance.isOnline,
      'currentLat': instance.currentLat,
      'currentLng': instance.currentLng,
      'rating': instance.rating,
      'totalDeliveries': instance.totalDeliveries,
      'createdAt': _driverDateTimeToJson(instance.createdAt),
    };
