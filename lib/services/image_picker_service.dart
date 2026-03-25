import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for picking images from camera or gallery with proper permission handling
class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  static Future<String?> pickFromCamera({int imageQuality = 85}) async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        debugPrint('❌ Camera permission denied');
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      return image?.path;
    } catch (e) {
      debugPrint('❌ Error picking from camera: $e');
      return null;
    }
  }

  /// Pick image from gallery
  static Future<String?> pickFromGallery({int imageQuality = 85}) async {
    try {
      final status = await Permission.photos.request();
      // On Android < 13, photos permission doesn't exist, so also try storage
      if (!status.isGranted && !status.isLimited) {
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          debugPrint('❌ Gallery permission denied');
          return null;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      return image?.path;
    } catch (e) {
      debugPrint('❌ Error picking from gallery: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  static Future<List<String>?> pickMultipleFromGallery({
    int imageQuality = 85,
    int? limit,
  }) async {
    try {
      final status = await Permission.photos.request();
      if (!status.isGranted && !status.isLimited) {
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          debugPrint('❌ Gallery permission denied');
          return null;
        }
      }

      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: imageQuality,
        maxWidth: 1920,
        maxHeight: 1920,
        limit: limit,
      );

      if (images.isEmpty) return null;
      return images.map((img) => img.path).toList();
    } catch (e) {
      debugPrint('❌ Error picking multiple from gallery: $e');
      return null;
    }
  }
}

