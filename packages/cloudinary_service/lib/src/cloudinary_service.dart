import 'package:cloudinary/cloudinary.dart';
import 'package:cloudinary_url_gen/cloudinary.dart' as url_gen;
import 'package:cloudinary_url_gen/transformation/delivery/delivery.dart';
import 'package:cloudinary_url_gen/transformation/resize/resize.dart';
import 'package:cloudinary_url_gen/transformation/transformation.dart';
import 'package:core/core.dart';

class CloudinaryService implements IStorageService {
  late final Cloudinary _cloudinary;
  late final url_gen.Cloudinary _cloudinaryUrl;
  final String _uploadPreset;

  CloudinaryService({
    required String cloudName,
    required String uploadPreset,
  }) : _uploadPreset = uploadPreset {
    _cloudinary = Cloudinary.unsignedConfig(cloudName: cloudName);
    _cloudinaryUrl = url_gen.Cloudinary.fromCloudName(cloudName: cloudName);
  }

  @override
  Future<CloudinaryUploadResult> uploadFile({
    required String filePath,
    required String folder,
    Map<String, String>? metadata,
  }) async {
    final response = await _cloudinary.unsignedUpload(
      file: filePath,
      uploadPreset: _uploadPreset,
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
    await _cloudinary.destroy(publicId);
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
    final t = Transformation();

    if (width != null || height != null) {
      t.resize(
        Resize.fill()
          ..width(width)
          ..height(height),
      );
    }

    if (quality != null) {
      t.delivery(Delivery.quality(quality));
    }

    if (format != null) {
      t.delivery(Delivery.format(format));
    }

    return _cloudinaryUrl
        .image(publicId)
        .transformation(t)
        .toString();
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
