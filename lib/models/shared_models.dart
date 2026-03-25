/// Shared data models for all user roles
///
/// Contains models for notifications, messages, and user profile
/// used across Mistri, Dealer, and Architect screens.

import 'package:flutter/material.dart';

// ============================================
// NOTIFICATION MODELS
// ============================================

/// Notification type enum
enum NotificationType {
  delivery,
  reward,
  order,
  approval,
  message,
  system,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.delivery:
        return 'Delivery';
      case NotificationType.reward:
        return 'Reward';
      case NotificationType.order:
        return 'Order';
      case NotificationType.approval:
        return 'Approval';
      case NotificationType.message:
        return 'Message';
      case NotificationType.system:
        return 'System';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.delivery:
        return Icons.local_shipping_outlined;
      case NotificationType.reward:
        return Icons.emoji_events_outlined;
      case NotificationType.order:
        return Icons.receipt_long_outlined;
      case NotificationType.approval:
        return Icons.fact_check_outlined;
      case NotificationType.message:
        return Icons.chat_bubble_outline;
      case NotificationType.system:
        return Icons.notifications_outlined;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.delivery:
        return const Color(0xFF2196F3);
      case NotificationType.reward:
        return const Color(0xFFFFA726);
      case NotificationType.order:
        return const Color(0xFF9C27B0);
      case NotificationType.approval:
        return const Color(0xFF4CAF50);
      case NotificationType.message:
        return const Color(0xFF00BCD4);
      case NotificationType.system:
        return const Color(0xFF607D8B);
    }
  }
}

/// App notification model
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? deepLink;
  final Map<String, dynamic>? metadata;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.deepLink,
    this.metadata,
  });

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? deepLink,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      deepLink: deepLink ?? this.deepLink,
      metadata: metadata ?? this.metadata,
    );
  }
}

// ============================================
// MESSAGING MODELS
// ============================================

/// Chat contact model
class ChatContact {
  final String id;
  final String? chatId;
  final String name;
  final String role;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  const ChatContact({
    required this.id,
    this.chatId,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}

/// Message sender type
enum MessageSender {
  me,
  other,
}

/// Message type
enum MessageType {
  text,
  image,
  location,
  file,
}

/// Chat message model
class ChatMessage {
  final String id;
  final String senderId;
  final MessageSender sender;
  final MessageType type;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.sender,
    required this.type,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.metadata,
  });
}

// ============================================
// USER PROFILE MODELS
// ============================================

/// User role enum
enum UserRole {
  mistri,
  dealer,
  architect,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.mistri:
        return 'Mistri';
      case UserRole.dealer:
        return 'Dealer';
      case UserRole.architect:
        return 'Architect';
    }
  }

  String get key {
    switch (this) {
      case UserRole.mistri:
        return 'mistri';
      case UserRole.dealer:
        return 'dealer';
      case UserRole.architect:
        return 'architect';
    }
  }

  static UserRole fromKey(String key) {
    return UserRole.values.firstWhere(
      (r) => r.name == key,
      orElse: () => UserRole.mistri,
    );
  }

  String get description {
    switch (this) {
      case UserRole.mistri:
        return 'Field Worker';
      case UserRole.dealer:
        return 'Distributor';
      case UserRole.architect:
        return 'Engineer';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.mistri:
        return Icons.construction;
      case UserRole.dealer:
        return Icons.store;
      case UserRole.architect:
        return Icons.architecture;
    }
  }

  Color get color {
    switch (this) {
      case UserRole.mistri:
        return const Color(0xFF388E3C);
      case UserRole.dealer:
        return const Color(0xFF2E7D32);
      case UserRole.architect:
        return const Color(0xFF1B5E20);
    }
  }
}

/// App user profile model
class AppUserProfile {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String? email;
  final String? avatarUrl;
  final String? location;
  final String? address;
  final DateTime? joinedDate;
  final int rewardPoints;
  final String? rank;
  final Map<String, dynamic>? metadata;

  const AppUserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    this.avatarUrl,
    this.location,
    this.address,
    this.joinedDate,
    this.rewardPoints = 0,
    this.rank,
    this.metadata,
  });

  AppUserProfile copyWith({
    String? id,
    String? name,
    String? phone,
    UserRole? role,
    String? email,
    String? avatarUrl,
    String? location,
    String? address,
    DateTime? joinedDate,
    int? rewardPoints,
    String? rank,
    Map<String, dynamic>? metadata,
  }) {
    return AppUserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      address: address ?? this.address,
      joinedDate: joinedDate ?? this.joinedDate,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      rank: rank ?? this.rank,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// App settings model
class AppSettings {
  final String languageCode;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool darkModeEnabled;
  final bool biometricEnabled;

  const AppSettings({
    this.languageCode = 'en',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.darkModeEnabled = false,
    this.biometricEnabled = false,
  });

  AppSettings copyWith({
    String? languageCode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? darkModeEnabled,
    bool? biometricEnabled,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}

// ============================================
// MOCK DATA
// ============================================

/// Mock data for shared features
class MockSharedData {
  MockSharedData._();

  /// Mock user profile
  static AppUserProfile get mockMistriProfile => AppUserProfile(
        id: 'mistri_001',
        name: 'Ramesh Kumar',
        phone: '+91 98765 43210',
        role: UserRole.mistri,
        email: 'ramesh.kumar@email.com',
        location: 'Mumbai, Maharashtra',
        address: 'Building No. 42, Sector 5, Andheri West, Mumbai - 400053',
        joinedDate: DateTime(2023, 6, 15),
        rewardPoints: 2450,
        rank: 'TSL Trusted Mistri',
      );

  static AppUserProfile get mockDealerProfile => AppUserProfile(
        id: 'dealer_001',
        name: 'Suresh Traders',
        phone: '+91 98765 12345',
        role: UserRole.dealer,
        email: 'suresh.traders@email.com',
        location: 'Pune, Maharashtra',
        address: 'Shop No. 15, Steel Market, Hadapsar, Pune - 411028',
        joinedDate: DateTime(2022, 3, 10),
        rewardPoints: 15600,
        rank: 'Gold Dealer',
      );

  static AppUserProfile get mockArchitectProfile => AppUserProfile(
        id: 'arch_001',
        name: 'Priya Sharma',
        phone: '+91 99887 76655',
        role: UserRole.architect,
        email: 'priya.sharma@design.com',
        location: 'Delhi NCR',
        address: 'Office 302, Design Hub, Connaught Place, New Delhi - 110001',
        joinedDate: DateTime(2023, 1, 20),
        rewardPoints: 8500,
        rank: 'Senior Architect Partner',
      );

  /// Mock notifications
  static List<AppNotification> get mockNotifications => [
        AppNotification(
          id: 'notif_001',
          type: NotificationType.delivery,
          title: 'New Delivery Assigned',
          message: 'You have been assigned a delivery of TMT Bars to Andheri West.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isRead: false,
          deepLink: '/mistri/deliveries/del_001',
        ),
        AppNotification(
          id: 'notif_002',
          type: NotificationType.reward,
          title: 'Points Earned!',
          message: 'You earned 150 points for completing delivery #DEL-2024-089.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: false,
          deepLink: '/mistri/rewards',
        ),
        AppNotification(
          id: 'notif_003',
          type: NotificationType.approval,
          title: 'POD Approved',
          message: 'Your proof of delivery for order #ORD-2024-156 has been approved.',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: true,
          deepLink: '/mistri/deliveries/del_002',
        ),
        AppNotification(
          id: 'notif_004',
          type: NotificationType.message,
          title: 'New Message from Dealer',
          message: 'Suresh Traders sent you a message about tomorrow\'s delivery.',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: true,
          deepLink: '/chat/dealer_001',
        ),
        AppNotification(
          id: 'notif_005',
          type: NotificationType.order,
          title: 'Order Request Received',
          message: 'New order request from Ramesh Kumar for 50 units of TMT Bars.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          deepLink: '/dealer/orders',
        ),
        AppNotification(
          id: 'notif_006',
          type: NotificationType.system,
          title: 'App Update Available',
          message: 'A new version of TSL Parivar is available. Update now for new features.',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
          isRead: true,
          deepLink: null,
        ),
        AppNotification(
          id: 'notif_007',
          type: NotificationType.delivery,
          title: 'Delivery Completed',
          message: 'Delivery #DEL-2024-087 has been marked as completed.',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
          deepLink: '/mistri/deliveries/del_003',
        ),
        AppNotification(
          id: 'notif_008',
          type: NotificationType.reward,
          title: 'Monthly Bonus Unlocked',
          message: 'Congratulations! You\'ve unlocked a 500 point monthly performance bonus.',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
          deepLink: '/mistri/rewards',
        ),
      ];

  /// Mock chat contacts
  static List<ChatContact> get mockChatContacts => [
        ChatContact(
          id: 'dealer_001',
          name: 'Suresh Traders',
          role: 'Dealer',
          lastMessage: 'Please confirm the delivery for tomorrow morning.',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
          unreadCount: 2,
          isOnline: true,
        ),
        ChatContact(
          id: 'mistri_002',
          name: 'Anil Yadav',
          role: 'Mistri',
          lastMessage: 'Delivery completed successfully!',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
          unreadCount: 0,
          isOnline: false,
        ),
        ChatContact(
          id: 'arch_001',
          name: 'Priya Sharma',
          role: 'Architect',
          lastMessage: 'Thanks for the specification update.',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
          unreadCount: 0,
          isOnline: true,
        ),
        ChatContact(
          id: 'support',
          name: 'TSL Support',
          role: 'Support',
          lastMessage: 'Your issue has been resolved.',
          lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
          unreadCount: 0,
          isOnline: true,
        ),
      ];

  /// Mock chat messages
  static List<ChatMessage> get mockChatMessages => [
        ChatMessage(
          id: 'msg_001',
          senderId: 'dealer_001',
          sender: MessageSender.other,
          type: MessageType.text,
          content: 'Hello! Tomorrow we have an urgent delivery.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: true,
        ),
        ChatMessage(
          id: 'msg_002',
          senderId: 'me',
          sender: MessageSender.me,
          type: MessageType.text,
          content: 'Okay, what\'s the location?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
          isRead: true,
        ),
        ChatMessage(
          id: 'msg_003',
          senderId: 'dealer_001',
          sender: MessageSender.other,
          type: MessageType.text,
          content: 'It\'s in Andheri West. TMT Bars - 100 units.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
          isRead: true,
        ),
        ChatMessage(
          id: 'msg_004',
          senderId: 'dealer_001',
          sender: MessageSender.other,
          type: MessageType.image,
          content: 'Site location photo',
          imageUrl: 'assets/images/site.jpg',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          isRead: true,
        ),
        ChatMessage(
          id: 'msg_005',
          senderId: 'me',
          sender: MessageSender.me,
          type: MessageType.text,
          content: 'Got it. I\'ll be there by 9 AM.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
          isRead: true,
        ),
        ChatMessage(
          id: 'msg_006',
          senderId: 'dealer_001',
          sender: MessageSender.other,
          type: MessageType.text,
          content: 'Perfect! The customer name is Mr. Sharma.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
          isRead: true,
        ),
        ChatMessage(
          id: 'msg_007',
          senderId: 'dealer_001',
          sender: MessageSender.other,
          type: MessageType.text,
          content: 'Please confirm the delivery for tomorrow morning.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isRead: false,
        ),
      ];

  /// Mock app settings
  static AppSettings get mockSettings => const AppSettings(
        languageCode: 'en',
        notificationsEnabled: true,
        soundEnabled: true,
        vibrationEnabled: true,
        darkModeEnabled: false,
        biometricEnabled: false,
      );
}

