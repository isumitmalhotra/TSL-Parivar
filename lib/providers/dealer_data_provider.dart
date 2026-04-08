import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/dealer_models.dart';
import '../models/shared_models.dart';
import '../services/firestore_service.dart';

/// Dealer data provider backed by Firestore streams.
class DealerDataProvider extends ChangeNotifier {
  static const DealerUser emptyDealerUser = DealerUser(
    id: '',
    name: 'Dealer',
    shopName: 'TSL Dealer',
    phone: '',
    address: '',
    totalMistris: 0,
    activeDeliveries: 0,
    pendingApprovals: 0,
    weeklyVolume: 0,
    loyaltyPoints: 0,
    mistriPoolPoints: 0,
  );

  String? _dealerId;
  bool _isLoading = false;
  bool _isAddingMistri = false;
  String? _errorMessage;

  DealerUser _dealerUser = emptyDealerUser;
  List<DealerMistriModel> _mistris = [];
  List<NearbyMistriModel> _nearbyMistris = [];
  List<OrderRequestModel> _orders = [];
  List<PodSubmissionModel> _pendingSubmissions = [];
  List<DealerRewardTransaction> _rewardTransactions = [];

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _dealerProfileSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _mistrisSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _nearbyMistrisSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _pendingSubmissionsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _rewardTransactionsSub;

  bool get isLoading => _isLoading;
  bool get isAddingMistri => _isAddingMistri;
  String? get errorMessage => _errorMessage;
  DealerUser get dealerUser => _dealerUser;
  List<DealerMistriModel> get mistris => _mistris;
  List<NearbyMistriModel> get nearbyMistris => _nearbyMistris;
  List<OrderRequestModel> get orders => _orders;
  List<PodSubmissionModel> get pendingSubmissions => _pendingSubmissions;
  List<DealerRewardTransaction> get rewardTransactions => _rewardTransactions;

  Future<void> syncAuthState({
    required bool isAuthenticated,
    required UserRole? role,
    String? userId,
  }) async {
    if (!isAuthenticated ||
        role != UserRole.dealer ||
        userId == null ||
        userId.isEmpty) {
      await _clearState();
      return;
    }

    if (_dealerId == userId) {
      return;
    }

    _dealerId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _cancelSubscriptions();
    _bindStreams(userId);
  }

  Future<void> _clearState() async {
    _dealerId = null;
    _dealerUser = emptyDealerUser;
    _mistris = [];
    _nearbyMistris = [];
    _orders = [];
    _pendingSubmissions = [];
    _rewardTransactions = [];
    _errorMessage = null;
    _isLoading = false;
    await _cancelSubscriptions();
    notifyListeners();
  }

  void _bindStreams(String dealerId) {
    _dealerProfileSub = FirestoreService.streamDealerProfile(dealerId).listen((
      snapshot,
    ) {
      final data = snapshot.data() ?? const <String, dynamic>{};
      _dealerUser = DealerUser(
        id: dealerId,
        name: (data['name'] as String?) ?? _dealerUser.name,
        shopName: (data['shopName'] as String?) ?? 'TSL Dealer',
        phone: (data['phone'] as String?) ?? '',
        address: (data['address'] as String?) ?? '',
        imageUrl: data['imageUrl'] as String?,
        totalMistris: _mistris.length,
        activeDeliveries: _orders
            .where((o) => o.status == OrderRequestStatus.newRequest)
            .length,
        pendingApprovals: _pendingSubmissions.length,
        weeklyVolume: ((data['weeklyVolume'] as num?) ?? 0).toDouble(),
        loyaltyPoints: (data['loyaltyPoints'] as int?) ?? 0,
        mistriPoolPoints: (data['mistriPoolPoints'] as int?) ?? 0,
      );
      _isLoading = false;
      notifyListeners();
    }, onError: (Object error) => _setError(error));

    _mistrisSub = FirestoreService.streamDealerMistris(dealerId).listen((
      snapshot,
    ) {
      final mapped = snapshot.docs
          .map((doc) => _mapMistri(doc.id, doc.data()))
          .toList();
      _mistris = _dedupeMistrisByPhone(mapped);
      _dealerUser = DealerUser(
        id: _dealerUser.id,
        name: _dealerUser.name,
        shopName: _dealerUser.shopName,
        phone: _dealerUser.phone,
        address: _dealerUser.address,
        imageUrl: _dealerUser.imageUrl,
        totalMistris: _mistris.length,
        activeDeliveries: _dealerUser.activeDeliveries,
        pendingApprovals: _dealerUser.pendingApprovals,
        weeklyVolume: _dealerUser.weeklyVolume,
        loyaltyPoints: _dealerUser.loyaltyPoints,
        mistriPoolPoints: _dealerUser.mistriPoolPoints,
      );
      notifyListeners();
    }, onError: (Object error) => _setError(error));

    _nearbyMistrisSub = FirestoreService.streamNearbyMistrisByDealerCity(
      dealerId,
    ).listen((snapshot) {
      final ownedIds = _mistris.map((m) => m.id).toSet();
      final mapped = snapshot.docs
          .map((doc) => _mapNearbyMistri(doc.id, doc.data()))
          .where((m) => m.existingDealerId != dealerId && !ownedIds.contains(m.id))
          .toList();

      mapped.sort((a, b) => a.name.compareTo(b.name));
      _nearbyMistris = mapped;
      notifyListeners();
    }, onError: (Object error) => _setError(error));

    _ordersSub = FirestoreService.streamDealerOrders(dealerId).listen((
      snapshot,
    ) {
      _orders = snapshot.docs
          .map((doc) => _mapOrder(doc.id, doc.data()))
          .toList();
      _orders.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
      notifyListeners();
    }, onError: (Object error) => _setError(error));

    _pendingSubmissionsSub =
        FirestoreService.streamDealerPendingPodSubmissions(dealerId).listen((
          snapshot,
        ) {
          _pendingSubmissions = snapshot.docs
              .map((doc) => _mapPodSubmission(doc.id, doc.data()))
              .where(
                (pod) =>
                    pod.status == PodApprovalStatus.pending ||
                    pod.status == PodApprovalStatus.needsInfo,
              )
              .toList();
          _pendingSubmissions.sort(
            (a, b) => b.submittedAt.compareTo(a.submittedAt),
          );
          _dealerUser = DealerUser(
            id: _dealerUser.id,
            name: _dealerUser.name,
            shopName: _dealerUser.shopName,
            phone: _dealerUser.phone,
            address: _dealerUser.address,
            imageUrl: _dealerUser.imageUrl,
            totalMistris: _dealerUser.totalMistris,
            activeDeliveries: _dealerUser.activeDeliveries,
            pendingApprovals: _pendingSubmissions.length,
            weeklyVolume: _dealerUser.weeklyVolume,
            loyaltyPoints: _dealerUser.loyaltyPoints,
            mistriPoolPoints: _dealerUser.mistriPoolPoints,
          );
          notifyListeners();
        }, onError: (Object error) => _setError(error));

    _rewardTransactionsSub =
        FirestoreService.streamDealerRewardTransactions(dealerId).listen((
          snapshot,
        ) {
          _rewardTransactions = snapshot.docs
              .map((doc) => _mapRewardTransaction(doc.id, doc.data()))
              .toList();
          _rewardTransactions.sort((a, b) => b.date.compareTo(a.date));
          notifyListeners();
        }, onError: (Object error) => _setError(error));
  }

  void _setError(Object error) {
    _isLoading = false;
    _errorMessage = 'Failed to load dealer data';
    debugPrint('❌ DealerDataProvider stream error: $error');
    notifyListeners();
  }

  DealerMistriModel _mapMistri(String id, Map<String, dynamic> data) {
    final statusKey =
        (data['status'] as String?) ??
        ((data['isActive'] as bool?) == true ? 'active' : 'pending');
    final status = switch (statusKey) {
      'active' => MistriStatus.active,
      'inactive' => MistriStatus.inactive,
      _ => MistriStatus.pending,
    };

    final completedDeliveries = (data['completedDeliveries'] as int?) ?? 0;
    final totalDeliveries =
        (data['totalDeliveries'] as int?) ?? completedDeliveries;

    return DealerMistriModel(
      id: id,
      name: (data['name'] as String?) ?? 'Mistri',
      phone: (data['phone'] as String?) ?? '',
      imageUrl: data['imageUrl'] as String?,
      specialization: (data['specialization'] as String?) ?? 'General',
      status: status,
      totalDeliveries: totalDeliveries,
      completedDeliveries: completedDeliveries,
      successRate: ((data['successRate'] as num?) ?? 0).toDouble(),
      rewardPoints:
          (data['rewardPoints'] as int?) ??
          (data['approvedPoints'] as int?) ??
          0,
      joinedDate: _parseDateTime(data['joinedDate'] ?? data['createdAt']),
    );
  }

  NearbyMistriModel _mapNearbyMistri(String id, Map<String, dynamic> data) {
    return NearbyMistriModel(
      id: id,
      name: (data['name'] as String?) ?? 'Mistri',
      phone: (data['phone'] as String?) ?? '',
      specialization: (data['specialization'] as String?) ?? 'General',
      city: (data[FirestoreService.fieldCity] as String?) ??
          (data['location'] as String?) ??
          'Unknown city',
      addressLine: data[FirestoreService.fieldAddressLine] as String?,
      existingDealerId: data[FirestoreService.fieldDealerId] as String?,
      isActive: (data['isActive'] as bool?) ?? true,
    );
  }

  List<DealerMistriModel> _dedupeMistrisByPhone(
    List<DealerMistriModel> mistris,
  ) {
    final byPhone = <String, DealerMistriModel>{};
    for (final mistri in mistris) {
      final key = _phoneKey(mistri.phone);
      final current = byPhone[key];
      if (current == null || _shouldPrefer(mistri, current)) {
        byPhone[key] = mistri;
      }
    }
    final deduped = byPhone.values.toList();
    deduped.sort((a, b) => b.joinedDate.compareTo(a.joinedDate));
    return deduped;
  }

  String _phoneKey(String phone) => phone.replaceAll(RegExp(r'[^0-9]'), '');

  bool _shouldPrefer(DealerMistriModel candidate, DealerMistriModel existing) {
    final rank = {
      MistriStatus.active: 3,
      MistriStatus.pending: 2,
      MistriStatus.inactive: 1,
    };
    final candidateRank = rank[candidate.status] ?? 0;
    final existingRank = rank[existing.status] ?? 0;
    if (candidateRank != existingRank) {
      return candidateRank > existingRank;
    }
    return candidate.joinedDate.isAfter(existing.joinedDate);
  }

  OrderRequestModel _mapOrder(String id, Map<String, dynamic> data) {
    final statusKey = (data['status'] as String?) ?? 'newRequest';
    final status = switch (statusKey) {
      'approved' => OrderRequestStatus.approved,
      'rejected' => OrderRequestStatus.rejected,
      'moreInfo' => OrderRequestStatus.moreInfo,
      'pending' || 'new' || 'newRequest' => OrderRequestStatus.newRequest,
      _ => OrderRequestStatus.newRequest,
    };

    return OrderRequestModel(
      id: id,
      mistriId:
          (data['mistriId'] as String?) ?? (data['userId'] as String?) ?? '',
      mistriName: (data['mistriName'] as String?) ?? 'Mistri',
      materialType:
          (data['materialType'] as String?) ??
          (data['productType'] as String?) ??
          'Material',
      quantity: ((data['quantity'] as num?) ?? 0).toDouble(),
      unit: (data['unit'] as String?) ?? 'Units',
      location:
          (data['location'] as String?) ??
          (data['customerAddress'] as String?) ??
          'Unknown',
      expectedDate: _parseDateTime(data['expectedDate']),
      urgency: (data['urgency'] as String?) ?? 'Normal',
      status: status,
      requestedAt: _parseDateTime(data['createdAt']),
      customerName: data['customerName'] as String?,
      notes: data['notes'] as String?,
    );
  }

  PodSubmissionModel _mapPodSubmission(String id, Map<String, dynamic> data) {
    final reviewStatus = (data['podReviewStatus'] as String?) ?? '';
    final statusKey = reviewStatus.isNotEmpty
        ? reviewStatus
        : ((data['status'] as String?) ?? 'pending');
    final status = switch (statusKey) {
      'approved' => PodApprovalStatus.approved,
      'rejected' => PodApprovalStatus.rejected,
      'needsInfo' => PodApprovalStatus.needsInfo,
      _ => PodApprovalStatus.pending,
    };

    final assignedQuantity =
        ((data['assignedQuantity'] as num?) ?? (data['quantity'] as num?) ?? 0)
            .toDouble();
    final deliveredQuantity =
        ((data['deliveredQuantity'] as num?) ?? assignedQuantity).toDouble();

    return PodSubmissionModel(
      id: id,
      deliveryId: id,
      mistriId:
          (data['mistriId'] as String?) ?? (data['userId'] as String?) ?? '',
      mistriName: (data['mistriName'] as String?) ?? 'Mistri',
      materialType:
          (data['productType'] as String?) ??
          (data['materialType'] as String?) ??
          'Material',
      assignedQuantity: assignedQuantity,
      deliveredQuantity: deliveredQuantity,
      unit: (data['unit'] as String?) ?? 'Units',
      customerName: (data['customerName'] as String?) ?? 'Customer',
      customerAddress:
          (data['customerAddress'] as String?) ?? 'Address unavailable',
      photoUrls: ((data['photoUrls'] as List?) ?? const <dynamic>[])
          .whereType<String>()
          .toList(),
      assignedLat:
          ((data['assignedLat'] as num?) ?? (data['latitude'] as num?) ?? 0)
              .toDouble(),
      assignedLng:
          ((data['assignedLng'] as num?) ?? (data['longitude'] as num?) ?? 0)
              .toDouble(),
      submittedLat:
          ((data['submittedLat'] as num?) ?? (data['latitude'] as num?) ?? 0)
              .toDouble(),
      submittedLng:
          ((data['submittedLng'] as num?) ?? (data['longitude'] as num?) ?? 0)
              .toDouble(),
      distanceFromTarget: ((data['distanceFromTarget'] as num?) ?? 0)
          .toDouble(),
      mistriNotes: data['mistriNotes'] as String?,
      issueReported: data['issueReported'] as String?,
      status: status,
      submittedAt: _parseDateTime(
        data['podSubmittedAt'] ?? data['updatedAt'] ?? data['createdAt'],
      ),
      basePoints: (data['basePoints'] as int?) ?? 0,
      bonusPoints: (data['bonusPoints'] as int?) ?? 0,
    );
  }

  DealerRewardTransaction _mapRewardTransaction(
    String id,
    Map<String, dynamic> data,
  ) {
    final type = switch ((data['type'] as String?) ?? 'earned') {
      'distributed' => DealerRewardType.distributed,
      'redeemed' => DealerRewardType.redeemed,
      'bonus' => DealerRewardType.bonus,
      _ => DealerRewardType.earned,
    };

    return DealerRewardTransaction(
      id: id,
      title: (data['title'] as String?) ?? 'Reward Transaction',
      description: (data['description'] as String?) ?? '',
      points: (data['points'] as int?) ?? 0,
      date: _parseDateTime(data['createdAt']),
      type: type,
      mistriName: data['mistriName'] as String?,
    );
  }

  DateTime _parseDateTime(dynamic rawValue) {
    if (rawValue is Timestamp) {
      return rawValue.toDate();
    }
    if (rawValue is String) {
      return DateTime.tryParse(rawValue) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Future<void> _cancelSubscriptions() async {
    await _dealerProfileSub?.cancel();
    await _mistrisSub?.cancel();
    await _nearbyMistrisSub?.cancel();
    await _ordersSub?.cancel();
    await _pendingSubmissionsSub?.cancel();
    await _rewardTransactionsSub?.cancel();
    _dealerProfileSub = null;
    _mistrisSub = null;
    _nearbyMistrisSub = null;
    _ordersSub = null;
    _pendingSubmissionsSub = null;
    _rewardTransactionsSub = null;
  }

  @override
  void dispose() {
    _dealerProfileSub?.cancel();
    _mistrisSub?.cancel();
    _nearbyMistrisSub?.cancel();
    _ordersSub?.cancel();
    _pendingSubmissionsSub?.cancel();
    _rewardTransactionsSub?.cancel();
    super.dispose();
  }

  Future<void> _refreshAuthSession() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw StateError('You are logged out. Please sign in again.');
    }
    await currentUser.getIdToken(true);
  }

  Future<void> _logDealerRoleSnapshot(String dealerId, String attemptId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final token = await currentUser?.getIdTokenResult(true);
      final tokenRole = token?.claims?['role'];
      final profile = await FirestoreService.getUserProfile(dealerId);
      final profileRole = profile?['role'];
      debugPrint(
        '🧪[ADD_MISTRI:$attemptId] role-snapshot uid=$dealerId tokenRole=$tokenRole profileRole=$profileRole',
      );
    } catch (e) {
      debugPrint('⚠️[ADD_MISTRI:$attemptId] role snapshot unavailable: $e');
    }
  }

  Future<String> _resolveDealerIdForAction() async {
    await _refreshAuthSession();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw StateError('You are logged out. Please sign in again.');
    }

    final liveUid = currentUser.uid;
    if (_dealerId == null || _dealerId!.isEmpty) {
      _dealerId = liveUid;
    } else if (_dealerId != liveUid) {
      // Recover from stale provider state after account switch/re-login.
      debugPrint('⚠️ DealerDataProvider uid mismatch: cached=$_dealerId live=$liveUid');
      _dealerId = liveUid;
    }

    return liveUid;
  }

  Future<void> _ensureDealerRoleForAction(String dealerId) async {
    try {
      final profile = await FirestoreService.getUserProfile(dealerId);
      final role = (profile?['role'] as String?)?.trim();

      if (role == null || role.isEmpty) {
        throw StateError(
          'Your account role is missing. Please log out and sign in again as dealer.',
        );
      }

      if (role != 'dealer') {
        throw StateError(
          'Account role mismatch: this account is "$role" but dealer access is required.',
        );
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw StateError(
          'Unable to verify account role. Please re-login and try again.',
        );
      }
      rethrow;
    }
  }

  Future<DealerMistriLinkResult> addMistriForDealer({
    required String name,
    required String phone,
    required String specialization,
  }) async {
     final attemptId = 'dm_${DateTime.now().millisecondsSinceEpoch}';
     _isAddingMistri = true;
     _errorMessage = null;
     notifyListeners();

     try {
       debugPrint(
         '🧪[ADD_MISTRI:$attemptId] submit name=${name.trim()} phone=${phone.trim()} specialization=${specialization.trim()}',
       );
      final dealerId = await _resolveDealerIdForAction();
        await _logDealerRoleSnapshot(dealerId, attemptId);
       await _ensureDealerRoleForAction(dealerId);
       final result = await FirestoreService.addOrLinkMistriToDealer(
         dealerId: dealerId,
         name: name,
         phone: phone,
         specialization: specialization,
       );
       debugPrint(
         '✅[ADD_MISTRI:$attemptId] linked mistriId=${result.mistriId} pending=${result.isPendingInvite} existing=${result.wasExisting}',
       );
      _upsertMistriFromLinkResult(result);
      return result;
    } catch (e) {
      debugPrint('❌[ADD_MISTRI:$attemptId] failed error=$e');
      if (e is StateError) {
        final message = e.message;
        if (message.contains('role mismatch')) {
          _errorMessage =
              'Account role mismatch. Please sign in with a dealer account.';
        } else if (message.contains('role is missing')) {
          _errorMessage =
              'Your account role is missing. Please re-login and try again.';
        } else if (message.contains('Unable to verify account role')) {
          _errorMessage =
              'Unable to verify account role. Please re-login and try again.';
        } else if (message.contains('logged out')) {
          _errorMessage = 'Session expired. Please login again.';
        } else if (message.contains('Dealer session')) {
          _errorMessage =
              'Dealer session is not ready. Please reopen this page and try again.';
        } else {
          _errorMessage =
              'Dealer session is not ready. Please reopen this page and try again.';
        }
      } else if (e is FirebaseException && e.code == 'permission-denied') {
        _errorMessage =
            'Permission denied while adding mistri. Please re-login once and verify this account role is dealer.';
      } else {
        _errorMessage = 'Failed to add mistri. Please try again.';
      }
      rethrow;
    } finally {
      _isAddingMistri = false;
      notifyListeners();
    }
  }

  Future<DealerMistriLinkResult> attachNearbyMistri(String mistriId) async {
    final attemptId = 'att_${DateTime.now().millisecondsSinceEpoch}';
    _isAddingMistri = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dealerId = await _resolveDealerIdForAction();
      await _ensureDealerRoleForAction(dealerId);
      final result = await FirestoreService.attachNearbyMistriToDealer(
        dealerId: dealerId,
        mistriId: mistriId,
      );

      _upsertMistriFromLinkResult(result);
      _nearbyMistris.removeWhere((m) => m.id == mistriId);
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('❌[ATTACH_MISTRI:$attemptId] failed error=$e');
      if (e is StateError) {
        _errorMessage = e.message;
      } else if (e is FirebaseException && e.code == 'permission-denied') {
        _errorMessage =
            'Permission denied while attaching mistri. Please re-login and try again.';
      } else {
        _errorMessage = 'Unable to attach mistri right now.';
      }
      rethrow;
    } finally {
      _isAddingMistri = false;
      notifyListeners();
    }
  }

  void _upsertMistriFromLinkResult(DealerMistriLinkResult result) {
    final existingIndex = _mistris.indexWhere((m) => m.id == result.mistriId);
    final model = DealerMistriModel(
      id: result.mistriId,
      name: result.name,
      phone: result.normalizedPhone,
      specialization: result.specialization,
      status: result.isPendingInvite
          ? MistriStatus.pending
          : MistriStatus.active,
      totalDeliveries: existingIndex >= 0
          ? _mistris[existingIndex].totalDeliveries
          : 0,
      completedDeliveries: existingIndex >= 0
          ? _mistris[existingIndex].completedDeliveries
          : 0,
      successRate: existingIndex >= 0 ? _mistris[existingIndex].successRate : 0,
      rewardPoints: existingIndex >= 0
          ? _mistris[existingIndex].rewardPoints
          : 0,
      joinedDate: DateTime.now(),
    );

    if (existingIndex >= 0) {
      _mistris[existingIndex] = model;
    } else {
      _mistris.insert(0, model);
    }
    _mistris = _dedupeMistrisByPhone(_mistris);
    notifyListeners();
  }
}
