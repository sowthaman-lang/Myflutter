import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_strings.dart';

class UserDefaults {
  const UserDefaults._();

  static const MethodChannel _channel = MethodChannel('my_flutter/user_defaults');
  static const _keyToken = 'token';
  static const _keyFcmToken = 'fcm_token';
  static const _keyLanguageCode = 'language_code';
  static const _keyThemeMode = 'theme_mode';
  static const _keyPortalProducts = 'portal_products';

  static final Map<String, String> _cache = <String, String>{};

  static Future<void> init() async {
    _cache[_keyToken] = await _getString(_keyToken) ?? '';
    _cache[_keyFcmToken] = await _getString(_keyFcmToken) ?? '';
    _cache[_keyLanguageCode] =
        await _getString(_keyLanguageCode) ?? AppStrings.languageEnglish;
    _cache[_keyThemeMode] = await _getString(_keyThemeMode) ?? ThemeMode.system.name;
  }

  static String get token => _cache[_keyToken] ?? '';
  static String get fcmToken => _cache[_keyFcmToken] ?? '';

  static Future<void> setToken(String value) async {
    _cache[_keyToken] = value;
    await _setString(_keyToken, value);
  }

  static Future<void> setFcmToken(String value) async {
    _cache[_keyFcmToken] = value;
    await _setString(_keyFcmToken, value);
  }

  static Locale get locale {
    final code = _cache[_keyLanguageCode] ?? AppStrings.languageEnglish;
    return Locale(code);
  }

  static Future<void> setLocale(String code) async {
    _cache[_keyLanguageCode] = code;
    await _setString(_keyLanguageCode, code);
  }

  static ThemeMode get themeMode {
    final value = _cache[_keyThemeMode] ?? ThemeMode.system.name;
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    _cache[_keyThemeMode] = mode.name;
    await _setString(_keyThemeMode, mode.name);
  }

  static Future<String> getPortalProductsJson() async {
    return await _getString(_keyPortalProducts) ?? '';
  }

  static Future<void> setPortalProductsJson(String value) async {
    await _setString(_keyPortalProducts, value);
  }

  static Future<void> clear() async {
    _cache.clear();
    try {
      await _channel.invokeMethod<void>('clear');
    } catch (_) {}
  }

  static Future<String?> _getString(String key) async {
    try {
      final value = await _channel.invokeMethod<String>(
        'getString',
        <String, dynamic>{'key': key},
      );
      return value;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _setString(String key, String value) async {
    try {
      await _channel.invokeMethod<void>(
        'setString',
        <String, dynamic>{'key': key, 'value': value},
      );
    } catch (_) {}
  }
}
