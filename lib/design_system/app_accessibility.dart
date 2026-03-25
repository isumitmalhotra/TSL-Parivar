import 'dart:async';

import 'package:flutter/material.dart';

/// Accessibility constants and utilities for TSL Parivar
///
/// Ensures the app meets WCAG 2.1 AA accessibility standards:
/// - 44dp minimum touch targets
/// - 4.5:1 contrast ratio for normal text
/// - 3:1 contrast ratio for large text
/// - Semantic labels for screen readers
abstract final class AppAccessibility {
  // ============================================
  // TOUCH TARGET SIZES
  // ============================================

  /// Minimum touch target size per WCAG 2.1 (44x44dp)
  static const double minTouchTarget = 44.0;

  /// Recommended touch target size for primary actions
  static const double recommendedTouchTarget = 48.0;

  /// Large touch target size for important CTAs
  static const double largeTouchTarget = 56.0;

  /// Ensures a widget meets minimum touch target size
  /// Wraps the child in a SizedBox with minimum constraints
  static Widget ensureMinTouchTarget({
    required Widget child,
    double minSize = minTouchTarget,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }

  // ============================================
  // SEMANTIC LABELS
  // ============================================

  /// Wraps a widget with Semantics for screen reader support
  static Widget withSemantics({
    required Widget child,
    required String label,
    String? hint,
    bool? button,
    bool? header,
    bool? image,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: button,
      header: header,
      image: image,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// Creates a semantically labeled icon button with proper touch target
  static Widget accessibleIconButton({
    required IconData icon,
    required String semanticLabel,
    required VoidCallback onPressed,
    double size = 24.0,
    Color? color,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: IconButton(
        icon: Icon(icon, size: size, color: color, semanticLabel: semanticLabel),
        onPressed: onPressed,
        constraints: const BoxConstraints(
          minWidth: minTouchTarget,
          minHeight: minTouchTarget,
        ),
      ),
    );
  }

  // ============================================
  // TEXT SCALING
  // ============================================

  /// Maximum text scale factor to prevent layout breakage
  static const double maxTextScaleFactor = 1.5;

  /// Minimum text scale factor
  static const double minTextScaleFactor = 0.8;

  /// Clamps the text scale factor to prevent extreme scaling
  static TextScaler clampedTextScaler(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scaleFactor = mediaQuery.textScaler.scale(1.0);
    final clampedScale = scaleFactor.clamp(minTextScaleFactor, maxTextScaleFactor);
    return TextScaler.linear(clampedScale);
  }

  /// Wraps a subtree with clamped text scaling
  static Widget withClampedTextScaling({
    required Widget child,
    required BuildContext context,
  }) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: clampedTextScaler(context),
      ),
      child: child,
    );
  }
}

/// Extension on Color to check contrast ratios
extension ColorContrast on Color {
  /// Calculate relative luminance per WCAG 2.1
  double get relativeLuminance {
    double r = _linearize(this.r / 255.0);
    double g = _linearize(this.g / 255.0);
    double b = _linearize(this.b / 255.0);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  double _linearize(double value) {
    return value <= 0.03928 ? value / 12.92 : ((value + 0.055) / 1.055);
  }

  /// Calculate contrast ratio between two colors
  double contrastRatio(Color other) {
    final l1 = relativeLuminance;
    final l2 = other.relativeLuminance;
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if contrast meets WCAG AA for normal text (4.5:1)
  bool meetsAANormalText(Color background) {
    return contrastRatio(background) >= 4.5;
  }

  /// Check if contrast meets WCAG AA for large text (3:1)
  bool meetsAALargeText(Color background) {
    return contrastRatio(background) >= 3.0;
  }
}

/// Debouncer utility for search inputs and other delayed actions
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// Run the callback after the delay, cancelling any previous pending call
  void run(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Cancel any pending debounced call
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose the debouncer
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

