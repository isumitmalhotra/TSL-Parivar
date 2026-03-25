import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mistri_models.dart';
import '../../models/shared_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../services/url_launcher_service.dart';
import '../../widgets/widgets.dart';

/// Mistri Home Screen
///
/// Features:
/// - Greeting card with reward points (3D animated)
/// - Assigned dealer info
/// - Active deliveries carousel
/// - Quick action buttons
class MistriHomeScreen extends StatefulWidget {
  const MistriHomeScreen({super.key});

  @override
  State<MistriHomeScreen> createState() => _MistriHomeScreenState();
}

class _MistriHomeScreenState extends State<MistriHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _greetingController;
  late AnimationController _floatController;
  late ScrollController _scrollController;

  MistriUser get _user =>
      context.read<UserProvider>().mistriData ?? MockMistriData.mockUser;
  List<DeliveryModel> get _deliveries =>
      context.read<DeliveryProvider>().allDeliveries;

  @override
  void initState() {
    super.initState();
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _scrollController = ScrollController();

    // Load data from providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId;
    if (userId != null) {
      final userProvider = context.read<UserProvider>();
      final deliveryProvider = context.read<DeliveryProvider>();
      if (!userProvider.hasUser) {
        await userProvider.loadUserData(userId, UserRole.mistri);
      }
      await deliveryProvider.loadDeliveries(userId: userId);
    }
  }

  @override
  void dispose() {
    _greetingController.dispose();
    _floatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<DeliveryModel> get _activeDeliveries => _deliveries
      .where((d) =>
          d.status == DeliveryStatus.assigned ||
          d.status == DeliveryStatus.inProgress)
      .toList();

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 17) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom App Bar with gradient
          _buildAppBar(l10n),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting & Rewards Card
                _buildGreetingCard(l10n),

                const SizedBox(height: AppSpacing.xl),

                // Assigned Dealer Card
                _buildDealerSection(l10n),

                const SizedBox(height: AppSpacing.xl),

                // Active Deliveries
                _buildDeliveriesSection(l10n),

                const SizedBox(height: AppSpacing.xl),

                // Quick Actions
                _buildQuickActions(l10n),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E7D32),
                Color(0xFF1B5E20),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
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
                bottom: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Row(
          children: [
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/tsl_logo_white.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'TSL',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'TSL Parivar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Notification bell
        IconButton(
          onPressed: () {
            context.push('/notifications');
          },
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Language toggle
        const Padding(
          padding: EdgeInsets.only(right: 8),
          child: TslLanguageToggle.compact(),
        ),
      ],
    );
  }

  Widget _buildGreetingCard(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: Listenable.merge([_greetingController, _floatController]),
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _greetingController,
          curve: Curves.easeOutCubic,
        ));

        final floatOffset = math.sin(_floatController.value * math.pi) * 5;

        return SlideTransition(
          position: slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Transform.translate(
              offset: Offset(0, floatOffset),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF43A047),
                      Color(0xFF2E7D32),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF43A047).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.emoji_events,
                        size: 150,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Greeting
                          Row(
                            children: [
                              Text(
                                _getGreeting(l10n),
                                style: AppTypography.bodyLarge.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              const Text('👋', style: TextStyle(fontSize: 20)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _user.name,
                            style: AppTypography.h1.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          // Rank badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _user.badgeIcon,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  _user.rank,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          // Reward points
                          Row(
                            children: [
                              // Approved points
                              Expanded(
                                child: _buildPointsCard(
                                  title: l10n.mistriHomeApprovedPoints,
                                  points: _user.approvedPoints,
                                  icon: Icons.check_circle,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              // Pending points
                              Expanded(
                                child: _buildPointsCard(
                                  title: l10n.mistriHomePendingPoints,
                                  points: _user.pendingPoints,
                                  icon: Icons.schedule,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
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

  Widget _buildPointsCard({
    required String title,
    required int points,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points.toString(),
                style: AppTypography.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'pts',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDealerSection(AppLocalizations l10n) {
    final dealer = _user.assignedDealer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TslSectionHeader(
            title: l10n.mistriHomeAssignedDealer,
            icon: Icons.store,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.sm,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF66BB6A).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        dealer.name.substring(0, 1).toUpperCase(),
                        style: AppTypography.h2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dealer.name,
                          style: AppTypography.h3,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          dealer.shopName,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Expanded(
                              child: Text(
                                dealer.address,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.call,
                  label: l10n.commonCall,
                  color: AppColors.success,
                  onTap: () {
                    _showCallDialog(dealer.phone);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.message,
                  label: l10n.commonMessage,
                  color: AppColors.info,
                  onTap: () {
                    context.push('/chat/${dealer.id}');
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.directions,
                  label: l10n.commonNavigate,
                  color: AppColors.secondary,
                  onTap: () {
                    _showNavigationDialog(dealer.address);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveriesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: TslSectionHeader(
            title: l10n.mistriHomeActiveDeliveries,
            trailing: _activeDeliveries.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_activeDeliveries.length}',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            onViewAll: () {
              // Navigate to deliveries tab (index 1 in bottom nav)
              _showDeliveriesTab();
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_activeDeliveries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TslEmptyState.noDeliveries(
              onAction: () {
                // Navigate to deliveries tab
                _showDeliveriesTab();
              },
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: _activeDeliveries.length,
              itemBuilder: (context, index) {
                final delivery = _activeDeliveries[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _activeDeliveries.length - 1
                        ? AppSpacing.md
                        : 0,
                  ),
                  child: _buildDeliveryCard(delivery),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDeliveryCard(DeliveryModel delivery) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            context.push('/mistri/deliveries/${delivery.id}');
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        delivery.productName,
                        style: AppTypography.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TslStatusPill.fromStatus(delivery.status.statusKey),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Customer
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        delivery.customerName,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Divider
                Divider(color: AppColors.divider),
                const SizedBox(height: AppSpacing.sm),
                // Bottom info
                Row(
                  children: [
                    // Distance
                    _buildInfoChip(
                      icon: Icons.location_on,
                      label: '${delivery.distance} km',
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Time
                    _buildInfoChip(
                      icon: Icons.schedule,
                      label: _formatTime(delivery.expectedDate),
                    ),
                    const Spacer(),
                    // Points
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            '+${delivery.rewardPoints}',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.isNegative) {
      return 'Overdue';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inDays}d';
    }
  }

  Widget _buildQuickActions(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TslSectionHeader(
            title: l10n.mistriHomeRequestOrder,
            icon: Icons.flash_on,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.add_shopping_cart,
                  label: l10n.mistriHomeRequestOrder,
                  gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                  onTap: () {
                    context.push('/mistri/request-order');
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.inventory_2,
                  label: 'Browse Products',
                  gradient: const [Color(0xFF2E7D32), Color(0xFF43A047)],
                  onTap: () {
                    context.push('/products');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.menu_book,
                  label: l10n.mistriHomeHelp,
                  gradient: const [Color(0xFF43A047), Color(0xFF2E7D32)],
                  onTap: () {
                    _showBuildingGuide();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background icon
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(
                  icon,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      label,
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for actions
  void _showDeliveriesTab() {
    // This would typically communicate with the shell screen to switch tabs
    // For now, show a snackbar indicating the action
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Deliveries tab'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showCallDialog(String phone) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.callDealer),
        content: Text(l10n.callConfirm(phone)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              UrlLauncherService.launchPhone(phone);
            },
            child: Text(l10n.commonCall),
          ),
        ],
      ),
    );
  }

  void _showNavigationDialog(String address) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.navigateToDealer),
        content: Text(l10n.navigateConfirm(address)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              UrlLauncherService.launchMaps(address);
            },
            child: Text(l10n.commonNavigate),
          ),
        ],
      ),
    );
  }

  void _showBuildingGuide() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Building Guide',
              style: AppTypography.h2,
            ),
            const SizedBox(height: 8),
            Text(
              'Steel specification guidelines',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Divider(height: 32),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildGuideItem('TMT Bars', 'Fe-500D grade for foundations'),
                  _buildGuideItem('Steel Beams', 'ISMB sections for structural support'),
                  _buildGuideItem('Binding Wire', '18 gauge for tying reinforcement'),
                  _buildGuideItem('Steel Plates', '6mm-12mm for base plates'),
                  _buildGuideItem('Angles', 'L-sections for frames'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.article, color: AppColors.primary),
        ),
        title: Text(title, style: AppTypography.labelLarge),
        subtitle: Text(description, style: AppTypography.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Show detailed guide
        },
      ),
    );
  }
}
