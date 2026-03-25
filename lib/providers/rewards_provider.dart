import 'package:flutter/foundation.dart';

import '../models/mistri_models.dart';

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

  /// Load rewards data
  Future<void> loadRewards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future<void>.delayed(const Duration(milliseconds: 800));

      // Load mock data
      _loadMockData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load rewards';
      notifyListeners();
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
    _approvedPoints = 0;
    _pendingPoints = 0;
    _redeemedPoints = 0;
    _bonusPoints = 0;
    _currentRank = 'Bronze';
    _badgeIcon = '🥉';
    _errorMessage = null;
    notifyListeners();
  }

  /// Load mock data
  void _loadMockData() {
    final now = DateTime.now();

    _approvedPoints = 2450;
    _pendingPoints = 150;
    _redeemedPoints = 500;
    _bonusPoints = 200;
    _currentRank = 'Gold';
    _badgeIcon = '🥇';

    _transactions = [
      RewardTransaction(
        id: 'TXN001',
        title: 'Delivery Completed',
        description: 'TMT Bars delivered to Mehta & Sons',
        points: 75,
        date: now.subtract(const Duration(hours: 2)),
        type: RewardType.earned,
        deliveryId: 'DEL004',
      ),
      RewardTransaction(
        id: 'TXN002',
        title: 'Pending Approval',
        description: 'Cement delivery awaiting approval',
        points: 25,
        date: now.subtract(const Duration(hours: 5)),
        type: RewardType.pending,
        deliveryId: 'DEL003',
      ),
      RewardTransaction(
        id: 'TXN003',
        title: 'Weekly Bonus',
        description: '100% delivery success this week',
        points: 50,
        date: now.subtract(const Duration(days: 1)),
        type: RewardType.bonus,
      ),
      RewardTransaction(
        id: 'TXN004',
        title: 'Points Redeemed',
        description: 'Amazon Gift Card ₹500',
        points: -500,
        date: now.subtract(const Duration(days: 2)),
        type: RewardType.redeemed,
      ),
      RewardTransaction(
        id: 'TXN005',
        title: 'Delivery Completed',
        description: 'Steel Rods delivered to Priya Builders',
        points: 35,
        date: now.subtract(const Duration(days: 3)),
        type: RewardType.earned,
        deliveryId: 'DEL002',
      ),
      RewardTransaction(
        id: 'TXN006',
        title: 'Delivery Completed',
        description: 'TMT Bars delivered to Amit Singh',
        points: 50,
        date: now.subtract(const Duration(days: 4)),
        type: RewardType.earned,
        deliveryId: 'DEL001',
      ),
      RewardTransaction(
        id: 'TXN007',
        title: 'Monthly Bonus',
        description: 'Top performer of December',
        points: 150,
        date: now.subtract(const Duration(days: 7)),
        type: RewardType.bonus,
      ),
      RewardTransaction(
        id: 'TXN008',
        title: 'Delivery Completed',
        description: 'Steel Angles delivered to Apex Builders',
        points: 40,
        date: now.subtract(const Duration(days: 10)),
        type: RewardType.earned,
      ),
    ];
  }
}

