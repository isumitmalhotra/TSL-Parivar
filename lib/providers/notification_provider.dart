import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../models/shared_models.dart';
import '../services/firestore_service.dart';
import '../services/messaging_service.dart';

/// Notification filter options
enum NotificationFilter {
  all,
  unread,
  delivery,
  reward,
  order,
  approval,
  message,
  system,
}

/// Provider for managing notifications
class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  NotificationFilter _currentFilter = NotificationFilter.all;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;
  bool _handlersInitialized = false;
  bool _isGeneralTopicSubscribed = false;

  // Getters
  List<AppNotification> get notifications => _filteredNotifications;
  List<AppNotification> get allNotifications => _notifications;
  NotificationFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get fcmToken => MessagingService.fcmToken;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  /// Get filtered notifications
  List<AppNotification> get _filteredNotifications {
    var filtered = _notifications;

    switch (_currentFilter) {
      case NotificationFilter.all:
        break;
      case NotificationFilter.unread:
        filtered = filtered.where((n) => !n.isRead).toList();
        break;
      case NotificationFilter.delivery:
        filtered = filtered.where((n) => n.type == NotificationType.delivery).toList();
        break;
      case NotificationFilter.reward:
        filtered = filtered.where((n) => n.type == NotificationType.reward).toList();
        break;
      case NotificationFilter.order:
        filtered = filtered.where((n) => n.type == NotificationType.order).toList();
        break;
      case NotificationFilter.approval:
        filtered = filtered.where((n) => n.type == NotificationType.approval).toList();
        break;
      case NotificationFilter.message:
        filtered = filtered.where((n) => n.type == NotificationType.message).toList();
        break;
      case NotificationFilter.system:
        filtered = filtered.where((n) => n.type == NotificationType.system).toList();
        break;
    }

    return filtered;
  }

  /// Get notifications grouped by date
  Map<String, List<AppNotification>> get notificationsByDate {
    final grouped = <String, List<AppNotification>>{};
    for (final notification in _filteredNotifications) {
      final dateKey = _getDateKey(notification.timestamp);
      grouped.putIfAbsent(dateKey, () => []).add(notification);
    }
    return grouped;
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(notificationDate).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return 'This Week';
    return 'Earlier';
  }

  /// Keep notification session aligned with auth state changes.
  Future<void> syncAuthState({
    required bool isAuthenticated,
    String? userId,
  }) async {
    debugPrint('🧪[NOTIF] syncAuthState auth=$isAuthenticated uid=$userId current=$_currentUserId');
    await _ensureHandlersInitialized();

    if (!isAuthenticated || userId == null || userId.isEmpty) {
      await _unsubscribeUserTopics();
      clearData();
      _currentUserId = null;
      debugPrint('🧪[NOTIF] cleared state for logged-out user');
      return;
    }

    if (_currentUserId == userId) {
      if (_notifications.isEmpty && !_isLoading) {
        await loadNotifications(userId: userId);
      }
      return;
    }

    final previousUserId = _currentUserId;
    _currentUserId = userId;

    if (!_isGeneralTopicSubscribed) {
      await MessagingService.subscribeToTopic('all_users');
      _isGeneralTopicSubscribed = true;
    }

    if (previousUserId != null && previousUserId.isNotEmpty) {
      await MessagingService.unsubscribeFromTopic('user_$previousUserId');
    }

    await MessagingService.subscribeToTopic('user_$userId');
    await MessagingService.saveTokenForUser(userId);
    debugPrint('🧪[NOTIF] subscribed topics for uid=$userId');
    await loadNotifications(userId: userId);
  }

  /// Initialize notification provider with Firebase
  Future<void> initialize({String? userId}) async {
    await _ensureHandlersInitialized();
    if (userId != null && userId.isNotEmpty) {
      await syncAuthState(isAuthenticated: true, userId: userId);
    }
  }

  Future<void> _ensureHandlersInitialized() async {
    if (_handlersInitialized) return;

    try {
      _setupFCMHandlers();
      _handlersInitialized = true;
      debugPrint('✅ NotificationProvider handlers initialized');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  /// Setup Firebase Cloud Messaging handlers
  void _setupFCMHandlers() {
    // Handle foreground messages
    MessagingService.setupForegroundHandler(_handleForegroundMessage);

    // Handle notification tap when app is in background/terminated
    MessagingService.setupNotificationOpenedHandler(_handleNotificationTap);

    // Check if app was opened from a notification
    _checkInitialMessage();
  }

  /// Handle foreground FCM message
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('🔔 Foreground message received: ${message.notification?.title}');

    // Convert FCM message to AppNotification
    final notification = _convertRemoteMessageToNotification(message);
    if (notification != null) {
      addNotification(notification);
      final activeUid = _currentUserId;
      if (activeUid != null && activeUid.isNotEmpty) {
        unawaited(loadNotifications(userId: activeUid));
      }
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('🔔 Notification tapped: ${message.data}');
    // Navigation will be handled by the app based on deepLink
  }

  /// Check if app was opened from a notification
  Future<void> _checkInitialMessage() async {
    final initialMessage = await MessagingService.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🔔 App opened from notification: ${initialMessage.data}');
      // Handle initial message navigation
    }
  }

  /// Convert RemoteMessage to AppNotification
  AppNotification? _convertRemoteMessageToNotification(RemoteMessage message) {
    try {
      final data = message.data;
      return AppNotification(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: _parseNotificationType(data['type'] as String?),
        title: message.notification?.title ?? (data['title'] as String?) ?? 'Notification',
        message: message.notification?.body ?? (data['body'] as String?) ?? '',
        timestamp: DateTime.now(),
        isRead: false,
        deepLink: data['deepLink'] as String?,
        metadata: data,
      );
    } catch (e) {
      debugPrint('❌ Error converting remote message: $e');
      return null;
    }
  }

  /// Parse notification type from string
  NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'delivery':
        return NotificationType.delivery;
      case 'reward':
        return NotificationType.reward;
      case 'order':
        return NotificationType.order;
      case 'approval':
        return NotificationType.approval;
      case 'message':
        return NotificationType.message;
      case 'system':
      default:
        return NotificationType.system;
    }
  }

  /// Load notifications for the currently signed-in user from Firestore.
  Future<void> loadNotifications({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    _currentUserId = userId ?? _currentUserId;
    notifyListeners();

    try {
      if (_currentUserId == null || _currentUserId!.isEmpty) {
        _notifications = [];
        _isLoading = false;
        debugPrint('🧪[NOTIF] loadNotifications skipped (no uid)');
        notifyListeners();
        return;
      }

      final notificationsSnapshot = await FirestoreService.notificationsCollection
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      _notifications = notificationsSnapshot.docs.map((doc) {
        final data = doc.data();
        return AppNotification(
          id: doc.id,
          type: _parseNotificationType(data['type'] as String?),
          title: (data['title'] as String?) ?? '',
          message: (data['message'] as String?) ?? '',
          timestamp: _parseTimestamp(data['timestamp']),
          isRead: (data['isRead'] as bool?) ?? false,
          deepLink: data['deepLink'] as String?,
          metadata: (data['metadata'] as Map<String, dynamic>?) ?? {},
        );
      }).toList();

      debugPrint(
        '✅ Loaded ${_notifications.length} notifications from Firestore for uid=$_currentUserId',
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading notifications: $e');
      _notifications = [];
      _errorMessage = 'Failed to load notifications';
      _isLoading = false;
      notifyListeners();
    }
  }

  DateTime _parseTimestamp(dynamic rawValue) {
    if (rawValue is Timestamp) {
      return rawValue.toDate();
    }
    if (rawValue is String) {
      return DateTime.tryParse(rawValue) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Load notifications (legacy method for backward compatibility)
  @Deprecated('Use loadNotifications(userId: ...) instead')
  Future<void> loadNotificationsLegacy() async {
    await loadNotifications();
  }

  /// Set filter
  void setFilter(NotificationFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();

      // Update in Firestore
      try {
        await FirestoreService.updateDocument(
          collection: FirestoreService.notificationsCollection,
          documentId: notificationId,
          data: {'isRead': true},
        );
      } catch (e) {
        debugPrint('⚠️ Failed to update notification in Firestore: $e');
      }
    }
  }

  /// Mark notification as unread
  Future<void> markAsUnread(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: false);
      notifyListeners();

      // Update in Firestore
      try {
        await FirestoreService.updateDocument(
          collection: FirestoreService.notificationsCollection,
          documentId: notificationId,
          data: {'isRead': false},
        );
      } catch (e) {
        debugPrint('⚠️ Failed to update notification in Firestore: $e');
      }
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    // Update all in Firestore (batch would be better for large lists)
    for (final notification in _notifications) {
      try {
        await FirestoreService.updateDocument(
          collection: FirestoreService.notificationsCollection,
          documentId: notification.id,
          data: {'isRead': true},
        );
      } catch (e) {
        debugPrint('⚠️ Failed to update notification ${notification.id}: $e');
      }
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();

    // Delete from Firestore
    try {
      await FirestoreService.deleteDocument(
        collection: FirestoreService.notificationsCollection,
        documentId: notificationId,
      );
    } catch (e) {
      debugPrint('⚠️ Failed to delete notification from Firestore: $e');
    }
  }

  /// Delete multiple notifications
  Future<void> deleteNotifications(List<String> notificationIds) async {
    _notifications.removeWhere((n) => notificationIds.contains(n.id));
    notifyListeners();

    // Delete from Firestore
    for (final id in notificationIds) {
      try {
        await FirestoreService.deleteDocument(
          collection: FirestoreService.notificationsCollection,
          documentId: id,
        );
      } catch (e) {
        debugPrint('⚠️ Failed to delete notification $id: $e');
      }
    }
  }

  /// Add new notification
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all data
  void clearData() {
    _notifications = [];
    _currentFilter = NotificationFilter.all;
    _errorMessage = null;
    notifyListeners();
  }

  /// Cleanup when user logs out
  Future<void> cleanup() async {
    try {
      await _unsubscribeUserTopics();

      // Clear data
      clearData();
      _currentUserId = null;
      _handlersInitialized = false;

      debugPrint('✅ NotificationProvider cleaned up');
    } catch (e) {
      debugPrint('❌ Error during notification cleanup: $e');
    }
  }

  Future<void> _unsubscribeUserTopics() async {
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      await MessagingService.unsubscribeFromTopic('user_$_currentUserId');
    }
    if (_isGeneralTopicSubscribed) {
      await MessagingService.unsubscribeFromTopic('all_users');
      _isGeneralTopicSubscribed = false;
    }
  }

  /// Mock notification data
  List<AppNotification> _getMockNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'NOT001',
        type: NotificationType.delivery,
        title: 'New Delivery Assigned',
        message: 'You have a new delivery for TMT Steel Bars to Amit Singh',
        timestamp: now.subtract(const Duration(minutes: 30)),
        isRead: false,
        deepLink: '/delivery/DEL001',
        metadata: {'deliveryId': 'DEL001'},
      ),
      AppNotification(
        id: 'NOT002',
        type: NotificationType.reward,
        title: 'Points Earned!',
        message: 'You earned 75 points for completing delivery DEL004',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: false,
        deepLink: '/rewards',
        metadata: {'points': 75, 'deliveryId': 'DEL004'},
      ),
      AppNotification(
        id: 'NOT003',
        type: NotificationType.approval,
        title: 'POD Approved',
        message: 'Your delivery proof for Mehta & Sons has been approved',
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
        deepLink: '/delivery/DEL004',
        metadata: {'deliveryId': 'DEL004'},
      ),
      AppNotification(
        id: 'NOT004',
        type: NotificationType.message,
        title: 'New Message',
        message: 'Sharma Steel Center: Please confirm delivery timing for tomorrow',
        timestamp: now.subtract(const Duration(hours: 8)),
        isRead: true,
        deepLink: '/messages/DLR001',
        metadata: {'contactId': 'DLR001'},
      ),
      AppNotification(
        id: 'NOT005',
        type: NotificationType.reward,
        title: 'Weekly Bonus!',
        message: 'Congratulations! You earned 50 bonus points for 100% delivery success',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        deepLink: '/rewards',
        metadata: {'points': 50, 'bonusType': 'weekly'},
      ),
      AppNotification(
        id: 'NOT006',
        type: NotificationType.order,
        title: 'Order Request Approved',
        message: 'Your order request for Steel Rods has been approved by dealer',
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
        isRead: true,
        deepLink: '/orders/ORD001',
        metadata: {'orderId': 'ORD001'},
      ),
      AppNotification(
        id: 'NOT007',
        type: NotificationType.delivery,
        title: 'Urgent Delivery',
        message: 'ASAP delivery assigned: Steel Angles to Apex Builders',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        deepLink: '/delivery/DEL005',
        metadata: {'deliveryId': 'DEL005', 'urgency': 'asap'},
      ),
      AppNotification(
        id: 'NOT008',
        type: NotificationType.system,
        title: 'App Update Available',
        message: 'A new version of TSL Parivar is available. Please update for new features.',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
        deepLink: null,
        metadata: {'version': '1.2.0'},
      ),
      AppNotification(
        id: 'NOT009',
        type: NotificationType.reward,
        title: 'Monthly Bonus!',
        message: 'You are the top performer of December! 150 bonus points added.',
        timestamp: now.subtract(const Duration(days: 7)),
        isRead: true,
        deepLink: '/rewards',
        metadata: {'points': 150, 'bonusType': 'monthly'},
      ),
      AppNotification(
        id: 'NOT010',
        type: NotificationType.system,
        title: 'Welcome to TSL Parivar!',
        message: 'Thank you for joining. Complete your first delivery to earn bonus points.',
        timestamp: now.subtract(const Duration(days: 30)),
        isRead: true,
        deepLink: null,
        metadata: {},
      ),
    ];
  }
}

