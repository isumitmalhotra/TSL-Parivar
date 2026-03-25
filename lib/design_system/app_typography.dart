import 'package:flutter/material.dart';

import 'app_colors.dart';

/// TSL Parivar Design System - Typography
///
/// This file contains all typography definitions following the design spec:
/// - Roboto (primary font - system default on Android)
/// - Noto Sans Devanagari (Hindi support)
///
/// Font Sizes:
/// - H1: 28sp Bold (section headers)
/// - H2: 24sp SemiBold (sub-headers)
/// - H3: 18sp SemiBold (card titles)
/// - Body Large: 16sp Regular
/// - Body Medium: 14sp Regular
/// - Caption: 12sp Regular
abstract final class AppTypography {
  // ============================================
  // BASE TEXT STYLES
  // ============================================

  /// Get the base Roboto text style (system default on Android)
  static const TextStyle _baseRoboto = TextStyle(fontFamily: 'Roboto');

  /// Get the base Noto Sans Devanagari text style for Hindi
  static const TextStyle _baseNotoSansDevanagari = TextStyle(fontFamily: 'NotoSansDevanagari');

  // ============================================
  // DISPLAY STYLES (Large Headers)
  // ============================================

  /// Display Large - 57sp
  static TextStyle get displayLarge => _baseRoboto.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
        color: AppColors.textPrimary,
      );

  /// Display Medium - 45sp
  static TextStyle get displayMedium => _baseRoboto.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
        color: AppColors.textPrimary,
      );

  /// Display Small - 36sp
  static TextStyle get displaySmall => _baseRoboto.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
        color: AppColors.textPrimary,
      );

  // ============================================
  // HEADLINE STYLES
  // ============================================

  /// Headline Large - 32sp
  static TextStyle get headlineLarge => _baseRoboto.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.25,
        color: AppColors.textPrimary,
      );

  /// Headline Medium - 28sp
  static TextStyle get headlineMedium => _baseRoboto.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.29,
        color: AppColors.textPrimary,
      );

  /// Headline Small - 24sp
  static TextStyle get headlineSmall => _baseRoboto.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.33,
        color: AppColors.textPrimary,
      );

  // ============================================
  // APP SPECIFIC HEADERS (from design spec)
  // ============================================

  /// H1: 28sp Bold - Section headers
  static TextStyle get h1 => _baseRoboto.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.29,
        color: AppColors.textPrimary,
      );

  /// H2: 24sp SemiBold - Sub-headers
  static TextStyle get h2 => _baseRoboto.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
        color: AppColors.textPrimary,
      );

  /// H3: 18sp SemiBold - Card titles
  static TextStyle get h3 => _baseRoboto.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
        color: AppColors.textPrimary,
      );

  // ============================================
  // TITLE STYLES
  // ============================================

  /// Title Large - 22sp
  static TextStyle get titleLarge => _baseRoboto.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.27,
        color: AppColors.textPrimary,
      );

  /// Title Medium - 16sp
  static TextStyle get titleMedium => _baseRoboto.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  /// Title Small - 14sp
  static TextStyle get titleSmall => _baseRoboto.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: AppColors.textPrimary,
      );

  // ============================================
  // BODY STYLES
  // ============================================

  /// Body Large: 16sp Regular
  static TextStyle get bodyLarge => _baseRoboto.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  /// Body Medium: 14sp Regular
  static TextStyle get bodyMedium => _baseRoboto.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: AppColors.textPrimary,
      );

  /// Body Small - 12sp
  static TextStyle get bodySmall => _baseRoboto.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: AppColors.textSecondary,
      );

  // ============================================
  // LABEL STYLES
  // ============================================

  /// Label Large - 14sp Medium
  static TextStyle get labelLarge => _baseRoboto.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: AppColors.textPrimary,
      );

  /// Label Medium - 12sp Medium
  static TextStyle get labelMedium => _baseRoboto.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
        color: AppColors.textPrimary,
      );

  /// Label Small - 11sp Medium
  static TextStyle get labelSmall => _baseRoboto.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
        color: AppColors.textSecondary,
      );

  // ============================================
  // CAPTION STYLE (from design spec)
  // ============================================

  /// Caption: 12sp Regular
  static TextStyle get caption => _baseRoboto.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: AppColors.textSecondary,
      );

  // ============================================
  // BUTTON STYLES
  // ============================================

  /// Button text style - Primary
  static TextStyle get buttonLarge => _baseRoboto.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.5,
        color: AppColors.textOnPrimary,
      );

  /// Button text style - Medium
  static TextStyle get buttonMedium => _baseRoboto.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.43,
        color: AppColors.textOnPrimary,
      );

  /// Button text style - Small
  static TextStyle get buttonSmall => _baseRoboto.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.33,
        color: AppColors.textOnPrimary,
      );

  // ============================================
  // HINDI TYPOGRAPHY STYLES
  // ============================================

  /// Hindi H1
  static TextStyle get h1Hindi => _baseNotoSansDevanagari.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  /// Hindi H2
  static TextStyle get h2Hindi => _baseNotoSansDevanagari.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  /// Hindi H3
  static TextStyle get h3Hindi => _baseNotoSansDevanagari.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  /// Hindi Body Large
  static TextStyle get bodyLargeHindi => _baseNotoSansDevanagari.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.6,
        color: AppColors.textPrimary,
      );

  /// Hindi Body Medium
  static TextStyle get bodyMediumHindi => _baseNotoSansDevanagari.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  /// Hindi Caption
  static TextStyle get captionHindi => _baseNotoSansDevanagari.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.4,
        color: AppColors.textSecondary,
      );

  // ============================================
  // SPECIALIZED STYLES
  // ============================================

  /// Price/Amount style
  static TextStyle get price => _baseRoboto.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  /// Large number/stat style
  static TextStyle get statLarge => _baseRoboto.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.2,
        color: AppColors.primary,
      );

  /// Medium stat style
  static TextStyle get statMedium => _baseRoboto.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.25,
        color: AppColors.textPrimary,
      );

  /// Badge text style
  static TextStyle get badge => _baseRoboto.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.2,
        color: AppColors.textOnPrimary,
      );

  /// Overline text style
  static TextStyle get overline => _baseRoboto.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        height: 1.6,
        color: AppColors.textSecondary,
      );

  /// Link text style
  static TextStyle get link => _baseRoboto.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        height: 1.43,
        color: AppColors.primary,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.primary,
      );

  // ============================================
  // TEXT THEME FOR MATERIAL
  // ============================================

  /// Get the complete TextTheme for Material Theme
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );

  /// Get the dark theme TextTheme
  static TextTheme get textThemeDark => TextTheme(
        displayLarge: displayLarge.copyWith(color: AppColors.darkTextPrimary),
        displayMedium: displayMedium.copyWith(color: AppColors.darkTextPrimary),
        displaySmall: displaySmall.copyWith(color: AppColors.darkTextPrimary),
        headlineLarge: headlineLarge.copyWith(color: AppColors.darkTextPrimary),
        headlineMedium:
            headlineMedium.copyWith(color: AppColors.darkTextPrimary),
        headlineSmall: headlineSmall.copyWith(color: AppColors.darkTextPrimary),
        titleLarge: titleLarge.copyWith(color: AppColors.darkTextPrimary),
        titleMedium: titleMedium.copyWith(color: AppColors.darkTextPrimary),
        titleSmall: titleSmall.copyWith(color: AppColors.darkTextPrimary),
        bodyLarge: bodyLarge.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium: bodyMedium.copyWith(color: AppColors.darkTextPrimary),
        bodySmall: bodySmall.copyWith(color: AppColors.darkTextSecondary),
        labelLarge: labelLarge.copyWith(color: AppColors.darkTextPrimary),
        labelMedium: labelMedium.copyWith(color: AppColors.darkTextPrimary),
        labelSmall: labelSmall.copyWith(color: AppColors.darkTextSecondary),
      );
}

