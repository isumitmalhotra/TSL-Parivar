import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

/// Firebase Cloud Messaging service for push notifications
class MessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// FCM Token for this device
  static String? _fcmToken;
  static String? get fcmToken => _fcmToken;

  /// Initialize FCM
  static Future<void> initialize() async {
    try {
      // Request permission (iOS)
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('🔔 FCM Permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        debugPrint('🔔 FCM Token: $_fcmToken');

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('🔔 FCM Token refreshed: $newToken');
          // Update token in Firestore for the current user
          _updateTokenInFirestore(newToken);
        });
      }
    } catch (e) {
      debugPrint('❌ FCM initialization error: $e');
    }
  }

  /// Save FCM token to Firestore for the given user
  static Future<void> saveTokenForUser(String userId) async {
    if (_fcmToken == null) return;
    await _updateTokenInFirestore(_fcmToken!, userId: userId);
  }

  /// Update FCM token in Firestore
  static Future<void> _updateTokenInFirestore(String token, {String? userId}) async {
    try {
      // Try to get user ID from Firebase Auth if not provided
      final uid = userId;
      if (uid == null) return;

      await FirestoreService.updateDocument(
        collection: FirestoreService.usersCollection,
        documentId: uid,
        data: {
          'fcmToken': token,
          'lastTokenUpdate': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('🔔 FCM Token saved to Firestore for user: $uid');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// Setup foreground notification handler
  static void setupForegroundHandler(void Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  /// Setup background notification handler
  static void setupBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  /// Background message handler (must be top-level function)
  @pragma('vm:entry-point')
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    debugPrint('🔔 Background message: ${message.messageId}');
    // Handle background message
  }

  /// Handle notification when app is opened from notification
  static void setupNotificationOpenedHandler(void Function(RemoteMessage) onMessageOpenedApp) {
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
  }

  /// Check if app was opened from a notification
  static Future<RemoteMessage?> getInitialMessage() async {
    return await _messaging.getInitialMessage();
  }

  /// Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('🔔 Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('🔔 Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Get APNs token (iOS only)
  static Future<String?> getAPNsToken() async {
    return await _messaging.getAPNSToken();
  }

  /// Delete FCM token (for logout)
  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      debugPrint('🔔 FCM Token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }
}

/// Notification data model
class NotificationData {
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final DateTime receivedAt;

  NotificationData({
    this.title,
    this.body,
    this.data,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory NotificationData.fromRemoteMessage(RemoteMessage message) {
    return NotificationData(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
    );
  }
}
