import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages and persists application ThemeMode (system, light, dark).
class ThemeCubit extends Cubit<ThemeMode> {
  static const String _prefKey = 'smart_muslim_theme_mode';

  ThemeCubit() : super(ThemeMode.system);

  /// Loads the persisted theme mode from SharedPreferences
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_prefKey);
      if (savedMode == 'light') {
        emit(ThemeMode.light);
      } else if (savedMode == 'dark') {
        emit(ThemeMode.dark);
      } else {
        emit(ThemeMode.system);
      }
    } catch (_) {
      emit(ThemeMode.system);
    }
  }

  /// Sets and persists a new ThemeMode
  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      switch (mode) {
        case ThemeMode.light:
          await prefs.setString(_prefKey, 'light');
          break;
        case ThemeMode.dark:
          await prefs.setString(_prefKey, 'dark');
          break;
        case ThemeMode.system:
          await prefs.setString(_prefKey, 'system');
          break;
      }
    } catch (_) {}
  }
}
