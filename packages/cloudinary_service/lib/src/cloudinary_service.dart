import 'dart:io';

import 'package:cloudinary/cloudinary.dart';
import 'package:core/core.dart';

class CloudinaryService implements IStorageService {
  late final Cloudinary _cloudinary;

  CloudinaryService({
    required String cloudName,
    required String uploadPreset,
  }) {
    _cloudinary = Cloudinary.usingEnvironment(
      cloudName: cloudName,
      uploadPreset: uploadPreset,
    );
  }

  @override
  Future<CloudinaryUploadResult> uploadFile({
    required String filePath,
    required String folder,
    Map<String, String>? metadata,
  }) async {
    final file = File(filePath);
    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        folder: folder,
        resourceType: CloudinaryResourceType.image,
      ),
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
    await _cloudinary.deleteFile(publicId);
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
    final transformations = <String>[];

    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (crop != null) transformations.add('c_$crop');
    if (quality != null) transformations.add('q_$quality');
    if (format != null) transformations.add('f_$format');

    return _cloudinary.createUrl(
      publicId: publicId,
      transformation: transformations.isNotEmpty ? transformations.join(',') : null,
    );
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
