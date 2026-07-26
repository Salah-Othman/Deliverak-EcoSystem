import 'package:flutter_test/flutter_test.dart';

import 'package:core/core.dart';

void main() {
  test('UserRole enum has expected values', () {
    expect(UserRole.values, contains(UserRole.customer));
    expect(UserRole.values, contains(UserRole.driver));
    expect(UserRole.values, contains(UserRole.vendor));
    expect(UserRole.values, contains(UserRole.admin));
  });
}
