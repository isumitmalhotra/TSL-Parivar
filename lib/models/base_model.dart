/// Base model classes and utilities
///
/// Contains base classes and utilities used across all models
/// for serialization, validation, and equality.

import 'package:flutter/foundation.dart';

/// Base class for all data models
/// Provides common functionality for JSON serialization and equality
abstract class BaseModel {
  const BaseModel();

  /// Convert model to JSON map
  Map<String, dynamic> toJson();

  /// Validate model data
  bool get isValid => true;

  @override
  String toString() => '$runtimeType(${toJson()})';
}

/// Validation result class
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
  });

  factory ValidationResult.valid() => const ValidationResult(isValid: true);

  factory ValidationResult.invalid(List<String> errors) =>
      ValidationResult(isValid: false, errors: errors);

  factory ValidationResult.singleError(String error) =>
      ValidationResult(isValid: false, errors: [error]);
}

/// Validation utilities
class Validators {
  Validators._();

  /// Validate phone number (Indian format)
  static ValidationResult validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return ValidationResult.singleError('Phone number is required');
    }

    // Remove spaces and country code
    final cleaned = phone.replaceAll(RegExp(r'[\s\-+]'), '');
    final digitsOnly = cleaned.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length < 10) {
      return ValidationResult.singleError('Phone number must be at least 10 digits');
    }

    // Indian mobile number format
    if (digitsOnly.length == 10 && !RegExp(r'^[6-9]\d{9}$').hasMatch(digitsOnly)) {
      return ValidationResult.singleError('Invalid mobile number format');
    }

    return ValidationResult.valid();
  }

  /// Validate email
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return ValidationResult.valid(); // Email is optional
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return ValidationResult.singleError('Invalid email format');
    }

    return ValidationResult.valid();
  }

  /// Validate required string
  static ValidationResult validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.singleError('$fieldName is required');
    }
    return ValidationResult.valid();
  }

  /// Validate positive number
  static ValidationResult validatePositive(num? value, String fieldName) {
    if (value == null) {
      return ValidationResult.singleError('$fieldName is required');
    }
    if (value <= 0) {
      return ValidationResult.singleError('$fieldName must be positive');
    }
    return ValidationResult.valid();
  }

  /// Validate non-negative number
  static ValidationResult validateNonNegative(num? value, String fieldName) {
    if (value == null) {
      return ValidationResult.singleError('$fieldName is required');
    }
    if (value < 0) {
      return ValidationResult.singleError('$fieldName cannot be negative');
    }
    return ValidationResult.valid();
  }

  /// Validate latitude
  static ValidationResult validateLatitude(double? lat) {
    if (lat == null) {
      return ValidationResult.singleError('Latitude is required');
    }
    if (lat < -90 || lat > 90) {
      return ValidationResult.singleError('Latitude must be between -90 and 90');
    }
    return ValidationResult.valid();
  }

  /// Validate longitude
  static ValidationResult validateLongitude(double? lng) {
    if (lng == null) {
      return ValidationResult.singleError('Longitude is required');
    }
    if (lng < -180 || lng > 180) {
      return ValidationResult.singleError('Longitude must be between -180 and 180');
    }
    return ValidationResult.valid();
  }

  /// Combine multiple validation results
  static ValidationResult combine(List<ValidationResult> results) {
    final allErrors = <String>[];
    for (final result in results) {
      if (!result.isValid) {
        allErrors.addAll(result.errors);
      }
    }
    return allErrors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(allErrors);
  }
}

/// JSON parsing utilities
class JsonUtils {
  JsonUtils._();

  /// Parse DateTime from various formats
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('Error parsing DateTime: $e');
        return null;
      }
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  /// Parse double from various formats
  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Parse int from various formats
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Parse bool from various formats
  static bool parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return defaultValue;
  }

  /// Parse list from JSON
  static List<T> parseList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value == null) return [];
    if (value is! List) return [];
    return value
        .whereType<Map<String, dynamic>>()
        .map((item) => fromJson(item))
        .toList();
  }

  /// Parse enum from string
  static T? parseEnum<T extends Enum>(String? value, List<T> values) {
    if (value == null) return null;
    try {
      return values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

/// Geo location model
class GeoLocation extends BaseModel {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime? timestamp;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.timestamp,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      latitude: JsonUtils.parseDouble(json['latitude']),
      longitude: JsonUtils.parseDouble(json['longitude']),
      accuracy: json['accuracy'] != null
          ? JsonUtils.parseDouble(json['accuracy'])
          : null,
      timestamp: JsonUtils.parseDateTime(json['timestamp']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (accuracy != null) 'accuracy': accuracy,
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      };

  GeoLocation copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return GeoLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Calculate distance to another location in meters
  double distanceTo(GeoLocation other) {
    const earthRadius = 6371000.0; // meters
    final lat1 = latitude * 3.141592653589793 / 180;
    final lat2 = other.latitude * 3.141592653589793 / 180;
    final dLat = (other.latitude - latitude) * 3.141592653589793 / 180;
    final dLon = (other.longitude - longitude) * 3.141592653589793 / 180;

    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(lat1) * _cos(lat2) * _sin(dLon / 2) * _sin(dLon / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));

    return earthRadius * c;
  }

  // Math helper functions
  static double _sin(double x) => x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  static double _cos(double x) => 1 - (x * x) / 2 + (x * x * x * x) / 24;
  static double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
  static double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }
  static double _atan(double x) => x - (x * x * x) / 3 + (x * x * x * x * x) / 5;

  @override
  bool get isValid =>
      Validators.validateLatitude(latitude).isValid &&
      Validators.validateLongitude(longitude).isValid;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoLocation &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

/// Address model
class Address extends BaseModel {
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final String? landmark;
  final GeoLocation? location;

  const Address({
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    this.landmark,
    this.location,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      line1: (json['line1'] as String?) ?? '',
      line2: json['line2'] as String?,
      city: (json['city'] as String?) ?? '',
      state: (json['state'] as String?) ?? '',
      pincode: (json['pincode'] as String?) ?? '',
      landmark: json['landmark'] as String?,
      location: json['location'] != null
          ? GeoLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'line1': line1,
        if (line2 != null) 'line2': line2,
        'city': city,
        'state': state,
        'pincode': pincode,
        if (landmark != null) 'landmark': landmark,
        if (location != null) 'location': location!.toJson(),
      };

  Address copyWith({
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? pincode,
    String? landmark,
    GeoLocation? location,
  }) {
    return Address(
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      landmark: landmark ?? this.landmark,
      location: location ?? this.location,
    );
  }

  /// Get formatted full address
  String get fullAddress {
    final parts = <String>[line1];
    if (line2 != null && line2!.isNotEmpty) parts.add(line2!);
    if (landmark != null && landmark!.isNotEmpty) parts.add('Near $landmark');
    parts.add('$city, $state - $pincode');
    return parts.join(', ');
  }

  /// Get short address
  String get shortAddress => '$city, $state';

  @override
  bool get isValid =>
      line1.isNotEmpty && city.isNotEmpty && state.isNotEmpty && pincode.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          line1 == other.line1 &&
          city == other.city &&
          pincode == other.pincode;

  @override
  int get hashCode => line1.hashCode ^ city.hashCode ^ pincode.hashCode;
}

/// Money/Currency value model
class Money extends BaseModel {
  final double amount;
  final String currency;

  const Money({
    required this.amount,
    this.currency = 'INR',
  });

  factory Money.fromJson(Map<String, dynamic> json) {
    return Money(
      amount: JsonUtils.parseDouble(json['amount']),
      currency: (json['currency'] as String?) ?? 'INR',
    );
  }

  factory Money.inr(double amount) => Money(amount: amount, currency: 'INR');

  @override
  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
      };

  Money copyWith({
    double? amount,
    String? currency,
  }) {
    return Money(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
    );
  }

  /// Get formatted string (₹1,234.56)
  String get formatted {
    final symbol = currency == 'INR' ? '₹' : currency;
    final formatted = amount.toStringAsFixed(2);
    // Add thousand separators
    final parts = formatted.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '$symbol$intPart.${parts[1]}';
  }

  /// Get short formatted string (₹1.2K)
  String get shortFormatted {
    final symbol = currency == 'INR' ? '₹' : currency;
    if (amount >= 10000000) {
      return '$symbol${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  Money operator +(Money other) =>
      Money(amount: amount + other.amount, currency: currency);

  Money operator -(Money other) =>
      Money(amount: amount - other.amount, currency: currency);

  Money operator *(num factor) =>
      Money(amount: amount * factor, currency: currency);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          currency == other.currency;

  @override
  int get hashCode => amount.hashCode ^ currency.hashCode;
}

/// Date range model
class DateRange extends BaseModel {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: JsonUtils.parseDateTime(json['start']) ?? DateTime.now(),
      end: JsonUtils.parseDateTime(json['end']) ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };

  /// Check if a date falls within this range
  bool contains(DateTime date) =>
      date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
      date.isBefore(end.add(const Duration(milliseconds: 1)));

  /// Get duration
  Duration get duration => end.difference(start);

  /// Get number of days
  int get days => duration.inDays;

  @override
  bool get isValid => start.isBefore(end);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

/// Pagination metadata
class PaginationMeta extends BaseModel {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: JsonUtils.parseInt(json['page'], defaultValue: 1),
      perPage: JsonUtils.parseInt(json['per_page'], defaultValue: 20),
      total: JsonUtils.parseInt(json['total']),
      totalPages: JsonUtils.parseInt(json['total_pages']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'page': page,
        'per_page': perPage,
        'total': total,
        'total_pages': totalPages,
      };

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
  int get startIndex => (page - 1) * perPage;
  int get endIndex => startIndex + perPage - 1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationMeta &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          total == other.total;

  @override
  int get hashCode => page.hashCode ^ total.hashCode;
}

/// API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;
  final PaginationMeta? pagination;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
    this.pagination,
  });

  factory ApiResponse.success(T data, {String? message, PaginationMeta? pagination}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      pagination: pagination,
    );
  }

  factory ApiResponse.error(String message, {String? errorCode}) {
    return ApiResponse(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }

  bool get hasData => data != null;
  bool get hasError => !success;
}

