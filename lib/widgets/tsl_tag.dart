import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Chip/tag widget for categories, products, skills, etc.
///
/// Features:
/// - Multiple color variants
/// - Selectable state
/// - Dismissible option
/// - Icon support
/// - Size variants
class TslTag extends StatelessWidget {
  /// Tag label
  final String label;

  /// Tag color variant
  final TslTagVariant variant;

  /// Whether tag is selected
  final bool isSelected;

  /// Callback when tag is tapped
  final VoidCallback? onTap;

  /// Callback when tag is dismissed (shows X button)
  final VoidCallback? onDismiss;

  /// Leading icon
  final IconData? leadingIcon;

  /// Tag size
  final TslTagSize size;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom text/icon color
  final Color? foregroundColor;

  const TslTag({
    super.key,
    required this.label,
    this.variant = TslTagVariant.primary,
    this.isSelected = false,
    this.onTap,
    this.onDismiss,
    this.leadingIcon,
    this.size = TslTagSize.medium,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Factory for category tags
  factory TslTag.category(String label, {VoidCallback? onTap}) {
    return TslTag(
      label: label,
      variant: TslTagVariant.primary,
      onTap: onTap,
    );
  }

  /// Factory for product tags
  factory TslTag.product(String label, {VoidCallback? onTap}) {
    return TslTag(
      label: label,
      variant: TslTagVariant.secondary,
      leadingIcon: Icons.inventory_2_outlined,
      onTap: onTap,
    );
  }

  /// Factory for skill tags
  factory TslTag.skill(String label, {VoidCallback? onTap}) {
    return TslTag(
      label: label,
      variant: TslTagVariant.info,
      leadingIcon: Icons.star_outline,
      onTap: onTap,
    );
  }

  /// Factory for filter tags
  factory TslTag.filter(
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return TslTag(
      label: label,
      variant: TslTagVariant.outline,
      isSelected: isSelected,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final dimensions = _getDimensions();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusChip,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: dimensions.horizontalPadding,
            vertical: dimensions.verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.selectedBackground
                : backgroundColor ?? colors.background,
            borderRadius: AppRadius.radiusChip,
            border: variant == TslTagVariant.outline
                ? Border.all(
                    color: isSelected
                        ? colors.selectedBorder
                        : colors.border,
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(
                  leadingIcon,
                  size: dimensions.iconSize,
                  color: isSelected
                      ? colors.selectedForeground
                      : foregroundColor ?? colors.foreground,
                ),
                SizedBox(width: dimensions.iconSpacing),
              ],
              Text(
                label,
                style: dimensions.textStyle.copyWith(
                  color: isSelected
                      ? colors.selectedForeground
                      : foregroundColor ?? colors.foreground,
                ),
              ),
              if (onDismiss != null) ...[
                SizedBox(width: dimensions.iconSpacing),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Icons.close,
                    size: dimensions.iconSize,
                    color: isSelected
                        ? colors.selectedForeground
                        : foregroundColor ?? colors.foreground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _TagColors _getColors() {
    switch (variant) {
      case TslTagVariant.primary:
        return _TagColors(
          background: AppColors.primaryContainer,
          foreground: AppColors.primary,
          border: AppColors.primary,
          selectedBackground: AppColors.primary,
          selectedForeground: AppColors.textOnPrimary,
          selectedBorder: AppColors.primary,
        );
      case TslTagVariant.secondary:
        return _TagColors(
          background: AppColors.secondaryContainer,
          foreground: AppColors.secondary,
          border: AppColors.secondary,
          selectedBackground: AppColors.secondary,
          selectedForeground: AppColors.textOnPrimary,
          selectedBorder: AppColors.secondary,
        );
      case TslTagVariant.success:
        return _TagColors(
          background: AppColors.successContainer,
          foreground: AppColors.success,
          border: AppColors.success,
          selectedBackground: AppColors.success,
          selectedForeground: AppColors.textOnPrimary,
          selectedBorder: AppColors.success,
        );
      case TslTagVariant.warning:
        return _TagColors(
          background: AppColors.warningContainer,
          foreground: AppColors.warningDark,
          border: AppColors.warning,
          selectedBackground: AppColors.warning,
          selectedForeground: AppColors.textPrimary,
          selectedBorder: AppColors.warning,
        );
      case TslTagVariant.error:
        return _TagColors(
          background: AppColors.errorContainer,
          foreground: AppColors.error,
          border: AppColors.error,
          selectedBackground: AppColors.error,
          selectedForeground: AppColors.textOnPrimary,
          selectedBorder: AppColors.error,
        );
      case TslTagVariant.info:
        return _TagColors(
          background: AppColors.infoContainer,
          foreground: AppColors.info,
          border: AppColors.info,
          selectedBackground: AppColors.info,
          selectedForeground: AppColors.textOnPrimary,
          selectedBorder: AppColors.info,
        );
      case TslTagVariant.neutral:
        return _TagColors(
          background: AppColors.disabled,
          foreground: AppColors.textSecondary,
          border: AppColors.border,
          selectedBackground: AppColors.textSecondary,
          selectedForeground: AppColors.textOnPrimary,
          selectedBorder: AppColors.textSecondary,
        );
      case TslTagVariant.outline:
        return _TagColors(
          background: Colors.transparent,
          foreground: AppColors.textSecondary,
          border: AppColors.border,
          selectedBackground: AppColors.primaryContainer,
          selectedForeground: AppColors.primary,
          selectedBorder: AppColors.primary,
        );
    }
  }

  _TagDimensions _getDimensions() {
    switch (size) {
      case TslTagSize.small:
        return _TagDimensions(
          horizontalPadding: AppSpacing.sm,
          verticalPadding: 2,
          iconSize: 12,
          iconSpacing: AppSpacing.xxs,
          textStyle: AppTypography.caption,
        );
      case TslTagSize.medium:
        return _TagDimensions(
          horizontalPadding: AppSpacing.md,
          verticalPadding: AppSpacing.xs,
          iconSize: 14,
          iconSpacing: AppSpacing.xs,
          textStyle: AppTypography.labelMedium,
        );
      case TslTagSize.large:
        return _TagDimensions(
          horizontalPadding: AppSpacing.lg,
          verticalPadding: AppSpacing.sm,
          iconSize: 16,
          iconSpacing: AppSpacing.sm,
          textStyle: AppTypography.labelLarge,
        );
    }
  }
}

/// Tag color variants
enum TslTagVariant {
  primary,
  secondary,
  success,
  warning,
  error,
  info,
  neutral,
  outline,
}

/// Tag size variants
enum TslTagSize {
  small,
  medium,
  large,
}

/// Internal class for tag colors
class _TagColors {
  final Color background;
  final Color foreground;
  final Color border;
  final Color selectedBackground;
  final Color selectedForeground;
  final Color selectedBorder;

  const _TagColors({
    required this.background,
    required this.foreground,
    required this.border,
    required this.selectedBackground,
    required this.selectedForeground,
    required this.selectedBorder,
  });
}

/// Internal class for tag dimensions
class _TagDimensions {
  final double horizontalPadding;
  final double verticalPadding;
  final double iconSize;
  final double iconSpacing;
  final TextStyle textStyle;

  const _TagDimensions({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.iconSize,
    required this.iconSpacing,
    required this.textStyle,
  });
}

/// Tag group widget for displaying multiple tags
class TslTagGroup extends StatelessWidget {
  /// List of tags to display
  final List<TslTag> tags;

  /// Spacing between tags
  final double spacing;

  /// Run spacing between rows
  final double runSpacing;

  /// Alignment of tags
  final WrapAlignment alignment;

  const TslTagGroup({
    super.key,
    required this.tags,
    this.spacing = AppSpacing.sm,
    this.runSpacing = AppSpacing.sm,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      children: tags,
    );
  }
}

