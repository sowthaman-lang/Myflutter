import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

class L10nStrings {
  const L10nStrings._();

  static const Map<String, Map<String, String>> values = {
    AppStrings.languageEnglish: {
      'title': 'Flutter Base',
      'welcome': 'Common base architecture is ready.',
      'current_theme': 'Current Theme',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'toggle_theme': 'Toggle Theme',
      'language': 'Language',
      'change_language': 'Change Language',
      'api_calls': 'API Calls',
      'header_call': 'GET with header',
      'without_header_call': 'GET without header',
      'post_header_call': 'POST with header',
      'post_without_header_call': 'POST without header',
      'form_data_call': 'POST form-data',
      'saved_token': 'Saved token',
      'save_token': 'Save token',
      'notifications': 'Notifications',
      'show_local_notification': 'Show local notification',
      'fcm_token': 'FCM token',
      'request_push_token': 'Refresh push token',
      'project_ready': 'Project base is ready. Start building your features.',
    },
    AppStrings.languageHindi: {
      'title': 'फ्लटर बेस',
      'welcome': 'कॉमन बेस आर्किटेक्चर तैयार है।',
      'current_theme': 'मौजूदा थीम',
      'light': 'लाइट',
      'dark': 'डार्क',
      'system': 'सिस्टम',
      'toggle_theme': 'थीम बदलें',
      'language': 'भाषा',
      'change_language': 'भाषा बदलें',
      'api_calls': 'API कॉल्स',
      'header_call': 'हेडर के साथ GET',
      'without_header_call': 'हेडर बिना GET',
      'post_header_call': 'हेडर के साथ POST',
      'post_without_header_call': 'हेडर बिना POST',
      'form_data_call': 'POST फॉर्म-डेटा',
      'saved_token': 'सेव टोकन',
      'save_token': 'टोकन सेव करें',
      'notifications': 'नोटिफिकेशन्स',
      'show_local_notification': 'लोकल नोटिफिकेशन दिखाएँ',
      'fcm_token': 'FCM टोकन',
      'request_push_token': 'पुश टोकन रीफ्रेश करें',
      'project_ready': 'प्रोजेक्ट बेस तैयार है। अब अपनी फीचर्स बनाना शुरू करें।',
    },
  };

  static String get(BuildContext context, String key, Locale locale) {
    final languageMap = values[locale.languageCode] ?? values[AppStrings.languageEnglish]!;
    return languageMap[key] ?? key;
  }
}
