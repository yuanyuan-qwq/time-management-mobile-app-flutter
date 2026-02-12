import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../data/database.dart';
import '../screens/today_tasks_screen.dart' show database;

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  // Singleton pattern
  static final ThemeNotifier _instance = ThemeNotifier._internal();

  factory ThemeNotifier() {
    return _instance;
  }

  ThemeNotifier._internal() : super(ThemeMode.system);

  /// Load theme preference from database
  Future<void> loadTheme() async {
    final settings = await database.getSettings();
    final modeIndex = settings.themeMode;
    value = _modeFromInt(modeIndex);
  }

  /// Update theme and save to database
  Future<void> setTheme(ThemeMode mode) async {
    if (value == mode) return;

    value = mode;

    // Save to DB
    final modeIndex = _intFromMode(mode);
    await database.updateSettings(
      AppSettingsCompanion(themeMode: drift.Value(modeIndex)),
    );
  }

  ThemeMode _modeFromInt(int index) {
    switch (index) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      case 0:
      default:
        return ThemeMode.system;
    }
  }

  int _intFromMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }
}
