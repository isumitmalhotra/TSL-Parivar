import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore database service for TSL Parivar
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

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
      final docRef = await ordersCollection.add({
        ...orderData,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
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
      final docRef = await deliveriesCollection.add({
        ...deliveryData,
        'status': 'scheduled',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
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

  /// Stream deliveries for a dealer
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamDealerDeliveries(String dealerId) {
    return deliveriesCollection
        .where('dealerId', isEqualTo: dealerId)
        .orderBy('scheduledDate', descending: true)
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
