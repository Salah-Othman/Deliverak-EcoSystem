import 'package:flutter_test/flutter_test.dart';

import 'package:ui_kit/ui_kit.dart';

void main() {
  test('AppSpacing has correct values', () {
    expect(AppSpacing.xs, 4.0);
    expect(AppSpacing.sm, 8.0);
    expect(AppSpacing.md, 16.0);
    expect(AppSpacing.lg, 24.0);
    expect(AppSpacing.xl, 32.0);
    expect(AppSpacing.xxl, 48.0);
  });
}
