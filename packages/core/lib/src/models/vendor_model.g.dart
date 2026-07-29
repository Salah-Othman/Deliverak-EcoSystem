// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VendorModel _$VendorModelFromJson(Map<String, dynamic> json) => _VendorModel(
  vendorId: json['vendorId'] as String? ?? '',
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  image: json['image'] as String? ?? '',
  category: json['category'] == null
      ? DeliveryType.food
      : _deliveryTypeFromJson(json['category'] as String),
  lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
  lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
  address: json['address'] as String? ?? '',
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
  isOpen: json['isOpen'] as bool? ?? false,
  ownerId: json['ownerId'] as String? ?? '',
  createdAt: _vendorDateTimeFromJson(json['createdAt'] as String),
);

Map<String, dynamic> _$VendorModelToJson(_VendorModel instance) =>
    <String, dynamic>{
      'vendorId': instance.vendorId,
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
      'category': _deliveryTypeToJson(instance.category),
      'lat': instance.lat,
      'lng': instance.lng,
      'address': instance.address,
      'rating': instance.rating,
      'totalOrders': instance.totalOrders,
      'isOpen': instance.isOpen,
      'ownerId': instance.ownerId,
      'createdAt': _vendorDateTimeToJson(instance.createdAt),
    };
