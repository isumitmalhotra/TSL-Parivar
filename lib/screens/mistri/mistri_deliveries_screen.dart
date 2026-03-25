 import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mistri_models.dart';
import '../../providers/delivery_provider.dart';
import '../../widgets/widgets.dart';

/// Mistri Deliveries Screen
///
/// Features:
/// - Grouped delivery list by status
/// - Search and filter functionality
/// - Beautiful delivery cards with status indicators
/// - Pull to refresh
class MistriDeliveriesScreen extends StatefulWidget {
  const MistriDeliveriesScreen({super.key});

  @override
  State<MistriDeliveriesScreen> createState() => _MistriDeliveriesScreenState();
}

class _MistriDeliveriesScreenState extends State<MistriDeliveriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer();

  List<DeliveryModel> get _deliveries =>
      context.read<DeliveryProvider>().allDeliveries;

  String _searchQuery = '';
  DeliveryStatus? _selectedFilter;

  final List<_TabData> _tabs = [
    const _TabData(label: 'All', status: null),
    const _TabData(label: 'Assigned', status: DeliveryStatus.assigned),
    const _TabData(label: 'In Progress', status: DeliveryStatus.inProgress),
    const _TabData(label: 'Pending', status: DeliveryStatus.pendingApproval),
    const _TabData(label: 'Completed', status: DeliveryStatus.completed),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _selectedFilter = _tabs[_tabController.index].status;
    });
  }

  List<DeliveryModel> get _filteredDeliveries {
    var deliveries = _deliveries;

    // Filter by status
    if (_selectedFilter != null) {
      deliveries = deliveries.where((d) => d.status == _selectedFilter).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      deliveries = deliveries.where((d) {
        final query = _searchQuery.toLowerCase();
        return d.productName.toLowerCase().contains(query) ||
            d.customerName.toLowerCase().contains(query) ||
            d.customerAddress.toLowerCase().contains(query);
      }).toList();
    }

    return deliveries;
  }

  Map<DeliveryStatus, List<DeliveryModel>> get _groupedDeliveries {
    final map = <DeliveryStatus, List<DeliveryModel>>{};
    for (final delivery in _filteredDeliveries) {
      map.putIfAbsent(delivery.status, () => []).add(delivery);
    }
    return map;
  }

  int _getCountForStatus(DeliveryStatus? status) {
    if (status == null) return _deliveries.length;
    return _deliveries.where((d) => d.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // App Bar
            _buildAppBar(innerBoxIsScrolled),

            // Search Bar
            SliverToBoxAdapter(
              child: _buildSearchBar(),
            ),

            // Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                tabBar: _buildTabBar(),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _tabs.map((tab) {
            return _buildDeliveryList(tab.status);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool innerBoxIsScrolled) {
    final l10n = AppLocalizations.of(context);
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.cardWhite,
      elevation: innerBoxIsScrolled ? 2 : 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          l10n.deliveriesTitle,
          style: AppTypography.h2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.filter_list),
          color: AppColors.textPrimary,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.sort),
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.cardWhite,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => _searchDebouncer.run(() => setState(() => _searchQuery = value)),
          decoration: InputDecoration(
            hintText: 'Search deliveries...',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
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
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelLarge,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        dividerColor: AppColors.divider,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        tabs: _tabs.map((tab) {
          final count = _getCountForStatus(tab.status);
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tab.label),
                if (count > 0) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: tab.status == _selectedFilter || (tab.status == null && _selectedFilter == null)
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.disabled.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: AppTypography.caption.copyWith(
                        color: tab.status == _selectedFilter || (tab.status == null && _selectedFilter == null)
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeliveryList(DeliveryStatus? status) {
    final deliveries = status == null
        ? _filteredDeliveries
        : _filteredDeliveries.where((d) => d.status == status).toList();

    if (deliveries.isEmpty) {
      return Center(
        child: TslEmptyState.noDeliveries(
          message: _searchQuery.isNotEmpty
              ? 'No deliveries match your search'
              : status != null
                  ? 'No ${status.displayName.toLowerCase()} deliveries'
                  : 'No deliveries yet',
          onAction: _searchQuery.isNotEmpty
              ? () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                }
              : null,
          actionLabel: _searchQuery.isNotEmpty ? 'Clear Search' : null,
        ),
      );
    }

    if (status == null) {
      // Show grouped list for "All" tab
      return _buildGroupedList();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future<void>.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: deliveries.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < deliveries.length - 1 ? AppSpacing.md : 0,
            ),
            child: _DeliveryCard(
              delivery: deliveries[index],
              onTap: () => _onDeliveryTap(deliveries[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupedList() {
    final grouped = _groupedDeliveries;
    final statusOrder = [
      DeliveryStatus.assigned,
      DeliveryStatus.inProgress,
      DeliveryStatus.pendingApproval,
      DeliveryStatus.completed,
      DeliveryStatus.rejected,
    ];

    return RefreshIndicator(
      onRefresh: () async {
        await Future<void>.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: statusOrder.length,
        itemBuilder: (context, index) {
          final status = statusOrder[index];
          final deliveries = grouped[status] ?? [];

          if (deliveries.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) const SizedBox(height: AppSpacing.lg),
              _buildStatusHeader(status, deliveries.length),
              const SizedBox(height: AppSpacing.md),
              ...deliveries.map((delivery) {
                final isLast = delivery == deliveries.last;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
                  child: _DeliveryCard(
                    delivery: delivery,
                    onTap: () => _onDeliveryTap(delivery),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(DeliveryStatus status, int count) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: status.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          status.displayName,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: AppTypography.caption.copyWith(
              color: status.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _onDeliveryTap(DeliveryModel delivery) {
    // Navigate to delivery details via GoRouter
    context.push('/mistri/deliveries/${delivery.id}');
  }
}

/// Delivery card widget
class _DeliveryCard extends StatelessWidget {
  final DeliveryModel delivery;
  final VoidCallback? onTap;

  const _DeliveryCard({
    required this.delivery,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.xs,
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Product info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            delivery.productName,
                            style: AppTypography.h3.copyWith(
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            '${delivery.quantity} ${delivery.unit}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status pill
                    TslStatusPill.fromStatus(delivery.status.statusKey),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),
                Divider(color: AppColors.divider),
                const SizedBox(height: AppSpacing.md),

                // Customer info
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
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        delivery.customerAddress,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Bottom row
                Row(
                  children: [
                    // Distance
                    _buildInfoChip(
                      icon: Icons.directions_car_outlined,
                      label: '${delivery.distance} km',
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Expected date
                    _buildInfoChip(
                      icon: Icons.schedule_outlined,
                      label: _formatDate(delivery.expectedDate),
                    ),
                    const Spacer(),
                    // Urgency badge
                    if (delivery.urgency != UrgencyLevel.normal)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: delivery.urgency.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.priority_high,
                              size: 12,
                              color: delivery.urgency.color,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              delivery.urgency.displayName,
                              style: AppTypography.caption.copyWith(
                                color: delivery.urgency.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Points
                    if (delivery.urgency == UrgencyLevel.normal)
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
                              size: 12,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              '+${delivery.rewardPoints}',
                              style: AppTypography.caption.copyWith(
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today ${_formatTime(date)}';
    } else if (dateOnly == today.add(const Duration(days: 1))) {
      return 'Tomorrow ${_formatTime(date)}';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}

/// Tab data class
class _TabData {
  final String label;
  final DeliveryStatus? status;

  const _TabData({required this.label, required this.status});
}

/// Tab bar delegate for sticky header
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  _TabBarDelegate({required this.tabBar});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return tabBar;
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

