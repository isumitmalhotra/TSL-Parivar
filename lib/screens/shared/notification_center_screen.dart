import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/shared_models.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/widgets.dart';

/// Notification Center Screen
///
/// Features:
/// - Notifications grouped by date
/// - Filter by type
/// - Mark as read/unread
/// - Delete notifications
/// - Deep linking to relevant screens
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _shimmerController;

  NotificationType? _selectedFilter;
  List<AppNotification> _notifications = [];
  NotificationProvider? _notificationProvider;
  final Set<String> _selectedNotifications = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_notificationProvider == null) {
      _notificationProvider = context.read<NotificationProvider>();
      _notificationProvider!.addListener(_syncNotificationsFromProvider);
      _syncNotificationsFromProvider();
      _notificationProvider!.loadNotifications();
    }
  }

  void _syncNotificationsFromProvider() {
    if (!mounted || _notificationProvider == null) return;
    setState(() {
      _notifications = List<AppNotification>.from(_notificationProvider!.allNotifications);
    });
  }

  @override
  void dispose() {
    _notificationProvider?.removeListener(_syncNotificationsFromProvider);
    _fabController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _toggleFilter(NotificationType? type) {
    setState(() {
      _selectedFilter = _selectedFilter == type ? null : type;
    });
  }

  List<AppNotification> get _filteredNotifications {
    if (_selectedFilter == null) return _notifications;
    return _notifications.where((n) => n.type == _selectedFilter).toList();
  }

  Map<String, List<AppNotification>> get _groupedNotifications {
    final groups = <String, List<AppNotification>>{};
    final now = DateTime.now();

    for (final notification in _filteredNotifications) {
      final diff = now.difference(notification.timestamp);
      String key;

      if (diff.inDays == 0) {
        key = 'today';
      } else if (diff.inDays == 1) {
        key = 'yesterday';
      } else if (diff.inDays < 7) {
        key = 'thisWeek';
      } else {
        key = 'earlier';
      }

      groups.putIfAbsent(key, () => []).add(notification);
    }

    return groups;
  }

  int get _unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  Future<void> _markAsRead(String id) async {
    await _notificationProvider?.markAsRead(id);
  }

  Future<void> _markAsUnread(String id) async {
    await _notificationProvider?.markAsUnread(id);
  }

  Future<void> _deleteNotification(String id) async {
    await _notificationProvider?.deleteNotification(id);
  }

  /// Navigate to the screen indicated by the deep link path
  void _navigateToDeepLink(String deepLink) {
    try {
      // Deep link format examples:
      // /mistri/deliveries/del_001 -> delivery details
      // /mistri/rewards -> rewards tab
      // /dealer/orders -> orders tab
      // /chat/dealer_001 -> chat screen

      final segments = deepLink.split('/').where((s) => s.isNotEmpty).toList();

      if (segments.isEmpty) return;

      switch (segments[0]) {
        case 'mistri':
          if (segments.length >= 3 && segments[1] == 'deliveries') {
            // Navigate to specific delivery details
            context.push('/mistri/deliveries/${segments[2]}');
          } else if (segments.length >= 2 && segments[1] == 'rewards') {
            context.go('/mistri');
            // Switch to rewards tab (index 2)
          } else {
            context.go('/mistri');
          }
          break;
        case 'dealer':
          if (segments.length >= 2 && segments[1] == 'orders') {
            context.go('/dealer');
            // Switch to orders tab (index 1)
          } else if (segments.length >= 2 && segments[1] == 'pending-approvals') {
            context.push('/dealer/pending-approvals');
          } else {
            context.go('/dealer');
          }
          break;
        case 'architect':
          if (segments.length >= 2 && segments[1] == 'projects') {
            context.go('/architect');
            // Switch to projects tab (index 1)
          } else {
            context.go('/architect');
          }
          break;
        case 'chat':
          if (segments.length >= 2) {
            context.push('/chat-contacts');
          }
          break;
        default:
          // Unknown deep link - just pop back
          debugPrint('Unknown deep link: $deepLink');
      }
    } catch (e) {
      debugPrint('Error navigating to deep link: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    await _notificationProvider?.markAllAsRead();
  }

  Future<void> _deleteSelected() async {
    final ids = _selectedNotifications.toList(growable: false);
    await _notificationProvider?.deleteNotifications(ids);
    setState(() {
      _selectedNotifications.clear();
      _isSelectionMode = false;
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedNotifications.contains(id)) {
        _selectedNotifications.remove(id);
        if (_selectedNotifications.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedNotifications.add(id);
      }
    });
  }

  void _startSelectionMode(String id) {
    setState(() {
      _isSelectionMode = true;
      _selectedNotifications.add(id);
    });
  }

  void _cancelSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNotifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(innerBoxIsScrolled),
            SliverToBoxAdapter(child: _buildFilterChips()),
          ];
        },
        body: _buildNotificationsList(),
      ),
      floatingActionButton: _unreadCount > 0 && !_isSelectionMode
          ? _buildMarkAllReadFab()
          : null,
    );
  }

  Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF2E7D32),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _cancelSelectionMode,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _selectedNotifications.isNotEmpty
                ? () => _showDeleteConfirmation()
                : null,
          ),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => _showSettingsSheet(),
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeaderContent(),
        title: innerBoxIsScrolled
            ? Text(
                _isSelectionMode
                    ? AppLocalizations.of(context)
                        .notificationsSelectedCount(_selectedNotifications.length)
                    : AppLocalizations.of(context).notificationsTitle,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              )
            : null,
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF388E3C), Color(0xFF1B5E20)],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _NotificationPatternPainter(),
            ),
          ),
          // Floating circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
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
                              AppLocalizations.of(context).notificationsTitle,
                              style: AppTypography.h2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Row(
                              children: [
                                if (_unreadCount > 0) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xxs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .notificationsUnreadCount(_unreadCount),
                                      style: AppTypography.caption.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                ],
                                Text(
                                  AppLocalizations.of(context)
                                      .notificationsTotalCount(_notifications.length),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.cardWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notificationsFilterByType,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, l10n.notificationsFilterAll, Icons.all_inbox_outlined),
                ...NotificationType.values.map((type) {
                  return _buildFilterChip(type, type.displayName, type.icon);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    NotificationType? type,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedFilter == type;
    final color = type?.color ?? const Color(0xFF2E7D32);

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          child: InkWell(
            onTap: () => _toggleFilter(type),
            borderRadius: BorderRadius.circular(AppRadius.chip),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : color,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected ? Colors.white : color,
                      fontWeight: FontWeight.w600,
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

  Widget _buildNotificationsList() {
    final l10n = AppLocalizations.of(context);
    if (_filteredNotifications.isEmpty) {
      return Center(
        child: TslEmptyState(
          icon: Icons.notifications_off_outlined,
          title: l10n.notificationsNoNotifications,
          message: _selectedFilter != null
              ? l10n.notificationsNoFiltered(_selectedFilter!.displayName.toLowerCase())
              : l10n.notificationsAllCaughtUp,
          actionText: _selectedFilter != null ? l10n.clearSearch : null,
          onAction: _selectedFilter != null
              ? () => _toggleFilter(null)
              : null,
        ),
      );
    }

    final groups = _groupedNotifications;
    final sortedKeys = ['today', 'yesterday', 'thisWeek', 'earlier']
        .where((key) => groups.containsKey(key))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final notifications = groups[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: AppSpacing.lg),
            _buildDateHeader(key),
            const SizedBox(height: AppSpacing.sm),
            ...notifications.map((notification) {
              return _NotificationCard(
                notification: notification,
                isSelected: _selectedNotifications.contains(notification.id),
                isSelectionMode: _isSelectionMode,
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleSelection(notification.id);
                  } else {
                    _markAsRead(notification.id);
                    _handleNotificationTap(notification);
                  }
                },
                onLongPress: () => _startSelectionMode(notification.id),
                onMarkRead: () => _markAsRead(notification.id),
                onMarkUnread: () => _markAsUnread(notification.id),
                onDelete: () => _deleteNotification(notification.id),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(String title) {
    final l10n = AppLocalizations.of(context);
    final localizedTitle = switch (title) {
      'today' => l10n.today,
      'yesterday' => l10n.yesterday,
      'thisWeek' => l10n.thisWeek,
      _ => l10n.earlier,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Text(
              localizedTitle,
              style: AppTypography.labelMedium.copyWith(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2E7D32).withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkAllReadFab() {
    final l10n = AppLocalizations.of(context);
    return FloatingActionButton.extended(
      onPressed: _markAllAsRead,
      backgroundColor: const Color(0xFF2E7D32),
      icon: const Icon(Icons.done_all, color: Colors.white),
      label: Text(
        l10n.notificationsMarkAllRead,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // Show notification detail dialog
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _NotificationDetailSheet(
        notification: notification,
        onMarkRead: () {
          _markAsRead(notification.id);
          Navigator.pop(context);
        },
        onDelete: () {
          _deleteNotification(notification.id);
          Navigator.pop(context);
        },
        onOpenDeepLink: () {
          Navigator.pop(context);
          // Navigate to deep link using GoRouter
          if (notification.deepLink != null) {
            _markAsRead(notification.id);
            _navigateToDeepLink(notification.deepLink!);
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(l10n.notificationsDeleteTitle),
        content: Text(
          l10n.notificationsDeleteConfirm(_selectedNotifications.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSelected();
            },
            child: Text(
              l10n.commonDelete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _NotificationSettingsSheet(),
    );
  }
}

/// Notification card widget
class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMarkRead;
  final VoidCallback onMarkUnread;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onMarkRead,
    required this.onMarkUnread,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: isSelectionMode
          ? DismissDirection.none
          : DismissDirection.horizontal,
      background: _buildSwipeBackground(
        Colors.green,
        Icons.check,
        AppLocalizations.of(context).notificationsRead,
      ),
      secondaryBackground:
          _buildSwipeBackground(
        AppColors.error,
        Icons.delete,
        AppLocalizations.of(context).commonDelete,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          notification.isRead ? onMarkUnread() : onMarkRead();
          return false;
        } else {
          return true;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
              : notification.isRead
                  ? AppColors.cardWhite
                  : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF2E7D32), width: 2)
              : notification.isRead
                  ? null
                  : Border.all(
                      color: notification.type.color.withValues(alpha: 0.3),
                      width: 1,
                    ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: notification.isRead ? 0.04 : 0.08),
              blurRadius: notification.isRead ? 8 : 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selection checkbox or type icon
                  if (isSelectionMode)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2E7D32)
                            : AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isSelected ? Icons.check : Icons.circle_outlined,
                        color: isSelected ? Colors.white : AppColors.disabled,
                      ),
                    )
                  else
                    _buildTypeIcon(),
                  const SizedBox(width: AppSpacing.md),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                  color: notification.isRead
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: notification.type.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          notification.message,
                          style: AppTypography.bodySmall.copyWith(
                            color: notification.isRead
                                ? AppColors.textSecondary.withValues(alpha: 0.7)
                                : AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: AppColors.textSecondary.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              _formatTimestamp(context, notification.timestamp),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary.withValues(alpha: 0.6),
                              ),
                            ),
                            if (notification.deepLink != null) ...[
                              const SizedBox(width: AppSpacing.md),
                              Icon(
                                Icons.open_in_new,
                                size: 12,
                                color: notification.type.color,
                              ),
                              const SizedBox(width: AppSpacing.xxs),
                              Text(
                                AppLocalizations.of(context).commonView,
                                style: AppTypography.caption.copyWith(
                                  color: notification.type.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildTypeIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            notification.type.color,
            notification.type.color.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: notification.type.color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        notification.type.icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildSwipeBackground(Color color, IconData icon, String label) {
    return Container(
      alignment: color == Colors.green
          ? Alignment.centerLeft
          : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: color == Colors.green
            ? [
                Icon(icon, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                Text(label, style: const TextStyle(color: Colors.white)),
              ]
            : [
                Text(label, style: const TextStyle(color: Colors.white)),
                const SizedBox(width: AppSpacing.sm),
                Icon(icon, color: Colors.white),
              ],
      ),
    );
  }

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return l10n.notificationsJustNow;
    } else if (diff.inMinutes < 60) {
      return l10n.agoMinutes(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.agoHours(diff.inHours);
    } else if (diff.inDays < 7) {
      return l10n.agoDays(diff.inDays);
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// Notification detail sheet
class _NotificationDetailSheet extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;
  final VoidCallback onOpenDeepLink;

  const _NotificationDetailSheet({
    required this.notification,
    required this.onMarkRead,
    required this.onDelete,
    required this.onOpenDeepLink,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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
          // Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      notification.type.color,
                      notification.type.color.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  notification.type.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: notification.type.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        notification.type.displayName,
                        style: AppTypography.caption.copyWith(
                          color: notification.type.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.title,
                      style: AppTypography.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              notification.message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Timestamp
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _formatFullTimestamp(notification.timestamp),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  label: Text(
                    AppLocalizations.of(context).commonDelete,
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: notification.deepLink != null
                      ? onOpenDeepLink
                      : null,
                  icon: const Icon(Icons.open_in_new, color: Colors.white),
                  label: Text(
                    AppLocalizations.of(context).notificationsOpen,
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: notification.type.color,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFullTimestamp(DateTime timestamp) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    final ampm = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year} at $hour:${timestamp.minute.toString().padLeft(2, '0')} $ampm';
  }
}

/// Notification settings sheet
class _NotificationSettingsSheet extends StatefulWidget {
  const _NotificationSettingsSheet();

  @override
  State<_NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState
    extends State<_NotificationSettingsSheet> {
  bool _deliveryNotifs = true;
  bool _rewardNotifs = true;
  bool _orderNotifs = true;
  bool _messageNotifs = true;
  bool _systemNotifs = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

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
          Text(AppLocalizations.of(context).notificationsSettings, style: AppTypography.h2),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppLocalizations.of(context).notificationsTypes,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildToggle(
            AppLocalizations.of(context).notificationsDeliveryUpdates,
            Icons.local_shipping_outlined,
            _deliveryNotifs,
            (v) => setState(() => _deliveryNotifs = v),
          ),
          _buildToggle(
            AppLocalizations.of(context).notificationsRewardsPoints,
            Icons.emoji_events_outlined,
            _rewardNotifs,
            (v) => setState(() => _rewardNotifs = v),
          ),
          _buildToggle(
            AppLocalizations.of(context).orderRequestsTitle,
            Icons.receipt_long_outlined,
            _orderNotifs,
            (v) => setState(() => _orderNotifs = v),
          ),
          _buildToggle(
            AppLocalizations.of(context).chatTitle,
            Icons.chat_bubble_outline,
            _messageNotifs,
            (v) => setState(() => _messageNotifs = v),
          ),
          _buildToggle(
            AppLocalizations.of(context).notificationsSystemAlerts,
            Icons.notifications_outlined,
            _systemNotifs,
            (v) => setState(() => _systemNotifs = v),
          ),
          const Divider(height: AppSpacing.xxl),
          Text(
            AppLocalizations.of(context).notificationsSoundVibration,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildToggle(
            AppLocalizations.of(context).notificationsSound,
            Icons.volume_up_outlined,
            _soundEnabled,
            (v) => setState(() => _soundEnabled = v),
          ),
          _buildToggle(
            AppLocalizations.of(context).notificationsVibration,
            Icons.vibration,
            _vibrationEnabled,
            (v) => setState(() => _vibrationEnabled = v),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: TslPrimaryButton(
              label: AppLocalizations.of(context).commonSave,
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).notificationsSettingsSaved),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label, style: AppTypography.bodyMedium),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF2E7D32);
              }
              return null;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF2E7D32).withValues(alpha: 0.5);
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }
}

/// Pattern painter for notification header
class _NotificationPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    // Draw curved lines
    for (var i = 0; i < 5; i++) {
      final path = Path();
      path.moveTo(0, size.height * (0.2 + i * 0.15));
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * (0.3 + i * 0.1),
        size.width,
        size.height * (0.1 + i * 0.2),
      );
      canvas.drawPath(path, paint..style = PaintingStyle.stroke);
    }

    // Draw dots
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (var i = 0; i < 20; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        2 + random.nextDouble() * 3,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

