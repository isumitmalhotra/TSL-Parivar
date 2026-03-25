import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Firebase Storage service for file uploads
class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============== Upload Operations ==============

  /// Upload a file to Firebase Storage
  static Future<String> uploadFile({
    required File file,
    required String path,
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);

      SettableMetadata? settableMetadata;
      if (metadata != null) {
        settableMetadata = SettableMetadata(customMetadata: metadata);
      }

      final uploadTask = ref.putFile(file, settableMetadata);

      // Listen to upload progress (optional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        debugPrint('📤 Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      debugPrint('✅ File uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading file: $e');
      rethrow;
    }
  }

  /// Upload bytes to Firebase Storage
  static Future<String> uploadBytes({
    required Uint8List bytes,
    required String path,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);

      SettableMetadata? settableMetadata;
      if (metadata != null || contentType != null) {
        settableMetadata = SettableMetadata(
          contentType: contentType,
          customMetadata: metadata,
        );
      }

      await ref.putData(bytes, settableMetadata);

      final downloadUrl = await ref.getDownloadURL();
      debugPrint('✅ Bytes uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading bytes: $e');
      rethrow;
    }
  }

  // ============== POD (Proof of Delivery) Uploads ==============

  /// Upload POD photo
  static Future<String> uploadPODPhoto({
    required File file,
    required String deliveryId,
    required String dealerId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'pod_photos/$dealerId/$deliveryId/$timestamp.jpg';

    return await uploadFile(
      file: file,
      path: path,
      metadata: {
        'deliveryId': deliveryId,
        'dealerId': dealerId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Upload signature image
  static Future<String> uploadSignature({
    required Uint8List signatureBytes,
    required String deliveryId,
    required String dealerId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'signatures/$dealerId/$deliveryId/$timestamp.png';

    return await uploadBytes(
      bytes: signatureBytes,
      path: path,
      contentType: 'image/png',
      metadata: {
        'deliveryId': deliveryId,
        'dealerId': dealerId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============== Profile Photo Uploads ==============

  /// Upload user profile photo
  static Future<String> uploadProfilePhoto({
    required File file,
    required String userId,
  }) async {
    final path = 'profile_photos/$userId/profile.jpg';

    return await uploadFile(
      file: file,
      path: path,
      metadata: {
        'userId': userId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============== Document Uploads ==============

  /// Upload document (for KYC, etc.)
  static Future<String> uploadDocument({
    required File file,
    required String userId,
    required String documentType,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.path.split('.').last;
    final path = 'documents/$userId/$documentType/$timestamp.$extension';

    return await uploadFile(
      file: file,
      path: path,
      metadata: {
        'userId': userId,
        'documentType': documentType,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============== Delete Operations ==============

  /// Delete a file from storage
  static Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
      debugPrint('✅ File deleted: $path');
    } catch (e) {
      debugPrint('❌ Error deleting file: $e');
      rethrow;
    }
  }

  /// Delete file by URL
  static Future<void> deleteFileByUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
      debugPrint('✅ File deleted by URL');
    } catch (e) {
      debugPrint('❌ Error deleting file by URL: $e');
      rethrow;
    }
  }

  // ============== Utility Operations ==============

  /// Get download URL for a path
  static Future<String> getDownloadUrl(String path) async {
    try {
      return await _storage.ref().child(path).getDownloadURL();
    } catch (e) {
      debugPrint('❌ Error getting download URL: $e');
      rethrow;
    }
  }

  /// List files in a directory
  static Future<List<Reference>> listFiles(String path) async {
    try {
      final result = await _storage.ref().child(path).listAll();
      return result.items;
    } catch (e) {
      debugPrint('❌ Error listing files: $e');
      rethrow;
    }
  }
}
