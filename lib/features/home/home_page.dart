import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/theme/theme_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.themeController,
    required this.localeController,
  });

  final ThemeController themeController;
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('title')),
      ),
      body: Center(
        child: Text(
          l10n.tr('project_ready'),
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
