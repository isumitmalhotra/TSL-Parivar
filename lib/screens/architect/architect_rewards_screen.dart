import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/architect_models.dart';
import '../../widgets/widgets.dart';

/// Architect Rewards Screen
///
/// Features:
/// - Points balance card
/// - Tabs: Earned, Redeemed, All
/// - Transaction list
/// - Redemption options
class ArchitectRewardsScreen extends StatefulWidget {
  const ArchitectRewardsScreen({super.key});

  @override
  State<ArchitectRewardsScreen> createState() => _ArchitectRewardsScreenState();
}

class _ArchitectRewardsScreenState extends State<ArchitectRewardsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _floatController;

  final ArchitectUser _user = MockArchitectData.mockUser; // Loaded from UserProvider in production
  final List<ArchitectRewardTransaction> _transactions =
      MockArchitectData.mockRewardTransactions; // Loaded from Firestore in production

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  List<ArchitectRewardTransaction> _getFilteredTransactions(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _transactions
            .where((t) =>
                t.type == ArchitectRewardType.specification ||
                t.type == ArchitectRewardType.projectComplete ||
                t.type == ArchitectRewardType.referral)
            .toList();
      case 1:
        return _transactions
            .where((t) => t.type == ArchitectRewardType.redeemed)
            .toList();
      case 2:
        return _transactions;
      default:
        return _transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 320,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF1A237E),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeaderContent(),
              ),
              title: innerBoxIsScrolled
                  ? Text(AppLocalizations.of(context).rewardsTitle, style: const TextStyle(color: Colors.white))
                  : null,
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(child: _buildTabBar()),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: List.generate(3, (index) {
            return _buildTransactionsList(_getFilteredTransactions(index));
          }),
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)],
        ),
      ),
      child: Stack(
        children: [
          // Blueprint pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _BlueprintPatternPainter(),
            ),
          ),
          // Decorative elements
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Your Rewards',
                    style: AppTypography.h2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // Rewards card
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final floatOffset =
                          math.sin(_floatController.value * math.pi) * 4;
                      return Transform.translate(
                        offset: Offset(0, floatOffset),
                        child: _buildRewardsCard(),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Quick actions
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.redeem,
                          label: 'Redeem',
                          onTap: () => _showRedemptionSheet(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.person_add,
                          label: 'Refer',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.info_outline,
                          label: 'How it works',
                          onTap: () => _showHowItWorksSheet(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43A047).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.stars,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Points',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${_user.rewardPoints}',
                  style: AppTypography.h1.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            'Architect Partner',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.architecture,
            size: 60,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.cardWhite,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF43A047),
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: const Color(0xFF43A047),
        indicatorWeight: 3,
        dividerColor: AppColors.divider,
        tabs: [
          Tab(text: AppLocalizations.of(context).rewardsTabEarned),
          Tab(text: AppLocalizations.of(context).rewardsTabRedeemed),
          Tab(text: AppLocalizations.of(context).tabAll),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<ArchitectRewardTransaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: TslEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No Transactions',
          message: 'No transactions in this category yet',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return _TransactionCard(transaction: transactions[index]);
      },
    );
  }

  void _showRedemptionSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _RedemptionSheet(
        availablePoints: _user.rewardPoints,
      ),
    );
  }

  void _showHowItWorksSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _HowItWorksSheet(),
    );
  }
}

/// Transaction card
class _TransactionCard extends StatelessWidget {
  final ArchitectRewardTransaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.xs,
      ),
      child: Row(
        children: [
          // Type icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: transaction.type.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              transaction.type.icon,
              color: transaction.type.color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  transaction.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Points and date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.points > 0 ? '+' : ''}${transaction.points}',
                style: AppTypography.h3.copyWith(
                  color: transaction.points > 0 ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                _formatDate(transaction.date),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

/// Redemption sheet
class _RedemptionSheet extends StatefulWidget {
  final int availablePoints;

  const _RedemptionSheet({required this.availablePoints});

  @override
  State<_RedemptionSheet> createState() => _RedemptionSheetState();
}

class _RedemptionSheetState extends State<_RedemptionSheet> {
  int? _selectedOption;

  final List<Map<String, dynamic>> _options = [
    {'name': 'Amazon Gift Card ₹500', 'points': 1000, 'icon': Icons.card_giftcard},
    {'name': 'Amazon Gift Card ₹1000', 'points': 2000, 'icon': Icons.card_giftcard},
    {'name': 'Flipkart Voucher ₹500', 'points': 1000, 'icon': Icons.shopping_bag},
    {'name': 'Professional Book Set', 'points': 1500, 'icon': Icons.menu_book},
    {'name': 'Software Subscription', 'points': 3000, 'icon': Icons.computer},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.disabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Redeem Points', style: AppTypography.h2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Color(0xFF43A047)),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${widget.availablePoints} pts',
                      style: AppTypography.labelMedium.copyWith(
                        color: const Color(0xFF43A047),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          ...List.generate(_options.length, (index) {
            final option = _options[index];
            final isAvailable = widget.availablePoints >= (option['points'] as int);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildRedemptionOption(
                name: option['name'] as String,
                points: option['points'] as int,
                icon: option['icon'] as IconData,
                isSelected: _selectedOption == index,
                isAvailable: isAvailable,
                onTap: isAvailable
                    ? () => setState(() => _selectedOption = index)
                    : null,
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: TslPrimaryButton(
              label: 'Redeem Now',
              onPressed: _selectedOption != null
                  ? () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Redemption successful!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedemptionOption({
    required String name,
    required int points,
    required IconData icon,
    required bool isSelected,
    required bool isAvailable,
    VoidCallback? onTap,
  }) {
    return Material(
      color: isSelected
          ? const Color(0xFF43A047).withValues(alpha: 0.1)
          : AppColors.backgroundLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: const Color(0xFF43A047), width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isAvailable ? const Color(0xFF43A047) : AppColors.disabled)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isAvailable ? const Color(0xFF43A047) : AppColors.disabled,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.labelMedium.copyWith(
                    color: isAvailable ? AppColors.textPrimary : AppColors.disabled,
                  ),
                ),
              ),
              Text(
                '$points pts',
                style: AppTypography.labelMedium.copyWith(
                  color: isAvailable ? const Color(0xFF43A047) : AppColors.disabled,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: Icon(Icons.check_circle, color: Color(0xFF43A047)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// How it works sheet
class _HowItWorksSheet extends StatelessWidget {
  const _HowItWorksSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.disabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('How TSL Rewards Works', style: AppTypography.h2),
          const SizedBox(height: AppSpacing.xl),
          _buildStep(
            number: '1',
            title: 'Create Specifications',
            description: 'Submit material specifications for your projects',
            icon: Icons.description,
            color: const Color(0xFF4CAF50),
          ),
          _buildStep(
            number: '2',
            title: 'Earn Points',
            description: 'Earn 100-200 points per specification submitted',
            icon: Icons.star,
            color: const Color(0xFFFFA726),
          ),
          _buildStep(
            number: '3',
            title: 'Complete Projects',
            description: 'Bonus points when projects are completed',
            icon: Icons.check_circle,
            color: const Color(0xFF2196F3),
          ),
          _buildStep(
            number: '4',
            title: 'Redeem Rewards',
            description: 'Exchange points for gift cards and more',
            icon: Icons.redeem,
            color: const Color(0xFF9C27B0),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: TslPrimaryButton(
              label: 'Got it!',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Blueprint pattern painter
class _BlueprintPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    const spacing = 25.0;

    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Tab bar delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

