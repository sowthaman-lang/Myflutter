import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/user_defaults.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/login_page.dart';

class AppBootstrap {
  static Future<Widget> initialize() async {
    await UserDefaults.init();
    await NotificationService.instance.initialize();
    final controller = ThemeController(
      initialMode: UserDefaults.themeMode,
    );
    final localeController = LocaleController(initialLocale: UserDefaults.locale);
    return MyApp(
      themeController: controller,
      localeController: localeController,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.themeController,
    required this.localeController,
  });

  final ThemeController themeController;
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeController, localeController]),
      builder: (_, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: LoginPage(
            themeController: themeController,
            localeController: localeController,
          ),
        );
      },
    );
  }
}
