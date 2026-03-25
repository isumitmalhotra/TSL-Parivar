import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/dealer_models.dart';
import '../../widgets/widgets.dart';

/// Dealer Orders/Requests Screen
///
/// Features:
/// - Tabs: New (with count badge), All, History
/// - Order request cards with mistri, material, urgency
/// - Actions: Approve, Reject, Request More Info
class DealerOrdersScreen extends StatefulWidget {
  const DealerOrdersScreen({super.key});

  @override
  State<DealerOrdersScreen> createState() => _DealerOrdersScreenState();
}

class _DealerOrdersScreenState extends State<DealerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<OrderRequestModel> _orders = MockDealerData.mockOrderRequests; // Loaded from Firestore orders collection in production

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderRequestModel> get _newOrders =>
      _orders.where((o) => o.status == OrderRequestStatus.newRequest).toList();

  List<OrderRequestModel> get _historyOrders =>
      _orders.where((o) => o.status != OrderRequestStatus.newRequest).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(innerBoxIsScrolled),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(child: _buildTabBar()),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOrdersList(_newOrders, 'No new requests'),
            _buildOrdersList(_orders, 'No orders yet'),
            _buildOrdersList(_historyOrders, 'No history yet'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.cardWhite,
      elevation: innerBoxIsScrolled ? 2 : 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          AppLocalizations.of(context).orderRequestsTitle,
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.filter_list),
          color: AppColors.textPrimary,
        ),
      ],
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
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('New'),
                if (_newOrders.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_newOrders.length}',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(text: AppLocalizations.of(context).orderRequestsTabAll),
          Tab(text: AppLocalizations.of(context).tabHistory),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderRequestModel> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(
        child: TslEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No Orders',
          message: emptyMessage,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future<void>.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < orders.length - 1 ? AppSpacing.md : 0,
            ),
            child: _OrderRequestCard(
              order: orders[index],
              onApprove: orders[index].status == OrderRequestStatus.newRequest
                  ? () => _handleApprove(orders[index])
                  : null,
              onReject: orders[index].status == OrderRequestStatus.newRequest
                  ? () => _handleReject(orders[index])
                  : null,
              onRequestInfo: orders[index].status == OrderRequestStatus.newRequest
                  ? () => _handleRequestInfo(orders[index])
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _handleApprove(OrderRequestModel order) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Approve Order'),
        content: Text(
          'Approve ${order.materialType} request from ${order.mistriName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order approved'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _handleReject(OrderRequestModel order) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _RejectOrderSheet(order: order),
    );
  }

  void _handleRequestInfo(OrderRequestModel order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Requested more info from ${order.mistriName}'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

/// Order request card
class _OrderRequestCard extends StatelessWidget {
  final OrderRequestModel order;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onRequestInfo;

  const _OrderRequestCard({
    required this.order,
    this.onApprove,
    this.onReject,
    this.onRequestInfo,
  });

  Color get _urgencyColor {
    switch (order.urgency.toLowerCase()) {
      case 'asap':
        return AppColors.error;
      case 'urgent':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.sm,
        border: order.urgency.toLowerCase() == 'asap'
            ? Border.all(color: AppColors.error.withValues(alpha: 0.5), width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Mistri avatar
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
                      order.mistriName.substring(0, 1).toUpperCase(),
                      style: AppTypography.h3.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.mistriName,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatTime(order.requestedAt),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status / Urgency
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (order.status == OrderRequestStatus.newRequest)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: _urgencyColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (order.urgency.toLowerCase() != 'normal')
                              Icon(Icons.priority_high, size: 12, color: _urgencyColor),
                            Text(
                              order.urgency,
                              style: AppTypography.caption.copyWith(
                                color: _urgencyColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      TslStatusPill.fromStatus(
                        order.status == OrderRequestStatus.approved
                            ? 'completed'
                            : 'rejected',
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Material info
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.materialType,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${order.quantity} ${order.unit}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Details row
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.location_on_outlined,
                    value: order.location,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.calendar_today_outlined,
                    value: _formatDate(order.expectedDate),
                  ),
                ),
              ],
            ),
            if (order.customerName != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildDetailItem(
                icon: Icons.person_outline,
                value: 'Customer: ${order.customerName}',
              ),
            ],
            if (order.notes != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildDetailItem(
                icon: Icons.note_outlined,
                value: order.notes!,
                maxLines: 2,
              ),
            ],
            // Actions
            if (order.status == OrderRequestStatus.newRequest) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.close,
                      label: 'Reject',
                      color: AppColors.error,
                      onTap: onReject,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.info_outline,
                      label: 'More Info',
                      color: AppColors.info,
                      onTap: onRequestInfo,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: _buildActionButton(
                      icon: Icons.check,
                      label: 'Approve',
                      color: AppColors.success,
                      filled: true,
                      onTap: onApprove,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String value,
    int maxLines = 1,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    bool filled = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: filled ? color : color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: filled ? Colors.white : color,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: filled ? Colors.white : color,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

/// Reject order bottom sheet
class _RejectOrderSheet extends StatefulWidget {
  final OrderRequestModel order;

  const _RejectOrderSheet({required this.order});

  @override
  State<_RejectOrderSheet> createState() => _RejectOrderSheetState();
}

class _RejectOrderSheetState extends State<_RejectOrderSheet> {
  String? _selectedReason;
  final TextEditingController _notesController = TextEditingController();

  final List<String> _reasons = [
    'Stock not available',
    'Delivery not possible to this location',
    'Invalid quantity requested',
    'Customer verification failed',
    'Other',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
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
              Text('Reject Order', style: AppTypography.h2),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Please select a reason for rejecting this order from ${widget.order.mistriName}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              RadioGroup<String>(
                groupValue: _selectedReason ?? '',
                onChanged: (value) => setState(() => _selectedReason = value),
                child: Column(
                  children: List.generate(_reasons.length, (index) {
                    final reason = _reasons[index];
                    return RadioListTile<String>(
                      value: reason,
                      title: Text(reason),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Additional notes (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: TslSecondaryButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedReason != null
                          ? () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order rejected'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Reject Order'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
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

