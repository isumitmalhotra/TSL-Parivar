import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/dealer_models.dart';
import '../../providers/dealer_data_provider.dart';
import '../../widgets/widgets.dart';

/// Dealer Rewards Screen
///
/// Features:
/// - Dual rewards summary: Loyalty Points + Mistri Pool
/// - Tabs: Earned, Distributed, Redeemed, History
/// - Transaction list with type-specific visuals
class DealerRewardsScreen extends StatefulWidget {
  const DealerRewardsScreen({super.key});

  @override
  State<DealerRewardsScreen> createState() => _DealerRewardsScreenState();
}

class _DealerRewardsScreenState extends State<DealerRewardsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _floatController;

  DealerUser get _user =>
      context.watch<DealerDataProvider>().dealerUser;
  List<DealerRewardTransaction> get _transactions =>
      context.watch<DealerDataProvider>().rewardTransactions;
  List<DealerMistriModel> get _mistris =>
      context.watch<DealerDataProvider>().mistris;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

  List<DealerRewardTransaction> _getFilteredTransactions(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _transactions
            .where((t) =>
                t.type == DealerRewardType.earned ||
                t.type == DealerRewardType.bonus)
            .toList();
      case 1:
        return _transactions
            .where((t) => t.type == DealerRewardType.distributed)
            .toList();
      case 2:
        return _transactions
            .where((t) => t.type == DealerRewardType.redeemed)
            .toList();
      case 3:
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
              expandedHeight: 360,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
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
          children: List.generate(4, (index) {
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
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
      ),
      child: Stack(
        children: [
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
          Positioned(
            left: -30,
            bottom: 50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
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
                  // Dual rewards cards
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final floatOffset =
                          math.sin(_floatController.value * math.pi) * 3;
                      return Transform.translate(
                        offset: Offset(0, floatOffset),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildRewardCard(
                                title: 'Loyalty Points',
                                points: _user.loyaltyPoints,
                                icon: Icons.card_giftcard,
                                gradient: const [
                                  Color(0xFF66BB6A),
                                  Color(0xFF43A047),
                                ],
                                subtitle: 'Your rewards',
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _buildRewardCard(
                                title: 'Mistri Pool',
                                points: _user.mistriPoolPoints,
                                icon: Icons.group,
                                gradient: const [
                                  Color(0xFF43A047),
                                  Color(0xFF2E7D32),
                                ],
                                subtitle: 'For distribution',
                              ),
                            ),
                          ],
                        ),
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
                          icon: Icons.send,
                          label: 'Distribute',
                          onTap: () => _showDistributeSheet(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.history,
                          label: 'History',
                          onTap: () {
                            _tabController.animateTo(3);
                          },
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

  Widget _buildRewardCard({
    required String title,
    required int points,
    required IconData icon,
    required List<Color> gradient,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.5),
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            points.toString(),
            style: AppTypography.h1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
            ),
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
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(color: Colors.white),
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
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        dividerColor: AppColors.divider,
        tabs: const [
          Tab(text: 'Earned'),
          Tab(text: 'Distributed'),
          Tab(text: 'Redeemed'),
          Tab(text: 'All'),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<DealerRewardTransaction> transactions) {
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
        availablePoints: _user.loyaltyPoints,
      ),
    );
  }

  void _showDistributeSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _DistributeSheet(
        availablePoints: _user.mistriPoolPoints,
        mistris: _mistris,
      ),
    );
  }
}

/// Transaction card
class _TransactionCard extends StatelessWidget {
  final DealerRewardTransaction transaction;

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
                if (transaction.mistriName != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        transaction.mistriName!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
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
                  color: transaction.points > 0
                      ? AppColors.success
                      : transaction.type == DealerRewardType.distributed
                          ? AppColors.info
                          : AppColors.error,
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
    {'name': 'Mobile Recharge ₹100', 'points': 200, 'icon': Icons.phone_android},
    {'name': 'Mobile Recharge ₹500', 'points': 1000, 'icon': Icons.phone_android},
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
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.secondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${widget.availablePoints} pts',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.secondary,
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
      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.backgroundLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isAvailable ? AppColors.primary : AppColors.disabled)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isAvailable ? AppColors.primary : AppColors.disabled,
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
                  color: isAvailable ? AppColors.secondary : AppColors.disabled,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: Icon(Icons.check_circle, color: AppColors.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Distribute points sheet
class _DistributeSheet extends StatefulWidget {
  final int availablePoints;
  final List<DealerMistriModel> mistris;

  const _DistributeSheet({
    required this.availablePoints,
    required this.mistris,
  });

  @override
  State<_DistributeSheet> createState() => _DistributeSheetState();
}

class _DistributeSheetState extends State<_DistributeSheet> {
  DealerMistriModel? _selectedMistri;
  int _pointsToDistribute = 50;

  List<DealerMistriModel> get _activeMistris =>
      widget.mistris.where((m) => m.status == MistriStatus.active).toList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
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
                Text('Distribute Points', style: AppTypography.h2),
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
                      const Icon(Icons.group, size: 16, color: Color(0xFF43A047)),
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
            // Select Mistri
            Text('Select Mistri', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _activeMistris.map((mistri) {
                final isSelected = _selectedMistri?.id == mistri.id;
                return FilterChip(
                  selected: isSelected,
                  label: Text(mistri.name),
                  avatar: CircleAvatar(
                    backgroundColor: isSelected ? AppColors.primary : AppColors.backgroundLight,
                    child: Text(
                      mistri.name.substring(0, 1),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedMistri = selected ? mistri : null;
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Points selector
            Text('Points to Distribute', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                IconButton(
                  onPressed: _pointsToDistribute > 10
                      ? () => setState(() => _pointsToDistribute -= 10)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.primary,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$_pointsToDistribute',
                        style: AppTypography.h1.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _pointsToDistribute < widget.availablePoints
                      ? () => setState(() => _pointsToDistribute += 10)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Quick select
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [50, 100, 200, 500].map((points) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: ActionChip(
                    label: Text('$points'),
                    onPressed: points <= widget.availablePoints
                        ? () => setState(() => _pointsToDistribute = points)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: TslPrimaryButton(
                label: 'Distribute Points',
                onPressed: _selectedMistri != null &&
                        _pointsToDistribute <= widget.availablePoints
                    ? () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Distributed $_pointsToDistribute points to ${_selectedMistri!.name}',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
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

