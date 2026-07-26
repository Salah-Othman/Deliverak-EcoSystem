import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  group('AppTheme', () {
    test('lightTheme is not null', () {
      expect(AppTheme.lightTheme, isNotNull);
    });

    test('darkTheme is not null', () {
      expect(AppTheme.darkTheme, isNotNull);
    });

    test('lightTheme uses Material 3', () {
      expect(AppTheme.lightTheme.useMaterial3, true);
    });

    test('darkTheme uses Material 3', () {
      expect(AppTheme.darkTheme.useMaterial3, true);
    });

    test('lightTheme has light brightness', () {
      expect(AppTheme.lightTheme.brightness, Brightness.light);
    });

    test('darkTheme has dark brightness', () {
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });
  });
}
