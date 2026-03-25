import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import 'tsl_primary_button.dart';

/// Empty state widget for screens with no data
///
/// Features:
/// - Icon display
/// - Title and message
/// - Optional action button
/// - Customizable appearance
class TslEmptyState extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Title text
  final String title;

  /// Description message
  final String? message;

  /// Action button text
  final String? actionText;

  /// Callback when action button is pressed
  final VoidCallback? onAction;

  /// Custom icon color
  final Color? iconColor;

  /// Icon size
  final double iconSize;

  /// Custom illustration widget (overrides icon)
  final Widget? illustration;

  /// Padding around the widget
  final EdgeInsetsGeometry padding;

  const TslEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.iconSize = 80,
    this.illustration,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  /// Factory for "No deliveries" empty state
  factory TslEmptyState.noDeliveries({
    VoidCallback? onAction,
    String? actionText,
    String? message,
    String? actionLabel,
  }) {
    return TslEmptyState(
      icon: Icons.local_shipping_outlined,
      title: 'No Deliveries',
      message: message ?? 'You don\'t have any deliveries yet. New deliveries will appear here.',
      actionText: actionLabel ?? actionText,
      onAction: onAction,
    );
  }

  /// Factory for "No orders" empty state
  factory TslEmptyState.noOrders({
    VoidCallback? onAction,
    String? actionText,
  }) {
    return TslEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No Orders',
      message: 'You haven\'t placed any orders yet. Start by requesting a new order.',
      actionText: actionText ?? 'Request Order',
      onAction: onAction,
    );
  }

  /// Factory for "No notifications" empty state
  factory TslEmptyState.noNotifications() {
    return const TslEmptyState(
      icon: Icons.notifications_none_outlined,
      title: 'No Notifications',
      message: 'You\'re all caught up! New notifications will appear here.',
    );
  }

  /// Factory for "No results" empty state (search)
  factory TslEmptyState.noResults({
    String? searchQuery,
    VoidCallback? onClearSearch,
  }) {
    return TslEmptyState(
      icon: Icons.search_off_outlined,
      title: 'No Results Found',
      message: searchQuery != null
          ? 'We couldn\'t find anything matching "$searchQuery"'
          : 'We couldn\'t find any results. Try adjusting your search or filters.',
      actionText: onClearSearch != null ? 'Clear Search' : null,
      onAction: onClearSearch,
    );
  }

  /// Factory for "No rewards" empty state
  factory TslEmptyState.noRewards({
    VoidCallback? onAction,
  }) {
    return TslEmptyState(
      icon: Icons.emoji_events_outlined,
      title: 'No Rewards Yet',
      message: 'Complete deliveries to earn reward points. Your rewards will appear here.',
      actionText: 'View Deliveries',
      onAction: onAction,
    );
  }

  /// Factory for "No mistris" empty state
  factory TslEmptyState.noMistris({
    VoidCallback? onAction,
  }) {
    return TslEmptyState(
      icon: Icons.people_outline,
      title: 'No Mistris',
      message: 'You haven\'t added any mistris yet. Add mistris to assign deliveries.',
      actionText: 'Add Mistri',
      onAction: onAction,
    );
  }

  /// Factory for "No projects" empty state
  factory TslEmptyState.noProjects({
    VoidCallback? onAction,
  }) {
    return TslEmptyState(
      icon: Icons.business_outlined,
      title: 'No Projects',
      message: 'You haven\'t created any projects yet. Start by creating a new specification.',
      actionText: 'Create Specification',
      onAction: onAction,
    );
  }

  /// Factory for "Error" state
  factory TslEmptyState.error({
    String? message,
    VoidCallback? onRetry,
  }) {
    return TslEmptyState(
      icon: Icons.error_outline,
      title: 'Something Went Wrong',
      message: message ?? 'An error occurred. Please try again.',
      actionText: 'Retry',
      onAction: onRetry,
      iconColor: AppColors.error,
    );
  }

  /// Factory for "Offline" state
  factory TslEmptyState.offline({
    VoidCallback? onRetry,
  }) {
    return TslEmptyState(
      icon: Icons.wifi_off_outlined,
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
      actionText: 'Retry',
      onAction: onRetry,
      iconColor: AppColors.textSecondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              illustration!
            else
              Container(
                width: iconSize + 40,
                height: iconSize + 40,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              TslPrimaryButton(
                label: actionText!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact empty state for inline use
class TslEmptyStateCompact extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Message text
  final String message;

  /// Custom icon color
  final Color? iconColor;

  const TslEmptyStateCompact({
    super.key,
    required this.icon,
    required this.message,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: iconColor ?? AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

