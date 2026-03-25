import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Custom tab bar for TSL Parivar app
///
/// Features:
/// - Multiple style variants
/// - Badge support
/// - Scrollable tabs
/// - Custom indicator
class TslTabBar extends StatelessWidget {
  /// List of tabs
  final List<TslTab> tabs;

  /// Currently selected index
  final int selectedIndex;

  /// Callback when tab is selected
  final ValueChanged<int>? onTabSelected;

  /// Tab bar style
  final TslTabBarStyle style;

  /// Whether tabs are scrollable
  final bool isScrollable;

  /// Selected tab color
  final Color? selectedColor;

  /// Unselected tab color
  final Color? unselectedColor;

  /// Indicator color
  final Color? indicatorColor;

  /// Background color
  final Color? backgroundColor;

  /// Tab controller (for use with TabBarView)
  final TabController? controller;

  const TslTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabSelected,
    this.style = TslTabBarStyle.underlined,
    this.isScrollable = false,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.backgroundColor,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case TslTabBarStyle.underlined:
        return _UnderlinedTabBar(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
          isScrollable: isScrollable,
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          indicatorColor: indicatorColor,
          backgroundColor: backgroundColor,
          controller: controller,
        );
      case TslTabBarStyle.pills:
        return _PillsTabBar(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
          isScrollable: isScrollable,
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          backgroundColor: backgroundColor,
        );
      case TslTabBarStyle.boxed:
        return _BoxedTabBar(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
          isScrollable: isScrollable,
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          backgroundColor: backgroundColor,
        );
    }
  }
}

/// Tab bar style variants
enum TslTabBarStyle {
  underlined,
  pills,
  boxed,
}

/// Tab data class
class TslTab {
  /// Tab label
  final String label;

  /// Tab icon
  final IconData? icon;

  /// Badge count
  final int? badgeCount;

  /// Whether tab is enabled
  final bool isEnabled;

  const TslTab({
    required this.label,
    this.icon,
    this.badgeCount,
    this.isEnabled = true,
  });
}

/// Underlined tab bar style
class _UnderlinedTabBar extends StatelessWidget {
  final List<TslTab> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;
  final bool isScrollable;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? indicatorColor;
  final Color? backgroundColor;
  final TabController? controller;

  const _UnderlinedTabBar({
    required this.tabs,
    required this.selectedIndex,
    this.onTabSelected,
    required this.isScrollable,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.backgroundColor,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? AppColors.primary;
    final effectiveUnselectedColor = unselectedColor ?? AppColors.textSecondary;
    final effectiveIndicatorColor = indicatorColor ?? AppColors.primary;

    return Container(
      color: backgroundColor ?? AppColors.cardWhite,
      child: TabBar(
        controller: controller,
        isScrollable: isScrollable,
        onTap: onTabSelected,
        labelColor: effectiveSelectedColor,
        unselectedLabelColor: effectiveUnselectedColor,
        labelStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelLarge,
        indicatorColor: effectiveIndicatorColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.divider,
        tabs: tabs.map((tab) => _buildTab(tab, effectiveSelectedColor)).toList(),
      ),
    );
  }

  Widget _buildTab(TslTab tab, Color selectedColor) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tab.icon != null) ...[
            Icon(tab.icon, size: 18),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(tab.label),
          if (tab.badgeCount != null && tab.badgeCount! > 0) ...[
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tab.badgeCount! > 99 ? '99+' : tab.badgeCount.toString(),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textOnPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pills tab bar style
class _PillsTabBar extends StatelessWidget {
  final List<TslTab> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;
  final bool isScrollable;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? backgroundColor;

  const _PillsTabBar({
    required this.tabs,
    required this.selectedIndex,
    this.onTabSelected,
    required this.isScrollable,
    this.selectedColor,
    this.unselectedColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? AppColors.primary;
    final effectiveUnselectedColor = unselectedColor ?? AppColors.textSecondary;

    Widget tabRow = Row(
      mainAxisSize: isScrollable ? MainAxisSize.min : MainAxisSize.max,
      children: List.generate(tabs.length, (index) {
        final tab = tabs[index];
        final isSelected = index == selectedIndex;

        return Padding(
          padding: EdgeInsets.only(
            right: index < tabs.length - 1 ? AppSpacing.sm : 0,
          ),
          child: _PillTab(
            tab: tab,
            isSelected: isSelected,
            selectedColor: effectiveSelectedColor,
            unselectedColor: effectiveUnselectedColor,
            onTap: tab.isEnabled ? () => onTabSelected?.call(index) : null,
          ),
        );
      }),
    );

    if (isScrollable) {
      return Container(
        color: backgroundColor,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: tabRow,
        ),
      );
    }

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: tabRow,
    );
  }
}

/// Single pill tab
class _PillTab extends StatelessWidget {
  final TslTab tab;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback? onTap;

  const _PillTab({
    required this.tab,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? selectedColor : Colors.transparent,
      borderRadius: AppRadius.radiusChip,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusChip,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusChip,
            border: isSelected
                ? null
                : Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tab.icon != null) ...[
                Icon(
                  tab.icon,
                  size: 16,
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : unselectedColor,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                tab.label,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : unselectedColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (tab.badgeCount != null && tab.badgeCount! > 0) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tab.badgeCount! > 99 ? '99+' : tab.badgeCount.toString(),
                    style: AppTypography.caption.copyWith(
                      color: isSelected ? selectedColor : AppColors.textOnPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Boxed tab bar style
class _BoxedTabBar extends StatelessWidget {
  final List<TslTab> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;
  final bool isScrollable;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? backgroundColor;

  const _BoxedTabBar({
    required this.tabs,
    required this.selectedIndex,
    this.onTabSelected,
    required this.isScrollable,
    this.selectedColor,
    this.unselectedColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? AppColors.primary;
    final effectiveUnselectedColor = unselectedColor ?? AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.disabled.withValues(alpha: 0.5),
        borderRadius: AppRadius.radiusButton,
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: tab.isEnabled ? () => onTabSelected?.call(index) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cardWhite : Colors.transparent,
                  borderRadius: AppRadius.radiusSm,
                  boxShadow: isSelected ? AppShadows.xs : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tab.icon != null) ...[
                      Icon(
                        tab.icon,
                        size: 16,
                        color: isSelected
                            ? effectiveSelectedColor
                            : effectiveUnselectedColor,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      tab.label,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? effectiveSelectedColor
                            : effectiveUnselectedColor,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (tab.badgeCount != null && tab.badgeCount! > 0) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tab.badgeCount! > 99
                              ? '99+'
                              : tab.badgeCount.toString(),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textOnPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Tab bar with TabBarView helper
class TslTabBarView extends StatefulWidget {
  /// List of tabs
  final List<TslTab> tabs;

  /// List of tab content widgets
  final List<Widget> children;

  /// Tab bar style
  final TslTabBarStyle style;

  /// Initial tab index
  final int initialIndex;

  /// Callback when tab changes
  final ValueChanged<int>? onTabChanged;

  /// Whether tabs are scrollable
  final bool isScrollable;

  const TslTabBarView({
    super.key,
    required this.tabs,
    required this.children,
    this.style = TslTabBarStyle.underlined,
    this.initialIndex = 0,
    this.onTabChanged,
    this.isScrollable = false,
  }) : assert(tabs.length == children.length);

  @override
  State<TslTabBarView> createState() => _TslTabBarViewState();
}

class _TslTabBarViewState extends State<TslTabBarView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      widget.onTabChanged?.call(_tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TslTabBar(
          tabs: widget.tabs,
          selectedIndex: _tabController.index,
          onTabSelected: (index) {
            _tabController.animateTo(index);
          },
          style: widget.style,
          isScrollable: widget.isScrollable,
          controller: widget.style == TslTabBarStyle.underlined
              ? _tabController
              : null,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}

