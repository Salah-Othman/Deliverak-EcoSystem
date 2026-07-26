import 'package:flutter_test/flutter_test.dart';

import 'package:cloudinary_service/cloudinary_service.dart';

void main() {
  test('CloudinaryService can be instantiated', () {
    expect(
      () => CloudinaryService(cloudName: 'test', uploadPreset: 'test'),
      returnsNormally,
    );
  });
}
