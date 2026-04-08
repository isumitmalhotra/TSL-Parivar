import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mistri_models.dart';
import '../../providers/user_provider.dart';
import '../../providers/rewards_provider.dart';
import '../../widgets/widgets.dart';

/// Mistri Rewards Screen
///
/// Features:
/// - Reward balance card (3D animated)
/// - Rank/badge display
/// - Tabs: Earned, Redeemed, Pending
/// - Reward transactions list
/// - Redemption functionality
class MistriRewardsScreen extends StatefulWidget {
  const MistriRewardsScreen({super.key});

  @override
  State<MistriRewardsScreen> createState() => _MistriRewardsScreenState();
}

class _MistriRewardsScreenState extends State<MistriRewardsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _cardAnimationController;
  late AnimationController _floatController;

  MistriUser get _user {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.currentUser;
    return userProvider.mistriData ??
        MistriUser(
          id: profile?.id ?? '',
          name: profile?.name ?? 'Mistri',
          phone: profile?.phone ?? '',
          imageUrl: profile?.imageUrl,
          specialization: 'General',
          approvedPoints: 0,
          pendingPoints: 0,
          rank: 'Bronze',
          badgeIcon: '🥉',
          totalDeliveries: 0,
          successRate: 0,
          assignedDealer: const DealerModel(
            id: '',
            name: 'Not Assigned',
            shopName: 'No Dealer',
            phone: '',
            address: '',
            rating: 0,
            totalDeliveries: 0,
          ),
        );
  }
  List<RewardTransaction> get _transactions =>
      context.read<RewardsProvider>().transactions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardAnimationController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  List<RewardTransaction> _getTransactionsForTab(int index) {
    switch (index) {
      case 0:
        return _transactions
            .where((t) =>
                t.type == RewardType.earned || t.type == RewardType.bonus)
            .toList();
      case 1:
        return _transactions
            .where((t) => t.type == RewardType.redeemed)
            .toList();
      case 2:
        return _transactions
            .where((t) => t.type == RewardType.pending)
            .toList();
      default:
        return _transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // App Bar
            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: innerBoxIsScrolled ? 2 : 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Text(
                  AppLocalizations.of(context).rewardsTitle,
                  style: AppTypography.h2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.history),
                  color: AppColors.textPrimary,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.help_outline),
                  color: AppColors.textPrimary,
                ),
              ],
            ),

            // Balance Card
            SliverToBoxAdapter(
              child: _buildBalanceCard(),
            ),

            // Stats Grid
            SliverToBoxAdapter(
              child: _buildStatsGrid(),
            ),

            // Redeem Button
            SliverToBoxAdapter(
              child: _buildRedeemSection(),
            ),

            // Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                child: _buildTabBar(),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTransactionsList(0),
            _buildTransactionsList(1),
            _buildTransactionsList(2),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([_cardAnimationController, _floatController]),
      builder: (context, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _cardAnimationController,
          curve: Curves.elasticOut,
        ));

        final floatOffset = math.sin(_floatController.value * math.pi) * 5;

        return Transform.scale(
          scale: scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(0, floatOffset),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF66BB6A),
                      Color(0xFF43A047),
                      Color(0xFFE64A19),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF66BB6A).withValues(alpha: 0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Icon(
                        Icons.star,
                        size: 180,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.emoji_events,
                        size: 120,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    // Shine effect
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        width: 80,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.4),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Points',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${_user.approvedPoints}',
                                        style: AppTypography.h1.copyWith(
                                          color: Colors.white,
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          ' pts',
                                          style:
                                              AppTypography.bodyLarge.copyWith(
                                            color:
                                                Colors.white.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Badge
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _user.badgeIcon,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Rank
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  _user.rank,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Pending',
              value: '${_user.pendingPoints}',
              subtitle: 'points',
              icon: Icons.schedule,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildStatCard(
              title: 'Deliveries',
              value: '${_user.totalDeliveries}',
              subtitle: 'total',
              icon: Icons.local_shipping,
              color: AppColors.info,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildStatCard(
              title: 'Success',
              value: '${_user.successRate.toStringAsFixed(0)}%',
              subtitle: 'rate',
              icon: Icons.trending_up,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.xs,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemSection() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: TslPrimaryButton(
        label: 'Redeem Points',
        leadingIcon: Icons.redeem,
        onPressed: () => _showRedeemSheet(),
      ),
    );
  }

  void _showRedeemSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _RedeemSheet(
        availablePoints: _user.approvedPoints,
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
        labelStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        dividerColor: AppColors.divider,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_downward, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Text(AppLocalizations.of(context).rewardsTabEarned),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_upward, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Text(AppLocalizations.of(context).rewardsTabRedeemed),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Text(AppLocalizations.of(context).rewardsTabPending),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(int tabIndex) {
    final transactions = _getTransactionsForTab(tabIndex);

    if (transactions.isEmpty) {
      return Center(
        child: TslEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No transactions',
          message: tabIndex == 0
              ? 'Complete deliveries to earn points'
              : tabIndex == 1
                  ? 'You haven\'t redeemed any points yet'
                  : 'No pending points',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < transactions.length - 1 ? AppSpacing.md : 0,
          ),
          child: _buildTransactionCard(transaction),
        );
      },
    );
  }

  Widget _buildTransactionCard(RewardTransaction transaction) {
    final isPositive = transaction.points > 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: transaction.type.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getTransactionIcon(transaction.type),
                color: transaction.type.color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Details
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDate(transaction.date),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // Points
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: (isPositive ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${transaction.points}',
                style: AppTypography.labelLarge.copyWith(
                  color: isPositive ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIcon(RewardType type) {
    switch (type) {
      case RewardType.earned:
        return Icons.check_circle;
      case RewardType.redeemed:
        return Icons.redeem;
      case RewardType.pending:
        return Icons.schedule;
      case RewardType.bonus:
        return Icons.star;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} minutes ago';
      }
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Tab bar delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

/// Redeem bottom sheet
class _RedeemSheet extends StatefulWidget {
  final int availablePoints;

  const _RedeemSheet({required this.availablePoints});

  @override
  State<_RedeemSheet> createState() => _RedeemSheetState();
}

class _RedeemSheetState extends State<_RedeemSheet> {
  final List<_RedeemOption> _options = [
    const _RedeemOption(
      title: 'Mobile Recharge',
      description: 'Recharge your mobile',
      points: 500,
      icon: Icons.phone_android,
      color: Color(0xFF4CAF50),
    ),
    const _RedeemOption(
      title: 'Amazon Voucher',
      description: '₹500 Amazon gift card',
      points: 1000,
      icon: Icons.card_giftcard,
      color: Color(0xFFFF9800),
    ),
    const _RedeemOption(
      title: 'Bank Transfer',
      description: 'Direct bank transfer',
      points: 2000,
      icon: Icons.account_balance,
      color: Color(0xFF2196F3),
    ),
    const _RedeemOption(
      title: 'Paytm Wallet',
      description: 'Transfer to Paytm',
      points: 500,
      icon: Icons.account_balance_wallet,
      color: Color(0xFF00BCD4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.disabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${widget.availablePoints}',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Options
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: _options.length,
                itemBuilder: (context, index) {
                  final option = _options[index];
                  final canRedeem =
                      widget.availablePoints >= option.points;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          index < _options.length - 1 ? AppSpacing.md : 0,
                    ),
                    child: _buildRedeemOptionCard(option, canRedeem),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRedeemOptionCard(_RedeemOption option, bool canRedeem) {
    return Opacity(
      opacity: canRedeem ? 1.0 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canRedeem
                ? option.color.withValues(alpha: 0.3)
                : AppColors.border,
          ),
          boxShadow: AppShadows.xs,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: canRedeem ? () => _onRedeemTap(option) : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: option.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          option.icon,
                          color: option.color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              option.description,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: option.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: option.color,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            '${option.points}',
                            style: AppTypography.labelMedium.copyWith(
                              color: option.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onRedeemTap(_RedeemOption option) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redeeming ${option.points} points for ${option.title}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }
}

/// Redeem option model
class _RedeemOption {
  final String title;
  final String description;
  final int points;
  final IconData icon;
  final Color color;

  const _RedeemOption({
    required this.title,
    required this.description,
    required this.points,
    required this.icon,
    required this.color,
  });
}

