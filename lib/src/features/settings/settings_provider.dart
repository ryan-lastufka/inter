import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inter/src/features/settings/settings_service.dart';

class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.light});
  final ThemeMode themeMode;
  AppSettings copyWith({ThemeMode? themeMode}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  late final SettingsService _settingsService;

  @override
  AppSettings build() {
    _settingsService = ref.watch(settingsServiceProvider);
    return AppSettings(themeMode: _settingsService.getThemeMode());
  }
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _settingsService.setThemeMode(themeMode);
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);
