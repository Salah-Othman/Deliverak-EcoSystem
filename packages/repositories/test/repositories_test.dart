import 'package:flutter_test/flutter_test.dart';

import 'package:repositories/repositories.dart';

void main() {
  test('repositories barrel exports', () {
    expect(AuthRepository, isNotNull);
  });
}
