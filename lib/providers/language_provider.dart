import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported locales in the app
enum AppLocale {
  english(Locale('en'), 'English', 'EN'),
  hindi(Locale('hi'), 'हिंदी', 'HI');

  const AppLocale(this.locale, this.displayName, this.code);

  final Locale locale;
  final String displayName;
  final String code;

  static AppLocale fromCode(String code) {
    return AppLocale.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLocale.english,
    );
  }

  static AppLocale fromLocale(Locale locale) {
    return AppLocale.values.firstWhere(
      (l) => l.locale.languageCode == locale.languageCode,
      orElse: () => AppLocale.english,
    );
  }
}

/// Provider for managing app language/locale
class LanguageProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  AppLocale _currentLocale = AppLocale.english;
  bool _isInitialized = false;

  /// Get the current app locale
  AppLocale get currentLocale => _currentLocale;

  /// Get the current Flutter Locale
  Locale get locale => _currentLocale.locale;

  /// Check if provider is initialized
  bool get isInitialized => _isInitialized;

  /// Check if current locale is English
  bool get isEnglish => _currentLocale == AppLocale.english;

  /// Check if current locale is Hindi
  bool get isHindi => _currentLocale == AppLocale.hindi;

  /// Initialize the provider by loading saved locale
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);

      if (savedLocaleCode != null) {
        _currentLocale = AppLocale.fromCode(savedLocaleCode);
      } else {
        // Default to device locale if available
        final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
        _currentLocale = AppLocale.fromLocale(deviceLocale);
      }
    } catch (e) {
      // Default to English if there's an error
      _currentLocale = AppLocale.english;
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Change the app locale
  Future<void> setLocale(AppLocale newLocale) async {
    if (_currentLocale == newLocale) return;

    _currentLocale = newLocale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.code);
    } catch (e) {
      // Silently fail - the locale change is already applied
    }
  }

  /// Toggle between English and Hindi
  Future<void> toggleLocale() async {
    final newLocale =
        _currentLocale == AppLocale.english ? AppLocale.hindi : AppLocale.english;
    await setLocale(newLocale);
  }

  /// Set locale by language code
  Future<void> setLocaleByCode(String code) async {
    final newLocale = AppLocale.fromCode(code);
    await setLocale(newLocale);
  }

  /// Get list of supported locales
  static List<Locale> get supportedLocales =>
      AppLocale.values.map((l) => l.locale).toList();
}

