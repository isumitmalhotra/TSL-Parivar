import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Color-coded status badge/pill widget
///
/// Used to display status indicators like:
/// - Assigned, In Progress, Pending, Completed, Rejected, Cancelled
class TslStatusPill extends StatelessWidget {
  /// Status text to display
  final String status;

  /// Status type for automatic color coding
  final TslStatus statusType;

  /// Custom background color (overrides statusType color)
  final Color? backgroundColor;

  /// Custom text color (overrides statusType color)
  final Color? textColor;

  /// Size variant
  final TslStatusPillSize size;

  /// Whether to show status icon
  final bool showIcon;

  /// Custom icon (overrides default icon)
  final IconData? icon;

  const TslStatusPill({
    super.key,
    required this.status,
    required this.statusType,
    this.backgroundColor,
    this.textColor,
    this.size = TslStatusPillSize.medium,
    this.showIcon = false,
    this.icon,
  });

  /// Factory constructor for 'Assigned' status
  factory TslStatusPill.assigned({
    String status = 'Assigned',
    TslStatusPillSize size = TslStatusPillSize.medium,
    bool showIcon = false,
  }) {
    return TslStatusPill(
      status: status,
      statusType: TslStatus.assigned,
      size: size,
      showIcon: showIcon,
    );
  }

  /// Factory constructor for 'In Progress' status
  factory TslStatusPill.inProgress({
    String status = 'In Progress',
    TslStatusPillSize size = TslStatusPillSize.medium,
    bool showIcon = false,
  }) {
    return TslStatusPill(
      status: status,
      statusType: TslStatus.inProgress,
      size: size,
      showIcon: showIcon,
    );
  }

  /// Factory constructor for 'Pending' status
  factory TslStatusPill.pending({
    String status = 'Pending',
    TslStatusPillSize size = TslStatusPillSize.medium,
    bool showIcon = false,
  }) {
    return TslStatusPill(
      status: status,
      statusType: TslStatus.pending,
      size: size,
      showIcon: showIcon,
    );
  }

  /// Factory constructor for 'Completed' status
  factory TslStatusPill.completed({
    String status = 'Completed',
    TslStatusPillSize size = TslStatusPillSize.medium,
    bool showIcon = false,
  }) {
    return TslStatusPill(
      status: status,
      statusType: TslStatus.completed,
      size: size,
      showIcon: showIcon,
    );
  }

  /// Factory constructor for 'Rejected' status
  factory TslStatusPill.rejected({
    String status = 'Rejected',
    TslStatusPillSize size = TslStatusPillSize.medium,
    bool showIcon = false,
  }) {
    return TslStatusPill(
      status: status,
      statusType: TslStatus.rejected,
      size: size,
      showIcon: showIcon,
    );
  }

  /// Factory constructor for 'Cancelled' status
  factory TslStatusPill.cancelled({
    String status = 'Cancelled',
    TslStatusPillSize size = TslStatusPillSize.medium,
    bool showIcon = false,
  }) {
    return TslStatusPill(
      status: status,
      statusType: TslStatus.cancelled,
      size: size,
      showIcon: showIcon,
    );
  }

  /// Factory constructor from status string
  /// Accepts status keys like 'assigned', 'in_progress', 'pending', etc.
  factory TslStatusPill.fromStatus(
    String statusKey, {
    TslStatusPillSize size = TslStatusPillSize.medium,
    bool showIcon = false,
  }) {
    final statusType = _parseStatusKey(statusKey);
    final displayName = _getDisplayName(statusType);
    return TslStatusPill(
      status: displayName,
      statusType: statusType,
      size: size,
      showIcon: showIcon,
    );
  }

  static TslStatus _parseStatusKey(String key) {
    switch (key.toLowerCase()) {
      case 'assigned':
        return TslStatus.assigned;
      case 'in_progress':
      case 'inprogress':
        return TslStatus.inProgress;
      case 'pending':
      case 'pending_approval':
        return TslStatus.pending;
      case 'completed':
      case 'delivered':
        return TslStatus.completed;
      case 'rejected':
        return TslStatus.rejected;
      case 'cancelled':
      case 'canceled':
        return TslStatus.cancelled;
      default:
        return TslStatus.pending;
    }
  }

  static String _getDisplayName(TslStatus status) {
    switch (status) {
      case TslStatus.assigned:
        return 'Assigned';
      case TslStatus.inProgress:
        return 'In Progress';
      case TslStatus.pending:
        return 'Pending';
      case TslStatus.completed:
        return 'Completed';
      case TslStatus.rejected:
        return 'Rejected';
      case TslStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final dimensions = _getDimensions();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions.horizontalPadding,
        vertical: dimensions.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.background,
        borderRadius: AppRadius.radiusChip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon ?? _getDefaultIcon(),
              size: dimensions.iconSize,
              color: textColor ?? colors.text,
            ),
            SizedBox(width: dimensions.iconSpacing),
          ],
          Text(
            status,
            style: dimensions.textStyle.copyWith(
              color: textColor ?? colors.text,
            ),
          ),
        ],
      ),
    );
  }

  _StatusColors _getColors() {
    switch (statusType) {
      case TslStatus.assigned:
        return _StatusColors(
          background: AppColors.infoContainer,
          text: AppColors.info,
        );
      case TslStatus.inProgress:
        return _StatusColors(
          background: AppColors.warningContainer,
          text: AppColors.warningDark,
        );
      case TslStatus.pending:
        return _StatusColors(
          background: AppColors.secondaryContainer,
          text: AppColors.secondary,
        );
      case TslStatus.completed:
        return _StatusColors(
          background: AppColors.successContainer,
          text: AppColors.success,
        );
      case TslStatus.rejected:
        return _StatusColors(
          background: AppColors.errorContainer,
          text: AppColors.error,
        );
      case TslStatus.cancelled:
        return _StatusColors(
          background: AppColors.disabled,
          text: AppColors.textSecondary,
        );
    }
  }

  _StatusDimensions _getDimensions() {
    switch (size) {
      case TslStatusPillSize.small:
        return _StatusDimensions(
          horizontalPadding: AppSpacing.sm,
          verticalPadding: 2,
          iconSize: 12,
          iconSpacing: AppSpacing.xxs,
          textStyle: AppTypography.caption,
        );
      case TslStatusPillSize.medium:
        return _StatusDimensions(
          horizontalPadding: AppSpacing.md,
          verticalPadding: AppSpacing.xs,
          iconSize: 14,
          iconSpacing: AppSpacing.xs,
          textStyle: AppTypography.labelMedium,
        );
      case TslStatusPillSize.large:
        return _StatusDimensions(
          horizontalPadding: AppSpacing.lg,
          verticalPadding: AppSpacing.sm,
          iconSize: 16,
          iconSpacing: AppSpacing.sm,
          textStyle: AppTypography.labelLarge,
        );
    }
  }

  IconData _getDefaultIcon() {
    switch (statusType) {
      case TslStatus.assigned:
        return Icons.assignment_outlined;
      case TslStatus.inProgress:
        return Icons.autorenew;
      case TslStatus.pending:
        return Icons.schedule;
      case TslStatus.completed:
        return Icons.check_circle_outline;
      case TslStatus.rejected:
        return Icons.cancel_outlined;
      case TslStatus.cancelled:
        return Icons.block;
    }
  }
}

/// Status types
enum TslStatus {
  assigned,
  inProgress,
  pending,
  completed,
  rejected,
  cancelled,
}

/// Status pill size variants
enum TslStatusPillSize {
  small,
  medium,
  large,
}

/// Internal class for status colors
class _StatusColors {
  final Color background;
  final Color text;

  const _StatusColors({
    required this.background,
    required this.text,
  });
}

/// Internal class for status dimensions
class _StatusDimensions {
  final double horizontalPadding;
  final double verticalPadding;
  final double iconSize;
  final double iconSpacing;
  final TextStyle textStyle;

  const _StatusDimensions({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.iconSize,
    required this.iconSpacing,
    required this.textStyle,
  });
}

/// Extension to create status pill from string
extension TslStatusPillExtension on String {
  TslStatusPill toStatusPill({
    TslStatusPillSize size = TslStatusPillSize.medium,
    bool showIcon = false,
  }) {
    final status = toLowerCase();

    if (status.contains('assign')) {
      return TslStatusPill.assigned(status: this, size: size, showIcon: showIcon);
    } else if (status.contains('progress')) {
      return TslStatusPill.inProgress(status: this, size: size, showIcon: showIcon);
    } else if (status.contains('pending')) {
      return TslStatusPill.pending(status: this, size: size, showIcon: showIcon);
    } else if (status.contains('complete')) {
      return TslStatusPill.completed(status: this, size: size, showIcon: showIcon);
    } else if (status.contains('reject')) {
      return TslStatusPill.rejected(status: this, size: size, showIcon: showIcon);
    } else if (status.contains('cancel')) {
      return TslStatusPill.cancelled(status: this, size: size, showIcon: showIcon);
    }

    // Default to pending if no match
    return TslStatusPill.pending(status: this, size: size, showIcon: showIcon);
  }
}

