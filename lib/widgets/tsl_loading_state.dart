import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Loading state widget with progress indicator and message
///
/// Features:
/// - Circular or linear progress indicator
/// - Optional message text
/// - Size variants
/// - Customizable appearance
class TslLoadingState extends StatelessWidget {
  /// Loading message
  final String? message;

  /// Whether to use linear progress indicator
  final bool isLinear;

  /// Progress value (null for indeterminate)
  final double? progress;

  /// Custom color
  final Color? color;

  /// Size variant
  final TslLoadingSize size;

  /// Padding around the widget
  final EdgeInsetsGeometry padding;

  const TslLoadingState({
    super.key,
    this.message,
    this.isLinear = false,
    this.progress,
    this.color,
    this.size = TslLoadingSize.medium,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  /// Factory for full screen loading overlay
  factory TslLoadingState.fullScreen({
    String? message,
    Color? color,
  }) {
    return TslLoadingState(
      message: message,
      color: color,
      size: TslLoadingSize.large,
    );
  }

  /// Factory for inline loading indicator
  factory TslLoadingState.inline({
    String? message,
    Color? color,
  }) {
    return TslLoadingState(
      message: message,
      color: color,
      size: TslLoadingSize.small,
      padding: const EdgeInsets.all(AppSpacing.md),
    );
  }

  /// Factory for button loading state
  factory TslLoadingState.button({Color? color}) {
    return TslLoadingState(
      color: color ?? AppColors.textOnPrimary,
      size: TslLoadingSize.tiny,
      padding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final effectiveColor = color ?? AppColors.primary;

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLinear)
              SizedBox(
                width: dimensions.linearWidth,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: effectiveColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                  minHeight: dimensions.linearHeight,
                  borderRadius: BorderRadius.circular(dimensions.linearHeight / 2),
                ),
              )
            else
              SizedBox(
                width: dimensions.circularSize,
                height: dimensions.circularSize,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: dimensions.strokeWidth,
                  backgroundColor: effectiveColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                ),
              ),
            if (message != null) ...[
              SizedBox(height: dimensions.spacing),
              Text(
                message!,
                style: dimensions.textStyle.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  _LoadingDimensions _getDimensions() {
    switch (size) {
      case TslLoadingSize.tiny:
        return _LoadingDimensions(
          circularSize: 16,
          strokeWidth: 2,
          linearWidth: 100,
          linearHeight: 2,
          spacing: AppSpacing.xs,
          textStyle: AppTypography.caption,
        );
      case TslLoadingSize.small:
        return _LoadingDimensions(
          circularSize: 24,
          strokeWidth: 2.5,
          linearWidth: 150,
          linearHeight: 3,
          spacing: AppSpacing.sm,
          textStyle: AppTypography.bodySmall,
        );
      case TslLoadingSize.medium:
        return _LoadingDimensions(
          circularSize: 40,
          strokeWidth: 3,
          linearWidth: 200,
          linearHeight: 4,
          spacing: AppSpacing.md,
          textStyle: AppTypography.bodyMedium,
        );
      case TslLoadingSize.large:
        return _LoadingDimensions(
          circularSize: 56,
          strokeWidth: 4,
          linearWidth: 280,
          linearHeight: 6,
          spacing: AppSpacing.lg,
          textStyle: AppTypography.bodyLarge,
        );
    }
  }
}

/// Loading size variants
enum TslLoadingSize {
  tiny,
  small,
  medium,
  large,
}

/// Internal class for loading dimensions
class _LoadingDimensions {
  final double circularSize;
  final double strokeWidth;
  final double linearWidth;
  final double linearHeight;
  final double spacing;
  final TextStyle textStyle;

  const _LoadingDimensions({
    required this.circularSize,
    required this.strokeWidth,
    required this.linearWidth,
    required this.linearHeight,
    required this.spacing,
    required this.textStyle,
  });
}

/// Full screen loading overlay
class TslLoadingOverlay extends StatelessWidget {
  /// Child widget to overlay
  final Widget child;

  /// Whether to show loading overlay
  final bool isLoading;

  /// Loading message
  final String? message;

  /// Overlay background color
  final Color? overlayColor;

  /// Progress indicator color
  final Color? progressColor;

  /// Whether to allow interaction with child while loading
  final bool allowInteraction;

  const TslLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.overlayColor,
    this.progressColor,
    this.allowInteraction = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: !allowInteraction,
              child: Container(
                color: overlayColor ?? Colors.black.withValues(alpha: 0.3),
                child: TslLoadingState.fullScreen(
                  message: message,
                  color: progressColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Shimmer loading placeholder
class TslShimmer extends StatefulWidget {
  /// Child widget to apply shimmer effect to
  final Widget child;

  /// Base color for shimmer
  final Color? baseColor;

  /// Highlight color for shimmer
  final Color? highlightColor;

  /// Duration of shimmer animation
  final Duration duration;

  const TslShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<TslShimmer> createState() => _TslShimmerState();
}

class _TslShimmerState extends State<TslShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? AppColors.disabled;
    final highlightColor = widget.highlightColor ?? AppColors.cardWhite;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Transform for sliding gradient effect
class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

/// Shimmer placeholder for list items
class TslShimmerListItem extends StatelessWidget {
  /// Height of the item
  final double height;

  /// Whether to show leading circle
  final bool hasLeading;

  /// Whether to show trailing
  final bool hasTrailing;

  /// Number of text lines
  final int lines;

  const TslShimmerListItem({
    super.key,
    this.height = 72,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.lines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return TslShimmer(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            if (hasLeading) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.disabled,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  lines,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index < lines - 1 ? AppSpacing.sm : 0,
                    ),
                    child: Container(
                      height: index == 0 ? 16 : 12,
                      width: index == 0 ? double.infinity : 150,
                      decoration: BoxDecoration(
                        color: AppColors.disabled,
                        borderRadius: AppRadius.radiusSm,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (hasTrailing) ...[
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.disabled,
                  borderRadius: AppRadius.radiusSm,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for cards
class TslShimmerCard extends StatelessWidget {
  /// Card height
  final double height;

  /// Card width (null for full width)
  final double? width;

  const TslShimmerCard({
    super.key,
    this.height = 120,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return TslShimmer(
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.disabled,
          borderRadius: AppRadius.radiusCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.cardWhite.withValues(alpha: 0.3),
                borderRadius: AppRadius.radiusSm,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardWhite.withValues(alpha: 0.3),
                borderRadius: AppRadius.radiusSm,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 14,
              width: 200,
              decoration: BoxDecoration(
                color: AppColors.cardWhite.withValues(alpha: 0.3),
                borderRadius: AppRadius.radiusSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

