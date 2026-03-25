import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tsl/providers/language_provider.dart';
import 'package:tsl/models/shared_models.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('LanguageProvider', () {
    test('initializes with English by default', () async {
      final provider = LanguageProvider();
      await provider.initialize();

      expect(provider.isInitialized, isTrue);
      expect(provider.isEnglish, isTrue);
      expect(provider.locale.languageCode, equals('en'));
    });

    test('toggles between English and Hindi', () async {
      final provider = LanguageProvider();
      await provider.initialize();

      expect(provider.isEnglish, isTrue);

      await provider.toggleLocale();
      expect(provider.isHindi, isTrue);
      expect(provider.locale.languageCode, equals('hi'));

      await provider.toggleLocale();
      expect(provider.isEnglish, isTrue);
      expect(provider.locale.languageCode, equals('en'));
    });

    test('sets locale by code', () async {
      final provider = LanguageProvider();
      await provider.initialize();

      await provider.setLocaleByCode('HI');
      expect(provider.isHindi, isTrue);

      await provider.setLocaleByCode('EN');
      expect(provider.isEnglish, isTrue);
    });

    test('persists language preference', () async {
      final provider = LanguageProvider();
      await provider.initialize();
      await provider.setLocaleByCode('HI');

      // Create a new provider - should load persisted preference
      final provider2 = LanguageProvider();
      await provider2.initialize();
      expect(provider2.isHindi, isTrue);
    });

    test('returns supported locales', () {
      final locales = LanguageProvider.supportedLocales;
      expect(locales.length, equals(2));
      expect(locales.any((l) => l.languageCode == 'en'), isTrue);
      expect(locales.any((l) => l.languageCode == 'hi'), isTrue);
    });

    test('handles invalid locale code gracefully', () async {
      final provider = LanguageProvider();
      await provider.initialize();

      await provider.setLocaleByCode('INVALID');
      // Should fall back to English
      expect(provider.isEnglish, isTrue);
    });
  });

  group('UserRole', () {
    test('has correct display names', () {
      expect(UserRole.mistri.displayName, equals('Mistri'));
      expect(UserRole.dealer.displayName, equals('Dealer'));
      expect(UserRole.architect.displayName, equals('Architect'));
    });

    test('has correct key values', () {
      expect(UserRole.mistri.key, equals('mistri'));
      expect(UserRole.dealer.key, equals('dealer'));
      expect(UserRole.architect.key, equals('architect'));
    });

    test('fromKey returns correct role', () {
      expect(UserRoleExtension.fromKey('mistri'), equals(UserRole.mistri));
      expect(UserRoleExtension.fromKey('dealer'), equals(UserRole.dealer));
      expect(UserRoleExtension.fromKey('architect'), equals(UserRole.architect));
    });

    test('fromKey defaults to mistri for unknown key', () {
      expect(UserRoleExtension.fromKey('unknown'), equals(UserRole.mistri));
    });
  });

  group('AppNotification', () {
    test('creates notification with required fields', () {
      final notification = AppNotification(
        id: 'test_1',
        type: NotificationType.delivery,
        title: 'Test Notification',
        message: 'Test message',
        timestamp: DateTime(2026, 1, 1),
      );

      expect(notification.id, equals('test_1'));
      expect(notification.type, equals(NotificationType.delivery));
      expect(notification.isRead, isFalse);
      expect(notification.deepLink, isNull);
    });

    test('copyWith creates modified copy', () {
      final notification = AppNotification(
        id: 'test_1',
        type: NotificationType.delivery,
        title: 'Test',
        message: 'Message',
        timestamp: DateTime(2026, 1, 1),
        isRead: false,
      );

      final modified = notification.copyWith(isRead: true);
      expect(modified.isRead, isTrue);
      expect(modified.id, equals('test_1')); // unchanged
      expect(modified.title, equals('Test')); // unchanged
    });
  });

  group('AppUserProfile', () {
    test('creates profile with required fields', () {
      final profile = AppUserProfile(
        id: 'user_1',
        name: 'Test User',
        phone: '+91 98765 43210',
        role: UserRole.mistri,
      );

      expect(profile.id, equals('user_1'));
      expect(profile.name, equals('Test User'));
      expect(profile.rewardPoints, equals(0));
      expect(profile.email, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      final profile = AppUserProfile(
        id: 'user_1',
        name: 'Test User',
        phone: '+91 98765 43210',
        role: UserRole.mistri,
        rewardPoints: 100,
      );

      final modified = profile.copyWith(name: 'New Name');
      expect(modified.name, equals('New Name'));
      expect(modified.phone, equals('+91 98765 43210'));
      expect(modified.rewardPoints, equals(100));
    });
  });

  group('AppSettings', () {
    test('mock settings have expected defaults', () {
      final settings = MockSharedData.mockSettings;
      expect(settings.languageCode, isNotEmpty);
      expect(settings.notificationsEnabled, isNotNull);
    });
  });

  group('MockSharedData', () {
    test('provides mock profiles for all roles', () {
      expect(MockSharedData.mockMistriProfile.role, equals(UserRole.mistri));
      expect(MockSharedData.mockDealerProfile.role, equals(UserRole.dealer));
      expect(MockSharedData.mockArchitectProfile.role, equals(UserRole.architect));
    });

    test('provides mock notifications', () {
      final notifications = MockSharedData.mockNotifications;
      expect(notifications, isNotEmpty);
      expect(notifications.every((n) => n.id.isNotEmpty), isTrue);
    });

    test('provides mock chat contacts', () {
      final contacts = MockSharedData.mockChatContacts;
      expect(contacts, isNotEmpty);
    });
  });

  group('NotificationType', () {
    test('has correct display names', () {
      expect(NotificationType.delivery.displayName, isNotEmpty);
      expect(NotificationType.reward.displayName, isNotEmpty);
      expect(NotificationType.order.displayName, isNotEmpty);
    });

    test('has correct icons', () {
      expect(NotificationType.delivery.icon, isNotNull);
      expect(NotificationType.reward.icon, isNotNull);
    });

    test('has distinct colors', () {
      final colors = NotificationType.values.map((t) => t.color).toSet();
      expect(colors.length, equals(NotificationType.values.length));
    });
  });
}

