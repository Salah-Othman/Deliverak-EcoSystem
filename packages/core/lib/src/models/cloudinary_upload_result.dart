class CloudinaryUploadResult {
  final String secureUrl;
  final String publicId;
  final int? width;
  final int? height;
  final String? format;

  const CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
    this.width,
    this.height,
    this.format,
  });
}
