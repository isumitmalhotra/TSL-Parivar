import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import 'tsl_primary_button.dart';
import 'tsl_secondary_button.dart';

/// Location picker component for TSL Parivar app
///
/// Features:
/// - Current GPS location
/// - Manual address input
/// - Map preview (placeholder)
/// - Location verification status
class TslLocationPicker extends StatelessWidget {
  /// Currently selected location
  final TslLocation? location;

  /// Callback when location changes
  final ValueChanged<TslLocation?>? onLocationChanged;

  /// Callback to get current GPS location
  final Future<TslLocation?> Function()? onGetCurrentLocation;

  /// Field label
  final String? label;

  /// Helper text below the field
  final String? helperText;

  /// Error text (shows error state when not null)
  final String? errorText;

  /// Whether field is required
  final bool isRequired;

  /// Whether field is enabled
  final bool isEnabled;

  /// Whether to show location verification status
  final bool showVerificationStatus;

  /// Target location for verification
  final TslLocation? targetLocation;

  /// Maximum allowed distance from target (in meters)
  final double maxDistanceMeters;

  const TslLocationPicker({
    super.key,
    this.location,
    this.onLocationChanged,
    this.onGetCurrentLocation,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isEnabled = true,
    this.showVerificationStatus = false,
    this.targetLocation,
    this.maxDistanceMeters = 500,
  });

  /// Factory for delivery location picker
  factory TslLocationPicker.delivery({
    TslLocation? location,
    ValueChanged<TslLocation?>? onLocationChanged,
    Future<TslLocation?> Function()? onGetCurrentLocation,
    String? errorText,
    TslLocation? targetLocation,
  }) {
    return TslLocationPicker(
      location: location,
      onLocationChanged: onLocationChanged,
      onGetCurrentLocation: onGetCurrentLocation,
      label: 'Delivery Location',
      helperText: 'Verify your location at delivery point',
      errorText: errorText,
      isRequired: true,
      showVerificationStatus: true,
      targetLocation: targetLocation,
      maxDistanceMeters: 500,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final verificationStatus = _getVerificationStatus();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          _buildLabel(),
          const SizedBox(height: AppSpacing.sm),
        ],
        // Location display/input
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: AppRadius.radiusCard,
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : AppColors.border,
            ),
            boxShadow: AppShadows.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location info
              if (location != null) ...[
                _buildLocationInfo(),
                const SizedBox(height: AppSpacing.md),
              ],
              // Map preview placeholder
              _buildMapPlaceholder(),
              const SizedBox(height: AppSpacing.md),
              // Action buttons
              _buildActionButtons(context),
              // Verification status
              if (showVerificationStatus && location != null) ...[
                const SizedBox(height: AppSpacing.md),
                _buildVerificationStatus(verificationStatus),
              ],
            ],
          ),
        ),
        // Error or helper text
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: AppTypography.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            helperText!,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Text(
          label!,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '*',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: AppRadius.radiusSm,
          ),
          child: const Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (location!.address != null)
                Text(
                  location!.address!,
                  style: AppTypography.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${location!.latitude.toStringAsFixed(6)}, ${location!.longitude.toStringAsFixed(6)}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (isEnabled)
          IconButton(
            onPressed: () => onLocationChanged?.call(null),
            icon: const Icon(Icons.clear),
            iconSize: 20,
            color: AppColors.textSecondary,
          ),
      ],
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.disabled.withValues(alpha: 0.3),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              location != null ? Icons.map : Icons.map_outlined,
              size: 32,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              location != null ? 'Map Preview' : 'No location selected',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TslPrimaryButton(
            label: 'Current Location',
            leadingIcon: Icons.my_location,
            onPressed: isEnabled && onGetCurrentLocation != null
                ? () => _getCurrentLocation(context)
                : null,
            size: TslButtonSize.small,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: TslSecondaryButton(
            label: 'Enter Address',
            leadingIcon: Icons.edit_location_alt_outlined,
            onPressed: isEnabled
                ? () => _showAddressInput(context)
                : null,
            size: TslButtonSize.small,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStatus(_VerificationStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String message;

    switch (status) {
      case _VerificationStatus.verified:
        backgroundColor = AppColors.successContainer;
        textColor = AppColors.success;
        icon = Icons.check_circle;
        message = 'Location verified - within ${maxDistanceMeters.toInt()}m of target';
        break;
      case _VerificationStatus.warning:
        backgroundColor = AppColors.warningContainer;
        textColor = AppColors.warningDark;
        icon = Icons.warning;
        message = 'Location slightly off - verify you\'re at the correct location';
        break;
      case _VerificationStatus.error:
        backgroundColor = AppColors.errorContainer;
        textColor = AppColors.error;
        icon = Icons.error;
        message = 'Location too far from target delivery point';
        break;
      case _VerificationStatus.unknown:
        backgroundColor = AppColors.disabled;
        textColor = AppColors.textSecondary;
        icon = Icons.help_outline;
        message = 'Cannot verify - target location not set';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _VerificationStatus _getVerificationStatus() {
    if (location == null || targetLocation == null) {
      return _VerificationStatus.unknown;
    }

    final distance = _calculateDistance(
      location!.latitude,
      location!.longitude,
      targetLocation!.latitude,
      targetLocation!.longitude,
    );

    if (distance <= maxDistanceMeters) {
      return _VerificationStatus.verified;
    } else if (distance <= maxDistanceMeters * 2) {
      return _VerificationStatus.warning;
    } else {
      return _VerificationStatus.error;
    }
  }

  // Simplified Haversine formula for distance calculation
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * 3.14159265359 / 180;
  double _sin(double x) => x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  double _cos(double x) => 1 - (x * x) / 2 + (x * x * x * x) / 24;
  double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
  double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.14159265359;
    if (x < 0 && y < 0) return _atan(y / x) - 3.14159265359;
    if (x == 0 && y > 0) return 3.14159265359 / 2;
    if (x == 0 && y < 0) return -3.14159265359 / 2;
    return 0;
  }
  double _atan(double x) => x - (x * x * x) / 3 + (x * x * x * x * x) / 5;

  Future<void> _getCurrentLocation(BuildContext context) async {
    if (onGetCurrentLocation == null) return;

    // Show loading indicator
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppSpacing.md),
                Text('Getting location...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final newLocation = await onGetCurrentLocation!();
      if (context.mounted) {
        Navigator.pop(context);
        if (newLocation != null) {
          onLocationChanged?.call(newLocation);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAddressInput(BuildContext context) {
    final addressController = TextEditingController(
      text: location?.address,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.disabled,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Enter Address',
                  style: AppTypography.h3,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter delivery address...',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusButton,
                    ),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TslSecondaryButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TslPrimaryButton(
                        label: 'Save',
                        onPressed: () {
                          final address = addressController.text.trim();
                          if (address.isNotEmpty) {
                            onLocationChanged?.call(
                              TslLocation(
                                latitude: location?.latitude ?? 0,
                                longitude: location?.longitude ?? 0,
                                address: address,
                              ),
                            );
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Location verification status
enum _VerificationStatus {
  verified,
  warning,
  error,
  unknown,
}

/// Location model
class TslLocation {
  final double latitude;
  final double longitude;
  final String? address;
  final double? accuracy;
  final DateTime? timestamp;

  const TslLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.accuracy,
    this.timestamp,
  });

  TslLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return TslLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'TslLocation(lat: $latitude, lng: $longitude, address: $address)';
  }
}

/// Location display card (read-only)
class TslLocationCard extends StatelessWidget {
  final TslLocation location;
  final VoidCallback? onNavigate;
  final VoidCallback? onTap;

  const TslLocationCard({
    super.key,
    required this.location,
    this.onNavigate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardWhite,
      borderRadius: AppRadius.radiusCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusCard,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusCard,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.radiusSm,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (location.address != null)
                      Text(
                        location.address!,
                        style: AppTypography.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Location',
                        style: AppTypography.bodyMedium,
                      ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onNavigate != null)
                IconButton(
                  onPressed: onNavigate,
                  icon: const Icon(Icons.directions),
                  color: AppColors.primary,
                  tooltip: 'Navigate',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

