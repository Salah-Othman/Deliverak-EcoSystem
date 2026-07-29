import 'package:freezed_annotation/freezed_annotation.dart';

part 'cloudinary_upload_result.freezed.dart';
part 'cloudinary_upload_result.g.dart';

@freezed
abstract class CloudinaryUploadResult with _$CloudinaryUploadResult {
  const factory CloudinaryUploadResult({
    required String secureUrl,
    required String publicId,
    int? width,
    int? height,
    String? format,
  }) = _CloudinaryUploadResult;

  const CloudinaryUploadResult._();

  factory CloudinaryUploadResult.fromJson(Map<String, dynamic> json) =>
      _$CloudinaryUploadResultFromJson(json);

  static CloudinaryUploadResult fromMap(Map<String, dynamic> map) =>
      CloudinaryUploadResult.fromJson(map);

  Map<String, dynamic> toMap() => toJson();
}
