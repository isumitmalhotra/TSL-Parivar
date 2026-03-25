import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tsl/design_system/app_accessibility.dart';
import 'package:tsl/services/cache_service.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Debouncer', () {
    test('runs callback after delay', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      int callCount = 0;

      debouncer.run(() => callCount++);

      // Not called immediately
      expect(callCount, equals(0));

      // Wait for debounce
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(callCount, equals(1));

      debouncer.dispose();
    });

    test('cancels previous call when run again', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      int callCount = 0;

      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Only the last call should execute
      expect(callCount, equals(1));

      debouncer.dispose();
    });

    test('cancel prevents execution', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      int callCount = 0;

      debouncer.run(() => callCount++);
      debouncer.cancel();

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(callCount, equals(0));

      debouncer.dispose();
    });

    test('dispose cleans up timer', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      int callCount = 0;

      debouncer.run(() => callCount++);
      debouncer.dispose();

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(callCount, equals(0));
    });
  });

  group('CacheService - In-Memory', () {
    setUp(() async {
      await CacheService.clearAll();
    });

    test('stores and retrieves data from memory', () {
      CacheService.putInMemory<String>('test_key', 'test_value');
      final result = CacheService.getFromMemory<String>('test_key');
      expect(result, equals('test_value'));
    });

    test('returns null for missing key', () {
      final result = CacheService.getFromMemory<String>('nonexistent');
      expect(result, isNull);
    });

    test('respects TTL expiration', () async {
      CacheService.putInMemory<String>(
        'expire_key',
        'value',
        ttl: const Duration(milliseconds: 50),
      );

      expect(CacheService.getFromMemory<String>('expire_key'), equals('value'));

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(CacheService.getFromMemory<String>('expire_key'), isNull);
    });

    test('invalidates by key', () async {
      CacheService.putInMemory<String>('key1', 'value1');
      CacheService.putInMemory<String>('key2', 'value2');

      await CacheService.invalidate('key1');

      expect(CacheService.getFromMemory<String>('key1'), isNull);
      expect(CacheService.getFromMemory<String>('key2'), equals('value2'));
    });

    test('invalidates by prefix', () async {
      CacheService.putInMemory<String>('user_1', 'value1');
      CacheService.putInMemory<String>('user_2', 'value2');
      CacheService.putInMemory<String>('order_1', 'value3');

      await CacheService.invalidateByPrefix('user_');

      expect(CacheService.getFromMemory<String>('user_1'), isNull);
      expect(CacheService.getFromMemory<String>('user_2'), isNull);
      expect(CacheService.getFromMemory<String>('order_1'), equals('value3'));
    });

    test('clears all cache', () async {
      CacheService.putInMemory<String>('key1', 'value1');
      CacheService.putInMemory<String>('key2', 'value2');

      await CacheService.clearAll();

      expect(CacheService.getFromMemory<String>('key1'), isNull);
      expect(CacheService.getFromMemory<String>('key2'), isNull);
    });

    test('returns correct stats', () {
      CacheService.putInMemory<String>('key1', 'value1');
      CacheService.putInMemory<String>('key2', 'value2');

      final stats = CacheService.getStats();
      expect(stats['memoryEntries'], equals(2));
      expect(stats['maxEntries'], equals(CacheService.maxMemoryCacheEntries));
    });

    test('cleans up expired entries', () async {
      CacheService.putInMemory<String>(
        'expire1',
        'value1',
        ttl: const Duration(milliseconds: 50),
      );
      CacheService.putInMemory<String>(
        'keep1',
        'value2',
        ttl: const Duration(hours: 1),
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      CacheService.cleanupExpired();

      expect(CacheService.getFromMemory<String>('expire1'), isNull);
      expect(CacheService.getFromMemory<String>('keep1'), equals('value2'));
    });
  });

  group('CacheService - Disk', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await CacheService.clearAll();
    });

    test('stores and retrieves data from disk', () async {
      await CacheService.putOnDisk<String>(
        'disk_key',
        'disk_value',
        toJsonFn: (v) => v,
      );

      final result = await CacheService.getFromDisk<String>(
        'disk_key',
        (json) => json as String,
      );

      expect(result, equals('disk_value'));
    });

    test('returns null for missing disk key', () async {
      final result = await CacheService.getFromDisk<String>(
        'nonexistent',
        (json) => json as String,
      );

      expect(result, isNull);
    });
  });

  group('CacheKeys', () {
    test('has all expected keys defined', () {
      expect(CacheKeys.userProfile, isNotEmpty);
      expect(CacheKeys.products, isNotEmpty);
      expect(CacheKeys.deliveries, isNotEmpty);
      expect(CacheKeys.orders, isNotEmpty);
      expect(CacheKeys.notifications, isNotEmpty);
      expect(CacheKeys.dealers, isNotEmpty);
      expect(CacheKeys.mistris, isNotEmpty);
      expect(CacheKeys.rewards, isNotEmpty);
      expect(CacheKeys.projects, isNotEmpty);
      expect(CacheKeys.specifications, isNotEmpty);
    });
  });
}

