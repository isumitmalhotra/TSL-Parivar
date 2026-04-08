import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'design_system/design_system.dart';
import 'l10n/app_localizations.dart';
import 'navigation/app_router.dart';
import 'providers/app_settings_provider.dart';
import 'providers/language_provider.dart';

/// The main application widget for TSL Parivar
class TslApp extends StatelessWidget {
  const TslApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, AppSettingsProvider>(
      builder: (context, languageProvider, appSettingsProvider, child) {
        return MaterialApp.router(
          title: 'TSL Parivar',
          debugShowCheckedModeBanner: false,

          // Router configuration
          routerConfig: AppRouter.router,

          // Theme configuration
          theme: AppTheme.light,
          themeMode: ThemeMode.light,

          // Accessibility: Clamp text scaling to prevent layout breakage
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: AppAccessibility.clampedTextScaler(context),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },

          // Localization configuration
          locale: languageProvider.locale,
          supportedLocales: LanguageProvider.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}

