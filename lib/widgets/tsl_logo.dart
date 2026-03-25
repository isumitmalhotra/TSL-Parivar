import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Reusable TSL Logo widget that displays the real brand logo
///
/// Falls back to a text-based logo if the image asset fails to load.
/// Supports different sizes and styles for various contexts.
class TslLogo extends StatelessWidget {
  /// Size of the logo (width and height)
  final double size;

  /// Border radius of the logo container
  final double borderRadius;

  /// Whether to use the white version of the logo
  final bool useWhiteVersion;

  /// Optional background color for the fallback
  final Color? fallbackBackgroundColor;

  /// Optional text color for the fallback
  final Color? fallbackTextColor;

  const TslLogo({
    super.key,
    this.size = 40,
    this.borderRadius = 10,
    this.useWhiteVersion = false,
    this.fallbackBackgroundColor,
    this.fallbackTextColor,
  });

  /// Small logo (24px) for compact spaces
  const TslLogo.small({
    super.key,
    this.useWhiteVersion = false,
    this.fallbackBackgroundColor,
    this.fallbackTextColor,
  })  : size = 24,
        borderRadius = 6;

  /// Medium logo (36px) for app bars
  const TslLogo.medium({
    super.key,
    this.useWhiteVersion = false,
    this.fallbackBackgroundColor,
    this.fallbackTextColor,
  })  : size = 36,
        borderRadius = 8;

  /// Large logo (64px) for splash/branding areas
  const TslLogo.large({
    super.key,
    this.useWhiteVersion = false,
    this.fallbackBackgroundColor,
    this.fallbackTextColor,
  })  : size = 64,
        borderRadius = 14;

  /// Extra large logo (120px) for splash screen
  const TslLogo.splash({
    super.key,
    this.useWhiteVersion = false,
    this.fallbackBackgroundColor,
    this.fallbackTextColor,
  })  : size = 160,
        borderRadius = 28;

  String get _assetPath => useWhiteVersion
      ? 'assets/images/tsl_logo_white.png'
      : 'assets/images/tsl_logo_new.png';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        _assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback();
        },
      ),
    );
  }

  Widget _buildFallback() {
    final bgColor = fallbackBackgroundColor ?? AppColors.primary;
    final txtColor = fallbackTextColor ?? Colors.white;
    final fontSize = size * 0.28;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Text(
          'TSL',
          style: TextStyle(
            color: txtColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize.clamp(8, 42),
          ),
        ),
      ),
    );
  }
}

