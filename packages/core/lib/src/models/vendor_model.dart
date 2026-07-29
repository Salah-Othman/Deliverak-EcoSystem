import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/delivery_type.dart';
import '../exceptions/app_exception.dart';

part 'vendor_model.freezed.dart';
part 'vendor_model.g.dart';

DateTime _vendorDateTimeFromJson(String value) => DateTime.parse(value);
String _vendorDateTimeToJson(DateTime value) => value.toIso8601String();

DeliveryType _deliveryTypeFromJson(String value) =>
    DeliveryType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DeliveryType.food,
    );

String _deliveryTypeToJson(DeliveryType type) => type.name;

@Freezed(copyWith: false)
abstract class VendorModel with _$VendorModel {
  const factory VendorModel({
    @Default('') String vendorId,
    @Default('') String name,
    @Default('') String description,
    @Default('') String image,
    @JsonKey(toJson: _deliveryTypeToJson, fromJson: _deliveryTypeFromJson)
    @Default(DeliveryType.food) DeliveryType category,
    @Default(0.0) double lat,
    @Default(0.0) double lng,
    @Default('') String address,
    @Default(0.0) double rating,
    @Default(0) int totalOrders,
    @Default(false) bool isOpen,
    @Default('') String ownerId,
    @JsonKey(toJson: _vendorDateTimeToJson, fromJson: _vendorDateTimeFromJson)
    required DateTime createdAt,
  }) = _VendorModel;

  const VendorModel._();

  factory VendorModel.fromJson(Map<String, dynamic> json) =>
      _$VendorModelFromJson(json);

  factory VendorModel.fromMap(Map<String, dynamic> map) {
    return VendorModel.fromJson({
      'createdAt': DateTime.now().toIso8601String(),
      ...map,
    });
  }

  Map<String, dynamic> toMap() => toJson();

  VendorModel copyWith({
    String? name,
    String? description,
    String? image,
    DeliveryType? category,
    double? lat,
    double? lng,
    String? address,
    double? rating,
    int? totalOrders,
    bool? isOpen,
  }) {
    return VendorModel(
      vendorId: vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      isOpen: isOpen ?? this.isOpen,
      ownerId: ownerId,
      createdAt: createdAt,
    );
  }

  void validate() {
    if (vendorId.trim().isEmpty) {
      throw const ValidationException(message: 'Vendor ID is required');
    }
    if (name.trim().isEmpty || name.trim().length > 100) {
      throw const ValidationException(message: 'Vendor name must be 1–100 characters');
    }
    if (description.trim().length > 1000) {
      throw const ValidationException(message: 'Description must be 1000 characters or less');
    }
    if (image.trim().isEmpty) {
      throw const ValidationException(message: 'Vendor image is required');
    }
    if (lat < -90 || lat > 90) {
      throw const ValidationException(message: 'Latitude must be between -90 and 90');
    }
    if (lng < -180 || lng > 180) {
      throw const ValidationException(message: 'Longitude must be between -180 and 180');
    }
    if (address.trim().isEmpty || address.trim().length > 200) {
      throw const ValidationException(message: 'Address must be 1–200 characters');
    }
    if (ownerId.trim().isEmpty) {
      throw const ValidationException(message: 'Owner ID is required');
    }
  }
}
