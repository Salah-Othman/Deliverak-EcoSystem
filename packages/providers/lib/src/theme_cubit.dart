import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';

enum AppThemeMode { light, dark, system }

class ThemeState extends Equatable {
  final AppThemeMode themeMode;

  const ThemeState({this.themeMode = AppThemeMode.system});

  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  @override
  List<Object?> get props => [themeMode];
}

class ThemeCubit extends Cubit<ThemeState> {
  final ISecureStorageService _secureStorage;
  static const String _key = 'theme_mode';

  ThemeCubit({required ISecureStorageService secureStorage})
      : _secureStorage = secureStorage,
        super(const ThemeState());

  Future<void> loadTheme() async {
    final saved = await _secureStorage.read(key: _key);
    if (saved != null) {
      final mode = AppThemeMode.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => AppThemeMode.system,
      );
      emit(ThemeState(themeMode: mode));
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    emit(ThemeState(themeMode: mode));
    await _secureStorage.write(key: _key, value: mode.name);
  }
}
