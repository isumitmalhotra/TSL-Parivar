import 'package:flutter/foundation.dart';

import '../models/mistri_models.dart';
import '../models/shared_models.dart';
import '../services/firestore_service.dart';

/// User profile model
class UserProfile {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? imageUrl;
  final UserRole role;
  final DateTime joinedDate;
  final Map<String, dynamic> roleSpecificData;

  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.imageUrl,
    required this.role,
    required this.joinedDate,
    this.roleSpecificData = const {},
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? imageUrl,
    UserRole? role,
    DateTime? joinedDate,
    Map<String, dynamic>? roleSpecificData,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      joinedDate: joinedDate ?? this.joinedDate,
      roleSpecificData: roleSpecificData ?? this.roleSpecificData,
    );
  }

  /// Create from Firestore document
  factory UserProfile.fromFirestore(String id, Map<String, dynamic> data, UserRole role) {
    return UserProfile(
      id: id,
      name: (data['name'] as String?) ?? 'User',
      phone: (data['phone'] as String?) ?? '',
      email: data['email'] as String?,
      imageUrl: data['imageUrl'] as String?,
      role: role,
      joinedDate: data['createdAt'] != null 
          ? DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      roleSpecificData: data,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'imageUrl': imageUrl,
      'role': role.key,
      ...roleSpecificData,
    };
  }
}

/// Provider for managing user data and profile
class UserProvider extends ChangeNotifier {
  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Role-specific data loaded from Firestore
  MistriUser? _mistriData;
  DealerUser? _dealerData;
  ArchitectUser? _architectData;

  // Getters
  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MistriUser? get mistriData => _mistriData;
  DealerUser? get dealerData => _dealerData;
  ArchitectUser? get architectData => _architectData;

  bool get hasUser => _currentUser != null;

  /// Load authenticated user data from Firestore.
  Future<void> loadUserData(
    String userId,
    UserRole role, {
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userDoc = await FirestoreService.getDocument(
        collection: FirestoreService.usersCollection,
        documentId: userId,
      );

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        _currentUser = UserProfile.fromFirestore(userId, data, role);
        debugPrint('✅ User data loaded from Firestore');

        // Load role-specific data from respective collection
        await _loadRoleSpecificDataFromFirestore(userId, role);
      } else {
        await _createInitialUserDocument(
          userId: userId,
          role: role,
          phoneNumber: phoneNumber,
        );

        _currentUser = UserProfile(
          id: userId,
          name: 'TSL User',
          phone: phoneNumber ?? '',
          role: role,
          joinedDate: DateTime.now(),
        );

        _mistriData = null;
        _dealerData = null;
        _architectData = null;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
      _errorMessage = 'Failed to load user data';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createInitialUserDocument({
    required String userId,
    required UserRole role,
    String? phoneNumber,
  }) async {
    await FirestoreService.createDocument(
      collection: FirestoreService.usersCollection,
      documentId: userId,
      data: {
        'name': 'TSL User',
        'phone': phoneNumber ?? '',
        'role': role.key,
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': true,
      },
    );
    debugPrint('✅ Initial user profile created for uid=$userId');
  }

  /// Load role-specific data from Firestore
  Future<void> _loadRoleSpecificDataFromFirestore(String userId, UserRole role) async {
    try {
      switch (role) {
        case UserRole.mistri:
          final mistriDoc = await FirestoreService.getDocument(
            collection: FirestoreService.mistrisCollection,
            documentId: userId,
          );
          if (mistriDoc.exists && mistriDoc.data() != null) {
            final data = mistriDoc.data()!;
            // Get assigned dealer or use a default placeholder
            final dealerData = data['assignedDealer'] as Map<String, dynamic>?;
            final assignedDealer = dealerData != null
                ? DealerModel(
                    id: (dealerData['id'] as String?) ?? '',
                    name: (dealerData['name'] as String?) ?? 'Dealer',
                    shopName: (dealerData['shopName'] as String?) ?? 'Shop',
                    phone: (dealerData['phone'] as String?) ?? '',
                    address: (dealerData['address'] as String?) ?? '',
                    imageUrl: dealerData['imageUrl'] as String?,
                    rating: ((dealerData['rating'] as num?) ?? 0).toDouble(),
                    totalDeliveries: (dealerData['totalDeliveries'] as int?) ?? 0,
                  )
                : const DealerModel(
                    id: 'default',
                    name: 'Not Assigned',
                    shopName: 'No Dealer',
                    phone: '',
                    address: '',
                    rating: 0,
                    totalDeliveries: 0,
                  );
            _mistriData = MistriUser(
              id: userId,
              name: _currentUser?.name ?? 'Mistri',
              phone: _currentUser?.phone ?? '',
              imageUrl: _currentUser?.imageUrl,
              specialization: (data['specialization'] as String?) ?? 'Steel Fitter',
              approvedPoints: (data['approvedPoints'] as int?) ?? 0,
              pendingPoints: (data['pendingPoints'] as int?) ?? 0,
              rank: (data['rank'] as String?) ?? 'Bronze',
              badgeIcon: (data['badgeIcon'] as String?) ?? '🥉',
              totalDeliveries: (data['totalDeliveries'] as int?) ?? 0,
              successRate: ((data['successRate'] as num?) ?? 0).toDouble(),
              assignedDealer: assignedDealer,
            );
          }
          break;
        case UserRole.dealer:
          final dealerDoc = await FirestoreService.getDocument(
            collection: FirestoreService.dealersCollection,
            documentId: userId,
          );
          if (dealerDoc.exists && dealerDoc.data() != null) {
            final data = dealerDoc.data()!;
            _dealerData = DealerUser(
              id: userId,
              name: _currentUser?.name ?? 'Dealer',
              shopName: (data['shopName'] as String?) ?? 'Shop',
              phone: _currentUser?.phone ?? '',
              email: _currentUser?.email,
              address: (data['address'] as String?) ?? '',
              imageUrl: _currentUser?.imageUrl,
              loyaltyPoints: (data['loyaltyPoints'] as int?) ?? 0,
              mistriPoolPoints: (data['mistriPoolPoints'] as int?) ?? 0,
              totalMistris: (data['totalMistris'] as int?) ?? 0,
              activeMistris: (data['activeMistris'] as int?) ?? 0,
              pendingApprovals: (data['pendingApprovals'] as int?) ?? 0,
              monthlyVolume: ((data['monthlyVolume'] as num?) ?? 0).toDouble(),
              rating: ((data['rating'] as num?) ?? 0).toDouble(),
            );
          }
          break;
        case UserRole.architect:
          // Architects stored in users collection with role-specific fields
          break;
      }
    } catch (e) {
      debugPrint('⚠️ Error loading role-specific data: $e');
    }
  }


  /// Update user profile - saves to Firestore
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? imageUrl,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Update in Firestore
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;

      await FirestoreService.updateDocument(
        collection: FirestoreService.usersCollection,
        documentId: _currentUser!.id,
        data: updateData,
      );
      debugPrint('✅ Profile updated in Firestore');

      // Update local state
      _currentUser = _currentUser!.copyWith(
        name: name,
        email: email,
        imageUrl: imageUrl,
      );

      // Update role-specific data as well
      if (_mistriData != null && name != null) {
        _mistriData = MistriUser(
          id: _mistriData!.id,
          name: name,
          phone: _mistriData!.phone,
          imageUrl: imageUrl ?? _mistriData!.imageUrl,
          specialization: _mistriData!.specialization,
          approvedPoints: _mistriData!.approvedPoints,
          pendingPoints: _mistriData!.pendingPoints,
          rank: _mistriData!.rank,
          badgeIcon: _mistriData!.badgeIcon,
          totalDeliveries: _mistriData!.totalDeliveries,
          successRate: _mistriData!.successRate,
          assignedDealer: _mistriData!.assignedDealer,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      _isLoading = false;
      _errorMessage = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }

  /// Clear user data on logout
  void clearUserData() {
    _currentUser = null;
    _mistriData = null;
    _dealerData = null;
    _architectData = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

/// Dealer user model for dealer role
class DealerUser {
  final String id;
  final String name;
  final String shopName;
  final String phone;
  final String? email;
  final String address;
  final String? imageUrl;
  final int loyaltyPoints;
  final int mistriPoolPoints;
  final int totalMistris;
  final int activeMistris;
  final int pendingApprovals;
  final double monthlyVolume;
  final double rating;

  const DealerUser({
    required this.id,
    required this.name,
    required this.shopName,
    required this.phone,
    this.email,
    required this.address,
    this.imageUrl,
    required this.loyaltyPoints,
    required this.mistriPoolPoints,
    required this.totalMistris,
    required this.activeMistris,
    required this.pendingApprovals,
    required this.monthlyVolume,
    required this.rating,
  });
}

/// Architect user model for architect role
class ArchitectUser {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String firmName;
  final String? imageUrl;
  final int totalPoints;
  final int pendingPoints;
  final int totalProjects;
  final int activeProjects;
  final int completedSpecs;
  final int associatedDealers;

  const ArchitectUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.firmName,
    this.imageUrl,
    required this.totalPoints,
    required this.pendingPoints,
    required this.totalProjects,
    required this.activeProjects,
    required this.completedSpecs,
    required this.associatedDealers,
  });
}

