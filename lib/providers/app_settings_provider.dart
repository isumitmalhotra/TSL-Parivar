import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/shared_models.dart';
import '../services/firestore_service.dart';

/// Persists user app settings locally and mirrors them to Firestore when possible.
class AppSettingsProvider extends ChangeNotifier {
  static const String _settingsPrefix = 'app_settings_v1';

  AppSettings _settings = const AppSettings();
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _userId;

  AppSettings get settings => _settings;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  Future<void> syncAuthState({
    required bool isAuthenticated,
    String? userId,
  }) async {
    final nextUserId = isAuthenticated ? userId : null;
    if (_isInitialized && _userId == nextUserId) {
      return;
    }

    _userId = nextUserId;
    _isLoading = true;
    notifyListeners();

    await _loadFromLocal();

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLanguageCode(String languageCode) async {
    await _update(_settings.copyWith(languageCode: languageCode));
  }

  Future<void> setNotificationsEnabled({required bool enabled}) async {
    await _update(_settings.copyWith(notificationsEnabled: enabled));
  }

  Future<void> setDarkModeEnabled({required bool enabled}) async {
    await _update(_settings.copyWith(darkModeEnabled: false));
  }

  Future<void> setBiometricEnabled({required bool enabled}) async {
    await _update(_settings.copyWith(biometricEnabled: enabled));
  }

  Future<void> _update(AppSettings nextSettings) async {
    _settings = nextSettings;
    notifyListeners();

    await _saveToLocal();
    await _saveToFirestore();
  }

  String _storageKeyForCurrentUser() {
    if (_userId == null || _userId!.isEmpty) {
      return '${_settingsPrefix}_guest';
    }
    return '${_settingsPrefix}_${_userId!}';
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKeyForCurrentUser());

    if (raw == null || raw.isEmpty) {
      _settings = const AppSettings();
      return;
    }

    final parts = raw.split('|');
    if (parts.length != 6) {
      _settings = const AppSettings();
      return;
    }

    _settings = AppSettings(
      languageCode: parts[0],
      notificationsEnabled: parts[1] == '1',
      soundEnabled: parts[2] == '1',
      vibrationEnabled: parts[3] == '1',
      darkModeEnabled: false,
      biometricEnabled: parts[5] == '1',
    );
  }

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = [
      _settings.languageCode,
      _settings.notificationsEnabled ? '1' : '0',
      _settings.soundEnabled ? '1' : '0',
      _settings.vibrationEnabled ? '1' : '0',
      '0',
      _settings.biometricEnabled ? '1' : '0',
    ].join('|');

    await prefs.setString(_storageKeyForCurrentUser(), raw);
  }

  Future<void> _saveToFirestore() async {
    if (_userId == null || _userId!.isEmpty) {
      return;
    }

    try {
      await FirestoreService.saveUserProfile(
        uid: _userId!,
        data: {
          'settings': {
            'languageCode': _settings.languageCode,
            'notificationsEnabled': _settings.notificationsEnabled,
            'soundEnabled': _settings.soundEnabled,
            'vibrationEnabled': _settings.vibrationEnabled,
            'darkModeEnabled': false,
            'biometricEnabled': _settings.biometricEnabled,
          },
        },
      );
    } catch (e) {
      debugPrint('Warning: Unable to persist app settings to Firestore: $e');
    }
  }
}



