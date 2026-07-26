import 'package:flutter_test/flutter_test.dart';

import 'package:providers/providers.dart';

void main() {
  test('providers barrel exports', () {
    expect(AuthCubit, isNotNull);
  });
}
