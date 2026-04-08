import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/mistri_models.dart';
import '../services/firestore_service.dart';

/// Reward filter options
enum RewardFilter {
  all,
  earned,
  redeemed,
  pending,
  bonus,
}

/// Provider for managing rewards data
class RewardsProvider extends ChangeNotifier {
  List<RewardTransaction> _transactions = [];
  RewardFilter _currentFilter = RewardFilter.all;
  bool _isLoading = false;
  String? _errorMessage;

  // Points summary
  int _approvedPoints = 0;
  int _pendingPoints = 0;
  int _redeemedPoints = 0;
  int _bonusPoints = 0;
  String _currentRank = 'Silver';
  String _badgeIcon = '🥈';

  // Getters
  List<RewardTransaction> get transactions => _filteredTransactions;
  List<RewardTransaction> get allTransactions => _transactions;
  RewardFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get approvedPoints => _approvedPoints;
  int get pendingPoints => _pendingPoints;
  int get redeemedPoints => _redeemedPoints;
  int get bonusPoints => _bonusPoints;
  int get totalEarnedPoints => _approvedPoints + _bonusPoints;
  int get availablePoints => _approvedPoints + _bonusPoints - _redeemedPoints;
  String get currentRank => _currentRank;
  String get badgeIcon => _badgeIcon;

  /// Get filtered transactions
  List<RewardTransaction> get _filteredTransactions {
    if (_currentFilter == RewardFilter.all) {
      return _transactions;
    }
    return _transactions.where((t) {
      switch (_currentFilter) {
        case RewardFilter.earned:
          return t.type == RewardType.earned;
        case RewardFilter.redeemed:
          return t.type == RewardType.redeemed;
        case RewardFilter.pending:
          return t.type == RewardType.pending;
        case RewardFilter.bonus:
          return t.type == RewardType.bonus;
        case RewardFilter.all:
          return true;
      }
    }).toList();
  }

  /// Get transactions grouped by date
  Map<String, List<RewardTransaction>> get transactionsByDate {
    final grouped = <String, List<RewardTransaction>>{};
    for (final transaction in _filteredTransactions) {
      final dateKey = _getDateKey(transaction.date);
      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }
    return grouped;
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(transactionDate).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return 'This Week';
    if (difference < 30) return 'This Month';
    return 'Earlier';
  }

  /// Load rewards data from Firestore for the authenticated user.
  Future<void> loadRewards({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (userId == null || userId.isEmpty) {
        clearData();
        return;
      }

      final rewardsDoc = await FirestoreService.rewardsCollection.doc(userId).get();
      final historySnapshot = await FirestoreService.rewardsCollection
          .doc(userId)
          .collection('history')
          .orderBy('createdAt', descending: true)
          .get();

      _transactions = historySnapshot.docs
          .map((doc) => _mapHistoryTransaction(doc.id, doc.data()))
          .toList();

      if (rewardsDoc.exists && rewardsDoc.data() != null) {
        final data = rewardsDoc.data()!;
        _approvedPoints = (data['approvedPoints'] as int?) ?? (data['points'] as int?) ?? 0;
        _pendingPoints = (data['pendingPoints'] as int?) ?? 0;
        _redeemedPoints = (data['redeemedPoints'] as int?) ?? 0;
        _bonusPoints = (data['bonusPoints'] as int?) ?? 0;
      } else {
        _rebuildSummaryFromTransactions();
      }

      _updateRank();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load rewards';
      _transactions = [];
      _approvedPoints = 0;
      _pendingPoints = 0;
      _redeemedPoints = 0;
      _bonusPoints = 0;
      notifyListeners();
    }
  }

  RewardTransaction _mapHistoryTransaction(String id, Map<String, dynamic> data) {
    final int points = (data['points'] as int?) ?? 0;
    return RewardTransaction(
      id: id,
      title: (data['title'] as String?) ?? (data['reason'] as String?) ?? 'Reward Update',
      description: (data['description'] as String?) ?? (data['reason'] as String?) ?? '',
      points: points,
      date: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      type: _resolveRewardType(data: data, points: points),
      deliveryId: data['deliveryId'] as String?,
    );
  }

  RewardType _resolveRewardType({required Map<String, dynamic> data, required int points}) {
    final rawType = data['type'] as String?;
    switch (rawType) {
      case 'redeemed':
        return RewardType.redeemed;
      case 'pending':
        return RewardType.pending;
      case 'bonus':
        return RewardType.bonus;
      case 'earned':
        return RewardType.earned;
    }

    if (points < 0) {
      return RewardType.redeemed;
    }

    final isPending = (data['isPending'] as bool?) ?? false;
    if (isPending) {
      return RewardType.pending;
    }

    return RewardType.earned;
  }

  DateTime? _parseDateTime(dynamic rawValue) {
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

  void _rebuildSummaryFromTransactions() {
    _approvedPoints = 0;
    _pendingPoints = 0;
    _redeemedPoints = 0;
    _bonusPoints = 0;

    for (final transaction in _transactions) {
      switch (transaction.type) {
        case RewardType.earned:
          _approvedPoints += transaction.points > 0 ? transaction.points : 0;
          break;
        case RewardType.pending:
          _pendingPoints += transaction.points > 0 ? transaction.points : 0;
          break;
        case RewardType.redeemed:
          _redeemedPoints += transaction.points.abs();
          break;
        case RewardType.bonus:
          _bonusPoints += transaction.points > 0 ? transaction.points : 0;
          break;
      }
    }
  }

  /// Set filter
  void setFilter(RewardFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Redeem points
  Future<bool> redeemPoints({
    required int points,
    required String redemptionType,
    String? description,
  }) async {
    if (points > availablePoints) {
      _errorMessage = 'Insufficient points';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(seconds: 1));

      // Add redemption transaction
      final transaction = RewardTransaction(
        id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        title: redemptionType,
        description: description ?? 'Points redeemed',
        points: -points,
        date: DateTime.now(),
        type: RewardType.redeemed,
      );

      _transactions.insert(0, transaction);
      _redeemedPoints += points;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to redeem points';
      notifyListeners();
      return false;
    }
  }

  /// Add earned points (called when delivery is approved)
  void addEarnedPoints({
    required int points,
    required String title,
    required String description,
    String? deliveryId,
  }) {
    final transaction = RewardTransaction(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      points: points,
      date: DateTime.now(),
      type: RewardType.earned,
      deliveryId: deliveryId,
    );

    _transactions.insert(0, transaction);
    _approvedPoints += points;
    _updateRank();
    notifyListeners();
  }

  /// Update rank based on total points
  void _updateRank() {
    final total = totalEarnedPoints;
    if (total >= 10000) {
      _currentRank = 'Platinum';
      _badgeIcon = '💎';
    } else if (total >= 5000) {
      _currentRank = 'Gold';
      _badgeIcon = '🥇';
    } else if (total >= 2000) {
      _currentRank = 'Silver';
      _badgeIcon = '🥈';
    } else {
      _currentRank = 'Bronze';
      _badgeIcon = '🥉';
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all data
  void clearData() {
    _transactions = [];
    _currentFilter = RewardFilter.all;
    _isLoading = false;
    _approvedPoints = 0;
    _pendingPoints = 0;
    _redeemedPoints = 0;
    _bonusPoints = 0;
    _currentRank = 'Bronze';
    _badgeIcon = '🥉';
    _errorMessage = null;
    notifyListeners();
  }

}

