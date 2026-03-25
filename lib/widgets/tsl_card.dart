import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Reusable card widget for TSL Parivar app
///
/// Features:
/// - Leading icon/widget support
/// - Title and subtitle
/// - Status indicator
/// - Trailing widget
/// - Customizable appearance
/// - Tap and long press callbacks
class TslCard extends StatelessWidget {
  /// Leading widget (usually an icon or avatar)
  final Widget? leading;

  /// Card title
  final String? title;

  /// Title widget (overrides [title])
  final Widget? titleWidget;

  /// Card subtitle
  final String? subtitle;

  /// Subtitle widget (overrides [subtitle])
  final Widget? subtitleWidget;

  /// Status text to display
  final String? status;

  /// Status type for color coding
  final TslCardStatus? statusType;

  /// Trailing widget
  final Widget? trailing;

  /// Card content (displayed below title/subtitle)
  final Widget? content;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when card is long pressed
  final VoidCallback? onLongPress;

  /// Card padding
  final EdgeInsetsGeometry padding;

  /// Card margin
  final EdgeInsetsGeometry margin;

  /// Card background color
  final Color? backgroundColor;

  /// Card border color
  final Color? borderColor;

  /// Whether card has shadow
  final bool hasShadow;

  /// Card elevation level
  final TslCardElevation elevation;

  /// Whether card is selected
  final bool isSelected;

  /// Whether card is disabled
  final bool isDisabled;

  const TslCard({
    super.key,
    this.leading,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.status,
    this.statusType,
    this.trailing,
    this.content,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.borderColor,
    this.hasShadow = true,
    this.elevation = TslCardElevation.sm,
    this.isSelected = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = isDisabled
        ? AppColors.disabled
        : isSelected
            ? AppColors.primaryContainer
            : backgroundColor ?? AppColors.cardWhite;

    final effectiveBorderColor = isSelected
        ? AppColors.primary
        : borderColor ?? Colors.transparent;

    return Padding(
      padding: margin,
      child: Material(
        color: effectiveBackgroundColor,
        borderRadius: AppRadius.radiusCard,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusCard,
            border: Border.all(
              color: effectiveBorderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: hasShadow && !isDisabled
                ? _getShadow(elevation)
                : null,
          ),
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            onLongPress: isDisabled ? null : onLongPress,
            borderRadius: AppRadius.radiusCard,
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  if (content != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    content!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hasHeader = leading != null ||
        title != null ||
        titleWidget != null ||
        subtitle != null ||
        subtitleWidget != null ||
        status != null ||
        trailing != null;

    if (!hasHeader) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (titleWidget != null)
                titleWidget!
              else if (title != null)
                Text(
                  title!,
                  style: AppTypography.h3.copyWith(
                    color: isDisabled
                        ? AppColors.textDisabled
                        : AppColors.textPrimary,
                  ),
                ),
              if (subtitleWidget != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                subtitleWidget!,
              ] else if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDisabled
                        ? AppColors.textDisabled
                        : AppColors.textSecondary,
                  ),
                ),
              ],
              if (status != null && statusType != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _StatusBadge(
                  status: status!,
                  statusType: statusType!,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }

  List<BoxShadow>? _getShadow(TslCardElevation elevation) {
    switch (elevation) {
      case TslCardElevation.none:
        return null;
      case TslCardElevation.xs:
        return AppShadows.xs;
      case TslCardElevation.sm:
        return AppShadows.sm;
      case TslCardElevation.md:
        return AppShadows.md;
      case TslCardElevation.lg:
        return AppShadows.lg;
      case TslCardElevation.xl:
        return AppShadows.xl;
    }
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final String status;
  final TslCardStatus statusType;

  const _StatusBadge({
    required this.status,
    required this.statusType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: AppRadius.radiusChip,
      ),
      child: Text(
        status,
        style: AppTypography.labelSmall.copyWith(
          color: _getTextColor(),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (statusType) {
      case TslCardStatus.assigned:
        return AppColors.infoContainer;
      case TslCardStatus.inProgress:
        return AppColors.warningContainer;
      case TslCardStatus.pending:
        return AppColors.secondaryContainer;
      case TslCardStatus.completed:
        return AppColors.successContainer;
      case TslCardStatus.rejected:
        return AppColors.errorContainer;
      case TslCardStatus.cancelled:
        return AppColors.disabled;
    }
  }

  Color _getTextColor() {
    switch (statusType) {
      case TslCardStatus.assigned:
        return AppColors.info;
      case TslCardStatus.inProgress:
        return AppColors.warning;
      case TslCardStatus.pending:
        return AppColors.secondary;
      case TslCardStatus.completed:
        return AppColors.success;
      case TslCardStatus.rejected:
        return AppColors.error;
      case TslCardStatus.cancelled:
        return AppColors.textSecondary;
    }
  }
}

/// Card status types for color coding
enum TslCardStatus {
  assigned,
  inProgress,
  pending,
  completed,
  rejected,
  cancelled,
}

/// Card elevation levels
enum TslCardElevation {
  none,
  xs,
  sm,
  md,
  lg,
  xl,
}

/// Icon card variant for quick actions
class TslIconCard extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Card label
  final String label;

  /// Optional subtitle
  final String? subtitle;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Icon color
  final Color? iconColor;

  /// Background color
  final Color? backgroundColor;

  /// Whether card is compact
  final bool isCompact;

  const TslIconCard({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.cardWhite,
      borderRadius: AppRadius.radiusCard,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusCard,
        child: Container(
          padding: EdgeInsets.all(isCompact ? AppSpacing.md : AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusCard,
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isCompact ? 40 : 56,
                height: isCompact ? 40 : 56,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  icon,
                  size: isCompact ? 20 : 28,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
              SizedBox(height: isCompact ? AppSpacing.sm : AppSpacing.md),
              Text(
                label,
                style: isCompact
                    ? AppTypography.labelMedium
                    : AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Stats card for displaying KPIs
class TslStatsCard extends StatelessWidget {
  /// Stat value
  final String value;

  /// Stat label
  final String label;

  /// Optional icon
  final IconData? icon;

  /// Icon/accent color
  final Color? accentColor;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Trend indicator (+/- percentage)
  final String? trend;

  /// Whether trend is positive
  final bool? isTrendPositive;

  const TslStatsCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.accentColor,
    this.onTap,
    this.trend,
    this.isTrendPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return Material(
      color: AppColors.cardWhite,
      borderRadius: AppRadius.radiusCard,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusCard,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusCard,
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (icon != null)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: AppRadius.radiusSm,
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: color,
                      ),
                    ),
                  if (trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: isTrendPositive == true
                            ? AppColors.successContainer
                            : isTrendPositive == false
                                ? AppColors.errorContainer
                                : AppColors.disabled,
                        borderRadius: AppRadius.radiusChip,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isTrendPositive == true
                                ? Icons.trending_up
                                : isTrendPositive == false
                                    ? Icons.trending_down
                                    : Icons.trending_flat,
                            size: 14,
                            color: isTrendPositive == true
                                ? AppColors.success
                                : isTrendPositive == false
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            trend!,
                            style: AppTypography.caption.copyWith(
                              color: isTrendPositive == true
                                  ? AppColors.success
                                  : isTrendPositive == false
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                value,
                style: AppTypography.h1.copyWith(
                  color: color,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

