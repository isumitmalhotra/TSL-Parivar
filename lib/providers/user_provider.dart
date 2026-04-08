import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      joinedDate: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      roleSpecificData: data,
    );
  }

  static DateTime? _parseDateTime(dynamic rawValue) {
    if (rawValue is Timestamp) {
      return rawValue.toDate();
    }
    if (rawValue is DateTime) {
      return rawValue;
    }
    if (rawValue is String) {
      return DateTime.tryParse(rawValue);
    }
    return null;
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
  static const String _defaultDisplayName = 'TSL User';

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
  bool get canEvaluateProfileCompleteness => _currentUser != null;

  bool get isProfileComplete {
    final user = _currentUser;
    if (user == null) return false;

    final name = user.name.trim();
    final location = (user.roleSpecificData['location'] as String?)?.trim() ?? '';
    final address = (user.roleSpecificData['address'] as String?)?.trim() ?? '';

    return name.isNotEmpty &&
        name.toLowerCase() != _defaultDisplayName.toLowerCase() &&
        location.isNotEmpty &&
        address.isNotEmpty;
  }

  Future<bool> completeMandatoryProfile({
    required String name,
    required String location,
    required String address,
    String? city,
    String? pincode,
    String? email,
  }) async {
    final trimmedName = name.trim();
    final trimmedLocation = location.trim();
    final trimmedAddress = address.trim();
    final trimmedEmail = email?.trim();

    if (trimmedName.isEmpty ||
        trimmedLocation.isEmpty ||
        trimmedAddress.isEmpty) {
      _errorMessage = 'Please complete all required fields.';
      notifyListeners();
      return false;
    }

    return updateProfile(
      name: trimmedName,
      location: trimmedLocation,
      address: trimmedAddress,
      city: city,
      pincode: pincode,
      email: (trimmedEmail == null || trimmedEmail.isEmpty)
          ? null
          : trimmedEmail,
    );
  }

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
        final storedRoleKey = data['role'] as String?;
        final effectiveRole = storedRoleKey != null
            ? UserRoleExtension.fromKey(storedRoleKey)
            : role;

        _currentUser = UserProfile.fromFirestore(userId, data, effectiveRole);
        debugPrint('✅ User data loaded from Firestore');

        // Load role-specific data from respective collection
        await _loadRoleSpecificDataFromFirestore(userId, effectiveRole);
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
          var mistriDoc = await FirestoreService.getDocument(
            collection: FirestoreService.mistrisCollection,
            documentId: userId,
          );

          if (!mistriDoc.exists || mistriDoc.data() == null) {
            final phone = _currentUser?.phone;
            if (phone != null && phone.trim().isNotEmpty) {
              await FirestoreService.ensureMistriProfileForUser(
                userId: userId,
                phone: phone,
                name: _currentUser?.name,
              );
              mistriDoc = await FirestoreService.getDocument(
                collection: FirestoreService.mistrisCollection,
                documentId: userId,
              );
            }
          }

          if (mistriDoc.exists && mistriDoc.data() != null) {
            final data = mistriDoc.data()!;
            // Support canonical dealerId and legacy assignedDealer map.
            DealerModel assignedDealer = const DealerModel(
              id: 'default',
              name: 'Not Assigned',
              shopName: 'No Dealer',
              phone: '',
              address: '',
              rating: 0,
              totalDeliveries: 0,
            );

            final dealerData = data['assignedDealer'] as Map<String, dynamic>?;
            if (dealerData != null) {
              assignedDealer = DealerModel(
                id: (dealerData['id'] as String?) ?? '',
                name: (dealerData['name'] as String?) ?? 'Dealer',
                shopName: (dealerData['shopName'] as String?) ?? 'Shop',
                phone: (dealerData['phone'] as String?) ?? '',
                address: (dealerData['address'] as String?) ?? '',
                imageUrl: dealerData['imageUrl'] as String?,
                rating: ((dealerData['rating'] as num?) ?? 0).toDouble(),
                totalDeliveries: (dealerData['totalDeliveries'] as int?) ?? 0,
              );
            } else {
              final dealerId = (data['dealerId'] as String?) ?? '';
              if (dealerId.isNotEmpty) {
                final dealerDoc = await FirestoreService.getDocument(
                  collection: FirestoreService.dealersCollection,
                  documentId: dealerId,
                );
                final dealerInfo = dealerDoc.data();
                Map<String, dynamic>? dealerUserInfo;
                try {
                  final dealerUserDoc = await FirestoreService.getDocument(
                    collection: FirestoreService.usersCollection,
                    documentId: dealerId,
                  );
                  dealerUserInfo = dealerUserDoc.data();
                } catch (_) {
                  dealerUserInfo = null;
                }

                final resolvedName = (dealerInfo?['name'] as String?) ??
                    (dealerUserInfo?['name'] as String?) ??
                    'Dealer';
                final resolvedShop = (dealerInfo?['shopName'] as String?) ??
                    (dealerUserInfo?['shopName'] as String?) ??
                    resolvedName;
                final resolvedPhone = (dealerInfo?['phone'] as String?) ??
                    (dealerUserInfo?['phone'] as String?) ??
                    '';
                final resolvedAddress = (dealerInfo?['address'] as String?) ??
                    (dealerUserInfo?['address'] as String?) ??
                    (dealerUserInfo?['addressLine'] as String?) ??
                    (dealerUserInfo?['location'] as String?) ??
                    '';
                assignedDealer = DealerModel(
                  id: dealerId,
                  name: resolvedName,
                  shopName: resolvedShop,
                  phone: resolvedPhone,
                  address: resolvedAddress,
                  imageUrl: (dealerInfo?['imageUrl'] as String?) ??
                      (dealerUserInfo?['imageUrl'] as String?),
                  rating: ((dealerInfo?['rating'] as num?) ?? 0).toDouble(),
                  totalDeliveries: (dealerInfo?['totalDeliveries'] as int?) ?? 0,
                );
              }
            }

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
    String? location,
    String? address,
    String? city,
    String? pincode,
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
      if (location != null) updateData['location'] = location;
      if (address != null) updateData['address'] = address;
      final locationContractData = _buildLocationContractData(
        location: location,
        address: address,
        city: city,
        pincode: pincode,
      );
      updateData.addAll(locationContractData);

      if (updateData.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return true;
      }

      try {
        await FirestoreService.updateDocument(
          collection: FirestoreService.usersCollection,
          documentId: _currentUser!.id,
          data: updateData,
        );
      } on FirebaseException catch (e) {
        if (e.code == 'not-found') {
          // Recover from missing profile doc by recreating with merge semantics.
          await FirestoreService.saveUserProfile(
            uid: _currentUser!.id,
            data: {
              'phone': _currentUser!.phone,
              'role': _currentUser!.role.key,
              ...updateData,
            },
          );
        } else {
          rethrow;
        }
      }
      debugPrint('✅ Profile updated in Firestore');

      await _syncRoleLocationData(locationContractData);

      // Update local state
      _currentUser = _currentUser!.copyWith(
        name: name,
        email: email,
        imageUrl: imageUrl,
        roleSpecificData: {
          ..._currentUser!.roleSpecificData,
          if (location != null) 'location': location,
          if (address != null) 'address': address,
          ...locationContractData,
        },
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

  Map<String, dynamic> _buildLocationContractData({
    String? location,
    String? address,
    String? city,
    String? pincode,
  }) {
    final contractData = <String, dynamic>{};

    final normalizedLocation = location?.trim();
    final normalizedAddress = address?.trim();
    final normalizedCity = city?.trim();
    final normalizedPincode = pincode?.trim();

    final resolvedCity = (normalizedCity != null && normalizedCity.isNotEmpty)
        ? normalizedCity
        : _extractCityFromLocation(normalizedLocation);

    if (normalizedAddress != null && normalizedAddress.isNotEmpty) {
      contractData['addressLine'] = normalizedAddress;
    }
    if (resolvedCity != null && resolvedCity.isNotEmpty) {
      contractData['city'] = resolvedCity;
      contractData['cityKey'] = resolvedCity.toLowerCase();
    }
    if (normalizedPincode != null && normalizedPincode.isNotEmpty) {
      contractData['pincode'] = normalizedPincode;
    }

    final geoPoint = _tryParseGeoPoint(normalizedLocation);
    if (geoPoint != null) {
      contractData['geo'] = geoPoint;
    }

    if (contractData.isNotEmpty) {
      contractData['locationUpdatedAt'] = FieldValue.serverTimestamp();
    }

    return contractData;
  }

  String? _extractCityFromLocation(String? location) {
    if (location == null || location.isEmpty) return null;
    final parts = location.split(',');
    if (parts.isEmpty) return null;
    final city = parts.first.trim();
    return city.isEmpty ? null : city;
  }

  GeoPoint? _tryParseGeoPoint(String? location) {
    if (location == null || location.isEmpty) return null;
    final match = RegExp(r'^\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$')
        .firstMatch(location);
    if (match == null) return null;
    final lat = double.tryParse(match.group(1)!);
    final lng = double.tryParse(match.group(2)!);
    if (lat == null || lng == null) return null;
    return GeoPoint(lat, lng);
  }

  Future<void> _syncRoleLocationData(Map<String, dynamic> locationContractData) async {
    if (_currentUser == null || locationContractData.isEmpty) return;

    final uid = _currentUser!.id;
    try {
      switch (_currentUser!.role) {
        case UserRole.mistri:
          await FirestoreService.mistrisCollection
              .doc(uid)
              .set(locationContractData, SetOptions(merge: true));
          break;
        case UserRole.dealer:
          await FirestoreService.dealersCollection
              .doc(uid)
              .set(locationContractData, SetOptions(merge: true));
          break;
        case UserRole.architect:
          break;
      }
    } catch (e) {
      debugPrint('⚠️ Failed to sync role location contract: $e');
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

