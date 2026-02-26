import 'package:flutter/material.dart';

import '../storage/user_defaults.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({required ThemeMode initialMode}) : _themeMode = initialMode;

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await UserDefaults.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> toggleLightDark() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
      return;
    }
    await setThemeMode(ThemeMode.dark);
  }
}
