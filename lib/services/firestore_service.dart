import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore database service for TSL Parivar
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static int _addMistriTraceCounter = 0;

  // Canonical shared data-contract fields for role linkage and ownership.
  static const String fieldDealerId = 'dealerId';
  static const String fieldMistriId = 'mistriId';
  static const String fieldUserId = 'userId';
  static const String fieldStatus = 'status';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldCity = 'city';
  static const String fieldCityKey = 'cityKey';
  static const String fieldAddressLine = 'addressLine';
  static const String fieldPincode = 'pincode';
  static const String fieldGeo = 'geo';
  static const String fieldLocationUpdatedAt = 'locationUpdatedAt';

  /// Normalize Indian phone input into +91XXXXXXXXXX for stable lookups.
  static String normalizeIndianPhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final normalizedDigits = digitsOnly.length > 10
        ? digitsOnly.substring(digitsOnly.length - 10)
        : digitsOnly;
    return '+91$normalizedDigits';
  }

  static String phoneDigits(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.length > 10
        ? digitsOnly.substring(digitsOnly.length - 10)
        : digitsOnly;
  }

  static String normalizeCityKey(String city) => city.trim().toLowerCase();

  // ============== Collection References ==============

  /// Users collection
  static CollectionReference<Map<String, dynamic>> get usersCollection =>
      _db.collection('users');

  /// Dealers collection
  static CollectionReference<Map<String, dynamic>> get dealersCollection =>
      _db.collection('dealers');

  /// Mistris collection
  static CollectionReference<Map<String, dynamic>> get mistrisCollection =>
      _db.collection('mistris');

  /// Orders collection
  static CollectionReference<Map<String, dynamic>> get ordersCollection =>
      _db.collection('orders');

  /// Deliveries collection
  static CollectionReference<Map<String, dynamic>> get deliveriesCollection =>
      _db.collection('deliveries');

  /// Rewards collection
  static CollectionReference<Map<String, dynamic>> get rewardsCollection =>
      _db.collection('rewards');

  /// Products collection
  static CollectionReference<Map<String, dynamic>> get productsCollection =>
      _db.collection('products');

  /// Notifications collection
  static CollectionReference<Map<String, dynamic>> get notificationsCollection =>
      _db.collection('notifications');

  /// Chats collection
  static CollectionReference<Map<String, dynamic>> get chatsCollection =>
      _db.collection('chats');

  // ============== Generic CRUD Operations ==============

  /// Create a document
  static Future<DocumentReference<Map<String, dynamic>>> createDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      if (documentId != null) {
        await collection.doc(documentId).set({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return collection.doc(documentId);
      } else {
        return await collection.add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('❌ Error creating document: $e');
      rethrow;
    }
  }

  /// Get a single document
  static Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String documentId,
  }) async {
    try {
      return await collection.doc(documentId).get();
    } catch (e) {
      debugPrint('❌ Error getting document: $e');
      rethrow;
    }
  }

  /// Update a document
  static Future<void> updateDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await collection.doc(documentId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Error updating document: $e');
      rethrow;
    }
  }

  /// Delete a document
  static Future<void> deleteDocument({
    required CollectionReference<Map<String, dynamic>> collection,
    required String documentId,
  }) async {
    try {
      await collection.doc(documentId).delete();
    } catch (e) {
      debugPrint('❌ Error deleting document: $e');
      rethrow;
    }
  }

  /// Get documents with query
  static Future<QuerySnapshot<Map<String, dynamic>>> getDocuments({
    required CollectionReference<Map<String, dynamic>> collection,
    List<QueryFilter>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = collection;

      // Apply filters
      if (filters != null) {
        for (final filter in filters) {
          switch (filter.operator) {
            case FilterOperator.equals:
              query = query.where(filter.field, isEqualTo: filter.value);
              break;
            case FilterOperator.notEquals:
              query = query.where(filter.field, isNotEqualTo: filter.value);
              break;
            case FilterOperator.lessThan:
              query = query.where(filter.field, isLessThan: filter.value);
              break;
            case FilterOperator.lessThanOrEquals:
              query = query.where(filter.field, isLessThanOrEqualTo: filter.value);
              break;
            case FilterOperator.greaterThan:
              query = query.where(filter.field, isGreaterThan: filter.value);
              break;
            case FilterOperator.greaterThanOrEquals:
              query = query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
              break;
            case FilterOperator.arrayContains:
              query = query.where(filter.field, arrayContains: filter.value);
              break;
            case FilterOperator.whereIn:
              query = query.where(filter.field, whereIn: filter.value as List);
              break;
          }
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      debugPrint('❌ Error getting documents: $e');
      rethrow;
    }
  }

  /// Stream of documents
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamDocuments({
    required CollectionReference<Map<String, dynamic>> collection,
    List<QueryFilter>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = collection;

    // Apply filters
    if (filters != null) {
      for (final filter in filters) {
        switch (filter.operator) {
          case FilterOperator.equals:
            query = query.where(filter.field, isEqualTo: filter.value);
            break;
          case FilterOperator.notEquals:
            query = query.where(filter.field, isNotEqualTo: filter.value);
            break;
          case FilterOperator.lessThan:
            query = query.where(filter.field, isLessThan: filter.value);
            break;
          case FilterOperator.lessThanOrEquals:
            query = query.where(filter.field, isLessThanOrEqualTo: filter.value);
            break;
          case FilterOperator.greaterThan:
            query = query.where(filter.field, isGreaterThan: filter.value);
            break;
          case FilterOperator.greaterThanOrEquals:
            query = query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
            break;
          case FilterOperator.arrayContains:
            query = query.where(filter.field, arrayContains: filter.value);
            break;
          case FilterOperator.whereIn:
            query = query.where(filter.field, whereIn: filter.value as List);
            break;
        }
      }
    }

    // Apply ordering
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  // ============== User-Specific Operations ==============

  /// Create or update user profile
  static Future<void> saveUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await usersCollection.doc(uid).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('✅ User profile saved: $uid');
    } catch (e) {
      debugPrint('❌ Error saving user profile: $e');
      rethrow;
    }
  }

  /// Get user profile by UID
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await usersCollection.doc(uid).get();
      return doc.data();
    } catch (e) {
      debugPrint('❌ Error getting user profile: $e');
      rethrow;
    }
  }

  /// Get user by phone number
  static Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    try {
      final snapshot = await usersCollection
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return {
          'id': snapshot.docs.first.id,
          ...snapshot.docs.first.data(),
        };
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user by phone: $e');
      rethrow;
    }
  }

  // ============== Order Operations ==============

  /// Create a new order
  static Future<String> createOrder(Map<String, dynamic> orderData) async {
    try {
      final normalized = await _normalizeOrderData(orderData);
      if (!_hasValidLocationPayload(normalized)) {
        throw StateError('Location pin and address are required to create an order.');
      }
      final dealerId = _asNonEmptyString(normalized[fieldDealerId]);
      if (dealerId == null) {
        throw StateError('No dealer is assigned to this mistri yet.');
      }

      final docRef = await ordersCollection.add({
        ...normalized,
        fieldStatus: (normalized[fieldStatus] as String?) ?? 'newRequest',
        fieldCreatedAt: FieldValue.serverTimestamp(),
        fieldUpdatedAt: FieldValue.serverTimestamp(),
      });

      await _createNotificationSafe(
        userId: dealerId,
        type: 'order',
        title: 'New order request',
        message: '${(normalized['mistriName'] as String?) ?? 'A mistri'} requested ${(normalized['materialType'] as String?) ?? 'material'}.',
        deepLink: '/dealer/orders',
        metadata: {
          'orderId': docRef.id,
          if (normalized[fieldMistriId] is String) 'mistriId': normalized[fieldMistriId],
        },
      );

      debugPrint('✅ Order created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating order: $e');
      rethrow;
    }
  }

  /// Update order status
  static Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Order status updated: $orderId -> $status');
    } catch (e) {
      debugPrint('❌ Error updating order status: $e');
      rethrow;
    }
  }

  /// Persist dealer order decision with audit fields.
  static Future<void> recordOrderDecision({
    required String orderId,
    required String dealerId,
    required String decision,
    String? reason,
    String? notes,
  }) async {
    try {
      final orderSnapshot = await ordersCollection.doc(orderId).get();
      final orderData = orderSnapshot.data() ?? const <String, dynamic>{};

      await ordersCollection.doc(orderId).update({
        'status': decision,
        'decisionType': decision,
        'decisionBy': dealerId,
        'decisionAt': FieldValue.serverTimestamp(),
        if (reason != null && reason.isNotEmpty) 'decisionReason': reason,
        if (notes != null && notes.isNotEmpty) 'decisionNotes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final mistriUserId = _asNonEmptyString(orderData[fieldMistriId]) ??
          _asNonEmptyString(orderData[fieldUserId]);
      if (mistriUserId != null) {
        final decisionLabel = switch (decision) {
          'approved' => 'approved',
          'rejected' => 'rejected',
          'moreInfo' => 'marked for more details',
          _ => 'updated',
        };
        await _createNotificationSafe(
          userId: mistriUserId,
          type: 'order',
          title: 'Order $decisionLabel',
          message: 'Your order has been $decisionLabel by the dealer.',
          deepLink: '/mistri/orders',
          metadata: {
            'orderId': orderId,
            'decision': decision,
            if (reason != null && reason.isNotEmpty) 'reason': reason,
          },
        );
      }

      debugPrint('✅ Order decision persisted: $orderId -> $decision');
    } catch (e) {
      debugPrint('❌ Error persisting order decision: $e');
      rethrow;
    }
  }

  /// Get orders for a user
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamUserOrders(String userId) {
    return ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ============== Delivery Operations ==============

  /// Create a new delivery
  static Future<String> createDelivery(Map<String, dynamic> deliveryData) async {
    try {
      final normalized = await _normalizeDeliveryData(deliveryData);
      if (!_hasValidLocationPayload(normalized)) {
        throw StateError('Location pin and address are required to create a delivery.');
      }
      final docRef = await deliveriesCollection.add({
        ...normalized,
        fieldStatus: (normalized[fieldStatus] as String?) ?? 'scheduled',
        fieldCreatedAt: FieldValue.serverTimestamp(),
        fieldUpdatedAt: FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Delivery created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating delivery: $e');
      rethrow;
    }
  }

  /// Update delivery with POD
  static Future<void> updateDeliveryPOD({
    required String deliveryId,
    required String podImageUrl,
    required String receiverName,
    String? signature,
  }) async {
    try {
      await deliveriesCollection.doc(deliveryId).update({
        'status': 'delivered',
        'podImageUrl': podImageUrl,
        'receiverName': receiverName,
        'signature': signature,
        'deliveredAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Delivery POD updated: $deliveryId');
    } catch (e) {
      debugPrint('❌ Error updating delivery POD: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> _normalizeOrderData(
    Map<String, dynamic> orderData,
  ) async {
    final normalized = <String, dynamic>{...orderData};

    final mistriId = _asNonEmptyString(normalized[fieldMistriId]) ??
        _asNonEmptyString(normalized[fieldUserId]);
    if (mistriId != null) {
      normalized[fieldMistriId] = mistriId;
      // Legacy mirror for compatibility with existing rules/queries.
      normalized[fieldUserId] = mistriId;
    }

    var dealerId = _asNonEmptyString(normalized[fieldDealerId]);
    if ((dealerId == null || dealerId.isEmpty) &&
        mistriId != null &&
        mistriId.isNotEmpty) {
      dealerId = await resolveDealerIdForMistri(mistriId);
    }
    if (dealerId != null && dealerId.isNotEmpty) {
      normalized[fieldDealerId] = dealerId;
    }

    return normalized;
  }

  static Future<Map<String, dynamic>> _normalizeDeliveryData(
    Map<String, dynamic> deliveryData,
  ) async {
    final normalized = <String, dynamic>{...deliveryData};

    final mistriId = _asNonEmptyString(normalized[fieldMistriId]) ??
        _asNonEmptyString(normalized[fieldUserId]);
    if (mistriId != null && mistriId.isNotEmpty) {
      normalized[fieldMistriId] = mistriId;
    }

    var dealerId = _asNonEmptyString(normalized[fieldDealerId]);
    if ((dealerId == null || dealerId.isEmpty) &&
        mistriId != null &&
        mistriId.isNotEmpty) {
      dealerId = await resolveDealerIdForMistri(mistriId);
    }
    if (dealerId != null && dealerId.isNotEmpty) {
      normalized[fieldDealerId] = dealerId;
    }

    return normalized;
  }

  /// Resolve dealer linkage for a mistri from canonical and legacy fields.
  static Future<String?> resolveDealerIdForMistri(String mistriId) async {
    try {
      final mistriDoc = await mistrisCollection.doc(mistriId).get();
      final mistriData = mistriDoc.data();
      final fromMistriDoc = _asNonEmptyString(mistriData?[fieldDealerId]);
      if (fromMistriDoc != null) {
        return fromMistriDoc;
      }

      final assigned = mistriData?['assignedDealer'];
      if (assigned is Map<String, dynamic>) {
        final assignedId = _asNonEmptyString(assigned['id']);
        if (assignedId != null) {
          return assignedId;
        }
      }

      final userDoc = await usersCollection.doc(mistriId).get();
      final userData = userDoc.data();
      final fromUserDoc = _asNonEmptyString(userData?[fieldDealerId]);
      if (fromUserDoc != null) {
        return fromUserDoc;
      }

      final assignedFromUser = userData?['assignedDealer'];
      if (assignedFromUser is Map<String, dynamic>) {
        return _asNonEmptyString(assignedFromUser['id']);
      }
    } catch (e) {
      debugPrint('⚠️ Dealer resolution failed for mistri=$mistriId: $e');
    }
    return null;
  }

  static String? _asNonEmptyString(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  static bool _hasValidLocationPayload(Map<String, dynamic> data) {
    final address = _asNonEmptyString(data['location']) ??
        _asNonEmptyString(data['customerAddress']) ??
        _asNonEmptyString(data[fieldAddressLine]);

    final latRaw = data['locationLat'] ?? data['assignedLat'] ?? data['latitude'];
    final lngRaw = data['locationLng'] ?? data['assignedLng'] ?? data['longitude'];
    final lat = latRaw is num ? latRaw.toDouble() : double.tryParse('$latRaw');
    final lng = lngRaw is num ? lngRaw.toDouble() : double.tryParse('$lngRaw');

    if (address == null || lat == null || lng == null) {
      return false;
    }

    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  /// Persist dealer POD review decision with audit fields.
  static Future<void> recordPodDecision({
    required String deliveryId,
    required String dealerId,
    required String decision,
    String? reason,
    String? notes,
    String? mistriId,
    int? approvedPoints,
  }) async {
    try {
      final status = switch (decision) {
        'approved' => 'completed',
        'rejected' => 'rejected',
        _ => 'pendingApproval',
      };

      await deliveriesCollection.doc(deliveryId).update({
        'status': status,
        'podReviewStatus': decision,
        'podDecisionBy': dealerId,
        'podDecisionAt': FieldValue.serverTimestamp(),
        if (reason != null && reason.isNotEmpty) 'podDecisionReason': reason,
        if (notes != null && notes.isNotEmpty) 'podDecisionNotes': notes,
        if (mistriId != null && mistriId.isNotEmpty) 'mistriId': mistriId,
        if (approvedPoints != null) 'approvedPoints': approvedPoints,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ POD decision persisted: $deliveryId -> $decision');
    } catch (e) {
      debugPrint('❌ Error persisting POD decision: $e');
      rethrow;
    }
  }

  /// Stream deliveries for a dealer
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamDealerDeliveries(String dealerId) {
    return deliveriesCollection
        .where('dealerId', isEqualTo: dealerId)
        .orderBy('scheduledDate', descending: true)
        .snapshots();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamDealerProfile(String dealerId) {
    return dealersCollection.doc(dealerId).snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamDealerMistris(String dealerId) {
    return mistrisCollection
        .where('dealerId', isEqualTo: dealerId)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamNearbyMistrisByDealerCity(
    String dealerId, {
    int limit = 40,
  }) async* {
    final cityKey = await _resolveDealerCityKey(dealerId);
    if (cityKey == null || cityKey.isEmpty) {
      yield* const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
      return;
    }

    yield* mistrisCollection
        .where(fieldCityKey, isEqualTo: cityKey)
        .where('isActive', isEqualTo: true)
        .limit(limit)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamDealerOrders(String dealerId) {
    return ordersCollection
        .where('dealerId', isEqualTo: dealerId)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamDealerPendingPodSubmissions(String dealerId) {
    return deliveriesCollection
        .where('dealerId', isEqualTo: dealerId)
        .where('status', whereIn: ['pendingApproval', 'needsInfo'])
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamDealerRewardTransactions(String dealerId) {
    return rewardsCollection
        .where('userId', isEqualTo: dealerId)
        .snapshots();
  }

  // ============== Rewards Operations ==============

  /// Get user rewards
  static Future<Map<String, dynamic>?> getUserRewards(String userId) async {
    try {
      final doc = await rewardsCollection.doc(userId).get();
      return doc.data();
    } catch (e) {
      debugPrint('❌ Error getting user rewards: $e');
      rethrow;
    }
  }

  /// Add reward points
  static Future<void> addRewardPoints({
    required String userId,
    required int points,
    required String reason,
  }) async {
    try {
      await rewardsCollection.doc(userId).set({
        'points': FieldValue.increment(points),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Add to reward history
      await rewardsCollection.doc(userId).collection('history').add({
        'points': points,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Reward points added: $userId +$points');
    } catch (e) {
      debugPrint('❌ Error adding reward points: $e');
      rethrow;
    }
  }

  /// Stream user reward points
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserRewards(String userId) {
    return rewardsCollection.doc(userId).snapshots();
  }

  // ============== Chat Operations ==============

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamUserChats(String userId) {
    return chatsCollection
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamChatMessages(String chatId) {
    return chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  static Future<String> createOrGetDirectChat({
    required String userId,
    required String userName,
    required String userRole,
    required String otherUserId,
    required String otherUserName,
    required String otherUserRole,
  }) async {
    final sortedIds = [userId, otherUserId]..sort();
    final chatId = sortedIds.join('_');

    final chatDoc = await chatsCollection.doc(chatId).get();
    if (!chatDoc.exists) {
      await chatsCollection.doc(chatId).set({
        'participantIds': sortedIds,
        'participantDetails': {
          userId: {'name': userName, 'role': userRole},
          otherUserId: {'name': otherUserName, 'role': otherUserRole},
        },
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  static Future<void> sendChatMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String content,
    String type = 'text',
  }) async {
    final chatRef = chatsCollection.doc(chatId);

    await chatRef.collection('messages').add({
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'type': type,
      'content': content,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await chatRef.update({
      'lastMessage': content,
      'lastMessageBy': senderId,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Create or attach a mistri to a dealer by phone, idempotently.
  static Future<DealerMistriLinkResult> addOrLinkMistriToDealer({
    required String dealerId,
    required String name,
    required String phone,
    required String specialization,
  }) async {
    try {
      final traceId = 'adm_${DateTime.now().millisecondsSinceEpoch}_${_addMistriTraceCounter++}';
      final normalizedPhone = normalizeIndianPhone(phone);
      final normalizedPhoneDigits = phoneDigits(phone);
      final normalizedName = name.trim().isEmpty ? 'Mistri' : name.trim();
      final normalizedSpecialization = specialization.trim().isEmpty
          ? 'General'
          : specialization.trim();

      debugPrint(
        '🧪[ADD_MISTRI:$traceId] start dealerId=$dealerId phone=$normalizedPhone digits=$normalizedPhoneDigits',
      );

      final existingMistriByPhone = await _findMistriByPhone(
        normalizedPhone: normalizedPhone,
        normalizedPhoneDigits: normalizedPhoneDigits,
      );

      String? existingUserId;
      try {
        final userData = await getUserByPhone(normalizedPhone);
        existingUserId = _asNonEmptyString(userData?['id']);
      } catch (e) {
        // Dealers may not be able to query users directly per security rules.
        debugPrint('⚠️[ADD_MISTRI:$traceId] user lookup by phone skipped: $e');
      }

      final uidLinkedDoc = existingUserId == null
          ? null
          : await mistrisCollection.doc(existingUserId).get();
      final uidLinkedData = uidLinkedDoc?.data();
      final phoneLinkedData = existingMistriByPhone?.data();

      // Canonical identity preference:
      // 1) uid-linked mistri doc, 2) phone-linked doc, 3) deterministic invite id.
      final resolvedMistriId = (uidLinkedDoc?.exists == true)
          ? existingUserId!
          : existingMistriByPhone?.id ??
              existingUserId ??
              'mistri_$normalizedPhoneDigits';
      final mistriRef = mistrisCollection.doc(resolvedMistriId);

      final currentSnapshot = (uidLinkedDoc?.exists == true)
          ? uidLinkedDoc!
          : existingMistriByPhone ?? await mistriRef.get();
      final currentData = currentSnapshot.data();

      final previousDealerId = _asNonEmptyString(currentData?[fieldDealerId]);
      final persistedUserId =
          _asNonEmptyString(currentData?[fieldUserId]) ??
          _asNonEmptyString(uidLinkedData?[fieldUserId]) ??
          _asNonEmptyString(phoneLinkedData?[fieldUserId]) ??
          existingUserId;
      final isPendingInvite = persistedUserId == null;
      final locationContract = persistedUserId == null
          ? const <String, dynamic>{}
          : await _loadUserLocationContract(persistedUserId);

      debugPrint(
        '🧪[ADD_MISTRI:$traceId] resolve mistriId=$resolvedMistriId existingUserId=$existingUserId hasUidDoc=${uidLinkedDoc?.exists == true} hasPhoneDoc=${existingMistriByPhone != null}',
      );

      await mistriRef.set({
        'name': normalizedName,
        'phone': normalizedPhone,
        'phoneDigits': normalizedPhoneDigits,
        'specialization': normalizedSpecialization,
        fieldDealerId: dealerId,
        fieldMistriId: resolvedMistriId,
        fieldUserId: persistedUserId,
        fieldStatus: (currentData?[fieldStatus] as String?) ?? (isPendingInvite ? 'pending' : 'active'),
        'isActive': (currentData?['isActive'] as bool?) ?? !isPendingInvite,
        ...locationContract,
        if (currentData == null || currentData[fieldCreatedAt] == null)
          fieldCreatedAt: FieldValue.serverTimestamp(),
        fieldUpdatedAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (persistedUserId != null && persistedUserId.isNotEmpty) {
        final dealerName = await _resolveDealerName(dealerId);
        await _createNotificationSafe(
          userId: persistedUserId,
          type: 'approval',
          title: 'Dealer linked your profile',
          message: '$dealerName added you as a mistri.',
          deepLink: '/mistri/home',
          metadata: {
            fieldDealerId: dealerId,
            fieldMistriId: resolvedMistriId,
          },
        );
      }

      debugPrint(
        '✅[ADD_MISTRI:$traceId] success mistriId=$resolvedMistriId pendingInvite=$isPendingInvite reassigned=${previousDealerId != null && previousDealerId != dealerId}',
      );

      return DealerMistriLinkResult(
        mistriId: resolvedMistriId,
        normalizedPhone: normalizedPhone,
        name: normalizedName,
        specialization: normalizedSpecialization,
        wasExisting: currentData != null,
        isPendingInvite: isPendingInvite,
        wasReassignedFromAnotherDealer:
            previousDealerId != null && previousDealerId != dealerId,
      );
    } catch (e) {
      debugPrint('❌[ADD_MISTRI] Error adding/linking mistri: $e');
      rethrow;
    }
  }

  static Future<DealerMistriLinkResult> attachNearbyMistriToDealer({
    required String dealerId,
    required String mistriId,
  }) async {
    final snapshot = await mistrisCollection.doc(mistriId).get();
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Mistri profile not found.');
    }

    final phone = _asNonEmptyString(data['phone']);
    if (phone == null) {
      throw StateError('Mistri phone number is missing.');
    }

    final name = _asNonEmptyString(data['name']) ?? 'Mistri';
    final specialization = _asNonEmptyString(data['specialization']) ?? 'General';

    return addOrLinkMistriToDealer(
      dealerId: dealerId,
      name: name,
      phone: phone,
      specialization: specialization,
    );
  }

  static Future<String?> _resolveDealerCityKey(String dealerId) async {
    try {
      final userDoc = await usersCollection.doc(dealerId).get();
      final userData = userDoc.data();
      final fromUserKey = _asNonEmptyString(userData?[fieldCityKey]);
      if (fromUserKey != null) return fromUserKey;

      final fromUserCity = _asNonEmptyString(userData?[fieldCity]);
      if (fromUserCity != null) return normalizeCityKey(fromUserCity);

      final dealerDoc = await dealersCollection.doc(dealerId).get();
      final dealerData = dealerDoc.data();
      final fromDealerKey = _asNonEmptyString(dealerData?[fieldCityKey]);
      if (fromDealerKey != null) return fromDealerKey;

      final fromDealerCity = _asNonEmptyString(dealerData?[fieldCity]);
      if (fromDealerCity != null) return normalizeCityKey(fromDealerCity);
    } catch (e) {
      debugPrint('⚠️ Failed to resolve dealer cityKey for nearby discovery: $e');
    }

    return null;
  }

  static Future<Map<String, dynamic>> _loadUserLocationContract(String userId) async {
    try {
      final userDoc = await usersCollection.doc(userId).get();
      final data = userDoc.data();
      if (data == null) return const <String, dynamic>{};

      final contract = <String, dynamic>{};
      for (final key in [
        fieldCity,
        fieldCityKey,
        fieldAddressLine,
        fieldPincode,
        fieldGeo,
        fieldLocationUpdatedAt,
      ]) {
        if (data.containsKey(key) && data[key] != null) {
          contract[key] = data[key];
        }
      }
      if (data['location'] is String && (data['location'] as String).trim().isNotEmpty) {
        contract['location'] = data['location'];
      }
      if (data['address'] is String && (data['address'] as String).trim().isNotEmpty) {
        contract['address'] = data['address'];
      }
      return contract;
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> _findMistriByPhone({
    required String normalizedPhone,
    required String normalizedPhoneDigits,
  }) async {
    final byPhone = await mistrisCollection
        .where('phone', isEqualTo: normalizedPhone)
        .limit(1)
        .get();
    if (byPhone.docs.isNotEmpty) {
      return byPhone.docs.first;
    }

    final byDigits = await mistrisCollection
        .where('phoneDigits', isEqualTo: normalizedPhoneDigits)
        .limit(1)
        .get();
    if (byDigits.docs.isNotEmpty) {
      return byDigits.docs.first;
    }

    return null;
  }

  /// Public phone lookup used by mistri-side hydration fallback.
  static Future<DocumentSnapshot<Map<String, dynamic>>?> findMistriByPhone(
    String phone,
  ) async {
    final normalizedPhone = normalizeIndianPhone(phone);
    final normalizedPhoneDigits = phoneDigits(phone);
    return _findMistriByPhone(
      normalizedPhone: normalizedPhone,
      normalizedPhoneDigits: normalizedPhoneDigits,
    );
  }

  /// Ensure the signed-in mistri has a uid-keyed doc, backfilling from phone link.
  static Future<void> ensureMistriProfileForUser({
    required String userId,
    required String phone,
    String? name,
  }) async {
    final uidDoc = await mistrisCollection.doc(userId).get();
    if (uidDoc.exists) {
      return;
    }

    final linkedDoc = await findMistriByPhone(phone);
    final linkedData = linkedDoc?.data();
    if (linkedData == null) {
      return;
    }

    final dealerId = _asNonEmptyString(linkedData[fieldDealerId]);
    Map<String, dynamic>? assignedDealer;
    if (dealerId != null) {
      final dealerSnapshot = await dealersCollection.doc(dealerId).get();
      final dealerData = dealerSnapshot.data();
      if (dealerData != null) {
        assignedDealer = {
          'id': dealerId,
          'name': (dealerData['name'] as String?) ?? 'Dealer',
          'shopName': (dealerData['shopName'] as String?) ?? 'Shop',
          'phone': (dealerData['phone'] as String?) ?? '',
          'address': (dealerData['address'] as String?) ?? '',
          if (dealerData['imageUrl'] is String) 'imageUrl': dealerData['imageUrl'],
          'rating': ((dealerData['rating'] as num?) ?? 0).toDouble(),
          'totalDeliveries': (dealerData['totalDeliveries'] as int?) ?? 0,
        };
      }
    }

    await mistrisCollection.doc(userId).set({
      'name': (name?.trim().isNotEmpty ?? false)
          ? name!.trim()
          : (linkedData['name'] as String?) ?? 'Mistri',
      'phone': normalizeIndianPhone(phone),
      'phoneDigits': phoneDigits(phone),
      'specialization': (linkedData['specialization'] as String?) ?? 'General',
      fieldMistriId: userId,
      fieldUserId: userId,
      if (dealerId != null) fieldDealerId: dealerId,
      if (assignedDealer != null) 'assignedDealer': assignedDealer,
      fieldStatus: 'active',
      'isActive': true,
      fieldCreatedAt: FieldValue.serverTimestamp(),
      fieldUpdatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (dealerId != null) {
      final dealerName = await _resolveDealerName(dealerId);
      await _createNotificationSafe(
        userId: userId,
        type: 'approval',
        title: 'Dealer assignment active',
        message: 'You are linked with $dealerName.',
        deepLink: '/mistri/home',
        metadata: {
          fieldDealerId: dealerId,
          fieldMistriId: userId,
        },
      );
    }
  }

  static Future<String> _resolveDealerName(String dealerId) async {
    try {
      final snapshot = await dealersCollection.doc(dealerId).get();
      final data = snapshot.data();
      if (data == null) {
        return 'Your dealer';
      }
      return _asNonEmptyString(data['shopName']) ??
          _asNonEmptyString(data['name']) ??
          'Your dealer';
    } catch (_) {
      return 'Your dealer';
    }
  }

  static Future<void> _createNotificationSafe({
    required String userId,
    required String type,
    required String title,
    required String message,
    String? deepLink,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await notificationsCollection.add({
        'userId': userId,
        'type': type,
        'title': title,
        'message': message,
        'isRead': false,
        if (deepLink != null && deepLink.isNotEmpty) 'deepLink': deepLink,
        if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
        'timestamp': FieldValue.serverTimestamp(),
        fieldCreatedAt: FieldValue.serverTimestamp(),
        fieldUpdatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('⚠️ Notification create skipped: $e');
    }
  }
}

class DealerMistriLinkResult {
  final String mistriId;
  final String normalizedPhone;
  final String name;
  final String specialization;
  final bool wasExisting;
  final bool isPendingInvite;
  final bool wasReassignedFromAnotherDealer;

  const DealerMistriLinkResult({
    required this.mistriId,
    required this.normalizedPhone,
    required this.name,
    required this.specialization,
    required this.wasExisting,
    required this.isPendingInvite,
    required this.wasReassignedFromAnotherDealer,
  });
}

/// Filter operator enum for queries
enum FilterOperator {
  equals,
  notEquals,
  lessThan,
  lessThanOrEquals,
  greaterThan,
  greaterThanOrEquals,
  arrayContains,
  whereIn,
}

/// Query filter class
class QueryFilter {
  final String field;
  final FilterOperator operator;
  final dynamic value;

  QueryFilter({
    required this.field,
    required this.operator,
    required this.value,
  });
}
