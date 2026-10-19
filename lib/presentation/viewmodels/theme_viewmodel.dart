import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls app-wide light/dark/system theme.
/// Persists selection to SharedPreferences.
///
/// MVVM Rule: No setState() — notifyListeners() only.
class ThemeViewModel extends ChangeNotifier {
  ThemeViewModel() {
    _loadTheme();
  }

  static const _key = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isLight => _themeMode == ThemeMode.light;
  bool get isSystem => _themeMode == ThemeMode.system;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    _themeMode = _fromString(stored);
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  Future<void> toggleDarkLight() async {
    await setTheme(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  ThemeMode _fromString(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}
