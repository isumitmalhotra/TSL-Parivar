import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/shared_models.dart';
import '../../navigation/app_router.dart';
import '../../widgets/widgets.dart';
import 'architect_home_screen.dart';
import 'architect_projects_screen.dart';
import 'architect_rewards_screen.dart';

/// Architect shell screen with bottom navigation
///
/// This is the main container for all Architect screens with
/// bottom navigation bar for switching between tabs.
class ArchitectShellScreen extends StatefulWidget {
  final int initialIndex;

  const ArchitectShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<ArchitectShellScreen> createState() => _ArchitectShellScreenState();
}

class _ArchitectShellScreenState extends State<ArchitectShellScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ArchitectShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex &&
        widget.initialIndex != _currentIndex) {
      _currentIndex = widget.initialIndex;
      _pageController.jumpToPage(_currentIndex);
      setState(() {});
    }
  }

  void _onTabChanged(int index) {
    if (index == 3) {
      context.push(AppRoutes.profileForRole(UserRole.architect));
      return;
    }

    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: [
          const ArchitectHomeScreen(),
          const ArchitectProjectsScreen(),
          const ArchitectRewardsScreen(),
          const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: TslBottomNavBar.architect(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        labelHome: l10n.navHome,
        labelProjects: l10n.navProjects,
        labelRewards: l10n.navRewards,
        labelProfile: l10n.navProfile,
      ),
    );
  }
}

