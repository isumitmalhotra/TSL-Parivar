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
  String? _currentUserId;

  // Getters
  List<DeliveryModel> get deliveries => _filteredDeliveries;
  List<DeliveryModel> get allDeliveries => _deliveries;
  DeliveryModel? get selectedDelivery => _selectedDelivery;
  DeliveryFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get filtered deliveries based on current filter and search
  List<DeliveryModel> get _filteredDeliveries {
    var filtered = _deliveries;

    // Apply status filter
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

    // Apply search
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

  /// Get deliveries grouped by status
  Map<DeliveryStatus, List<DeliveryModel>> get deliveriesByStatus {
    final grouped = <DeliveryStatus, List<DeliveryModel>>{};
    for (final status in DeliveryStatus.values) {
      grouped[status] = _deliveries.where((d) => d.status == status).toList();
    }
    return grouped;
  }

  /// Get count by status
  int getCountByStatus(DeliveryStatus status) {
    return _deliveries.where((d) => d.status == status).length;
  }

  /// Get active deliveries (assigned + in progress)
  List<DeliveryModel> get activeDeliveries {
    return _deliveries.where((d) =>
        d.status == DeliveryStatus.assigned ||
        d.status == DeliveryStatus.inProgress).toList();
  }

  /// Load deliveries - from Firestore with fallback to mock data
  Future<void> loadDeliveries({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    _currentUserId = userId;
    notifyListeners();

    try {
      // Try to load from Firestore first
      final deliveriesSnapshot = await FirestoreService.deliveriesCollection
          .where('mistriId', isEqualTo: userId)
          .orderBy('expectedDate', descending: false)
          .get();

      if (deliveriesSnapshot.docs.isNotEmpty) {
        _deliveries = deliveriesSnapshot.docs.map((doc) {
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
            expectedDate: data['expectedDate'] != null
                ? DateTime.tryParse(data['expectedDate'] as String) ?? DateTime.now()
                : DateTime.now(),
            deliveredDate: data['deliveredDate'] != null
                ? DateTime.tryParse(data['deliveredDate'] as String)
                : null,
            status: _parseDeliveryStatus(data['status'] as String?),
            urgency: _parseUrgencyLevel(data['urgency'] as String?),
            rewardPoints: (data['rewardPoints'] as int?) ?? 0,
            notes: data['notes'] as String?,
          );
        }).toList();
        debugPrint('✅ Loaded ${_deliveries.length} deliveries from Firestore');
      } else {
        // Fall back to mock data for demo
        debugPrint('⚠️ No deliveries in Firestore, using mock data');
        _deliveries = _getMockDeliveries();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading deliveries: $e');
      // Fall back to mock data on error
      _deliveries = _getMockDeliveries();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Parse delivery status from string
  DeliveryStatus _parseDeliveryStatus(String? status) {
    switch (status) {
      case 'assigned':
        return DeliveryStatus.assigned;
      case 'inProgress':
        return DeliveryStatus.inProgress;
      case 'pendingApproval':
        return DeliveryStatus.pendingApproval;
      case 'completed':
        return DeliveryStatus.completed;
      default:
        return DeliveryStatus.assigned;
    }
  }

  /// Parse urgency level from string
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

  /// Set filter
  void setFilter(DeliveryFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Select a delivery
  void selectDelivery(DeliveryModel delivery) {
    _selectedDelivery = delivery;
    notifyListeners();
  }

  /// Clear selected delivery
  void clearSelectedDelivery() {
    _selectedDelivery = null;
    notifyListeners();
  }

  /// Start delivery
  Future<bool> startDelivery(String deliveryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));

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
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to start delivery';
      notifyListeners();
      return false;
    }
  }

  /// Submit proof of delivery
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
      await Future<void>.delayed(const Duration(seconds: 1));

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
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to submit POD';
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all data
  void clearData() {
    _deliveries = [];
    _selectedDelivery = null;
    _currentFilter = DeliveryFilter.all;
    _searchQuery = '';
    _errorMessage = null;
    notifyListeners();
  }

  /// Mock delivery data
  List<DeliveryModel> _getMockDeliveries() {
    final now = DateTime.now();
    return [
      DeliveryModel(
        id: 'DEL001',
        productName: 'TMT Steel Bars',
        productType: 'TMT Bars',
        quantity: 2.5,
        unit: 'Tonnes',
        customerName: 'Amit Singh',
        customerPhone: '+91 98765 11111',
        customerAddress: 'Plot 45, Industrial Area, Phase 2, Pune',
        latitude: 18.5204,
        longitude: 73.8567,
        distance: 5.2,
        expectedDate: now.add(const Duration(hours: 4)),
        status: DeliveryStatus.assigned,
        urgency: UrgencyLevel.urgent,
        rewardPoints: 50,
      ),
      DeliveryModel(
        id: 'DEL002',
        productName: 'Steel Rods 12mm',
        productType: 'Rods',
        quantity: 500,
        unit: 'Pieces',
        customerName: 'Priya Builders',
        customerPhone: '+91 98765 22222',
        customerAddress: 'Site 12, Wakad, Pune',
        latitude: 18.5914,
        longitude: 73.7680,
        distance: 8.5,
        expectedDate: now.add(const Duration(hours: 6)),
        status: DeliveryStatus.inProgress,
        urgency: UrgencyLevel.normal,
        rewardPoints: 35,
      ),
      DeliveryModel(
        id: 'DEL003',
        productName: 'Cement Bags',
        productType: 'Cement',
        quantity: 100,
        unit: 'Bags',
        customerName: 'Raj Construction',
        customerPhone: '+91 98765 33333',
        customerAddress: 'Lane 5, Kothrud, Pune',
        latitude: 18.5074,
        longitude: 73.8077,
        distance: 3.2,
        expectedDate: now.subtract(const Duration(hours: 2)),
        deliveredDate: now.subtract(const Duration(hours: 1)),
        status: DeliveryStatus.pendingApproval,
        urgency: UrgencyLevel.normal,
        rewardPoints: 25,
      ),
      DeliveryModel(
        id: 'DEL004',
        productName: 'TMT Steel Bars',
        productType: 'TMT Bars',
        quantity: 5.0,
        unit: 'Tonnes',
        customerName: 'Mehta & Sons',
        customerPhone: '+91 98765 44444',
        customerAddress: 'MIDC, Hinjewadi, Pune',
        latitude: 18.5793,
        longitude: 73.7378,
        distance: 12.0,
        expectedDate: now.subtract(const Duration(days: 1)),
        deliveredDate: now.subtract(const Duration(days: 1)),
        status: DeliveryStatus.completed,
        urgency: UrgencyLevel.normal,
        rewardPoints: 75,
      ),
      DeliveryModel(
        id: 'DEL005',
        productName: 'Steel Angles',
        productType: 'Angles',
        quantity: 200,
        unit: 'Pieces',
        customerName: 'Apex Builders',
        customerPhone: '+91 98765 55555',
        customerAddress: 'Baner Road, Pune',
        latitude: 18.5590,
        longitude: 73.7868,
        distance: 6.8,
        expectedDate: now.add(const Duration(days: 1)),
        status: DeliveryStatus.assigned,
        urgency: UrgencyLevel.asap,
        rewardPoints: 40,
      ),
    ];
  }
}

