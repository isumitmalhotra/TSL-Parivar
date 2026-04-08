import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for getting device location with proper permission handling
class LocationService {
  /// Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location services are disabled');
        return null;
      }

      // Request permission
      final status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
        debugPrint('❌ Location permission denied');
        return null;
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      debugPrint('📍 Location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      return null;
    }
  }

  /// Get last known position (faster, may be null)
  static Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('❌ Error getting last known position: $e');
      return null;
    }
  }

  /// Format position as human-readable string
  static String formatPosition(Position position) {
    return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
  }

  /// Basic coordinate sanity checks used before writing location payloads.
  static bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  static bool isAddressUsable(String? address) {
    return address != null && address.trim().isNotEmpty;
  }

  /// Reverse geocode coordinates into a compact one-line address.
  static Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    if (!isValidCoordinates(latitude, longitude)) {
      return null;
    }
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final parts = <String>[
        if ((p.street ?? '').trim().isNotEmpty) p.street!.trim(),
        if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
        if ((p.administrativeArea ?? '').trim().isNotEmpty)
          p.administrativeArea!.trim(),
        if ((p.postalCode ?? '').trim().isNotEmpty) p.postalCode!.trim(),
      ];
      if (parts.isEmpty) return null;
      return parts.join(', ');
    } catch (e) {
      debugPrint('⚠️ Reverse geocode failed: $e');
      return null;
    }
  }

  /// Calculate distance between two points in meters
  static double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  /// Open app settings (for when permission is permanently denied)
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
}

