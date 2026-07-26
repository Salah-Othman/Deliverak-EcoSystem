import 'package:equatable/equatable.dart';

import '../exceptions/app_exception.dart';

class DriverModel extends Equatable {
  final String driverId;
  final String userId;
  final String vehicleType;
  final String vehicleNumber;
  final String licenseNumber;
  final bool isOnline;
  final double currentLat;
  final double currentLng;
  final double rating;
  final int totalDeliveries;
  final DateTime createdAt;

  const DriverModel({
    required this.driverId,
    required this.userId,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.licenseNumber,
    required this.isOnline,
    required this.currentLat,
    required this.currentLng,
    required this.rating,
    required this.totalDeliveries,
    required this.createdAt,
  });

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      driverId: map['driverId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      vehicleType: map['vehicleType'] as String? ?? '',
      vehicleNumber: map['vehicleNumber'] as String? ?? '',
      licenseNumber: map['licenseNumber'] as String? ?? '',
      isOnline: map['isOnline'] as bool? ?? false,
      currentLat: (map['currentLat'] as num?)?.toDouble() ?? 0.0,
      currentLng: (map['currentLng'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalDeliveries: map['totalDeliveries'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'userId': userId,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'licenseNumber': licenseNumber,
      'isOnline': isOnline,
      'currentLat': currentLat,
      'currentLng': currentLng,
      'rating': rating,
      'totalDeliveries': totalDeliveries,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  DriverModel copyWith({
    String? vehicleType,
    String? vehicleNumber,
    String? licenseNumber,
    bool? isOnline,
    double? currentLat,
    double? currentLng,
    double? rating,
    int? totalDeliveries,
  }) {
    return DriverModel(
      driverId: driverId,
      userId: userId,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      isOnline: isOnline ?? this.isOnline,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [driverId, userId, vehicleType, vehicleNumber, licenseNumber, isOnline, currentLat, currentLng, rating, totalDeliveries, createdAt];

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
      throw const ValidationException(message: 'Vehicle number must be 1–20 characters');
    }
    if (licenseNumber.trim().isEmpty || licenseNumber.trim().length > 30) {
      throw const ValidationException(message: 'License number must be 1–30 characters');
    }
  }
}
