import 'package:flutter/material.dart';

import 'app_colors.dart';

/// TSL Parivar Design System - Shadows & Elevation
///
/// This file contains all shadow and elevation definitions
/// following Material 3 design guidelines.
abstract final class AppShadows {
  // ============================================
  // ELEVATION LEVELS
  // ============================================

  /// Level 0 - No elevation (0dp)
  static const double elevation0 = 0.0;

  /// Level 1 - Minimal elevation (1dp)
  static const double elevation1 = 1.0;

  /// Level 2 - Low elevation (3dp)
  static const double elevation2 = 3.0;

  /// Level 3 - Medium elevation (6dp)
  static const double elevation3 = 6.0;

  /// Level 4 - High elevation (8dp)
  static const double elevation4 = 8.0;

  /// Level 5 - Maximum elevation (12dp)
  static const double elevation5 = 12.0;

  // ============================================
  // BOX SHADOWS
  // ============================================

  /// No shadow
  static const List<BoxShadow> none = [];

  /// Extra small shadow (subtle)
  static List<BoxShadow> get xs => [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.04),
          offset: const Offset(0, 1),
          blurRadius: 2,
          spreadRadius: 0,
        ),
      ];

  /// Small shadow (cards at rest)
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.05),
          offset: const Offset(0, 1),
          blurRadius: 3,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, 1),
          blurRadius: 2,
          spreadRadius: 0,
        ),
      ];

  /// Medium shadow (cards hover, dropdowns)
  static List<BoxShadow> get md => [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, 4),
          blurRadius: 6,
          spreadRadius: -1,
        ),
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.06),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
      ];

  /// Large shadow (modals, dialogs)
  static List<BoxShadow> get lg => [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, 10),
          blurRadius: 15,
          spreadRadius: -3,
        ),
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.05),
          offset: const Offset(0, 4),
          blurRadius: 6,
          spreadRadius: -2,
        ),
      ];

  /// Extra large shadow (navigation drawer, bottom sheets)
  static List<BoxShadow> get xl => [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, 20),
          blurRadius: 25,
          spreadRadius: -5,
        ),
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.04),
          offset: const Offset(0, 10),
          blurRadius: 10,
          spreadRadius: -5,
        ),
      ];

  /// Extra extra large shadow (modal overlays)
  static List<BoxShadow> get xxl => [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.25),
          offset: const Offset(0, 25),
          blurRadius: 50,
          spreadRadius: -12,
        ),
      ];

  // ============================================
  // COMPONENT-SPECIFIC SHADOWS
  // ============================================

  /// Card shadow (default)
  static List<BoxShadow> get card => sm;

  /// Card shadow (elevated)
  static List<BoxShadow> get cardElevated => md;

  /// Button shadow (subtle)
  static List<BoxShadow> get button => [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.08),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];

  /// Button shadow (pressed)
  static List<BoxShadow> get buttonPressed => [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.04),
          offset: const Offset(0, 1),
          blurRadius: 2,
          spreadRadius: 0,
        ),
      ];

  /// FAB shadow
  static List<BoxShadow> get fab => [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.15),
          offset: const Offset(0, 6),
          blurRadius: 10,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];

  /// Bottom navigation shadow
  static List<BoxShadow> get bottomNav => [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, -2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  /// App bar shadow
  static List<BoxShadow> get appBar => [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.08),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];

  /// Dropdown shadow
  static List<BoxShadow> get dropdown => md;

  /// Modal shadow
  static List<BoxShadow> get modal => lg;

  /// Bottom sheet shadow
  static List<BoxShadow> get bottomSheet => xl;

  /// Snackbar shadow
  static List<BoxShadow> get snackbar => md;

  /// Tooltip shadow
  static List<BoxShadow> get tooltip => sm;

  // ============================================
  // COLORED SHADOWS
  // ============================================

  /// Primary color shadow (for primary buttons)
  static List<BoxShadow> get primaryShadow => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3),
          offset: const Offset(0, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.2),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];

  /// Success color shadow
  static List<BoxShadow> get successShadow => [
        BoxShadow(
          color: AppColors.success.withValues(alpha: 0.3),
          offset: const Offset(0, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  /// Warning color shadow
  static List<BoxShadow> get warningShadow => [
        BoxShadow(
          color: AppColors.warning.withValues(alpha: 0.3),
          offset: const Offset(0, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  /// Error color shadow
  static List<BoxShadow> get errorShadow => [
        BoxShadow(
          color: AppColors.error.withValues(alpha: 0.3),
          offset: const Offset(0, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  // ============================================
  // INNER SHADOWS (for pressed states)
  // ============================================

  /// Inner shadow for pressed state
  static List<BoxShadow> get innerSm => [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.06),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
      ];

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get shadow by elevation level
  static List<BoxShadow> getByElevation(double elevation) {
    if (elevation <= 0) return none;
    if (elevation <= 1) return xs;
    if (elevation <= 3) return sm;
    if (elevation <= 6) return md;
    if (elevation <= 8) return lg;
    return xl;
  }

  /// Create custom colored shadow
  static List<BoxShadow> colored({
    required Color color,
    double opacity = 0.3,
    Offset offset = const Offset(0, 4),
    double blurRadius = 8,
    double spreadRadius = 0,
  }) =>
      [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          offset: offset,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
      ];
}

