import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  group('AppSpacing', () {
    test('has correct values', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 16.0);
      expect(AppSpacing.lg, 24.0);
      expect(AppSpacing.xl, 32.0);
      expect(AppSpacing.xxl, 48.0);
    });

    test('semantic spacing values', () {
      expect(AppSpacing.screenPaddingHorizontal, 16.0);
      expect(AppSpacing.screenPaddingVertical, 24.0);
      expect(AppSpacing.cardPadding, 16.0);
      expect(AppSpacing.listItemSpacing, 8.0);
      expect(AppSpacing.sectionSpacing, 24.0);
    });
  });

  group('AppRadius', () {
    test('radius values are defined', () {
      expect(AppRadius.sm, 8.0);
      expect(AppRadius.md, 12.0);
      expect(AppRadius.lg, 16.0);
      expect(AppRadius.xl, 24.0);
      expect(AppRadius.full, 999.0);
    });

    test('border radius constants are defined', () {
      expect(AppRadius.borderRadiusSm, isNotNull);
      expect(AppRadius.borderRadiusMd, isNotNull);
      expect(AppRadius.borderRadiusLg, isNotNull);
      expect(AppRadius.borderRadiusXl, isNotNull);
      expect(AppRadius.borderRadiusFull, isNotNull);
    });
  });

  group('AppColors', () {
    test('primary color is defined', () {
      expect(AppColors.primary, isNotNull);
    });

    test('secondary color is defined', () {
      expect(AppColors.secondary, isNotNull);
    });

    test('error color is defined', () {
      expect(AppColors.error, isNotNull);
    });

    test('success color is defined', () {
      expect(AppColors.success, isNotNull);
    });

    test('grey scale has values', () {
      expect(AppColors.grey50, isNotNull);
      expect(AppColors.grey100, isNotNull);
      expect(AppColors.grey200, isNotNull);
      expect(AppColors.grey300, isNotNull);
      expect(AppColors.grey400, isNotNull);
      expect(AppColors.grey500, isNotNull);
      expect(AppColors.grey600, isNotNull);
      expect(AppColors.grey700, isNotNull);
      expect(AppColors.grey800, isNotNull);
      expect(AppColors.grey900, isNotNull);
    });

    test('dark mode colors are defined', () {
      expect(AppColors.darkBackground, isNotNull);
      expect(AppColors.darkSurface, isNotNull);
      expect(AppColors.darkCard, isNotNull);
      expect(AppColors.darkText, isNotNull);
    });
  });
}
