import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/shared_models.dart';
import '../../navigation/app_router.dart';
import '../../widgets/widgets.dart';
import 'mistri_home_screen.dart';
import 'mistri_deliveries_screen.dart';
import 'mistri_rewards_screen.dart';

/// Mistri shell screen with bottom navigation
///
/// This is the main container for all Mistri screens with
/// bottom navigation bar for switching between tabs.
class MistriShellScreen extends StatefulWidget {
  /// Initial tab index
  final int initialIndex;

  const MistriShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MistriShellScreen> createState() => _MistriShellScreenState();
}

class _MistriShellScreenState extends State<MistriShellScreen> {
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

  void _onTabChanged(int index) {
    if (index == 3) {
      context.push(AppRoutes.profileForRole(UserRole.mistri));
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
          const MistriHomeScreen(),
          const MistriDeliveriesScreen(),
          const MistriRewardsScreen(),
          const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: TslBottomNavBar.mistri(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        labelHome: l10n.navHome,
        labelDeliveries: l10n.navDeliveries,
        labelRewards: l10n.navRewards,
        labelProfile: l10n.navProfile,
      ),
    );
  }
}

