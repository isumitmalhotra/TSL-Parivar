import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../l10n/app_localizations.dart';
import 'tsl_primary_button.dart';
import 'tsl_secondary_button.dart';

/// Error state widget for handling various error scenarios
///
/// Features:
/// - Multiple error type presets (network, server, unknown, permission, etc.)
/// - Animated icon display
/// - Retry and secondary actions
/// - Customizable appearance
/// - Localized error messages
class TslErrorState extends StatefulWidget {
  /// Error type
  final TslErrorType type;

  /// Custom title (overrides type default)
  final String? title;

  /// Custom message (overrides type default)
  final String? message;

  /// Primary action button text
  final String? actionText;

  /// Primary action callback
  final VoidCallback? onAction;

  /// Secondary action button text
  final String? secondaryActionText;

  /// Secondary action callback
  final VoidCallback? onSecondaryAction;

  /// Custom icon
  final IconData? icon;

  /// Custom icon color
  final Color? iconColor;

  /// Whether to show animation
  final bool animate;

  /// Padding around the widget
  final EdgeInsetsGeometry padding;

  const TslErrorState({
    super.key,
    this.type = TslErrorType.unknown,
    this.title,
    this.message,
    this.actionText,
    this.onAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.icon,
    this.iconColor,
    this.animate = true,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  /// Factory for network error
  factory TslErrorState.network({
    VoidCallback? onRetry,
    String? message,
  }) {
    return TslErrorState(
      type: TslErrorType.network,
      message: message,
      onAction: onRetry,
    );
  }

  /// Factory for server error
  factory TslErrorState.server({
    VoidCallback? onRetry,
    String? message,
  }) {
    return TslErrorState(
      type: TslErrorType.server,
      message: message,
      onAction: onRetry,
    );
  }

  /// Factory for authentication error
  factory TslErrorState.auth({
    VoidCallback? onLogin,
    String? message,
  }) {
    return TslErrorState(
      type: TslErrorType.authentication,
      message: message,
      onAction: onLogin,
    );
  }

  /// Factory for permission error
  factory TslErrorState.permission({
    VoidCallback? onRequestPermission,
    String? message,
  }) {
    return TslErrorState(
      type: TslErrorType.permission,
      message: message,
      onAction: onRequestPermission,
    );
  }

  /// Factory for timeout error
  factory TslErrorState.timeout({
    VoidCallback? onRetry,
    String? message,
  }) {
    return TslErrorState(
      type: TslErrorType.timeout,
      message: message,
      onAction: onRetry,
    );
  }

  /// Factory for not found error
  factory TslErrorState.notFound({
    VoidCallback? onGoBack,
    String? message,
  }) {
    return TslErrorState(
      type: TslErrorType.notFound,
      message: message,
      onAction: onGoBack,
    );
  }

  /// Factory for maintenance error
  factory TslErrorState.maintenance({
    String? message,
  }) {
    return TslErrorState(
      type: TslErrorType.maintenance,
      message: message,
    );
  }

  /// Factory for custom error
  factory TslErrorState.custom({
    required String title,
    required String message,
    required IconData icon,
    Color? iconColor,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return TslErrorState(
      type: TslErrorType.unknown,
      title: title,
      message: message,
      icon: icon,
      iconColor: iconColor,
      actionText: actionText,
      onAction: onAction,
    );
  }

  @override
  State<TslErrorState> createState() => _TslErrorStateState();
}

class _TslErrorStateState extends State<TslErrorState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _ErrorConfig _getConfig(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (widget.type) {
      case TslErrorType.network:
        return _ErrorConfig(
          icon: Icons.wifi_off_rounded,
          title: l10n.errorNetworkTitle,
          message: l10n.errorNetworkMessage,
          actionText: l10n.commonRetry,
          iconColor: AppColors.warning,
        );
      case TslErrorType.server:
        return _ErrorConfig(
          icon: Icons.cloud_off_rounded,
          title: l10n.errorServerTitle,
          message: l10n.errorServerMessage,
          actionText: l10n.commonRetry,
          iconColor: AppColors.error,
        );
      case TslErrorType.authentication:
        return _ErrorConfig(
          icon: Icons.lock_outline_rounded,
          title: 'Session Expired',
          message: 'Please log in again to continue.',
          actionText: 'Log In',
          iconColor: AppColors.warning,
        );
      case TslErrorType.permission:
        return _ErrorConfig(
          icon: Icons.security_rounded,
          title: 'Permission Required',
          message: 'This feature requires additional permissions to work properly.',
          actionText: 'Grant Permission',
          iconColor: AppColors.info,
        );
      case TslErrorType.timeout:
        return _ErrorConfig(
          icon: Icons.timer_off_rounded,
          title: 'Request Timeout',
          message: 'The request took too long. Please check your connection and try again.',
          actionText: l10n.commonRetry,
          iconColor: AppColors.warning,
        );
      case TslErrorType.notFound:
        return _ErrorConfig(
          icon: Icons.search_off_rounded,
          title: 'Not Found',
          message: 'The requested content could not be found.',
          actionText: l10n.commonBack,
          iconColor: AppColors.textSecondary,
        );
      case TslErrorType.maintenance:
        return _ErrorConfig(
          icon: Icons.construction_rounded,
          title: 'Under Maintenance',
          message: 'We\'re making some improvements. Please check back soon.',
          actionText: null,
          iconColor: AppColors.secondary,
        );
      case TslErrorType.unknown:
        return _ErrorConfig(
          icon: Icons.error_outline_rounded,
          title: l10n.errorUnknownTitle,
          message: l10n.errorUnknownMessage,
          actionText: l10n.commonRetry,
          iconColor: AppColors.error,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(context);
    final effectiveIcon = widget.icon ?? config.icon;
    final effectiveTitle = widget.title ?? config.title;
    final effectiveMessage = widget.message ?? config.message;
    final effectiveActionText = widget.actionText ?? config.actionText;
    final effectiveIconColor = widget.iconColor ?? config.iconColor;

    return Padding(
      padding: widget.padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Icon
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: effectiveIconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple effect
                        ...List.generate(3, (index) {
                          return AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              final delay = index * 0.2;
                              final progress = ((_controller.value - delay) / (1 - delay)).clamp(0.0, 1.0);
                              return Container(
                                width: 120 + (progress * 40),
                                height: 120 + (progress * 40),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: effectiveIconColor.withValues(alpha: 0.1 * (1 - progress)),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        // Icon
                        Transform.scale(
                          scale: _bounceAnimation.value,
                          child: Icon(
                            effectiveIcon,
                            size: 56,
                            color: effectiveIconColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Title
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _scaleAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _scaleAnimation.value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                effectiveTitle,
                style: AppTypography.h2.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Message
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delayedProgress = ((_controller.value - 0.2) / 0.8).clamp(0.0, 1.0);
                return Opacity(
                  opacity: delayedProgress,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - delayedProgress)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  effectiveMessage,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Action Buttons
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delayedProgress = ((_controller.value - 0.4) / 0.6).clamp(0.0, 1.0);
                return Opacity(
                  opacity: delayedProgress,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - delayedProgress)),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  if (effectiveActionText != null && widget.onAction != null)
                    TslPrimaryButton(
                      label: effectiveActionText,
                      onPressed: widget.onAction,
                      leadingIcon: _getActionIcon(widget.type),
                    ),
                  if (widget.secondaryActionText != null && widget.onSecondaryAction != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    TslSecondaryButton(
                      label: widget.secondaryActionText!,
                      onPressed: widget.onSecondaryAction,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData? _getActionIcon(TslErrorType type) {
    switch (type) {
      case TslErrorType.network:
      case TslErrorType.server:
      case TslErrorType.timeout:
      case TslErrorType.unknown:
        return Icons.refresh_rounded;
      case TslErrorType.authentication:
        return Icons.login_rounded;
      case TslErrorType.permission:
        return Icons.settings_rounded;
      case TslErrorType.notFound:
        return Icons.arrow_back_rounded;
      case TslErrorType.maintenance:
        return null;
    }
  }
}

/// Error types
enum TslErrorType {
  network,
  server,
  authentication,
  permission,
  timeout,
  notFound,
  maintenance,
  unknown,
}

/// Internal config class
class _ErrorConfig {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final Color iconColor;

  const _ErrorConfig({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionText,
    required this.iconColor,
  });
}

/// Compact inline error widget
class TslErrorInline extends StatelessWidget {
  /// Error message
  final String message;

  /// Retry callback
  final VoidCallback? onRetry;

  /// Custom icon
  final IconData icon;

  /// Custom color
  final Color? color;

  const TslErrorInline({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.error;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: effectiveColor, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: effectiveColor,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh_rounded,
                color: effectiveColor,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }
}

/// Snackbar-style error notification
class TslErrorSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onRetry();
                },
                child: Text(
                  'RETRY',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}

