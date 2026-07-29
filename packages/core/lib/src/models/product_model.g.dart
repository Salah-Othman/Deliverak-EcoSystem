// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductModel _$ProductModelFromJson(Map<String, dynamic> json) =>
    _ProductModel(
      productId: json['productId'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      category: json['category'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      createdAt: _productDateTimeFromJson(json['createdAt'] as String),
    );

Map<String, dynamic> _$ProductModelToJson(_ProductModel instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'vendorId': instance.vendorId,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'discountPrice': instance.discountPrice,
      'images': instance.images,
      'category': instance.category,
      'isAvailable': instance.isAvailable,
      'createdAt': _productDateTimeToJson(instance.createdAt),
    };
