import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Primary action button with TSL brand styling
///
/// Features:
/// - Brand red color (#D32F2F)
/// - Loading state with spinner
/// - Icon support (leading/trailing)
/// - Full width option
/// - Size variants (small, medium, large)
class TslPrimaryButton extends StatelessWidget {
  /// Button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Whether button is in loading state
  final bool isLoading;

  /// Whether button takes full width
  final bool isFullWidth;

  /// Leading icon
  final IconData? leadingIcon;

  /// Trailing icon
  final IconData? trailingIcon;

  /// Button size variant
  final TslButtonSize size;

  /// Custom background color (overrides brand red)
  final Color? backgroundColor;

  /// Custom text color
  final Color? textColor;

  /// Button elevation
  final double elevation;

  const TslPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.size = TslButtonSize.medium,
    this.backgroundColor,
    this.textColor,
    this.elevation = 2,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final isDisabled = onPressed == null || isLoading;

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: dimensions.iconSize,
            height: dimensions.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? AppColors.textOnPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (leadingIcon != null) ...[
          Icon(
            leadingIcon,
            size: dimensions.iconSize,
            color: textColor ?? AppColors.textOnPrimary,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          label,
          style: dimensions.textStyle.copyWith(
            color: textColor ?? AppColors.textOnPrimary,
          ),
        ),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(
            trailingIcon,
            size: dimensions.iconSize,
            color: textColor ?? AppColors.textOnPrimary,
          ),
        ],
      ],
    );

    final button = ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.disabled,
        disabledForegroundColor: AppColors.textDisabled,
        elevation: isDisabled ? 0 : elevation,
        shadowColor: AppColors.primary.withValues(alpha: 0.4),
        padding: EdgeInsets.symmetric(
          horizontal: dimensions.horizontalPadding,
          vertical: dimensions.verticalPadding,
        ),
        minimumSize: Size(
          dimensions.minWidth,
          dimensions.height,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusButton,
        ),
      ),
      child: buttonChild,
    );

    final wrappedButton = Semantics(
      label: label,
      button: true,
      enabled: !isDisabled,
      child: button,
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: wrappedButton,
      );
    }

    return wrappedButton;
  }

  _ButtonDimensions _getDimensions() {
    switch (size) {
      case TslButtonSize.small:
        return _ButtonDimensions(
          height: 44,
          minWidth: 64,
          horizontalPadding: AppSpacing.md,
          verticalPadding: AppSpacing.xs,
          iconSize: 16,
          textStyle: AppTypography.labelMedium,
        );
      case TslButtonSize.medium:
        return _ButtonDimensions(
          height: 48,
          minWidth: 88,
          horizontalPadding: AppSpacing.lg,
          verticalPadding: AppSpacing.md,
          iconSize: 20,
          textStyle: AppTypography.labelLarge,
        );
      case TslButtonSize.large:
        return _ButtonDimensions(
          height: 56,
          minWidth: 120,
          horizontalPadding: AppSpacing.xl,
          verticalPadding: AppSpacing.lg,
          iconSize: 24,
          textStyle: AppTypography.labelLarge.copyWith(fontSize: 18),
        );
    }
  }
}

/// Button size variants
enum TslButtonSize {
  small,
  medium,
  large,
}

/// Internal class for button dimensions
class _ButtonDimensions {
  final double height;
  final double minWidth;
  final double horizontalPadding;
  final double verticalPadding;
  final double iconSize;
  final TextStyle textStyle;

  const _ButtonDimensions({
    required this.height,
    required this.minWidth,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.iconSize,
    required this.textStyle,
  });
}

/// Icon-only primary button variant
class TslPrimaryIconButton extends StatelessWidget {
  /// Button icon
  final IconData icon;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Whether button is in loading state
  final bool isLoading;

  /// Button size variant
  final TslButtonSize size;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom icon color
  final Color? iconColor;

  /// Tooltip text
  final String? tooltip;

  const TslPrimaryIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.size = TslButtonSize.medium,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final isDisabled = onPressed == null || isLoading;

    Widget button = Material(
      color: isDisabled
          ? AppColors.disabled
          : backgroundColor ?? AppColors.primary,
      borderRadius: AppRadius.radiusButton,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: AppRadius.radiusButton,
        child: SizedBox(
          width: dimensions.size,
          height: dimensions.size,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: dimensions.iconSize,
                    height: dimensions.iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        iconColor ?? AppColors.textOnPrimary,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    size: dimensions.iconSize,
                    color: isDisabled
                        ? AppColors.textDisabled
                        : iconColor ?? AppColors.textOnPrimary,
                  ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  _IconButtonDimensions _getDimensions() {
    switch (size) {
      case TslButtonSize.small:
        return const _IconButtonDimensions(size: 36, iconSize: 18);
      case TslButtonSize.medium:
        return const _IconButtonDimensions(size: 48, iconSize: 24);
      case TslButtonSize.large:
        return const _IconButtonDimensions(size: 56, iconSize: 28);
    }
  }
}

/// Internal class for icon button dimensions
class _IconButtonDimensions {
  final double size;
  final double iconSize;

  const _IconButtonDimensions({
    required this.size,
    required this.iconSize,
  });
}

