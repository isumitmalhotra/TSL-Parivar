import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/mistri_models.dart';
import '../services/firestore_service.dart';

/// Delivery filter options
enum DeliveryFilter {
  all,
  assigned,
  inProgress,
  pendingApproval,
  completed,
}

/// Provider for managing delivery data
class DeliveryProvider extends ChangeNotifier {
  List<DeliveryModel> _deliveries = [];
  DeliveryModel? _selectedDelivery;
  DeliveryFilter _currentFilter = DeliveryFilter.all;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<DeliveryModel> get deliveries => _filteredDeliveries;
  List<DeliveryModel> get allDeliveries => _deliveries;
  DeliveryModel? get selectedDelivery => _selectedDelivery;
  DeliveryFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<DeliveryModel> get _filteredDeliveries {
    var filtered = _deliveries;

    if (_currentFilter != DeliveryFilter.all) {
      filtered = filtered.where((d) {
        switch (_currentFilter) {
          case DeliveryFilter.assigned:
            return d.status == DeliveryStatus.assigned;
          case DeliveryFilter.inProgress:
            return d.status == DeliveryStatus.inProgress;
          case DeliveryFilter.pendingApproval:
            return d.status == DeliveryStatus.pendingApproval;
          case DeliveryFilter.completed:
            return d.status == DeliveryStatus.completed;
          case DeliveryFilter.all:
            return true;
        }
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((d) {
        return d.customerName.toLowerCase().contains(query) ||
            d.productName.toLowerCase().contains(query) ||
            d.customerAddress.toLowerCase().contains(query) ||
            d.id.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Map<DeliveryStatus, List<DeliveryModel>> get deliveriesByStatus {
    final grouped = <DeliveryStatus, List<DeliveryModel>>{};
    for (final status in DeliveryStatus.values) {
      grouped[status] = _deliveries.where((d) => d.status == status).toList();
    }
    return grouped;
  }

  int getCountByStatus(DeliveryStatus status) {
    return _deliveries.where((d) => d.status == status).length;
  }

  List<DeliveryModel> get activeDeliveries {
    return _deliveries
        .where((d) =>
            d.status == DeliveryStatus.assigned ||
            d.status == DeliveryStatus.inProgress)
        .toList();
  }

  /// Load deliveries from Firestore for the authenticated mistri.
  Future<void> loadDeliveries({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (userId == null || userId.isEmpty) {
        _deliveries = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final canonicalSnapshot = await FirestoreService.deliveriesCollection
          .where('mistriId', isEqualTo: userId)
          .get();
      final legacySnapshot = await FirestoreService.deliveriesCollection
          .where('userId', isEqualTo: userId)
          .get();

      final uniqueDocs = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{
        for (final doc in canonicalSnapshot.docs) doc.id: doc,
        for (final doc in legacySnapshot.docs) doc.id: doc,
      };

      _deliveries = uniqueDocs.values.map((doc) {
        final data = doc.data();
        return DeliveryModel(
          id: doc.id,
          productName: (data['productName'] as String?) ?? '',
          productType: (data['productType'] as String?) ?? '',
          quantity: ((data['quantity'] as num?) ?? 0).toDouble(),
          unit: (data['unit'] as String?) ?? '',
          customerName: (data['customerName'] as String?) ?? '',
          customerPhone: (data['customerPhone'] as String?) ?? '',
          customerAddress: (data['customerAddress'] as String?) ?? '',
          latitude: ((data['latitude'] as num?) ?? 0).toDouble(),
          longitude: ((data['longitude'] as num?) ?? 0).toDouble(),
          distance: ((data['distance'] as num?) ?? 0).toDouble(),
          expectedDate: _parseDateTime(data['expectedDate']) ?? DateTime.now(),
          deliveredDate:
              _parseDateTime(data['deliveredDate'] ?? data['deliveredAt']),
          status: _parseDeliveryStatus(data['status'] as String?),
          urgency: _parseUrgencyLevel(data['urgency'] as String?),
          rewardPoints: (data['rewardPoints'] as int?) ?? 0,
          notes: data['notes'] as String?,
        );
      }).toList();

      _deliveries.sort((a, b) => a.expectedDate.compareTo(b.expectedDate));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading deliveries: $e');
      _deliveries = [];
      _errorMessage = 'Failed to load deliveries';
      _isLoading = false;
      notifyListeners();
    }
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

  DeliveryStatus _parseDeliveryStatus(String? status) {
    switch (status) {
      case 'assigned':
        return DeliveryStatus.assigned;
      case 'in_progress':
      case 'inProgress':
        return DeliveryStatus.inProgress;
      case 'pending':
      case 'pendingApproval':
        return DeliveryStatus.pendingApproval;
      case 'scheduled':
        return DeliveryStatus.assigned;
      case 'delivered':
      case 'completed':
        return DeliveryStatus.completed;
      case 'rejected':
        return DeliveryStatus.rejected;
      default:
        return DeliveryStatus.assigned;
    }
  }

  UrgencyLevel _parseUrgencyLevel(String? urgency) {
    switch (urgency) {
      case 'asap':
        return UrgencyLevel.asap;
      case 'urgent':
        return UrgencyLevel.urgent;
      case 'normal':
        return UrgencyLevel.normal;
      default:
        return UrgencyLevel.normal;
    }
  }

  void setFilter(DeliveryFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectDelivery(DeliveryModel delivery) {
    _selectedDelivery = delivery;
    notifyListeners();
  }

  void clearSelectedDelivery() {
    _selectedDelivery = null;
    notifyListeners();
  }

  Future<bool> startDelivery(String deliveryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _deliveries.indexWhere((d) => d.id == deliveryId);
      if (index != -1) {
        final delivery = _deliveries[index];
        _deliveries[index] = DeliveryModel(
          id: delivery.id,
          productName: delivery.productName,
          productType: delivery.productType,
          quantity: delivery.quantity,
          unit: delivery.unit,
          customerName: delivery.customerName,
          customerPhone: delivery.customerPhone,
          customerAddress: delivery.customerAddress,
          latitude: delivery.latitude,
          longitude: delivery.longitude,
          distance: delivery.distance,
          expectedDate: delivery.expectedDate,
          deliveredDate: delivery.deliveredDate,
          status: DeliveryStatus.inProgress,
          urgency: delivery.urgency,
          rewardPoints: delivery.rewardPoints,
          notes: delivery.notes,
        );

        if (_selectedDelivery?.id == deliveryId) {
          _selectedDelivery = _deliveries[index];
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Failed to start delivery';
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitPod({
    required String deliveryId,
    required double deliveredQuantity,
    required List<String> photoUrls,
    required double latitude,
    required double longitude,
    String? issueReported,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _deliveries.indexWhere((d) => d.id == deliveryId);
      if (index != -1) {
        final delivery = _deliveries[index];
        _deliveries[index] = DeliveryModel(
          id: delivery.id,
          productName: delivery.productName,
          productType: delivery.productType,
          quantity: delivery.quantity,
          unit: delivery.unit,
          customerName: delivery.customerName,
          customerPhone: delivery.customerPhone,
          customerAddress: delivery.customerAddress,
          latitude: delivery.latitude,
          longitude: delivery.longitude,
          distance: delivery.distance,
          expectedDate: delivery.expectedDate,
          deliveredDate: DateTime.now(),
          status: DeliveryStatus.pendingApproval,
          urgency: delivery.urgency,
          rewardPoints: delivery.rewardPoints,
          notes: notes ?? delivery.notes,
        );

        if (_selectedDelivery?.id == deliveryId) {
          _selectedDelivery = _deliveries[index];
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Failed to submit POD';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearData() {
    _deliveries = [];
    _selectedDelivery = null;
    _currentFilter = DeliveryFilter.all;
    _searchQuery = '';
    _errorMessage = null;
    notifyListeners();
  }
}
