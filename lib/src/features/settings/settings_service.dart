import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError(); 
});

class SettingsService {
  SettingsService(this._prefs);
  final SharedPreferences _prefs;
  static const _themeModeKey = 'themeMode';
  ThemeMode getThemeMode() {
    final themeModeString = _prefs.getString(_themeModeKey);
    if (themeModeString == 'dark') {
      return ThemeMode.dark;
    }
    return ThemeMode.light; 
  }
  Future<void> setThemeMode(ThemeMode themeMode) async {
    String themeModeString;
    switch (themeMode) {
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.light:
      case ThemeMode.system: 
        themeModeString = 'light';
        break;
    }
    await _prefs.setString(_themeModeKey, themeModeString);
  }
}
