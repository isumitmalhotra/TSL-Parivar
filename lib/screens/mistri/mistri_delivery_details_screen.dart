import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../models/mistri_models.dart';
import '../../providers/delivery_provider.dart';
import '../../services/url_launcher_service.dart';
import '../../widgets/widgets.dart';

/// Mistri Delivery Details Screen
///
/// Features:
/// - Map snippet with delivery location
/// - Product info section
/// - Customer contact details
/// - Delivery progress stepper
/// - Action buttons
class MistriDeliveryDetailsScreen extends StatefulWidget {
  final String deliveryId;

  const MistriDeliveryDetailsScreen({
    super.key,
    required this.deliveryId,
  });

  @override
  State<MistriDeliveryDetailsScreen> createState() =>
      _MistriDeliveryDetailsScreenState();
}

class _MistriDeliveryDetailsScreenState
    extends State<MistriDeliveryDetailsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late DeliveryModel _delivery;
  bool _hasDelivery = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    // Find delivery from provider data.
    final allDeliveries = context.read<DeliveryProvider>().allDeliveries;
    final index = allDeliveries.indexWhere((d) => d.id == widget.deliveryId);
    if (index >= 0) {
      _delivery = allDeliveries[index];
      _hasDelivery = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allDeliveries = context.watch<DeliveryProvider>().allDeliveries;
    final index = allDeliveries.indexWhere((d) => d.id == widget.deliveryId);
    if (index >= 0) {
      _delivery = allDeliveries[index];
      _hasDelivery = true;
    } else {
      _hasDelivery = false;
    }

    if (!_hasDelivery) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.cardWhite,
          elevation: 0,
          title: const Text('Delivery not found'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: TslEmptyState(
              icon: Icons.local_shipping_outlined,
              title: 'Delivery unavailable',
              message: 'This delivery was not found. Please refresh and try again.',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar with Map
          _buildSliverAppBar(),

          // Content
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final slideAnimation = Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOutCubic,
                ));

                final fadeAnimation = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeIn,
                ));

                return SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: _buildContent(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.cardWhite,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppShadows.xs,
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.xs,
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildMapPlaceholder(),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Map placeholder with gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.info.withValues(alpha: 0.3),
                AppColors.info.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Grid pattern for map effect
              CustomPaint(
                painter: _GridPainter(),
                size: Size.infinite,
              ),
              // Location marker
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Bottom gradient for smooth transition
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.backgroundLight,
                ],
              ),
            ),
          ),
        ),
        // Distance badge
        Positioned(
          bottom: 70,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.directions_car,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${_delivery.distance} km',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status and ID
        _buildHeaderSection(),

        const SizedBox(height: AppSpacing.lg),

        // Product Info
        _buildProductSection(),

        const SizedBox(height: AppSpacing.lg),

        // Customer Info
        _buildCustomerSection(),

        const SizedBox(height: AppSpacing.lg),

        // Delivery Progress
        _buildProgressSection(),

        const SizedBox(height: AppSpacing.lg),

        // Reward Info
        _buildRewardSection(),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery #${_delivery.id.substring(4)}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              TslStatusPill.fromStatus(
                _delivery.status.statusKey,
                size: TslStatusPillSize.large,
              ),
            ],
          ),
          if (_delivery.urgency != UrgencyLevel.normal)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: _delivery.urgency.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _delivery.urgency.color.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.priority_high,
                    size: 18,
                    color: _delivery.urgency.color,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _delivery.urgency.displayName,
                    style: AppTypography.labelMedium.copyWith(
                      color: _delivery.urgency.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.sm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Details',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _delivery.productName,
                          style: AppTypography.h3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Divider(color: AppColors.divider),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      label: 'Product Type',
                      value: _delivery.productType,
                      icon: Icons.category,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      label: 'Quantity',
                      value: '${_delivery.quantity} ${_delivery.unit}',
                      icon: Icons.straighten,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.sm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        _delivery.customerName.substring(0, 1).toUpperCase(),
                        style: AppTypography.h3.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _delivery.customerName,
                          style: AppTypography.h3,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          _delivery.customerPhone,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Address
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _delivery.customerAddress,
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TslSecondaryButton(
                      label: 'Call',
                      leadingIcon: Icons.call,
                      onPressed: () => UrlLauncherService.launchPhone(_delivery.customerPhone),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TslSecondaryButton(
                      label: 'Message',
                      leadingIcon: Icons.message,
                      onPressed: () => UrlLauncherService.launchSms(_delivery.customerPhone),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final steps = [
      _ProgressStep(
        title: 'Order Assigned',
        subtitle: 'Today, 9:30 AM',
        isCompleted: true,
        isActive: false,
      ),
      _ProgressStep(
        title: 'Picked Up',
        subtitle: _delivery.status == DeliveryStatus.assigned
            ? 'Pending'
            : 'Today, 10:15 AM',
        isCompleted: _delivery.status != DeliveryStatus.assigned,
        isActive: _delivery.status == DeliveryStatus.assigned,
      ),
      _ProgressStep(
        title: 'In Transit',
        subtitle: _delivery.status == DeliveryStatus.inProgress
            ? 'In Progress'
            : _delivery.status == DeliveryStatus.assigned
                ? 'Pending'
                : 'Today, 11:00 AM',
        isCompleted: _delivery.status == DeliveryStatus.pendingApproval ||
            _delivery.status == DeliveryStatus.completed,
        isActive: _delivery.status == DeliveryStatus.inProgress,
      ),
      _ProgressStep(
        title: 'Delivered',
        subtitle: _delivery.status == DeliveryStatus.completed
            ? 'Today, 11:45 AM'
            : 'Pending',
        isCompleted: _delivery.status == DeliveryStatus.completed,
        isActive: _delivery.status == DeliveryStatus.pendingApproval,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.sm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Progress',
                style: AppTypography.h3,
              ),
              const SizedBox(height: AppSpacing.lg),
              ...steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                final isLast = index == steps.length - 1;

                return _buildProgressStep(step, isLast);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep(_ProgressStep step, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicator
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: step.isCompleted
                    ? AppColors.success
                    : step.isActive
                        ? AppColors.primary
                        : AppColors.disabled,
                border: step.isActive
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 3,
                      )
                    : null,
              ),
              child: step.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : step.isActive
                      ? Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        )
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: step.isCompleted
                    ? AppColors.success
                    : AppColors.disabled,
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: step.isActive || step.isCompleted
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  step.subtitle,
                  style: AppTypography.caption.copyWith(
                    color: step.isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF66BB6A).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.star,
                size: 100,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reward Points',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${_delivery.rewardPoints}',
                              style: AppTypography.h1.copyWith(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                'points',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Navigate button
            Expanded(
              child: TslSecondaryButton(
                label: 'Navigate',
                leadingIcon: Icons.directions,
                onPressed: () => UrlLauncherService.launchMaps(_delivery.customerAddress),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Primary action
            Expanded(
              flex: 2,
              child: TslPrimaryButton(
                label: _getPrimaryButtonLabel(),
                leadingIcon: _getPrimaryButtonIcon(),
                onPressed: () => _handlePrimaryAction(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePrimaryAction() async {
    final provider = context.read<DeliveryProvider>();
    switch (_delivery.status) {
      case DeliveryStatus.assigned:
        final ok = await provider.startDelivery(_delivery.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok
                ? 'Delivery started. Proceed to POD when reached.'
                : provider.errorMessage ?? 'Unable to start delivery.'),
            backgroundColor: ok ? AppColors.success : AppColors.error,
          ),
        );
        return;
      case DeliveryStatus.inProgress:
      case DeliveryStatus.rejected:
        if (!mounted) return;
        context.push('/mistri/deliveries/${_delivery.id}/pod');
        return;
      case DeliveryStatus.pendingApproval:
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('POD already submitted and pending review.')),
        );
        return;
      case DeliveryStatus.completed:
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery already completed.')),
        );
        return;
    }
  }

  String _getPrimaryButtonLabel() {
    switch (_delivery.status) {
      case DeliveryStatus.assigned:
        return 'Start Delivery';
      case DeliveryStatus.inProgress:
        return 'Mark Reached';
      case DeliveryStatus.pendingApproval:
        return 'View Submission';
      case DeliveryStatus.completed:
        return 'View Details';
      case DeliveryStatus.rejected:
        return 'Resubmit';
    }
  }

  IconData _getPrimaryButtonIcon() {
    switch (_delivery.status) {
      case DeliveryStatus.assigned:
        return Icons.play_arrow;
      case DeliveryStatus.inProgress:
        return Icons.location_on;
      case DeliveryStatus.pendingApproval:
        return Icons.visibility;
      case DeliveryStatus.completed:
        return Icons.check_circle;
      case DeliveryStatus.rejected:
        return Icons.refresh;
    }
  }
}

/// Progress step data
class _ProgressStep {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;

  const _ProgressStep({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
  });
}

/// Grid painter for map effect
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    const spacing = 30.0;

    // Horizontal lines
    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }

    // Vertical lines
    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

