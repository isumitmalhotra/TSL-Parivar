/// Mock data models and data for Dealer screens
///
/// This file contains all the mock data used in the Dealer screens
/// for development and testing purposes.

import 'package:flutter/material.dart';

/// Mistri status enum for dealer view
enum MistriStatus {
  active,
  inactive,
  pending,
}

extension MistriStatusExtension on MistriStatus {
  String get displayName {
    switch (this) {
      case MistriStatus.active:
        return 'Active';
      case MistriStatus.inactive:
        return 'Inactive';
      case MistriStatus.pending:
        return 'Pending';
    }
  }

  Color get color {
    switch (this) {
      case MistriStatus.active:
        return const Color(0xFF4CAF50);
      case MistriStatus.inactive:
        return const Color(0xFF9E9E9E);
      case MistriStatus.pending:
        return const Color(0xFFFFA726);
    }
  }
}

/// Order request status
enum OrderRequestStatus {
  newRequest,
  approved,
  rejected,
  moreInfo,
}

extension OrderRequestStatusExtension on OrderRequestStatus {
  String get displayName {
    switch (this) {
      case OrderRequestStatus.newRequest:
        return 'New';
      case OrderRequestStatus.approved:
        return 'Approved';
      case OrderRequestStatus.rejected:
        return 'Rejected';
      case OrderRequestStatus.moreInfo:
        return 'More Info';
    }
  }

  Color get color {
    switch (this) {
      case OrderRequestStatus.newRequest:
        return const Color(0xFF2196F3);
      case OrderRequestStatus.approved:
        return const Color(0xFF4CAF50);
      case OrderRequestStatus.rejected:
        return const Color(0xFFF44336);
      case OrderRequestStatus.moreInfo:
        return const Color(0xFFFFA726);
    }
  }
}

/// POD Approval status
enum PodApprovalStatus {
  pending,
  approved,
  rejected,
  needsInfo,
}

extension PodApprovalStatusExtension on PodApprovalStatus {
  String get displayName {
    switch (this) {
      case PodApprovalStatus.pending:
        return 'Pending Review';
      case PodApprovalStatus.approved:
        return 'Approved';
      case PodApprovalStatus.rejected:
        return 'Rejected';
      case PodApprovalStatus.needsInfo:
        return 'Needs Info';
    }
  }

  Color get color {
    switch (this) {
      case PodApprovalStatus.pending:
        return const Color(0xFFFFA726);
      case PodApprovalStatus.approved:
        return const Color(0xFF4CAF50);
      case PodApprovalStatus.rejected:
        return const Color(0xFFF44336);
      case PodApprovalStatus.needsInfo:
        return const Color(0xFF2196F3);
    }
  }
}

/// Mistri model for dealer view
class DealerMistriModel {
  final String id;
  final String name;
  final String phone;
  final String? imageUrl;
  final String specialization;
  final MistriStatus status;
  final int totalDeliveries;
  final int completedDeliveries;
  final double successRate;
  final int rewardPoints;
  final DateTime joinedDate;

  const DealerMistriModel({
    required this.id,
    required this.name,
    required this.phone,
    this.imageUrl,
    required this.specialization,
    required this.status,
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.successRate,
    required this.rewardPoints,
    required this.joinedDate,
  });
}

/// Nearby registered mistri discoverable by a dealer.
class NearbyMistriModel {
  final String id;
  final String name;
  final String phone;
  final String specialization;
  final String city;
  final String? addressLine;
  final String? existingDealerId;
  final bool isActive;

  const NearbyMistriModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.specialization,
    required this.city,
    this.addressLine,
    this.existingDealerId,
    required this.isActive,
  });
}

/// Order request model
class OrderRequestModel {
  final String id;
  final String mistriId;
  final String mistriName;
  final String materialType;
  final double quantity;
  final String unit;
  final String location;
  final DateTime expectedDate;
  final String urgency;
  final OrderRequestStatus status;
  final DateTime requestedAt;
  final String? customerName;
  final String? notes;

  const OrderRequestModel({
    required this.id,
    required this.mistriId,
    required this.mistriName,
    required this.materialType,
    required this.quantity,
    required this.unit,
    required this.location,
    required this.expectedDate,
    required this.urgency,
    required this.status,
    required this.requestedAt,
    this.customerName,
    this.notes,
  });
}

/// POD submission for approval
class PodSubmissionModel {
  final String id;
  final String deliveryId;
  final String mistriId;
  final String mistriName;
  final String materialType;
  final double assignedQuantity;
  final double deliveredQuantity;
  final String unit;
  final String customerName;
  final String customerAddress;
  final List<String> photoUrls;
  final double assignedLat;
  final double assignedLng;
  final double submittedLat;
  final double submittedLng;
  final double distanceFromTarget; // in meters
  final String? mistriNotes;
  final String? issueReported;
  final PodApprovalStatus status;
  final DateTime submittedAt;
  final int basePoints;
  final int bonusPoints;

  const PodSubmissionModel({
    required this.id,
    required this.deliveryId,
    required this.mistriId,
    required this.mistriName,
    required this.materialType,
    required this.assignedQuantity,
    required this.deliveredQuantity,
    required this.unit,
    required this.customerName,
    required this.customerAddress,
    required this.photoUrls,
    required this.assignedLat,
    required this.assignedLng,
    required this.submittedLat,
    required this.submittedLng,
    required this.distanceFromTarget,
    this.mistriNotes,
    this.issueReported,
    required this.status,
    required this.submittedAt,
    required this.basePoints,
    required this.bonusPoints,
  });

  int get totalPoints => basePoints + bonusPoints;

  String get locationStatus {
    if (distanceFromTarget <= 100) return 'excellent';
    if (distanceFromTarget <= 500) return 'good';
    if (distanceFromTarget <= 1000) return 'acceptable';
    return 'far';
  }

  Color get locationStatusColor {
    switch (locationStatus) {
      case 'excellent':
        return const Color(0xFF4CAF50);
      case 'good':
        return const Color(0xFF8BC34A);
      case 'acceptable':
        return const Color(0xFFFFA726);
      default:
        return const Color(0xFFF44336);
    }
  }
}

/// Dealer user model
class DealerUser {
  final String id;
  final String name;
  final String shopName;
  final String phone;
  final String address;
  final String? imageUrl;
  final int totalMistris;
  final int activeDeliveries;
  final int pendingApprovals;
  final double weeklyVolume; // in tonnes
  final int loyaltyPoints;
  final int mistriPoolPoints;

  const DealerUser({
    required this.id,
    required this.name,
    required this.shopName,
    required this.phone,
    required this.address,
    this.imageUrl,
    required this.totalMistris,
    required this.activeDeliveries,
    required this.pendingApprovals,
    required this.weeklyVolume,
    required this.loyaltyPoints,
    required this.mistriPoolPoints,
  });
}

/// Dealer reward transaction
class DealerRewardTransaction {
  final String id;
  final String title;
  final String description;
  final int points;
  final DateTime date;
  final DealerRewardType type;
  final String? mistriName; // for distributed rewards

  const DealerRewardTransaction({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.date,
    required this.type,
    this.mistriName,
  });
}

enum DealerRewardType {
  earned,
  distributed,
  redeemed,
  bonus,
}

extension DealerRewardTypeExtension on DealerRewardType {
  String get displayName {
    switch (this) {
      case DealerRewardType.earned:
        return 'Earned';
      case DealerRewardType.distributed:
        return 'Distributed';
      case DealerRewardType.redeemed:
        return 'Redeemed';
      case DealerRewardType.bonus:
        return 'Bonus';
    }
  }

  Color get color {
    switch (this) {
      case DealerRewardType.earned:
        return const Color(0xFF4CAF50);
      case DealerRewardType.distributed:
        return const Color(0xFF2196F3);
      case DealerRewardType.redeemed:
        return const Color(0xFFF44336);
      case DealerRewardType.bonus:
        return const Color(0xFFFFA726);
    }
  }

  IconData get icon {
    switch (this) {
      case DealerRewardType.earned:
        return Icons.arrow_downward;
      case DealerRewardType.distributed:
        return Icons.group;
      case DealerRewardType.redeemed:
        return Icons.arrow_upward;
      case DealerRewardType.bonus:
        return Icons.star;
    }
  }
}

/// ============================================
/// MOCK DATA
/// ============================================

class MockDealerData {
  MockDealerData._();

  /// Mock dealer user
  static const DealerUser mockUser = DealerUser(
    id: 'dealer_001',
    name: 'Rajesh Kumar',
    shopName: 'Kumar Steel Traders',
    phone: '+91 98765 43210',
    address: 'Shop No. 15, Industrial Area, Sector 62, Noida',
    totalMistris: 24,
    activeDeliveries: 8,
    pendingApprovals: 5,
    weeklyVolume: 45.5,
    loyaltyPoints: 12500,
    mistriPoolPoints: 8500,
  );

  /// Mock mistris
  static List<DealerMistriModel> get mockMistris => [
    DealerMistriModel(
      id: 'mistri_001',
      name: 'Ramesh Singh',
      phone: '+91 99999 88888',
      specialization: 'TMT Bars & Structural Steel',
      status: MistriStatus.active,
      totalDeliveries: 156,
      completedDeliveries: 154,
      successRate: 98.7,
      rewardPoints: 2450,
      joinedDate: DateTime.now().subtract(const Duration(days: 180)),
    ),
    DealerMistriModel(
      id: 'mistri_002',
      name: 'Suresh Yadav',
      phone: '+91 99999 77777',
      specialization: 'Girders & Channels',
      status: MistriStatus.active,
      totalDeliveries: 98,
      completedDeliveries: 95,
      successRate: 96.9,
      rewardPoints: 1850,
      joinedDate: DateTime.now().subtract(const Duration(days: 120)),
    ),
    DealerMistriModel(
      id: 'mistri_003',
      name: 'Mukesh Kumar',
      phone: '+91 99999 66666',
      specialization: 'All Materials',
      status: MistriStatus.active,
      totalDeliveries: 234,
      completedDeliveries: 228,
      successRate: 97.4,
      rewardPoints: 3200,
      joinedDate: DateTime.now().subtract(const Duration(days: 365)),
    ),
    DealerMistriModel(
      id: 'mistri_004',
      name: 'Ravi Sharma',
      phone: '+91 99999 55555',
      specialization: 'Color Sheets & Pipes',
      status: MistriStatus.inactive,
      totalDeliveries: 45,
      completedDeliveries: 42,
      successRate: 93.3,
      rewardPoints: 650,
      joinedDate: DateTime.now().subtract(const Duration(days: 90)),
    ),
    DealerMistriModel(
      id: 'mistri_005',
      name: 'Anil Verma',
      phone: '+91 99999 44444',
      specialization: 'TMT Bars',
      status: MistriStatus.pending,
      totalDeliveries: 0,
      completedDeliveries: 0,
      successRate: 0,
      rewardPoints: 0,
      joinedDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  /// Mock order requests
  static List<OrderRequestModel> get mockOrderRequests => [
    OrderRequestModel(
      id: 'order_001',
      mistriId: 'mistri_001',
      mistriName: 'Ramesh Singh',
      materialType: 'TSL 550 SD TMT Bars',
      quantity: 500,
      unit: 'kg',
      location: 'Sector 45, Gurugram',
      expectedDate: DateTime.now().add(const Duration(days: 1)),
      urgency: 'Urgent',
      status: OrderRequestStatus.newRequest,
      requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
      customerName: 'Arun Construction',
      notes: 'Customer needs delivery by noon',
    ),
    OrderRequestModel(
      id: 'order_002',
      mistriId: 'mistri_002',
      mistriName: 'Suresh Yadav',
      materialType: 'TSL Girders',
      quantity: 15,
      unit: 'pcs',
      location: 'DLF Phase 3, Gurugram',
      expectedDate: DateTime.now().add(const Duration(days: 2)),
      urgency: 'Normal',
      status: OrderRequestStatus.newRequest,
      requestedAt: DateTime.now().subtract(const Duration(hours: 5)),
      customerName: 'Metro Builders',
    ),
    OrderRequestModel(
      id: 'order_003',
      mistriId: 'mistri_003',
      mistriName: 'Mukesh Kumar',
      materialType: 'TSL Angles',
      quantity: 300,
      unit: 'kg',
      location: 'Sector 18, Noida',
      expectedDate: DateTime.now().add(const Duration(hours: 6)),
      urgency: 'ASAP',
      status: OrderRequestStatus.newRequest,
      requestedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      customerName: 'Quick Build Co.',
      notes: 'Emergency requirement for ongoing project',
    ),
    OrderRequestModel(
      id: 'order_004',
      mistriId: 'mistri_001',
      mistriName: 'Ramesh Singh',
      materialType: 'TSL Duro Colour',
      quantity: 50,
      unit: 'sheets',
      location: 'Sector 62, Noida',
      expectedDate: DateTime.now().add(const Duration(days: 3)),
      urgency: 'Normal',
      status: OrderRequestStatus.approved,
      requestedAt: DateTime.now().subtract(const Duration(days: 1)),
      customerName: 'Sharma Industries',
    ),
  ];

  /// Mock POD submissions for approval
  static List<PodSubmissionModel> get mockPodSubmissions => [
    PodSubmissionModel(
      id: 'pod_001',
      deliveryId: 'del_001',
      mistriId: 'mistri_001',
      mistriName: 'Ramesh Singh',
      materialType: 'TSL 550 SD TMT Bars',
      assignedQuantity: 500,
      deliveredQuantity: 500,
      unit: 'kg',
      customerName: 'Arun Construction',
      customerAddress: '123, Sector 45, Gurugram',
      photoUrls: ['photo1.jpg', 'photo2.jpg', 'photo3.jpg'],
      assignedLat: 28.4595,
      assignedLng: 77.0266,
      submittedLat: 28.4598,
      submittedLng: 77.0270,
      distanceFromTarget: 50,
      status: PodApprovalStatus.pending,
      submittedAt: DateTime.now().subtract(const Duration(hours: 1)),
      basePoints: 50,
      bonusPoints: 25,
    ),
    PodSubmissionModel(
      id: 'pod_002',
      deliveryId: 'del_002',
      mistriId: 'mistri_002',
      mistriName: 'Suresh Yadav',
      materialType: 'TSL Girders',
      assignedQuantity: 10,
      deliveredQuantity: 10,
      unit: 'pcs',
      customerName: 'Metro Builders',
      customerAddress: '456, DLF Phase 3, Gurugram',
      photoUrls: ['photo1.jpg', 'photo2.jpg'],
      assignedLat: 28.4820,
      assignedLng: 77.0920,
      submittedLat: 28.4825,
      submittedLng: 77.0918,
      distanceFromTarget: 75,
      mistriNotes: 'Delivered to site manager Mr. Gupta',
      status: PodApprovalStatus.pending,
      submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
      basePoints: 75,
      bonusPoints: 15,
    ),
    PodSubmissionModel(
      id: 'pod_003',
      deliveryId: 'del_003',
      mistriId: 'mistri_003',
      mistriName: 'Mukesh Kumar',
      materialType: 'TSL Angles',
      assignedQuantity: 200,
      deliveredQuantity: 180,
      unit: 'kg',
      customerName: 'Sharma Industries',
      customerAddress: '789, Industrial Area, Faridabad',
      photoUrls: ['photo1.jpg', 'photo2.jpg'],
      assignedLat: 28.4089,
      assignedLng: 77.3178,
      submittedLat: 28.4120,
      submittedLng: 77.3200,
      distanceFromTarget: 380,
      mistriNotes: 'Customer accepted partial delivery due to storage constraints',
      issueReported: 'Partial Delivery',
      status: PodApprovalStatus.pending,
      submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
      basePoints: 40,
      bonusPoints: 0,
    ),
    PodSubmissionModel(
      id: 'pod_004',
      deliveryId: 'del_004',
      mistriId: 'mistri_001',
      mistriName: 'Ramesh Singh',
      materialType: 'TSL Channels',
      assignedQuantity: 300,
      deliveredQuantity: 300,
      unit: 'kg',
      customerName: 'Verma Steels',
      customerAddress: 'Sahibabad Industrial Area, Ghaziabad',
      photoUrls: ['photo1.jpg', 'photo2.jpg', 'photo3.jpg'],
      assignedLat: 28.6846,
      assignedLng: 77.3719,
      submittedLat: 28.6900,
      submittedLng: 77.3750,
      distanceFromTarget: 650,
      status: PodApprovalStatus.pending,
      submittedAt: DateTime.now().subtract(const Duration(hours: 8)),
      basePoints: 55,
      bonusPoints: 10,
    ),
    PodSubmissionModel(
      id: 'pod_005',
      deliveryId: 'del_005',
      mistriId: 'mistri_002',
      mistriName: 'Suresh Yadav',
      materialType: 'TSL Wires',
      assignedQuantity: 50,
      deliveredQuantity: 50,
      unit: 'kg',
      customerName: 'ABC Builders',
      customerAddress: 'Sector 15, Noida',
      photoUrls: ['photo1.jpg', 'photo2.jpg'],
      assignedLat: 28.5800,
      assignedLng: 77.3100,
      submittedLat: 28.5802,
      submittedLng: 77.3105,
      distanceFromTarget: 30,
      status: PodApprovalStatus.pending,
      submittedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      basePoints: 30,
      bonusPoints: 20,
    ),
  ];

  /// Mock dealer reward transactions
  static List<DealerRewardTransaction> get mockRewardTransactions => [
    DealerRewardTransaction(
      id: 'reward_001',
      title: 'Purchase Reward',
      description: 'TSL 550 SD - 5 tonnes purchase',
      points: 500,
      date: DateTime.now().subtract(const Duration(hours: 12)),
      type: DealerRewardType.earned,
    ),
    DealerRewardTransaction(
      id: 'reward_002',
      title: 'Distributed to Ramesh Singh',
      description: 'Delivery completion bonus',
      points: -75,
      date: DateTime.now().subtract(const Duration(hours: 1)),
      type: DealerRewardType.distributed,
      mistriName: 'Ramesh Singh',
    ),
    DealerRewardTransaction(
      id: 'reward_003',
      title: 'Monthly Target Bonus',
      description: 'Achieved 50+ tonnes monthly target',
      points: 1000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: DealerRewardType.bonus,
    ),
    DealerRewardTransaction(
      id: 'reward_004',
      title: 'Distributed to Suresh Yadav',
      description: 'Delivery completion bonus',
      points: -90,
      date: DateTime.now().subtract(const Duration(hours: 3)),
      type: DealerRewardType.distributed,
      mistriName: 'Suresh Yadav',
    ),
    DealerRewardTransaction(
      id: 'reward_005',
      title: 'Purchase Reward',
      description: 'Steel Girders - 2 tonnes purchase',
      points: 200,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: DealerRewardType.earned,
    ),
    DealerRewardTransaction(
      id: 'reward_006',
      title: 'Redeemed',
      description: 'Amazon Gift Card ₹1000',
      points: -2000,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: DealerRewardType.redeemed,
    ),
  ];
}

