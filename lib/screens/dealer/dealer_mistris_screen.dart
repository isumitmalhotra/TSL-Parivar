import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/base_model.dart';
import '../../models/dealer_models.dart';
import '../../navigation/app_router.dart';
import '../../providers/dealer_data_provider.dart';
import '../../services/url_launcher_service.dart';
import '../../widgets/widgets.dart';

/// Dealer Mistris Management Screen
///
/// Features:
/// - Search and filter functionality
/// - Add new mistri button
/// - Mistri list grouped by status
/// - Mistri cards with stats and actions
class DealerMistrisScreen extends StatefulWidget {
  const DealerMistrisScreen({super.key});

  @override
  State<DealerMistrisScreen> createState() => _DealerMistrisScreenState();
}

class _DealerMistrisScreenState extends State<DealerMistrisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer();
  List<DealerMistriModel> get _mistris =>
      context.watch<DealerDataProvider>().mistris;
  List<NearbyMistriModel> get _nearbyMistris =>
      context.watch<DealerDataProvider>().nearbyMistris;

  String _searchQuery = '';
  String _sortBy = 'name';

  final List<_TabData> _tabs = [
    const _TabData(label: 'All', status: null),
    const _TabData(label: 'Active', status: MistriStatus.active),
    const _TabData(label: 'Inactive', status: MistriStatus.inactive),
    const _TabData(label: 'Pending', status: MistriStatus.pending),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  List<DealerMistriModel> get _filteredMistris {
    var mistris = _mistris.toList();

    // Filter by tab status
    final currentTab = _tabs[_tabController.index];
    if (currentTab.status != null) {
      mistris = mistris.where((m) => m.status == currentTab.status).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      mistris = mistris.where((m) {
        final query = _searchQuery.toLowerCase();
        return m.name.toLowerCase().contains(query) ||
            m.phone.toLowerCase().contains(query) ||
            m.specialization.toLowerCase().contains(query);
      }).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'name':
        mistris.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'deliveries':
        mistris.sort((a, b) => b.totalDeliveries.compareTo(a.totalDeliveries));
        break;
      case 'success':
        mistris.sort((a, b) => b.successRate.compareTo(a.successRate));
        break;
      case 'points':
        mistris.sort((a, b) => b.rewardPoints.compareTo(a.rewardPoints));
        break;
    }

    return mistris;
  }

  int _getCountForStatus(MistriStatus? status) {
    if (status == null) return _mistris.length;
    return _mistris.where((m) => m.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(innerBoxIsScrolled),
            SliverToBoxAdapter(child: _buildSearchAndActions()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(child: _buildTabBar()),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _tabs.map((tab) => _buildMistriList()).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMistriSheet(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Mistri'),
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
          AppLocalizations.of(context).mistriMgmtTitle,
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort, color: AppColors.textPrimary),
          onSelected: (value) => setState(() => _sortBy = value),
          itemBuilder: (context) => [
            _buildSortMenuItem('name', 'Name'),
            _buildSortMenuItem('deliveries', 'Deliveries'),
            _buildSortMenuItem('success', 'Success Rate'),
            _buildSortMenuItem('points', 'Points'),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (_sortBy == value)
            const Icon(Icons.check, size: 18, color: AppColors.primary)
          else
            const SizedBox(width: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSearchAndActions() {
    return Container(
      color: AppColors.cardWhite,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _searchDebouncer.run(
                () => setState(() => _searchQuery = value),
              ),
              decoration: InputDecoration(
                hintText: 'Search mistris...',
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
          const SizedBox(height: AppSpacing.md),
          // Stats row
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildStatChip(
                label: 'Total',
                value: '${_mistris.length}',
                color: AppColors.primary,
              ),
              _buildStatChip(
                label: 'Active',
                value: '${_getCountForStatus(MistriStatus.active)}',
                color: AppColors.success,
              ),
              _buildStatChip(
                label: 'Pending',
                value: '${_getCountForStatus(MistriStatus.pending)}',
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildNearbyDiscoverySection(),
        ],
      ),
    );
  }

  Widget _buildNearbyDiscoverySection() {
    if (_nearbyMistris.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby Registered Mistris',
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._nearbyMistris.take(4).map(
          (mistri) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mistri.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          '${mistri.specialization} - ${mistri.city}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () => _attachNearbyMistri(mistri),
                      child: const Text('Attach'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _attachNearbyMistri(NearbyMistriModel mistri) async {
    try {
      final result = await context.read<DealerDataProvider>().attachNearbyMistri(
        mistri.id,
      );
      if (!mounted) return;
      final message = result.wasReassignedFromAnotherDealer
          ? 'Mistri moved to your account successfully'
          : 'Mistri linked successfully';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success),
      );

      final smsBody = result.isPendingInvite
          ? 'TSL Parivar: You were added as mistri. Login with OTP on this number to activate your account.'
          : 'TSL Parivar: Your profile is linked with a dealer. Login to view assigned dealer details and start orders.';
      await UrlLauncherService.launchSms(result.normalizedPhone, body: smsBody);
    } catch (_) {
      if (!mounted) return;
      final error = context.read<DealerDataProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Unable to attach mistri.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.caption.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.cardWhite,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        onTap: (_) => setState(() {}),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        dividerColor: AppColors.divider,
        tabs: _tabs.map((tab) {
          final count = _getCountForStatus(tab.status);
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tab.label),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.disabled.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMistriList() {
    final mistris = _filteredMistris;

    if (mistris.isEmpty) {
      return Center(
        child: TslEmptyState(
          icon: Icons.group_outlined,
          title: 'No Mistris Found',
          message: _searchQuery.isNotEmpty
              ? 'No mistris match your search'
              : 'Add your first mistri to get started',
          actionText: _searchQuery.isEmpty ? 'Add Mistri' : 'Clear Search',
          onAction: _searchQuery.isEmpty
              ? () => _showAddMistriSheet()
              : () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future<void>.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: mistris.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < mistris.length - 1
                  ? AppSpacing.md
                  : AppSpacing.xxxl,
            ),
            child: _MistriCard(
              mistri: mistris[index],
              onTap: () => _showMistriDetails(mistris[index]),
              onCall: () => _callMistri(mistris[index]),
              onMessage: () => _messageMistri(mistris[index]),
              onAssign: () => _assignDeliveryToMistri(mistris[index]),
            ),
          );
        },
      ),
    );
  }

  void _showAddMistriSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _AddMistriSheet(),
    );
  }

  void _showMistriDetails(DealerMistriModel mistri) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _MistriDetailsSheet(
        mistri: mistri,
        onCall: () => _callMistri(mistri),
        onMessage: () => _messageMistri(mistri),
        onAssign: () => _assignDeliveryToMistri(mistri),
      ),
    );
  }

  Future<void> _callMistri(DealerMistriModel mistri) async {
    final launched = await UrlLauncherService.launchPhone(mistri.phone);
    if (!mounted || launched) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open phone dialer.')),
    );
  }

  Future<void> _messageMistri(DealerMistriModel mistri) async {
    final launched = await UrlLauncherService.launchSms(
      mistri.phone,
      body: 'Hello ${mistri.name}, please check your TSL Parivar tasks.',
    );
    if (!mounted || launched) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open messaging app.')),
    );
  }

  void _assignDeliveryToMistri(DealerMistriModel mistri) {
    if (mistri.status != MistriStatus.active) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only active mistris can be assigned deliveries.')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Assign Delivery'),
        content: Text('Open orders tab to assign delivery for ${mistri.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.go('${AppRoutes.dealerHome}?tab=orders');
            },
            child: const Text('Open Orders'),
          ),
        ],
      ),
    );
  }
}

/// Mistri card widget
class _MistriCard extends StatelessWidget {
  final DealerMistriModel mistri;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onAssign;

  const _MistriCard({
    required this.mistri,
    this.onTap,
    this.onCall,
    this.onMessage,
    this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: _getGradientColors()),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          mistri.name.substring(0, 1).toUpperCase(),
                          style: AppTypography.h2.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  mistri.name,
                                  style: AppTypography.h3,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              _buildStatusBadge(),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            mistri.specialization,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            mistri.phone,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Stats
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.local_shipping,
                          value: '${mistri.completedDeliveries}',
                          label: 'Deliveries',
                        ),
                      ),
                      _buildDivider(),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.trending_up,
                          value: '${mistri.successRate.toStringAsFixed(1)}%',
                          label: 'Success',
                          valueColor: _getSuccessColor(),
                        ),
                      ),
                      _buildDivider(),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.star,
                          value: '${mistri.rewardPoints}',
                          label: 'Points',
                          valueColor: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.call,
                        label: 'Call',
                        color: AppColors.success,
                        onTap: onCall,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.message,
                        label: 'Message',
                        color: AppColors.info,
                        onTap: onMessage,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.assignment,
                        label: 'Assign',
                        color: AppColors.primary,
                        onTap: mistri.status == MistriStatus.active
                            ? onAssign
                            : null,
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

  List<Color> _getGradientColors() {
    switch (mistri.status) {
      case MistriStatus.active:
        return const [Color(0xFF4CAF50), Color(0xFF2E7D32)];
      case MistriStatus.inactive:
        return const [Color(0xFF9E9E9E), Color(0xFF616161)];
      case MistriStatus.pending:
        return const [Color(0xFFFFA726), Color(0xFFEF6C00)];
    }
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: mistri.status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        mistri.status.displayName,
        style: AppTypography.caption.copyWith(
          color: mistri.status.color,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: valueColor ?? AppColors.textSecondary),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              value,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 30, color: AppColors.divider);
  }

  Color _getSuccessColor() {
    if (mistri.successRate >= 95) return AppColors.success;
    if (mistri.successRate >= 85) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return Material(
      color: isEnabled
          ? color.withValues(alpha: 0.1)
          : AppColors.disabled.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isEnabled ? color : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    color: isEnabled ? color : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tab data class
class _TabData {
  final String label;
  final MistriStatus? status;

  const _TabData({required this.label, required this.status});
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

/// Add Mistri bottom sheet
class _AddMistriSheet extends StatefulWidget {
  const _AddMistriSheet();

  @override
  State<_AddMistriSheet> createState() => _AddMistriSheetState();
}

class _AddMistriSheetState extends State<_AddMistriSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _specialization = 'TMT Bars & Structural Steel';
  bool _isSubmitting = false;

  final List<String> _specializations = [
    'TMT Bars & Structural Steel',
    'Girders & Channels',
    'Color Sheets & Pipes',
    'Binding Wire',
    'All Materials',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await context
          .read<DealerDataProvider>()
          .addMistriForDealer(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            specialization: _specialization,
          );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      final message = result.wasReassignedFromAnotherDealer
          ? 'Mistri moved to your account successfully'
          : result.isPendingInvite
          ? 'Mistri invite created. Link will activate after login.'
          : result.wasExisting
          ? 'Mistri linked successfully'
          : 'Mistri added successfully';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      final providerMessage = context.read<DealerDataProvider>().errorMessage;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            providerMessage ?? 'Unable to add mistri. Please try again.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
          child: Form(
            key: _formKey,
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
                Text('Add New Mistri', style: AppTypography.h2),
                const SizedBox(height: AppSpacing.xxl),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) => value?.trim().isEmpty ?? true
                      ? 'Please enter name'
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    prefixText: '+91 ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    final validation = Validators.validatePhone(value);
                    if (validation.isValid) {
                      return null;
                    }
                    return validation.errors.first;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  initialValue: _specialization,
                  decoration: InputDecoration(
                    labelText: 'Specialization',
                    prefixIcon: const Icon(Icons.work_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _specializations
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _specialization = value);
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: TslPrimaryButton(
                    label: 'Add Mistri',
                    leadingIcon: Icons.person_add,
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mistri details bottom sheet
class _MistriDetailsSheet extends StatelessWidget {
  final DealerMistriModel mistri;
  final VoidCallback onCall;
  final VoidCallback onMessage;
  final VoidCallback onAssign;

  const _MistriDetailsSheet({
    required this.mistri,
    required this.onCall,
    required this.onMessage,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.disabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      mistri.name.substring(0, 1).toUpperCase(),
                      style: AppTypography.h1.copyWith(
                        color: Colors.white,
                        fontSize: 36,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(mistri.name, style: AppTypography.h2),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  mistri.specialization,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: mistri.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mistri.status.displayName,
                    style: AppTypography.labelMedium.copyWith(
                      color: mistri.status.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                // Stats grid
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailStat(
                        'Deliveries',
                        '${mistri.totalDeliveries}',
                      ),
                    ),
                    Expanded(
                      child: _buildDetailStat(
                        'Completed',
                        '${mistri.completedDeliveries}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailStat(
                        'Success Rate',
                        '${mistri.successRate.toStringAsFixed(1)}%',
                      ),
                    ),
                    Expanded(
                      child: _buildDetailStat(
                        'Points',
                        '${mistri.rewardPoints}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                // Actions
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: TslSecondaryButton(
                        label: 'Call',
                        leadingIcon: Icons.call,
                        onPressed: onCall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: TslSecondaryButton(
                        label: 'Message',
                        leadingIcon: Icons.message,
                        onPressed: onMessage,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: TslPrimaryButton(
                        label: 'Assign Delivery',
                        leadingIcon: Icons.assignment,
                        onPressed: mistri.status == MistriStatus.active
                            ? onAssign
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.h2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
