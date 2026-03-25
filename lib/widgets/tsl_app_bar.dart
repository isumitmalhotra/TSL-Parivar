import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import 'tsl_language_toggle.dart';

/// Custom AppBar for TSL Parivar app
///
/// Features:
/// - Logo/title display
/// - Notification bell with badge
/// - Language toggle (EN/HI)
/// - Customizable actions
class TslAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String? title;

  /// Widget to display as title (overrides [title])
  final Widget? titleWidget;

  /// Whether to show the TSL logo
  final bool showLogo;

  /// Whether to show the notification bell
  final bool showNotificationBell;

  /// Notification count to display on badge
  final int notificationCount;

  /// Callback when notification bell is tapped
  final VoidCallback? onNotificationTap;

  /// Whether to show the language toggle
  final bool showLanguageToggle;

  /// Additional actions to display
  final List<Widget>? actions;

  /// Leading widget (overrides default back button)
  final Widget? leading;

  /// Whether to show the default back button
  final bool automaticallyImplyLeading;

  /// Background color (defaults to theme)
  final Color? backgroundColor;

  /// Elevation (defaults to 0)
  final double elevation;

  /// Whether the app bar is for a scrolled-under surface
  final bool scrolledUnder;

  /// Center the title
  final bool centerTitle;

  const TslAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showLogo = false,
    this.showNotificationBell = false,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.showLanguageToggle = false,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation = 0,
    this.scrolledUnder = false,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildTitle(context),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ??
          (scrolledUnder ? AppColors.surface : AppColors.backgroundLight),
      elevation: elevation,
      scrolledUnderElevation: scrolledUnder ? 2 : 0,
      surfaceTintColor: Colors.transparent,
      actions: _buildActions(context),
    );
  }

  Widget? _buildTitle(BuildContext context) {
    if (titleWidget != null) return titleWidget;

    if (showLogo) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TslLogo(),
          if (title != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              title!,
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      );
    }

    if (title != null) {
      return Text(
        title!,
        style: AppTypography.h3.copyWith(
          color: AppColors.textPrimary,
        ),
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    final List<Widget> allActions = [];

    // Add custom actions first
    if (actions != null) {
      allActions.addAll(actions!);
    }

    // Add language toggle
    if (showLanguageToggle) {
      allActions.add(const TslLanguageToggle());
    }

    // Add notification bell
    if (showNotificationBell) {
      allActions.add(
        _NotificationBell(
          count: notificationCount,
          onTap: onNotificationTap,
        ),
      );
    }

    if (allActions.isEmpty) return null;

    return allActions;
  }
}

/// TSL Logo widget
class _TslLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/images/tsl_logo_new.png',
        width: 36,
        height: 36,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadius.radiusSm,
            ),
            child: Center(
              child: Text(
                'TSL',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Notification bell with badge
class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _NotificationBell({
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(
          count > 99 ? '99+' : count.toString(),
          style: AppTypography.caption.copyWith(
            color: AppColors.textOnPrimary,
            fontSize: 10,
          ),
        ),
        backgroundColor: AppColors.error,
        child: const Icon(
          Icons.notifications_outlined,
          color: AppColors.textPrimary,
        ),
      ),
      tooltip: 'Notifications',
    );
  }
}

/// Sliver version of TslAppBar for use with CustomScrollView
class TslSliverAppBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showLogo;
  final bool showNotificationBell;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final bool showLanguageToggle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double? expandedHeight;
  final Widget? flexibleSpace;
  final bool centerTitle;

  const TslSliverAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showLogo = false,
    this.showNotificationBell = false,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.showLanguageToggle = false,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.expandedHeight,
    this.flexibleSpace,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: _buildTitle(context),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 2,
      surfaceTintColor: Colors.transparent,
      pinned: pinned,
      floating: floating,
      snap: snap,
      expandedHeight: expandedHeight,
      flexibleSpace: flexibleSpace,
      actions: _buildActions(context),
    );
  }

  Widget? _buildTitle(BuildContext context) {
    if (titleWidget != null) return titleWidget;

    if (showLogo) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TslLogo(),
          if (title != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              title!,
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      );
    }

    if (title != null) {
      return Text(
        title!,
        style: AppTypography.h3.copyWith(
          color: AppColors.textPrimary,
        ),
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    final List<Widget> allActions = [];

    if (actions != null) {
      allActions.addAll(actions!);
    }

    if (showLanguageToggle) {
      allActions.add(const TslLanguageToggle());
    }

    if (showNotificationBell) {
      allActions.add(
        _NotificationBell(
          count: notificationCount,
          onTap: onNotificationTap,
        ),
      );
    }

    if (allActions.isEmpty) return null;

    return allActions;
  }
}

