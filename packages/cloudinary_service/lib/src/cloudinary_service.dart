import 'dart:io';

import 'package:cloudinary_url_gen/cloudinary.dart' as url_gen;
import 'package:core/core.dart';

class CloudinaryService implements IStorageService {
  late final Cloudinaryinary _cloudinaryApi;
  late final url_gen.Cloudinary _cloudinaryUrl;

  CloudinaryService({
    required String cloudName,
    required String uploadPreset,
  }) {
    _cloudinaryApi = Cloudinaryinary(
      cloudName: cloudName,
      uploadPreset: uploadPreset,
    );
    _cloudinaryUrl = url_gen.Cloudinary.fromCloudName(
      cloudName: cloudName,
    );
  }

  @override
  Future<CloudinaryUploadResult> uploadFile({
    required String filePath,
    required String folder,
    Map<String, String>? metadata,
  }) async {
    final file = File(filePath);
    final response = await _cloudinaryApi.uploadFile(
      file: file,
      folder: folder,
      resourceType: CloudinaryResourceType.image,
    );

    if (response.isSuccessful) {
      return CloudinaryUploadResult(
        secureUrl: response.secureUrl ?? '',
        publicId: response.publicId ?? '',
        width: response.width,
        height: response.height,
        format: response.format,
      );
    } else {
      throw Exception('Failed to upload image: ${response.error}');
    }
  }

  @override
  Future<void> deleteFile(String publicId) async {
    await _cloudinaryApi.deleteFile(publicId: publicId);
  }

  @override
  String getTransformedUrl({
    required String publicId,
    int? width,
    int? height,
    String? crop,
    int? quality,
    String? format,
  }) {
    var image = _cloudinaryUrl.image(publicId: publicId);

    if (width != null) image = image.resize(width: width);
    if (height != null) image = image.resize(height: height);
    if (crop != null) image = image.resize(crop: url_gen.Crop.values.firstWhere((e) => e.name == crop, orElse: () => url_gen.Crop.fill));
    if (quality != null) image = image.quality(quality: quality);
    if (format != null) image = image.format(url_gen.Format.values.firstWhere((e) => e.name == format, orElse: () => url_gen.Format.auto));

    return image.toString();
  }

  @override
  String getThumbnailUrl(String publicId, {int size = 100}) {
    return getTransformedUrl(
      publicId: publicId,
      width: size,
      height: size,
      crop: 'fill',
      quality: 80,
    );
  }

  @override
  String getMediumUrl(String publicId, {int size = 400}) {
    return getTransformedUrl(
      publicId: publicId,
      width: size,
      height: size,
      crop: 'fill',
      quality: 80,
    );
  }
}
