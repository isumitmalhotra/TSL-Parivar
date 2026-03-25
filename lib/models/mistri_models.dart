/// Mock data models and data for Mistri screens
///
/// This file contains all the mock data used in the Mistri screens
/// for development and testing purposes.

import 'package:flutter/material.dart';

/// Delivery status enum
enum DeliveryStatus {
  assigned,
  inProgress,
  pendingApproval,
  completed,
  rejected,
}

extension DeliveryStatusExtension on DeliveryStatus {
  String get displayName {
    switch (this) {
      case DeliveryStatus.assigned:
        return 'Assigned';
      case DeliveryStatus.inProgress:
        return 'In Progress';
      case DeliveryStatus.pendingApproval:
        return 'Pending Approval';
      case DeliveryStatus.completed:
        return 'Completed';
      case DeliveryStatus.rejected:
        return 'Rejected';
    }
  }

  String get statusKey {
    switch (this) {
      case DeliveryStatus.assigned:
        return 'assigned';
      case DeliveryStatus.inProgress:
        return 'in_progress';
      case DeliveryStatus.pendingApproval:
        return 'pending';
      case DeliveryStatus.completed:
        return 'completed';
      case DeliveryStatus.rejected:
        return 'rejected';
    }
  }

  Color get color {
    switch (this) {
      case DeliveryStatus.assigned:
        return const Color(0xFF2196F3);
      case DeliveryStatus.inProgress:
        return const Color(0xFFFFA726);
      case DeliveryStatus.pendingApproval:
        return const Color(0xFFFFC107);
      case DeliveryStatus.completed:
        return const Color(0xFF4CAF50);
      case DeliveryStatus.rejected:
        return const Color(0xFFF44336);
    }
  }
}

/// Urgency level enum
enum UrgencyLevel {
  normal,
  urgent,
  asap,
}

extension UrgencyLevelExtension on UrgencyLevel {
  String get displayName {
    switch (this) {
      case UrgencyLevel.normal:
        return 'Normal';
      case UrgencyLevel.urgent:
        return 'Urgent';
      case UrgencyLevel.asap:
        return 'ASAP';
    }
  }

  Color get color {
    switch (this) {
      case UrgencyLevel.normal:
        return const Color(0xFF4CAF50);
      case UrgencyLevel.urgent:
        return const Color(0xFFFFA726);
      case UrgencyLevel.asap:
        return const Color(0xFFF44336);
    }
  }
}

/// Delivery model
class DeliveryModel {
  final String id;
  final String productName;
  final String productType;
  final double quantity;
  final String unit;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final double latitude;
  final double longitude;
  final double distance; // in km
  final DateTime expectedDate;
  final DateTime? deliveredDate;
  final DeliveryStatus status;
  final UrgencyLevel urgency;
  final int rewardPoints;
  final String? notes;

  const DeliveryModel({
    required this.id,
    required this.productName,
    required this.productType,
    required this.quantity,
    required this.unit,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.expectedDate,
    this.deliveredDate,
    required this.status,
    this.urgency = UrgencyLevel.normal,
    this.rewardPoints = 0,
    this.notes,
  });
}

/// Dealer model
class DealerModel {
  final String id;
  final String name;
  final String shopName;
  final String phone;
  final String address;
  final String? imageUrl;
  final double rating;
  final int totalDeliveries;

  const DealerModel({
    required this.id,
    required this.name,
    required this.shopName,
    required this.phone,
    required this.address,
    this.imageUrl,
    required this.rating,
    required this.totalDeliveries,
  });
}

/// Reward transaction model
class RewardTransaction {
  final String id;
  final String title;
  final String description;
  final int points;
  final DateTime date;
  final RewardType type;
  final String? deliveryId;

  const RewardTransaction({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.date,
    required this.type,
    this.deliveryId,
  });
}

/// Reward type enum
enum RewardType {
  earned,
  redeemed,
  pending,
  bonus,
}

extension RewardTypeExtension on RewardType {
  String get displayName {
    switch (this) {
      case RewardType.earned:
        return 'Earned';
      case RewardType.redeemed:
        return 'Redeemed';
      case RewardType.pending:
        return 'Pending';
      case RewardType.bonus:
        return 'Bonus';
    }
  }

  Color get color {
    switch (this) {
      case RewardType.earned:
        return const Color(0xFF4CAF50);
      case RewardType.redeemed:
        return const Color(0xFF2196F3);
      case RewardType.pending:
        return const Color(0xFFFFA726);
      case RewardType.bonus:
        return const Color(0xFF2E7D32);
    }
  }
}

/// Material type model
class TslMaterialType {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<String> availableUnits;
  final List<String> grades;

  const TslMaterialType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.availableUnits,
    required this.grades,
  });
}

/// Mistri user model
class MistriUser {
  final String id;
  final String name;
  final String phone;
  final String? imageUrl;
  final String specialization;
  final int approvedPoints;
  final int pendingPoints;
  final String rank;
  final String badgeIcon;
  final int totalDeliveries;
  final double successRate;
  final DealerModel assignedDealer;

  const MistriUser({
    required this.id,
    required this.name,
    required this.phone,
    this.imageUrl,
    required this.specialization,
    required this.approvedPoints,
    required this.pendingPoints,
    required this.rank,
    required this.badgeIcon,
    required this.totalDeliveries,
    required this.successRate,
    required this.assignedDealer,
  });
}

/// ============================================
/// MOCK DATA
/// ============================================

class MockMistriData {
  MockMistriData._();

  /// Mock dealer
  static const DealerModel mockDealer = DealerModel(
    id: 'dealer_001',
    name: 'Rajesh Kumar',
    shopName: 'Kumar Steel Traders',
    phone: '+91 98765 43210',
    address: 'Shop No. 15, Industrial Area, Sector 62, Noida',
    rating: 4.8,
    totalDeliveries: 1250,
  );

  /// Mock mistri user
  static const MistriUser mockUser = MistriUser(
    id: 'mistri_001',
    name: 'Ramesh Singh',
    phone: '+91 99999 88888',
    specialization: 'TMT Bars & Structural Steel',
    approvedPoints: 2450,
    pendingPoints: 350,
    rank: 'TSL Trusted Mistri',
    badgeIcon: '🏆',
    totalDeliveries: 156,
    successRate: 98.5,
    assignedDealer: mockDealer,
  );

  /// Mock deliveries
  static List<DeliveryModel> get mockDeliveries => [
    DeliveryModel(
      id: 'del_001',
      productName: 'TSL 550 SD TMT Bars',
      productType: 'TMT Bars',
      quantity: 500,
      unit: 'kg',
      customerName: 'Arun Construction',
      customerPhone: '+91 98765 11111',
      customerAddress: '123, Sector 45, Gurugram, Haryana',
      latitude: 28.4595,
      longitude: 77.0266,
      distance: 5.2,
      expectedDate: DateTime.now().add(const Duration(hours: 2)),
      status: DeliveryStatus.assigned,
      urgency: UrgencyLevel.urgent,
      rewardPoints: 50,
    ),
    DeliveryModel(
      id: 'del_002',
      productName: 'TSL Girders',
      productType: 'Girders',
      quantity: 10,
      unit: 'pcs',
      customerName: 'Metro Builders',
      customerPhone: '+91 98765 22222',
      customerAddress: '456, DLF Phase 3, Gurugram, Haryana',
      latitude: 28.4820,
      longitude: 77.0920,
      distance: 8.5,
      expectedDate: DateTime.now().add(const Duration(hours: 4)),
      status: DeliveryStatus.inProgress,
      rewardPoints: 75,
    ),
    DeliveryModel(
      id: 'del_003',
      productName: 'TSL Angles',
      productType: 'Angles',
      quantity: 200,
      unit: 'kg',
      customerName: 'Sharma Industries',
      customerPhone: '+91 98765 33333',
      customerAddress: '789, Industrial Area, Faridabad',
      latitude: 28.4089,
      longitude: 77.3178,
      distance: 12.3,
      expectedDate: DateTime.now().add(const Duration(days: 1)),
      status: DeliveryStatus.pendingApproval,
      rewardPoints: 40,
    ),
    DeliveryModel(
      id: 'del_004',
      productName: 'TSL 550 SD TMT Bars',
      productType: 'TMT Bars',
      quantity: 1000,
      unit: 'kg',
      customerName: 'Gupta Constructions',
      customerPhone: '+91 98765 44444',
      customerAddress: '321, Sector 18, Noida',
      latitude: 28.5700,
      longitude: 77.3219,
      distance: 3.8,
      expectedDate: DateTime.now().subtract(const Duration(days: 1)),
      deliveredDate: DateTime.now().subtract(const Duration(hours: 20)),
      status: DeliveryStatus.completed,
      rewardPoints: 100,
    ),
    DeliveryModel(
      id: 'del_005',
      productName: 'TSL Duro Colour',
      productType: 'Sheets',
      quantity: 50,
      unit: 'sheets',
      customerName: 'Royal Fabricators',
      customerPhone: '+91 98765 55555',
      customerAddress: '567, Okhla Industrial Area, Delhi',
      latitude: 28.5355,
      longitude: 77.2729,
      distance: 15.7,
      expectedDate: DateTime.now().add(const Duration(days: 2)),
      status: DeliveryStatus.assigned,
      urgency: UrgencyLevel.normal,
      rewardPoints: 60,
    ),
    DeliveryModel(
      id: 'del_006',
      productName: 'TSL Channels',
      productType: 'Channels',
      quantity: 300,
      unit: 'kg',
      customerName: 'Verma Steels',
      customerPhone: '+91 98765 66666',
      customerAddress: '890, Sahibabad Industrial Area, Ghaziabad',
      latitude: 28.6846,
      longitude: 77.3719,
      distance: 20.1,
      expectedDate: DateTime.now().subtract(const Duration(days: 2)),
      deliveredDate: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      status: DeliveryStatus.completed,
      rewardPoints: 55,
    ),
  ];

  /// Mock reward transactions
  static List<RewardTransaction> get mockRewardTransactions => [
    RewardTransaction(
      id: 'reward_001',
      title: 'Delivery Completed',
      description: 'TSL 550 SD TMT Bars to Gupta Constructions',
      points: 100,
      date: DateTime.now().subtract(const Duration(hours: 20)),
      type: RewardType.earned,
      deliveryId: 'del_004',
    ),
    RewardTransaction(
      id: 'reward_002',
      title: 'On-Time Bonus',
      description: 'Delivered before expected time',
      points: 25,
      date: DateTime.now().subtract(const Duration(hours: 20)),
      type: RewardType.bonus,
      deliveryId: 'del_004',
    ),
    RewardTransaction(
      id: 'reward_003',
      title: 'Delivery Completed',
      description: 'TSL Channels to Verma Steels',
      points: 55,
      date: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      type: RewardType.earned,
      deliveryId: 'del_006',
    ),
    RewardTransaction(
      id: 'reward_004',
      title: 'Pending Approval',
      description: 'TSL Angles to Sharma Industries',
      points: 40,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      type: RewardType.pending,
      deliveryId: 'del_003',
    ),
    RewardTransaction(
      id: 'reward_005',
      title: 'Redeemed',
      description: 'Mobile Recharge ₹500',
      points: -500,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: RewardType.redeemed,
    ),
    RewardTransaction(
      id: 'reward_006',
      title: 'Weekly Bonus',
      description: '10+ deliveries completed this week',
      points: 200,
      date: DateTime.now().subtract(const Duration(days: 7)),
      type: RewardType.bonus,
    ),
  ];

  /// Mock material types - mirrors TSL product catalog
  static List<TslMaterialType> get mockMaterialTypes => [
    const TslMaterialType(
      id: 'mat_001',
      name: 'TSL 550 SD TMT Bars',
      description: 'Strength That Forms the Spine',
      icon: Icons.view_column,
      availableUnits: ['kg', 'tonnes', 'quintal'],
      grades: ['Fe-500', 'Fe-550 SD', 'Fe-600'],
    ),
    const TslMaterialType(
      id: 'mat_002',
      name: 'TSL Wires',
      description: 'The Unseen Strength',
      icon: Icons.cable,
      availableUnits: ['kg', 'bundles'],
      grades: ['18 Gauge', '20 Gauge', '22 Gauge'],
    ),
    const TslMaterialType(
      id: 'mat_003',
      name: 'TSL Round Pipe',
      description: 'Flow with Power',
      icon: Icons.circle_outlined,
      availableUnits: ['pcs', 'metres'],
      grades: ['15mm', '20mm', '25mm', '32mm', '40mm'],
    ),
    const TslMaterialType(
      id: 'mat_004',
      name: 'TSL Square Pipe',
      description: 'Geometry with Strength',
      icon: Icons.crop_square,
      availableUnits: ['pcs', 'metres'],
      grades: ['15mm', '20mm', '25mm', '40mm'],
    ),
    const TslMaterialType(
      id: 'mat_005',
      name: 'TSL Duro Colour',
      description: 'Strength with Style',
      icon: Icons.grid_on,
      availableUnits: ['sheets', 'sq.ft'],
      grades: ['0.35mm', '0.40mm', '0.45mm', '0.50mm'],
    ),
    const TslMaterialType(
      id: 'mat_006',
      name: 'TSL Angles',
      description: 'Right Angles, Right Results',
      icon: Icons.change_history,
      availableUnits: ['kg', 'pcs'],
      grades: ['25x25', '50x50', '75x75', '100x100'],
    ),
    const TslMaterialType(
      id: 'mat_007',
      name: 'TSL Channels',
      description: 'Shaping the Frame of Strength',
      icon: Icons.view_stream,
      availableUnits: ['kg', 'metres'],
      grades: ['75mm', '100mm', '125mm', '150mm'],
    ),
    const TslMaterialType(
      id: 'mat_008',
      name: 'TSL Girders',
      description: 'The Giants of Load-Bearing',
      icon: Icons.straighten,
      availableUnits: ['pcs', 'metres'],
      grades: ['Standard', 'Heavy Duty'],
    ),
  ];
}

