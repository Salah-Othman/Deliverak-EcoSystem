import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:providers/providers.dart';

import '../helpers/mock_repositories.dart';

void main() {
  late MockSecureStorageService mockSecureStorage;
  late ThemeCubit cubit;

  setUp(() {
    mockSecureStorage = MockSecureStorageService();
    cubit = ThemeCubit(secureStorage: mockSecureStorage);
  });

  tearDown(() {
    cubit.close();
  });

  group('ThemeCubit', () {
    test('initial state is ThemeState with system mode', () {
      expect(cubit.state, const ThemeState(themeMode: AppThemeMode.system));
    });

    group('flutterThemeMode getter', () {
      test('maps light to ThemeMode.light', () {
        expect(
          const ThemeState(themeMode: AppThemeMode.light).flutterThemeMode,
          ThemeMode.light,
        );
      });

      test('maps dark to ThemeMode.dark', () {
        expect(
          const ThemeState(themeMode: AppThemeMode.dark).flutterThemeMode,
          ThemeMode.dark,
        );
      });

      test('maps system to ThemeMode.system', () {
        expect(
          const ThemeState(themeMode: AppThemeMode.system).flutterThemeMode,
          ThemeMode.system,
        );
      });
    });

    group('loadTheme', () {
      blocTest<ThemeCubit, ThemeState>(
        'emits light when saved value is "light"',
        build: () {
          when(() => mockSecureStorage.read(key: 'theme_mode'))
              .thenAnswer((_) async => 'light');
          return ThemeCubit(secureStorage: mockSecureStorage);
        },
        act: (cubit) => cubit.loadTheme(),
        expect: () => [
          const ThemeState(themeMode: AppThemeMode.light),
        ],
        verify: (_) {
          verify(() => mockSecureStorage.read(key: 'theme_mode')).called(1);
        },
      );

      blocTest<ThemeCubit, ThemeState>(
        'emits dark when saved value is "dark"',
        build: () {
          when(() => mockSecureStorage.read(key: 'theme_mode'))
              .thenAnswer((_) async => 'dark');
          return ThemeCubit(secureStorage: mockSecureStorage);
        },
        act: (cubit) => cubit.loadTheme(),
        expect: () => [
          const ThemeState(themeMode: AppThemeMode.dark),
        ],
      );

      blocTest<ThemeCubit, ThemeState>(
        'stays system when saved value is "system"',
        build: () {
          when(() => mockSecureStorage.read(key: 'theme_mode'))
              .thenAnswer((_) async => 'system');
          return ThemeCubit(secureStorage: mockSecureStorage);
        },
        act: (cubit) => cubit.loadTheme(),
        expect: () => [
          const ThemeState(themeMode: AppThemeMode.system),
        ],
      );

      blocTest<ThemeCubit, ThemeState>(
        'stays system when saved value is null',
        build: () {
          when(() => mockSecureStorage.read(key: 'theme_mode'))
              .thenAnswer((_) async => null);
          return ThemeCubit(secureStorage: mockSecureStorage);
        },
        act: (cubit) => cubit.loadTheme(),
        expect: () => <ThemeState>[],
      );

      blocTest<ThemeCubit, ThemeState>(
        'falls back to system for unknown saved value',
        build: () {
          when(() => mockSecureStorage.read(key: 'theme_mode'))
              .thenAnswer((_) async => 'invalid_value');
          return ThemeCubit(secureStorage: mockSecureStorage);
        },
        act: (cubit) => cubit.loadTheme(),
        expect: () => [
          const ThemeState(themeMode: AppThemeMode.system),
        ],
      );
    });

    group('setThemeMode', () {
      blocTest<ThemeCubit, ThemeState>(
        'emits light and persists',
        build: () {
          when(() => mockSecureStorage.write(
                key: 'theme_mode',
                value: 'light',
              )).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.setThemeMode(AppThemeMode.light),
        expect: () => [
          const ThemeState(themeMode: AppThemeMode.light),
        ],
        verify: (_) {
          verify(() => mockSecureStorage.write(
                key: 'theme_mode',
                value: 'light',
              )).called(1);
        },
      );

      blocTest<ThemeCubit, ThemeState>(
        'emits dark and persists',
        build: () {
          when(() => mockSecureStorage.write(
                key: 'theme_mode',
                value: 'dark',
              )).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.setThemeMode(AppThemeMode.dark),
        expect: () => [
          const ThemeState(themeMode: AppThemeMode.dark),
        ],
        verify: (_) {
          verify(() => mockSecureStorage.write(
                key: 'theme_mode',
                value: 'dark',
              )).called(1);
        },
      );

      blocTest<ThemeCubit, ThemeState>(
        'emits system and persists',
        build: () {
          when(() => mockSecureStorage.write(
                key: 'theme_mode',
                value: 'system',
              )).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.setThemeMode(AppThemeMode.system),
        expect: () => [
          const ThemeState(themeMode: AppThemeMode.system),
        ],
        verify: (_) {
          verify(() => mockSecureStorage.write(
                key: 'theme_mode',
                value: 'system',
              )).called(1);
        },
      );

      blocTest<ThemeCubit, ThemeState>(
        'persists before emit completes',
        build: () {
          when(() => mockSecureStorage.write(
                key: any(named: 'key'),
                value: any(named: 'value'),
              )).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.setThemeMode(AppThemeMode.dark),
        verify: (_) {
          verify(() => mockSecureStorage.write(
                key: 'theme_mode',
                value: 'dark',
              )).called(1);
        },
      );
    });
  });
}
