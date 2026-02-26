import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../storage/user_defaults.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({Locale? initialLocale})
      : _locale = initialLocale ?? const Locale(AppStrings.languageEnglish);

  Locale _locale;

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await UserDefaults.setLocale(locale.languageCode);
    notifyListeners();
  }
}
