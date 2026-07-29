// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    _CategoryModel(
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      type: $enumDecode(_$DeliveryTypeEnumMap, json['type']),
      sortOrder: (json['sortOrder'] as num).toInt(),
    );

Map<String, dynamic> _$CategoryModelToJson(_CategoryModel instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'name': instance.name,
      'image': instance.image,
      'type': _$DeliveryTypeEnumMap[instance.type]!,
      'sortOrder': instance.sortOrder,
    };

const _$DeliveryTypeEnumMap = {
  DeliveryType.food: 'food',
  DeliveryType.grocery: 'grocery',
  DeliveryType.medicine: 'medicine',
  DeliveryType.package: 'package',
};
