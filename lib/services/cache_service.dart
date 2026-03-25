import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache entry with expiration
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;

  const CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;

  Map<String, dynamic> toJson(dynamic Function(T) toJsonFn) => {
        'data': toJsonFn(data),
        'timestamp': timestamp.toIso8601String(),
        'ttlMs': ttl.inMilliseconds,
      };

  static CacheEntry<T>? fromJson<T>(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonFn,
  ) {
    try {
      return CacheEntry<T>(
        data: fromJsonFn(json['data']),
        timestamp: DateTime.parse(json['timestamp'] as String),
        ttl: Duration(milliseconds: json['ttlMs'] as int),
      );
    } catch (e) {
      return null;
    }
  }
}

/// In-memory + disk cache service for optimizing data access
///
/// Features:
/// - In-memory LRU cache for fast access
/// - Disk persistence via SharedPreferences for offline support
/// - TTL (time-to-live) based expiration
/// - Cache invalidation by key or prefix
/// - Automatic cleanup of expired entries
class CacheService {
  CacheService._();

  /// Default TTL for cached data (15 minutes)
  static const Duration defaultTtl = Duration(minutes: 15);

  /// Short TTL for frequently changing data (5 minutes)
  static const Duration shortTtl = Duration(minutes: 5);

  /// Long TTL for rarely changing data (1 hour)
  static const Duration longTtl = Duration(hours: 1);

  /// Very long TTL for static data (24 hours)
  static const Duration staticTtl = Duration(hours: 24);

  /// Maximum in-memory cache entries
  static const int maxMemoryCacheEntries = 100;

  /// Cache key prefix for disk storage
  static const String _cachePrefix = 'tsl_cache_';

  /// In-memory cache storage
  static final Map<String, CacheEntry<dynamic>> _memoryCache = {};

  /// Access order tracking for LRU eviction
  static final List<String> _accessOrder = [];

  // ============================================
  // IN-MEMORY CACHE
  // ============================================

  /// Get data from in-memory cache
  static T? getFromMemory<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _memoryCache.remove(key);
      _accessOrder.remove(key);
      return null;
    }

    // Update access order (LRU)
    _accessOrder.remove(key);
    _accessOrder.add(key);

    return entry.data as T?;
  }

  /// Store data in in-memory cache
  static void putInMemory<T>(
    String key,
    T data, {
    Duration ttl = defaultTtl,
  }) {
    // Evict oldest entry if cache is full
    if (_memoryCache.length >= maxMemoryCacheEntries &&
        !_memoryCache.containsKey(key)) {
      _evictOldest();
    }

    _memoryCache[key] = CacheEntry<T>(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl,
    );

    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  /// Evict the least recently used entry
  static void _evictOldest() {
    if (_accessOrder.isNotEmpty) {
      final oldestKey = _accessOrder.removeAt(0);
      _memoryCache.remove(oldestKey);
    }
  }

  // ============================================
  // DISK CACHE (SharedPreferences)
  // ============================================

  /// Get data from disk cache
  static Future<T?> getFromDisk<T>(
    String key,
    T Function(dynamic) fromJsonFn,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('$_cachePrefix$key');
      if (jsonStr == null) return null;

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final entry = CacheEntry.fromJson<T>(json, fromJsonFn);

      if (entry == null || entry.isExpired) {
        // Remove expired entry
        await prefs.remove('$_cachePrefix$key');
        return null;
      }

      // Also store in memory for faster subsequent access
      putInMemory<T>(key, entry.data, ttl: entry.ttl);

      return entry.data;
    } catch (e) {
      debugPrint('CacheService: Error reading from disk cache: $e');
      return null;
    }
  }

  /// Store data in disk cache
  static Future<void> putOnDisk<T>(
    String key,
    T data, {
    required dynamic Function(T) toJsonFn,
    Duration ttl = defaultTtl,
  }) async {
    try {
      final entry = CacheEntry<T>(
        data: data,
        timestamp: DateTime.now(),
        ttl: ttl,
      );

      final jsonStr = jsonEncode(entry.toJson(toJsonFn));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cachePrefix$key', jsonStr);

      // Also store in memory
      putInMemory<T>(key, data, ttl: ttl);
    } catch (e) {
      debugPrint('CacheService: Error writing to disk cache: $e');
    }
  }

  // ============================================
  // COMBINED GET (Memory → Disk → Fetch)
  // ============================================

  /// Get data with fallback chain: Memory → Disk → Fetch function
  ///
  /// This is the primary method for cached data access.
  /// Example usage:
  /// ```dart
  /// final products = await CacheService.get<List<Product>>(
  ///   key: 'products_list',
  ///   fromJsonFn: (json) => (json as List).map((e) => Product.fromJson(e)).toList(),
  ///   toJsonFn: (data) => data.map((e) => e.toJson()).toList(),
  ///   fetchFn: () => firestoreService.getProducts(),
  ///   ttl: CacheService.longTtl,
  /// );
  /// ```
  static Future<T?> get<T>({
    required String key,
    required T Function(dynamic) fromJsonFn,
    required dynamic Function(T) toJsonFn,
    required Future<T?> Function() fetchFn,
    Duration ttl = defaultTtl,
    bool forceRefresh = false,
  }) async {
    // 1. Check in-memory cache (fastest)
    if (!forceRefresh) {
      final memoryData = getFromMemory<T>(key);
      if (memoryData != null) {
        debugPrint('CacheService: HIT (memory) for key: $key');
        return memoryData;
      }

      // 2. Check disk cache
      final diskData = await getFromDisk<T>(key, fromJsonFn);
      if (diskData != null) {
        debugPrint('CacheService: HIT (disk) for key: $key');
        return diskData;
      }
    }

    // 3. Fetch from source
    debugPrint('CacheService: MISS for key: $key — fetching...');
    final freshData = await fetchFn();

    if (freshData != null) {
      // Store in both memory and disk
      putInMemory<T>(key, freshData, ttl: ttl);
      await putOnDisk<T>(key, freshData, toJsonFn: toJsonFn, ttl: ttl);
    }

    return freshData;
  }

  // ============================================
  // CACHE INVALIDATION
  // ============================================

  /// Invalidate a specific cache entry
  static Future<void> invalidate(String key) async {
    _memoryCache.remove(key);
    _accessOrder.remove(key);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$key');
    } catch (e) {
      debugPrint('CacheService: Error invalidating disk cache: $e');
    }
  }

  /// Invalidate all entries matching a key prefix
  static Future<void> invalidateByPrefix(String prefix) async {
    // Clear memory cache
    final keysToRemove = _memoryCache.keys
        .where((k) => k.startsWith(prefix))
        .toList();
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
      _accessOrder.remove(key);
    }

    // Clear disk cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final diskKeysToRemove = allKeys
          .where((k) => k.startsWith('$_cachePrefix$prefix'))
          .toList();
      for (final key in diskKeysToRemove) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('CacheService: Error invalidating by prefix: $e');
    }
  }

  /// Clear all cached data
  static Future<void> clearAll() async {
    _memoryCache.clear();
    _accessOrder.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final cacheKeys = allKeys
          .where((k) => k.startsWith(_cachePrefix))
          .toList();
      for (final key in cacheKeys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('CacheService: Error clearing all cache: $e');
    }

    debugPrint('CacheService: All cache cleared');
  }

  /// Clean up expired entries from memory
  static void cleanupExpired() {
    final expiredKeys = _memoryCache.entries
        .where((e) => e.value.isExpired)
        .map((e) => e.key)
        .toList();

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      _accessOrder.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      debugPrint('CacheService: Cleaned up ${expiredKeys.length} expired entries');
    }
  }

  // ============================================
  // CACHE STATS (for debugging)
  // ============================================

  /// Get current cache statistics
  static Map<String, dynamic> getStats() {
    return {
      'memoryEntries': _memoryCache.length,
      'maxEntries': maxMemoryCacheEntries,
      'expiredEntries': _memoryCache.values.where((e) => e.isExpired).length,
      'accessOrderSize': _accessOrder.length,
    };
  }
}

/// Predefined cache keys for the app
abstract final class CacheKeys {
  static const String userProfile = 'user_profile';
  static const String products = 'products';
  static const String deliveries = 'deliveries';
  static const String orders = 'orders';
  static const String notifications = 'notifications';
  static const String dealers = 'dealers';
  static const String mistris = 'mistris';
  static const String rewards = 'rewards';
  static const String projects = 'projects';
  static const String specifications = 'specifications';
}

