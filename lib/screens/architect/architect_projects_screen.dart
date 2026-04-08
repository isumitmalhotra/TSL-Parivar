import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/architect_models.dart';
import '../../services/url_launcher_service.dart';
import '../../widgets/widgets.dart';

/// Architect Projects Screen
///
/// Features:
/// - Projects list view
/// - Project card component
/// - Project detail view
/// - Filter by status
class ArchitectProjectsScreen extends StatefulWidget {
  const ArchitectProjectsScreen({super.key});

  @override
  State<ArchitectProjectsScreen> createState() => _ArchitectProjectsScreenState();
}

class _ArchitectProjectsScreenState extends State<ArchitectProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<ArchitectProject> _projects = [];
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer();
  String _searchQuery = '';

  final List<_TabData> _tabs = [
    const _TabData(label: 'All', status: null),
    const _TabData(label: 'Active', status: ProjectStatus.active),
    const _TabData(label: 'On Hold', status: ProjectStatus.onHold),
    const _TabData(label: 'Completed', status: ProjectStatus.completed),
    const _TabData(label: 'Drafts', status: ProjectStatus.draft),
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

  List<ArchitectProject> get _filteredProjects {
    var projects = _projects.toList();

    // Filter by tab status
    final currentTab = _tabs[_tabController.index];
    if (currentTab.status != null) {
      projects = projects.where((p) => p.status == currentTab.status).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      projects = projects.where((p) {
        final query = _searchQuery.toLowerCase();
        return p.name.toLowerCase().contains(query) ||
            p.location.toLowerCase().contains(query) ||
            p.type.displayName.toLowerCase().contains(query);
      }).toList();
    }

    return projects;
  }

  int _getCountForStatus(ProjectStatus? status) {
    if (status == null) return _projects.length;
    return _projects.where((p) => p.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(innerBoxIsScrolled),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(child: _buildTabBar()),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _tabs.map((tab) => _buildProjectsList()).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/architect/create-spec');
        },
        backgroundColor: const Color(0xFF43A047),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context).newProject),
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
          AppLocalizations.of(context).myProjects,
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
      ),
      actions: [
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => _searchDebouncer.run(() => setState(() => _searchQuery = value)),
          decoration: InputDecoration(
            hintText: 'Search projects...',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    icon: const Icon(Icons.clear, color: AppColors.textSecondary),
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
        onTap: (_) => setState(() {}),
        labelColor: const Color(0xFF43A047),
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: const Color(0xFF43A047),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

  Widget _buildProjectsList() {
    final projects = _filteredProjects;

    if (projects.isEmpty) {
      return Center(
        child: TslEmptyState(
          icon: Icons.folder_open_outlined,
          title: 'No Projects Found',
          message: _searchQuery.isNotEmpty
              ? 'No projects match your search'
              : 'Start by creating a new project',
          actionText: _searchQuery.isEmpty ? AppLocalizations.of(context).createProject : AppLocalizations.of(context).clearSearch,
          onAction: _searchQuery.isEmpty
              ? () {
                  context.push('/architect/create-spec');
                }
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
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < projects.length - 1 ? AppSpacing.md : AppSpacing.xxxl,
            ),
            child: _ProjectCard(
              project: projects[index],
              onTap: () => _showProjectDetails(projects[index]),
            ),
          );
        },
      ),
    );
  }

  void _showProjectDetails(ArchitectProject project) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProjectDetailSheet(project: project),
    );
  }
}

/// Project card widget
class _ProjectCard extends StatelessWidget {
  final ArchitectProject project;
  final VoidCallback? onTap;

  const _ProjectCard({
    required this.project,
    this.onTap,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: project.type.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        project.type.icon,
                        color: project.type.color,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: AppTypography.h3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                                  color: project.type.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  project.type.displayName,
                                  style: AppTypography.caption.copyWith(
                                    color: project.type.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: project.status.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  project.status.displayName,
                                  style: AppTypography.caption.copyWith(
                                    color: project.status.color,
                                    fontWeight: FontWeight.w500,
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
                const SizedBox(height: AppSpacing.md),
                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      project.location,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.description,
                        value: '${project.specifications.length}',
                        label: 'Specs',
                      ),
                      _buildDivider(),
                      _buildStatItem(
                        icon: Icons.store,
                        value: '${project.dealers.length}',
                        label: 'Dealers',
                      ),
                      _buildDivider(),
                      _buildStatItem(
                        icon: Icons.inventory_2,
                        value: '${project.totalQuantity.toStringAsFixed(0)}kg',
                        label: 'Material',
                      ),
                      _buildDivider(),
                      _buildStatItem(
                        icon: Icons.star,
                        value: '${project.pointsEarned}',
                        label: 'Points',
                        valueColor: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
                // Notes if any
                if (project.notes != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            project.notes!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.warning,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
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
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.divider,
    );
  }
}

/// Project detail bottom sheet
class _ProjectDetailSheet extends StatelessWidget {
  final ArchitectProject project;

  const _ProjectDetailSheet({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
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
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: project.type.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    project.type.icon,
                    color: project.type.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name, style: AppTypography.h2),
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: project.status.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              project.status.displayName,
                              style: AppTypography.caption.copyWith(
                                color: project.status.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: AppSpacing.xl),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location
                  _buildDetailSection(
                    title: 'Location',
                    icon: Icons.location_on,
                    child: Text(
                      project.location,
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Specifications
                  _buildDetailSection(
                    title: 'Material Specifications',
                    icon: Icons.description,
                    child: project.specifications.isEmpty
                        ? Text(
                            'No specifications yet',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )
                        : Column(
                            children: project.specifications.map((spec) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.construction,
                                        size: 20,
                                        color: Color(0xFF43A047),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              spec.materialType,
                                              style: AppTypography.labelMedium,
                                            ),
                                            Text(
                                              '${spec.quantity} ${spec.unit} • ${spec.grade.displayName}',
                                              style: AppTypography.caption.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Dealers
                  _buildDetailSection(
                    title: 'Associated Dealers',
                    icon: Icons.store,
                    child: project.dealers.isEmpty
                        ? Text(
                            'No dealers associated',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )
                        : Column(
                            children: project.dealers.map((dealer) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: Container(
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
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            dealer.name.substring(0, 1),
                                            style: AppTypography.labelLarge.copyWith(
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
                                              dealer.name,
                                              style: AppTypography.labelMedium,
                                            ),
                                            Text(
                                              dealer.shopName,
                                              style: AppTypography.caption.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () => UrlLauncherService.launchPhone(dealer.phone),
                                            icon: const Icon(Icons.call, size: 20),
                                            color: AppColors.success,
                                          ),
                                          IconButton(
                                            onPressed: () => UrlLauncherService.launchSms(dealer.phone),
                                            icon: const Icon(Icons.message, size: 20),
                                            color: AppColors.info,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Points earned
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 32),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Points Earned',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            Text(
                              '${project.pointsEarned}',
                              style: AppTypography.h1.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
          // Actions
          Container(
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
                  Expanded(
                    child: TslSecondaryButton(
                      label: AppLocalizations.of(context).commonEdit,
                      leadingIcon: Icons.edit,
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/architect/create-spec', extra: project);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TslPrimaryButton(
                      label: AppLocalizations.of(context).addSpec,
                      leadingIcon: Icons.add,
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/architect/create-spec', extra: project);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF43A047)),
            const SizedBox(width: AppSpacing.sm),
            Text(title, style: AppTypography.h3),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}

/// Tab data class
class _TabData {
  final String label;
  final ProjectStatus? status;

  const _TabData({required this.label, required this.status});
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

