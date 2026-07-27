import 'package:flutter/material.dart';

abstract class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double screenPaddingHorizontal = 16.0;
  static const double screenPaddingVertical = 24.0;
  static const double screenPaddingHorizontalTablet = 32.0;
  static const double screenPaddingVerticalTablet = 32.0;
  static const double cardPadding = 16.0;
  static const double listItemSpacing = 8.0;
  static const double sectionSpacing = 24.0;

  static double responsiveHorizontal(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return screenPaddingHorizontalTablet;
    if (width >= 600) return 24.0;
    return screenPaddingHorizontal;
  }

  static double responsiveVertical(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 600) return screenPaddingVerticalTablet;
    return screenPaddingVertical;
  }

  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: responsiveHorizontal(context),
      vertical: responsiveVertical(context),
    );
  }
}

abstract class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(full));
}
