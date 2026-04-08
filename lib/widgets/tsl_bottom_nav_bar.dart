import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Role-specific bottom navigation bar for TSL Parivar app
///
/// Features:
/// - Three role variants (Mistri, Dealer, Architect)
/// - Animated selection
/// - Badge support for notifications
/// - Customizable appearance
class TslBottomNavBar extends StatelessWidget {
  /// Currently selected index
  final int currentIndex;

  /// Callback when item is selected
  final ValueChanged<int>? onTap;

  /// Navigation items
  final List<TslBottomNavItem> items;

  /// Background color
  final Color? backgroundColor;

  /// Selected item color
  final Color? selectedColor;

  /// Unselected item color
  final Color? unselectedColor;

  /// Whether to show labels
  final bool showLabels;

  /// Type of bottom nav bar
  final TslBottomNavType type;

  const TslBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.showLabels = true,
    this.type = TslBottomNavType.fixed,
  });

  /// Factory for Mistri navigation
  factory TslBottomNavBar.mistri({
    required int currentIndex,
    ValueChanged<int>? onTap,
    int notificationCount = 0,
    String labelHome = 'Home',
    String labelDeliveries = 'Deliveries',
    String labelRewards = 'Rewards',
    String labelProfile = 'Profile',
  }) {
    return TslBottomNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        TslBottomNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: labelHome,
        ),
        TslBottomNavItem(
          icon: Icons.local_shipping_outlined,
          activeIcon: Icons.local_shipping,
          label: labelDeliveries,
        ),
        TslBottomNavItem(
          icon: Icons.emoji_events_outlined,
          activeIcon: Icons.emoji_events,
          label: labelRewards,
        ),
        TslBottomNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: labelProfile,
          badge: notificationCount > 0 ? notificationCount.toString() : null,
        ),
      ],
    );
  }

  /// Factory for Dealer navigation
  factory TslBottomNavBar.dealer({
    required int currentIndex,
    ValueChanged<int>? onTap,
    int pendingApprovals = 0,
    String labelHome = 'Home',
    String labelOrders = 'Orders',
    String labelMistris = 'Mistris',
    String labelProfile = 'Profile',
  }) {
    return TslBottomNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        TslBottomNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: labelHome,
        ),
        TslBottomNavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: labelOrders,
          badge: pendingApprovals > 0 ? pendingApprovals.toString() : null,
        ),
        TslBottomNavItem(
          icon: Icons.people_outline,
          activeIcon: Icons.people,
          label: labelMistris,
        ),
        TslBottomNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: labelProfile,
        ),
      ],
    );
  }

  /// Factory for Architect navigation
  factory TslBottomNavBar.architect({
    required int currentIndex,
    ValueChanged<int>? onTap,
    String labelHome = 'Home',
    String labelProjects = 'Projects',
    String labelRewards = 'Rewards',
    String labelProfile = 'Profile',
  }) {
    return TslBottomNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        TslBottomNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: labelHome,
        ),
        TslBottomNavItem(
          icon: Icons.business_outlined,
          activeIcon: Icons.business,
          label: labelProjects,
        ),
        TslBottomNavItem(
          icon: Icons.emoji_events_outlined,
          activeIcon: Icons.emoji_events,
          label: labelRewards,
        ),
        TslBottomNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: labelProfile,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    final effectiveSelectedColor = selectedColor ?? colorScheme.primary;
    final effectiveUnselectedColor = unselectedColor ?? colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: _NavItem(
                  item: item,
                  isSelected: isSelected,
                  selectedColor: effectiveSelectedColor,
                  unselectedColor: effectiveUnselectedColor,
                  showLabel: showLabels,
                  onTap: () => onTap?.call(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Single navigation item widget
class _NavItem extends StatelessWidget {
  final TslBottomNavItem item;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final bool showLabel;
  final VoidCallback? onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.showLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;
    final icon = isSelected ? (item.activeIcon ?? item.icon) : item.icon;

    return Semantics(
      label: item.label,
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(isSelected ? AppSpacing.sm : 0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                if (item.badge != null)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 18),
                      child: Text(
                        item.badge!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textOnPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            if (showLabel) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                item.label,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
      ),
      ),
    );
  }
}

/// Bottom navigation item data
class TslBottomNavItem {
  /// Default icon
  final IconData icon;

  /// Active/selected icon
  final IconData? activeIcon;

  /// Item label
  final String label;

  /// Optional badge text
  final String? badge;

  const TslBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
  });
}

/// Bottom nav bar type
enum TslBottomNavType {
  fixed,
  shifting,
}

/// Floating action button for bottom nav
class TslBottomNavFab extends StatelessWidget {
  /// FAB icon
  final IconData icon;

  /// Callback when FAB is pressed
  final VoidCallback? onPressed;

  /// FAB label (for extended FAB)
  final String? label;

  /// Whether FAB is extended
  final bool isExtended;

  /// Background color
  final Color? backgroundColor;

  /// Icon color
  final Color? iconColor;

  const TslBottomNavFab({
    super.key,
    required this.icon,
    this.onPressed,
    this.label,
    this.isExtended = false,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.primary;
    final effectiveIconColor = iconColor ?? AppColors.textOnPrimary;

    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: effectiveIconColor,
        icon: Icon(icon),
        label: Text(label!),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusFab,
        ),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveIconColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusFab,
      ),
      child: Icon(icon),
    );
  }
}

/// Bottom nav scaffold helper
class TslBottomNavScaffold extends StatelessWidget {
  /// Page body
  final Widget body;

  /// Bottom navigation bar
  final TslBottomNavBar bottomNavBar;

  /// Optional floating action button
  final Widget? floatingActionButton;

  /// FAB location
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// App bar
  final PreferredSizeWidget? appBar;

  /// Background color
  final Color? backgroundColor;

  const TslBottomNavScaffold({
    super.key,
    required this.body,
    required this.bottomNavBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.appBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.backgroundLight,
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

