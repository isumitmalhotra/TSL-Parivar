import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/shared_models.dart';
import '../../navigation/app_router.dart';
import '../../widgets/widgets.dart';
import 'dealer_home_screen.dart';
import 'dealer_orders_screen.dart';
import 'dealer_mistris_screen.dart';

/// Dealer shell screen with bottom navigation
///
/// This is the main container for all Dealer screens with
/// bottom navigation bar for switching between tabs.
class DealerShellScreen extends StatefulWidget {
  final int initialIndex;

  const DealerShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<DealerShellScreen> createState() => _DealerShellScreenState();
}

class _DealerShellScreenState extends State<DealerShellScreen> {
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
      context.push(AppRoutes.profileForRole(UserRole.dealer));
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
          const DealerHomeScreen(),
          const DealerOrdersScreen(),
          const DealerMistrisScreen(),
          const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: TslBottomNavBar.dealer(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        labelHome: l10n.navHome,
        labelOrders: l10n.navOrders,
        labelMistris: l10n.navMistris,
        labelProfile: l10n.navProfile,
      ),
    );
  }
}

