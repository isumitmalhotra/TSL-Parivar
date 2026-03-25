import 'package:flutter/material.dart';

/// TSL Parivar Design System - Color Palette
///
/// This file contains all the color definitions used throughout the app.
/// Colors follow the TSL brand guidelines with Material 3 compatibility.
abstract final class AppColors {
  // ============================================
  // PRIMARY COLORS
  // ============================================

  /// Primary Brand Green - Used for primary CTAs and brand elements
  static const Color primary = Color(0xFF2E7D32);

  /// Primary color variants for different states
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryContainer = Color(0xFFC8E6C9);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF002106);

  // ============================================
  // SECONDARY COLORS
  // ============================================

  /// Secondary Gold - Used for badges, achievements, rewards
  static const Color secondary = Color(0xFFFFA726);
  static const Color secondaryLight = Color(0xFFFFD95B);
  static const Color secondaryDark = Color(0xFFC77800);
  static const Color secondaryContainer = Color(0xFFFFDDB3);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onSecondaryContainer = Color(0xFF2A1800);

  // ============================================
  // SEMANTIC COLORS
  // ============================================

  /// Success Green - Used for success states, completed status
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF80E27E);
  static const Color successDark = Color(0xFF087F23);
  static const Color successContainer = Color(0xFFB7F5B9);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF002106);

  /// Warning Amber - Used for warnings, pending states
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF350);
  static const Color warningDark = Color(0xFFC79100);
  static const Color warningContainer = Color(0xFFFFE082);
  static const Color onWarning = Color(0xFF000000);
  static const Color onWarningContainer = Color(0xFF251A00);

  /// Error Red - Used for errors, destructive actions
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFF7961);
  static const Color errorDark = Color(0xFFBA000D);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  /// Info Blue - Used for informational content
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF6EC6FF);
  static const Color infoDark = Color(0xFF0069C0);
  static const Color infoContainer = Color(0xFFD1E4FF);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color onInfoContainer = Color(0xFF001D36);

  // ============================================
  // NEUTRAL COLORS
  // ============================================

  /// Background colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE8F5E9);
  static const Color surfaceDim = Color(0xFFD8DED8);
  static const Color surfaceBright = Color(0xFFF1F8E9);

  /// Card colors
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardElevated = Color(0xFFFAFAFA);

  /// Text colors — All meet WCAG 2.1 AA contrast requirements
  static const Color textDark = Color(0xFF212121); // 16.1:1 on white
  static const Color textPrimary = Color(0xFF212121); // 16.1:1 on white
  static const Color textSecondary = Color(0xFF757575); // 4.6:1 on white (AA normal text)
  static const Color textTertiary = Color(0xFF767676); // 4.5:1 on white (AA normal text)
  static const Color textDisabled = Color(0xFFBDBDBD); // Used only for disabled state (exempt)
  static const Color textOnDark = Color(0xFFFFFFFF); // 16.1:1 on #212121
  static const Color textOnPrimary = Color(0xFFFFFFFF); // 7.1:1 on primary green

  /// Border and divider colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color borderDark = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color outline = Color(0xFF5D7160);
  static const Color outlineVariant = Color(0xFFC2D8BE);

  /// Disabled state color
  static const Color disabled = Color(0xFFE0E0E0);
  static const Color disabledBackground = Color(0xFFF5F5F5);

  // ============================================
  // OVERLAY COLORS
  // ============================================

  /// Scrim and overlay colors
  static const Color scrim = Color(0xFF000000);
  static const Color overlay = Color(0x52000000);
  static const Color overlayLight = Color(0x1F000000);
  static const Color overlayDark = Color(0x8A000000);

  /// Shadow color
  static const Color shadow = Color(0xFF000000);

  // ============================================
  // STATUS COLORS (for delivery/order status)
  // ============================================

  /// Assigned status
  static const Color statusAssigned = Color(0xFF2196F3);
  static const Color statusAssignedBg = Color(0xFFE3F2FD);

  /// In Progress status
  static const Color statusInProgress = Color(0xFFFFA726);
  static const Color statusInProgressBg = Color(0xFFFFF3E0);

  /// Pending status
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusPendingBg = Color(0xFFFFF8E1);

  /// Completed status
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusCompletedBg = Color(0xFFE8F5E9);

  /// Rejected status
  static const Color statusRejected = Color(0xFFF44336);
  static const Color statusRejectedBg = Color(0xFFFFEBEE);

  /// Cancelled status
  static const Color statusCancelled = Color(0xFF9E9E9E);
  static const Color statusCancelledBg = Color(0xFFF5F5F5);

  // ============================================
  // GRADIENT COLORS
  // ============================================

  /// Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  /// Secondary gradient (gold)
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary],
  );

  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successDark],
  );

  /// Hero banner gradient
  static const LinearGradient heroBannerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2E7D32),
      Color(0xFF1B5E20),
    ],
  );

  /// Card overlay gradient (for images)
  static const LinearGradient cardOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0x8A000000),
    ],
  );

  /// Brand accent gradient - for feature cards, banners, highlights
  static const LinearGradient brandAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
  );

  // ============================================
  // ROLE-SPECIFIC ACCENT COLORS
  // ============================================

  /// Mistri accent color
  static const Color mistriAccent = Color(0xFF4CAF50);

  /// Dealer accent color
  static const Color dealerAccent = Color(0xFF388E3C);

  /// Architect accent color
  static const Color architectAccent = Color(0xFF2E7D32);

  // ============================================
  // DARK THEME COLORS
  // ============================================

  /// Dark theme surface colors
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF3B4F3D);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF2C2C2C);

  /// Dark theme text colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextTertiary = Color(0xFF808080);

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Get status color based on status string
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return statusAssigned;
      case 'in_progress':
      case 'inprogress':
      case 'in progress':
        return statusInProgress;
      case 'pending':
      case 'pending_approval':
        return statusPending;
      case 'completed':
      case 'delivered':
        return statusCompleted;
      case 'rejected':
      case 'failed':
        return statusRejected;
      case 'cancelled':
      case 'canceled':
        return statusCancelled;
      default:
        return textSecondary;
    }
  }

  /// Get status background color based on status string
  static Color getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return statusAssignedBg;
      case 'in_progress':
      case 'inprogress':
      case 'in progress':
        return statusInProgressBg;
      case 'pending':
      case 'pending_approval':
        return statusPendingBg;
      case 'completed':
      case 'delivered':
        return statusCompletedBg;
      case 'rejected':
      case 'failed':
        return statusRejectedBg;
      case 'cancelled':
      case 'canceled':
        return statusCancelledBg;
      default:
        return backgroundLight;
    }
  }
}

