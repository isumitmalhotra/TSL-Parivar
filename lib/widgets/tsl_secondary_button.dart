import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import 'tsl_primary_button.dart';

/// Secondary outlined button with TSL styling
///
/// Features:
/// - Outlined style with brand red border
/// - Loading state with spinner
/// - Icon support (leading/trailing)
/// - Full width option
/// - Size variants (small, medium, large)
class TslSecondaryButton extends StatelessWidget {
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

  /// Custom border/text color
  final Color? color;

  /// Custom background color
  final Color? backgroundColor;

  /// Border width
  final double borderWidth;

  const TslSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.size = TslButtonSize.medium,
    this.color,
    this.backgroundColor,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final isDisabled = onPressed == null || isLoading;
    final effectiveColor = isDisabled
        ? AppColors.textDisabled
        : color ?? AppColors.primary;

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
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (leadingIcon != null) ...[
          Icon(
            leadingIcon,
            size: dimensions.iconSize,
            color: effectiveColor,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          label,
          style: dimensions.textStyle.copyWith(
            color: effectiveColor,
          ),
        ),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(
            trailingIcon,
            size: dimensions.iconSize,
            color: effectiveColor,
          ),
        ],
      ],
    );

    final button = OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: effectiveColor,
        backgroundColor: backgroundColor ?? Colors.transparent,
        disabledForegroundColor: AppColors.textDisabled,
        side: BorderSide(
          color: isDisabled ? AppColors.border : effectiveColor,
          width: borderWidth,
        ),
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

/// Secondary icon-only button variant
class TslSecondaryIconButton extends StatelessWidget {
  /// Button icon
  final IconData icon;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Whether button is in loading state
  final bool isLoading;

  /// Button size variant
  final TslButtonSize size;

  /// Custom border/icon color
  final Color? color;

  /// Custom background color
  final Color? backgroundColor;

  /// Tooltip text
  final String? tooltip;

  /// Border width
  final double borderWidth;

  const TslSecondaryIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.size = TslButtonSize.medium,
    this.color,
    this.backgroundColor,
    this.tooltip,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final isDisabled = onPressed == null || isLoading;
    final effectiveColor = isDisabled
        ? AppColors.textDisabled
        : color ?? AppColors.primary;

    Widget button = Container(
      width: dimensions.size,
      height: dimensions.size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: AppRadius.radiusButton,
        border: Border.all(
          color: isDisabled ? AppColors.border : effectiveColor,
          width: borderWidth,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: AppRadius.radiusButton,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: dimensions.iconSize,
                    height: dimensions.iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                    ),
                  )
                : Icon(
                    icon,
                    size: dimensions.iconSize,
                    color: effectiveColor,
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
        return const _IconButtonDimensions(size: 44, iconSize: 18);
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

/// Text button variant for tertiary actions
class TslTextButton extends StatelessWidget {
  /// Button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Whether button is in loading state
  final bool isLoading;

  /// Leading icon
  final IconData? leadingIcon;

  /// Trailing icon
  final IconData? trailingIcon;

  /// Button size variant
  final TslButtonSize size;

  /// Custom text color
  final Color? color;

  const TslTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.size = TslButtonSize.medium,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final isDisabled = onPressed == null || isLoading;
    final effectiveColor = isDisabled
        ? AppColors.textDisabled
        : color ?? AppColors.primary;

    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveColor,
        padding: EdgeInsets.symmetric(
          horizontal: dimensions.horizontalPadding,
          vertical: dimensions.verticalPadding,
        ),
        minimumSize: Size(0, dimensions.height),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusButton,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: dimensions.iconSize,
              height: dimensions.iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ] else if (leadingIcon != null) ...[
            Icon(
              leadingIcon,
              size: dimensions.iconSize,
              color: effectiveColor,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: dimensions.textStyle.copyWith(
              color: effectiveColor,
            ),
          ),
          if (trailingIcon != null && !isLoading) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(
              trailingIcon,
              size: dimensions.iconSize,
              color: effectiveColor,
            ),
          ],
        ],
      ),
    );
  }

  _ButtonDimensions _getDimensions() {
    switch (size) {
      case TslButtonSize.small:
        return _ButtonDimensions(
          height: 44,
          minWidth: 0,
          horizontalPadding: AppSpacing.sm,
          verticalPadding: AppSpacing.xs,
          iconSize: 16,
          textStyle: AppTypography.labelMedium,
        );
      case TslButtonSize.medium:
        return _ButtonDimensions(
          height: 44,
          minWidth: 0,
          horizontalPadding: AppSpacing.md,
          verticalPadding: AppSpacing.sm,
          iconSize: 18,
          textStyle: AppTypography.labelLarge,
        );
      case TslButtonSize.large:
        return _ButtonDimensions(
          height: 48,
          minWidth: 0,
          horizontalPadding: AppSpacing.lg,
          verticalPadding: AppSpacing.md,
          iconSize: 20,
          textStyle: AppTypography.labelLarge,
        );
    }
  }
}

