import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Section header with title and optional "View All" action
///
/// Used to introduce sections in lists/screens with consistent styling
class TslSectionHeader extends StatelessWidget {
  /// Section title
  final String title;

  /// Optional subtitle
  final String? subtitle;

  /// "View All" or custom action text
  final String? actionText;

  /// Callback when action is tapped
  final VoidCallback? onActionTap;

  /// Callback for "View All" action (alias for onActionTap)
  final VoidCallback? onViewAll;

  /// Custom action widget (overrides actionText)
  final Widget? actionWidget;

  /// Custom trailing widget
  final Widget? trailing;

  /// Leading icon (alias for leadingIcon)
  final IconData? icon;

  /// Leading icon
  final IconData? leadingIcon;

  /// Leading icon color
  final Color? leadingIconColor;

  /// Title text style
  final TextStyle? titleStyle;

  /// Padding around the header
  final EdgeInsetsGeometry padding;

  const TslSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionTap,
    this.onViewAll,
    this.actionWidget,
    this.trailing,
    this.icon,
    this.leadingIcon,
    this.leadingIconColor,
    this.titleStyle,
    this.padding = EdgeInsets.zero,
  });

  IconData? get _effectiveIcon => leadingIcon ?? icon;
  VoidCallback? get _effectiveOnAction => onActionTap ?? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_effectiveIcon != null) ...[
            Icon(
              _effectiveIcon,
              size: 24,
              color: leadingIconColor ?? AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle ?? AppTypography.h3,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (actionWidget != null)
            actionWidget!
          else if (actionText != null || _effectiveOnAction != null)
            TextButton(
              onPressed: _effectiveOnAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText ?? 'View All',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact section header variant
class TslSectionHeaderCompact extends StatelessWidget {
  /// Section title
  final String title;

  /// Count badge value
  final int? count;

  /// Callback when header is tapped
  final VoidCallback? onTap;

  const TslSectionHeaderCompact({
    super.key,
    required this.title,
    this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.radiusChip,
                ),
                child: Text(
                  count.toString(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
            const Spacer(),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

/// Section divider with optional label
class TslSectionDivider extends StatelessWidget {
  /// Optional label to display on divider
  final String? label;

  /// Divider thickness
  final double thickness;

  /// Divider color
  final Color? color;

  /// Padding around the divider
  final EdgeInsetsGeometry padding;

  const TslSectionDivider({
    super.key,
    this.label,
    this.thickness = 1,
    this.color,
    this.padding = const EdgeInsets.symmetric(vertical: AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Padding(
        padding: padding,
        child: Divider(
          thickness: thickness,
          color: color ?? AppColors.divider,
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: thickness,
              color: color ?? AppColors.divider,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              label!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              thickness: thickness,
              color: color ?? AppColors.divider,
            ),
          ),
        ],
      ),
    );
  }
}

