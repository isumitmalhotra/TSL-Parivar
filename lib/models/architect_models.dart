/// Mock data models and data for Architect screens
///
/// This file contains all the mock data used in the Architect screens
/// for development and testing purposes.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Project type enum
enum ProjectType {
  housing,
  commercial,
  industrial,
  railways,
  infrastructure,
  bridges,
}

extension ProjectTypeExtension on ProjectType {
  String get displayName {
    switch (this) {
      case ProjectType.housing:
        return 'Housing';
      case ProjectType.commercial:
        return 'Commercial';
      case ProjectType.industrial:
        return 'Industrial';
      case ProjectType.railways:
        return 'Railways';
      case ProjectType.infrastructure:
        return 'Infrastructure';
      case ProjectType.bridges:
        return 'Bridges';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectType.housing:
        return Icons.home;
      case ProjectType.commercial:
        return Icons.business;
      case ProjectType.industrial:
        return Icons.factory;
      case ProjectType.railways:
        return Icons.train;
      case ProjectType.infrastructure:
        return Icons.engineering;
      case ProjectType.bridges:
        return Icons.architecture;
    }
  }

  Color get color {
    switch (this) {
      case ProjectType.housing:
        return const Color(0xFF4CAF50);
      case ProjectType.commercial:
        return const Color(0xFF2196F3);
      case ProjectType.industrial:
        return const Color(0xFFFF9800);
      case ProjectType.railways:
        return const Color(0xFF9C27B0);
      case ProjectType.infrastructure:
        return const Color(0xFF607D8B);
      case ProjectType.bridges:
        return const Color(0xFFE91E63);
    }
  }

  static ProjectType fromKey(String? value) {
    switch (value) {
      case 'housing':
        return ProjectType.housing;
      case 'commercial':
        return ProjectType.commercial;
      case 'industrial':
        return ProjectType.industrial;
      case 'railways':
        return ProjectType.railways;
      case 'bridges':
        return ProjectType.bridges;
      case 'infrastructure':
      default:
        return ProjectType.infrastructure;
    }
  }

  String get key => name;
}

/// Project status enum
enum ProjectStatus {
  draft,
  active,
  onHold,
  completed,
}

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case ProjectStatus.draft:
        return const Color(0xFF9E9E9E);
      case ProjectStatus.active:
        return const Color(0xFF4CAF50);
      case ProjectStatus.onHold:
        return const Color(0xFFFFA726);
      case ProjectStatus.completed:
        return const Color(0xFF2196F3);
    }
  }

  static ProjectStatus fromKey(String? value) {
    switch (value) {
      case 'draft':
        return ProjectStatus.draft;
      case 'onHold':
        return ProjectStatus.onHold;
      case 'completed':
        return ProjectStatus.completed;
      case 'active':
      default:
        return ProjectStatus.active;
    }
  }

  String get key => name;
}

/// Specification status
enum SpecStatus {
  draft,
  submitted,
  approved,
  delivered,
}

extension SpecStatusExtension on SpecStatus {
  String get displayName {
    switch (this) {
      case SpecStatus.draft:
        return 'Draft';
      case SpecStatus.submitted:
        return 'Submitted';
      case SpecStatus.approved:
        return 'Approved';
      case SpecStatus.delivered:
        return 'Delivered';
    }
  }

  Color get color {
    switch (this) {
      case SpecStatus.draft:
        return const Color(0xFF9E9E9E);
      case SpecStatus.submitted:
        return const Color(0xFFFFA726);
      case SpecStatus.approved:
        return const Color(0xFF4CAF50);
      case SpecStatus.delivered:
        return const Color(0xFF2196F3);
    }
  }
}

/// Material grade enum
enum MaterialGrade {
  fe500,
  fe550sd,
  fe600,
}

extension MaterialGradeExtension on MaterialGrade {
  String get displayName {
    switch (this) {
      case MaterialGrade.fe500:
        return 'Fe 500';
      case MaterialGrade.fe550sd:
        return 'Fe 550 SD';
      case MaterialGrade.fe600:
        return 'Fe 600';
    }
  }

  static MaterialGrade fromKey(String? value) {
    switch (value) {
      case 'fe500':
        return MaterialGrade.fe500;
      case 'fe600':
        return MaterialGrade.fe600;
      case 'fe550sd':
      default:
        return MaterialGrade.fe550sd;
    }
  }

  String get key => name;
}

/// Associated dealer model
class AssociatedDealer {
  final String id;
  final String name;
  final String shopName;
  final String phone;
  final String location;
  final double rating;

  const AssociatedDealer({
    required this.id,
    required this.name,
    required this.shopName,
    required this.phone,
    required this.location,
    required this.rating,
  });

  factory AssociatedDealer.fromMap(String id, Map<String, dynamic> data) {
    return AssociatedDealer(
      id: id,
      name: (data['name'] as String?) ?? 'Dealer',
      shopName: (data['shopName'] as String?) ?? 'TSL Dealer',
      phone: (data['phone'] as String?) ?? '',
      location: (data['location'] as String?) ?? (data['address'] as String?) ?? '',
      rating: ((data['rating'] as num?) ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shopName': shopName,
      'phone': phone,
      'location': location,
      'rating': rating,
    };
  }
}

/// Material specification model
class MaterialSpec {
  final String id;
  final String materialType;
  final double quantity;
  final String unit;
  final MaterialGrade grade;

  const MaterialSpec({
    required this.id,
    required this.materialType,
    required this.quantity,
    required this.unit,
    required this.grade,
  });

  factory MaterialSpec.fromMap(String id, Map<String, dynamic> data) {
    return MaterialSpec(
      id: id,
      materialType: (data['materialType'] as String?) ?? 'Material',
      quantity: ((data['quantity'] as num?) ?? 0).toDouble(),
      unit: (data['unit'] as String?) ?? 'kg',
      grade: MaterialGradeExtension.fromKey(data['grade'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materialType': materialType,
      'quantity': quantity,
      'unit': unit,
      'grade': grade.key,
    };
  }
}

/// Project model
class ArchitectProject {
  final String id;
  final String name;
  final ProjectType type;
  final ProjectStatus status;
  final String location;
  final List<AssociatedDealer> dealers;
  final List<MaterialSpec> specifications;
  final DateTime createdAt;
  final DateTime? expectedDelivery;
  final int pointsEarned;
  final String? notes;

  const ArchitectProject({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.location,
    required this.dealers,
    required this.specifications,
    required this.createdAt,
    this.expectedDelivery,
    required this.pointsEarned,
    this.notes,
  });

  double get totalQuantity => specifications.fold(0, (sum, s) => sum + s.quantity);

  factory ArchitectProject.fromMap(String id, Map<String, dynamic> data) {
    final dealers = ((data['dealers'] as List?) ?? const <dynamic>[])
        .whereType<Map>()
        .map((raw) => Map<String, dynamic>.from(raw as Map))
        .map((dealerData) {
          final dealerId = (dealerData['id'] as String?) ?? '';
          return AssociatedDealer.fromMap(dealerId, dealerData);
        })
        .toList();

    final specs = ((data['specifications'] as List?) ?? const <dynamic>[])
        .whereType<Map>()
        .map((raw) => Map<String, dynamic>.from(raw as Map))
        .toList();

    final mappedSpecs = specs
        .asMap()
        .entries
        .map((entry) {
          final specData = entry.value;
          final specId = (specData['id'] as String?) ?? '${id}_spec_${entry.key}';
          return MaterialSpec.fromMap(specId, specData);
        })
        .toList();

    return ArchitectProject(
      id: id,
      name: (data['name'] as String?) ?? 'Project',
      type: ProjectTypeExtension.fromKey(data['type'] as String?),
      status: ProjectStatusExtension.fromKey(data['status'] as String?),
      location: (data['location'] as String?) ?? '',
      dealers: dealers,
      specifications: mappedSpecs,
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      expectedDelivery: _parseDateTime(data['expectedDelivery']),
      pointsEarned: (data['pointsEarned'] as int?) ?? 0,
      notes: data['notes'] as String?,
    );
  }
}

/// Recent specification for home screen
class RecentSpec {
  final String id;
  final String projectName;
  final String materialType;
  final double quantity;
  final String unit;
  final SpecStatus status;
  final int pointsEarned;
  final DateTime createdAt;

  const RecentSpec({
    required this.id,
    required this.projectName,
    required this.materialType,
    required this.quantity,
    required this.unit,
    required this.status,
    required this.pointsEarned,
    required this.createdAt,
  });
}

/// Architect user model
class ArchitectUser {
  final String id;
  final String name;
  final String licenseNo;
  final String phone;
  final String? imageUrl;
  final int activeProjects;
  final int totalSpecifications;
  final int rewardPoints;
  final int connectedDealers;

  const ArchitectUser({
    required this.id,
    required this.name,
    required this.licenseNo,
    required this.phone,
    this.imageUrl,
    required this.activeProjects,
    required this.totalSpecifications,
    required this.rewardPoints,
    required this.connectedDealers,
  });
}

/// Architect reward transaction
class ArchitectRewardTransaction {
  final String id;
  final String title;
  final String description;
  final int points;
  final DateTime date;
  final ArchitectRewardType type;

  const ArchitectRewardTransaction({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.date,
    required this.type,
  });

  factory ArchitectRewardTransaction.fromMap(String id, Map<String, dynamic> data) {
    final rawPoints = data['points'];
    final rawCreatedAt = data['createdAt'] ?? data['date'];
    return ArchitectRewardTransaction(
      id: id,
      title: (data['title'] as String?) ?? 'Reward',
      description: (data['description'] as String?) ?? '',
      points: rawPoints is num ? rawPoints.toInt() : 0,
      date: _parseDateTime(rawCreatedAt) ?? DateTime.now(),
      type: ArchitectRewardTypeExtension.fromKey(data['type'] as String?),
    );
  }
}

enum ArchitectRewardType {
  specification,
  projectComplete,
  referral,
  redeemed,
}

extension ArchitectRewardTypeExtension on ArchitectRewardType {
  String get displayName {
    switch (this) {
      case ArchitectRewardType.specification:
        return 'Specification';
      case ArchitectRewardType.projectComplete:
        return 'Project Complete';
      case ArchitectRewardType.referral:
        return 'Referral';
      case ArchitectRewardType.redeemed:
        return 'Redeemed';
    }
  }

  Color get color {
    switch (this) {
      case ArchitectRewardType.specification:
        return const Color(0xFF4CAF50);
      case ArchitectRewardType.projectComplete:
        return const Color(0xFF2196F3);
      case ArchitectRewardType.referral:
        return const Color(0xFFFFA726);
      case ArchitectRewardType.redeemed:
        return const Color(0xFFF44336);
    }
  }

  IconData get icon {
    switch (this) {
      case ArchitectRewardType.specification:
        return Icons.description;
      case ArchitectRewardType.projectComplete:
        return Icons.check_circle;
      case ArchitectRewardType.referral:
        return Icons.person_add;
      case ArchitectRewardType.redeemed:
        return Icons.redeem;
    }
  }

  static ArchitectRewardType fromKey(String? value) {
    switch (value) {
      case 'projectComplete':
        return ArchitectRewardType.projectComplete;
      case 'referral':
        return ArchitectRewardType.referral;
      case 'redeemed':
        return ArchitectRewardType.redeemed;
      case 'specification':
      default:
        return ArchitectRewardType.specification;
    }
  }

  String get key => name;
}

DateTime? _parseDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

/// ============================================
/// MOCK DATA
/// ============================================

class MockArchitectData {
  MockArchitectData._();

  /// Mock architect user
  static const ArchitectUser mockUser = ArchitectUser(
    id: 'architect_001',
    name: 'Ar. Priya Sharma',
    licenseNo: 'COA/2018/123456',
    phone: '+91 98765 12345',
    activeProjects: 5,
    totalSpecifications: 28,
    rewardPoints: 8500,
    connectedDealers: 3,
  );

  /// Mock associated dealers
  static List<AssociatedDealer> get mockDealers => [
    const AssociatedDealer(
      id: 'dealer_001',
      name: 'Rajesh Kumar',
      shopName: 'Kumar Steel Traders',
      phone: '+91 98765 43210',
      location: 'Sector 62, Noida',
      rating: 4.8,
    ),
    const AssociatedDealer(
      id: 'dealer_002',
      name: 'Amit Gupta',
      shopName: 'Gupta Steel House',
      phone: '+91 98765 54321',
      location: 'Saket, New Delhi',
      rating: 4.5,
    ),
    const AssociatedDealer(
      id: 'dealer_003',
      name: 'Vikram Singh',
      shopName: 'Singh Steel Works',
      phone: '+91 98765 65432',
      location: 'Gurugram',
      rating: 4.7,
    ),
  ];

  /// Mock projects
  static List<ArchitectProject> get mockProjects => [
    ArchitectProject(
      id: 'proj_001',
      name: 'Green Valley Residences',
      type: ProjectType.housing,
      status: ProjectStatus.active,
      location: 'Sector 45, Gurugram',
      dealers: [mockDealers[0]],
      specifications: [
        const MaterialSpec(
          id: 'spec_001',
          materialType: 'TSL 550 SD TMT Bars',
          quantity: 5000,
          unit: 'kg',
          grade: MaterialGrade.fe550sd,
        ),
        const MaterialSpec(
          id: 'spec_002',
          materialType: 'TSL Girders',
          quantity: 50,
          unit: 'pcs',
          grade: MaterialGrade.fe500,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      expectedDelivery: DateTime.now().add(const Duration(days: 60)),
      pointsEarned: 1500,
    ),
    ArchitectProject(
      id: 'proj_002',
      name: 'Tech Park Tower',
      type: ProjectType.commercial,
      status: ProjectStatus.active,
      location: 'Cyber City, Gurugram',
      dealers: [mockDealers[0], mockDealers[2]],
      specifications: [
        const MaterialSpec(
          id: 'spec_003',
          materialType: 'TSL 600 TMT Bars',
          quantity: 15000,
          unit: 'kg',
          grade: MaterialGrade.fe600,
        ),
        const MaterialSpec(
          id: 'spec_004',
          materialType: 'TSL Channels',
          quantity: 200,
          unit: 'pcs',
          grade: MaterialGrade.fe500,
        ),
        const MaterialSpec(
          id: 'spec_005',
          materialType: 'TSL Angles',
          quantity: 500,
          unit: 'kg',
          grade: MaterialGrade.fe500,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      expectedDelivery: DateTime.now().add(const Duration(days: 90)),
      pointsEarned: 3500,
    ),
    ArchitectProject(
      id: 'proj_003',
      name: 'Metro Station Extension',
      type: ProjectType.infrastructure,
      status: ProjectStatus.onHold,
      location: 'Sector 18, Noida',
      dealers: [mockDealers[1]],
      specifications: [
        const MaterialSpec(
          id: 'spec_006',
          materialType: 'TSL 550 SD TMT Bars',
          quantity: 25000,
          unit: 'kg',
          grade: MaterialGrade.fe550sd,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      pointsEarned: 2000,
      notes: 'Pending environmental clearance',
    ),
    ArchitectProject(
      id: 'proj_004',
      name: 'Riverside Apartments',
      type: ProjectType.housing,
      status: ProjectStatus.completed,
      location: 'Yamuna Expressway',
      dealers: [mockDealers[0]],
      specifications: [
        const MaterialSpec(
          id: 'spec_007',
          materialType: 'TSL 550 SD TMT Bars',
          quantity: 8000,
          unit: 'kg',
          grade: MaterialGrade.fe550sd,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      expectedDelivery: DateTime.now().subtract(const Duration(days: 30)),
      pointsEarned: 2500,
    ),
    ArchitectProject(
      id: 'proj_005',
      name: 'Industrial Warehouse',
      type: ProjectType.industrial,
      status: ProjectStatus.draft,
      location: 'IMT Manesar',
      dealers: [],
      specifications: [],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      pointsEarned: 0,
    ),
  ];

  /// Mock recent specifications
  static List<RecentSpec> get mockRecentSpecs => [
    RecentSpec(
      id: 'spec_recent_001',
      projectName: 'Green Valley Residences',
      materialType: 'TSL 550 SD TMT Bars',
      quantity: 500,
      unit: 'kg',
      status: SpecStatus.delivered,
      pointsEarned: 150,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RecentSpec(
      id: 'spec_recent_002',
      projectName: 'Tech Park Tower',
      materialType: 'TSL Girders',
      quantity: 25,
      unit: 'pcs',
      status: SpecStatus.approved,
      pointsEarned: 200,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    RecentSpec(
      id: 'spec_recent_003',
      projectName: 'Tech Park Tower',
      materialType: 'TSL Channels',
      quantity: 50,
      unit: 'pcs',
      status: SpecStatus.submitted,
      pointsEarned: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  /// Mock reward transactions
  static List<ArchitectRewardTransaction> get mockRewardTransactions => [
    ArchitectRewardTransaction(
      id: 'reward_001',
      title: 'Specification Submitted',
      description: 'TSL 550 SD - Green Valley Residences',
      points: 150,
      date: DateTime.now().subtract(const Duration(hours: 12)),
      type: ArchitectRewardType.specification,
    ),
    ArchitectRewardTransaction(
      id: 'reward_002',
      title: 'Project Completed',
      description: 'Riverside Apartments',
      points: 500,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: ArchitectRewardType.projectComplete,
    ),
    ArchitectRewardTransaction(
      id: 'reward_003',
      title: 'Dealer Referral',
      description: 'Referred Singh Steel Works',
      points: 250,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: ArchitectRewardType.referral,
    ),
    ArchitectRewardTransaction(
      id: 'reward_004',
      title: 'Specification Submitted',
      description: 'TSL Girders - Tech Park Tower',
      points: 200,
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: ArchitectRewardType.specification,
    ),
    ArchitectRewardTransaction(
      id: 'reward_005',
      title: 'Redeemed',
      description: 'Amazon Gift Card â‚¹500',
      points: -1000,
      date: DateTime.now().subtract(const Duration(days: 10)),
      type: ArchitectRewardType.redeemed,
    ),
  ];

  /// Material types for specifications - mirrors TSL product catalog
  static List<String> get materialTypes => [
    'TSL 550 SD TMT Bars',
    'TSL Wires',
    'TSL Round Pipe',
    'TSL Square Pipe',
    'TSL Duro Colour',
    'TSL Angles',
    'TSL Channels',
    'TSL Girders',
  ];
}

