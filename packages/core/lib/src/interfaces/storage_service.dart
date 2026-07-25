import 'package:core/src/models/cloudinary_upload_result.dart';

abstract class IStorageService {
  Future<CloudinaryUploadResult> uploadFile({
    required String filePath,
    required String folder,
    Map<String, String>? metadata,
  });

  Future<void> deleteFile(String publicId);

  String getTransformedUrl({
    required String publicId,
    int? width,
    int? height,
    String? crop,
    int? quality,
    String? format,
  });

  String getThumbnailUrl(String publicId, {int size = 100});

  String getMediumUrl(String publicId, {int size = 400});
}
