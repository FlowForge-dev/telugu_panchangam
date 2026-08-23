import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's light/dark/system theme preference.
class ThemeController extends ChangeNotifier {
  static const _kKey = 'theme_mode_preference';

  ThemeMode mode = ThemeMode.system;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kKey);
    mode = ThemeMode.values.firstWhere((m) => m.name == stored, orElse: () => ThemeMode.system);
    notifyListeners();
  }

  Future<void> setMode(ThemeMode newMode) async {
    mode = newMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, newMode.name);
  }
}
