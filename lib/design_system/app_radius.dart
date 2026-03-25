import 'package:flutter/material.dart';

/// TSL Parivar Design System - Border Radius Constants
///
/// This file contains all border radius definitions as per design spec:
/// - Buttons: 10dp
/// - Cards: 12dp
/// - Chips: 16dp
/// - FAB: 24dp
abstract final class AppRadius {
  // ============================================
  // RADIUS VALUES
  // ============================================

  /// No radius (0dp)
  static const double none = 0.0;

  /// Extra small radius (4dp)
  static const double xs = 4.0;

  /// Small radius (8dp)
  static const double sm = 8.0;

  /// Button radius (10dp)
  static const double button = 10.0;

  /// Card radius (12dp)
  static const double card = 12.0;

  /// Medium radius (12dp) - alias for card
  static const double md = 12.0;

  /// Large radius (16dp)
  static const double lg = 16.0;

  /// Chip radius (16dp)
  static const double chip = 16.0;

  /// Extra large radius (20dp)
  static const double xl = 20.0;

  /// FAB radius (24dp)
  static const double fab = 24.0;

  /// Extra extra large radius (28dp)
  static const double xxl = 28.0;

  /// Full/Circular radius (9999dp - effectively circular)
  static const double full = 9999.0;

  // ============================================
  // BORDER RADIUS OBJECTS
  // ============================================

  /// No border radius
  static const BorderRadius radiusNone = BorderRadius.zero;

  /// Extra small border radius (4dp)
  static BorderRadius get radiusXs => BorderRadius.circular(xs);

  /// Small border radius (8dp)
  static BorderRadius get radiusSm => BorderRadius.circular(sm);

  /// Button border radius (10dp)
  static BorderRadius get radiusButton => BorderRadius.circular(button);

  /// Card border radius (12dp)
  static BorderRadius get radiusCard => BorderRadius.circular(card);

  /// Medium border radius (12dp)
  static BorderRadius get radiusMd => BorderRadius.circular(md);

  /// Large border radius (16dp)
  static BorderRadius get radiusLg => BorderRadius.circular(lg);

  /// Chip border radius (16dp)
  static BorderRadius get radiusChip => BorderRadius.circular(chip);

  /// Extra large border radius (20dp)
  static BorderRadius get radiusXl => BorderRadius.circular(xl);

  /// FAB border radius (24dp)
  static BorderRadius get radiusFab => BorderRadius.circular(fab);

  /// Extra extra large border radius (28dp)
  static BorderRadius get radiusXxl => BorderRadius.circular(xxl);

  /// Circular/Pill border radius
  static BorderRadius get radiusFull => BorderRadius.circular(full);

  // ============================================
  // SPECIALIZED BORDER RADIUS
  // ============================================

  /// Top-only rounded (for bottom sheets, modal headers)
  static BorderRadius get radiusTopLg => const BorderRadius.only(
        topLeft: Radius.circular(lg),
        topRight: Radius.circular(lg),
      );

  /// Top-only rounded extra large (for modals)
  static BorderRadius get radiusTopXl => const BorderRadius.only(
        topLeft: Radius.circular(xl),
        topRight: Radius.circular(xl),
      );

  /// Top-only rounded for bottom sheets
  static BorderRadius get radiusTopXxl => const BorderRadius.only(
        topLeft: Radius.circular(xxl),
        topRight: Radius.circular(xxl),
      );

  /// Bottom-only rounded
  static BorderRadius get radiusBottomLg => const BorderRadius.only(
        bottomLeft: Radius.circular(lg),
        bottomRight: Radius.circular(lg),
      );

  /// Left-only rounded
  static BorderRadius get radiusLeftLg => const BorderRadius.only(
        topLeft: Radius.circular(lg),
        bottomLeft: Radius.circular(lg),
      );

  /// Right-only rounded
  static BorderRadius get radiusRightLg => const BorderRadius.only(
        topRight: Radius.circular(lg),
        bottomRight: Radius.circular(lg),
      );

  // ============================================
  // SHAPE BORDERS FOR MATERIAL COMPONENTS
  // ============================================

  /// Rounded rectangle shape - button
  static RoundedRectangleBorder get shapeButton =>
      RoundedRectangleBorder(borderRadius: radiusButton);

  /// Rounded rectangle shape - card
  static RoundedRectangleBorder get shapeCard =>
      RoundedRectangleBorder(borderRadius: radiusCard);

  /// Rounded rectangle shape - chip
  static RoundedRectangleBorder get shapeChip =>
      RoundedRectangleBorder(borderRadius: radiusChip);

  /// Rounded rectangle shape - dialog
  static RoundedRectangleBorder get shapeDialog =>
      RoundedRectangleBorder(borderRadius: radiusXxl);

  /// Rounded rectangle shape - bottom sheet
  static RoundedRectangleBorder get shapeBottomSheet =>
      RoundedRectangleBorder(borderRadius: radiusTopXxl);

  /// Rounded rectangle shape - FAB
  static RoundedRectangleBorder get shapeFab =>
      RoundedRectangleBorder(borderRadius: radiusFab);

  /// Stadium shape (pill-shaped)
  static const StadiumBorder shapeStadium = StadiumBorder();

  /// Circle shape
  static const CircleBorder shapeCircle = CircleBorder();

  // ============================================
  // OUTLINE INPUT BORDERS
  // ============================================

  /// Input border - default
  static OutlineInputBorder inputBorder({
    Color color = const Color(0xFFE0E0E0),
    double width = 1.0,
  }) =>
      OutlineInputBorder(
        borderRadius: radiusButton,
        borderSide: BorderSide(color: color, width: width),
      );

  /// Input border - focused
  static OutlineInputBorder inputBorderFocused({
    Color color = const Color(0xFF2E7D32),
    double width = 2.0,
  }) =>
      OutlineInputBorder(
        borderRadius: radiusButton,
        borderSide: BorderSide(color: color, width: width),
      );

  /// Input border - error
  static OutlineInputBorder inputBorderError({
    Color color = const Color(0xFFF44336),
    double width = 1.0,
  }) =>
      OutlineInputBorder(
        borderRadius: radiusButton,
        borderSide: BorderSide(color: color, width: width),
      );

  /// Input border - disabled
  static OutlineInputBorder inputBorderDisabled({
    Color color = const Color(0xFFBDBDBD),
    double width = 1.0,
  }) =>
      OutlineInputBorder(
        borderRadius: radiusButton,
        borderSide: BorderSide(color: color, width: width),
      );

  // ============================================
  // CONTINUOUS RECTANGLE (iOS style)
  // ============================================

  /// Continuous rounded rectangle for iOS-style smooth corners
  static ContinuousRectangleBorder continuousRectangle({
    double radius = card,
  }) =>
      ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      );
}

