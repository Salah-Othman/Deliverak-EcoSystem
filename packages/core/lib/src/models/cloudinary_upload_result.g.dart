// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloudinary_upload_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CloudinaryUploadResult _$CloudinaryUploadResultFromJson(
  Map<String, dynamic> json,
) => _CloudinaryUploadResult(
  secureUrl: json['secureUrl'] as String,
  publicId: json['publicId'] as String,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  format: json['format'] as String?,
);

Map<String, dynamic> _$CloudinaryUploadResultToJson(
  _CloudinaryUploadResult instance,
) => <String, dynamic>{
  'secureUrl': instance.secureUrl,
  'publicId': instance.publicId,
  'width': instance.width,
  'height': instance.height,
  'format': instance.format,
};
