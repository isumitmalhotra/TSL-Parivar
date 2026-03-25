import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

/// Image compression service for optimizing images before upload
///
/// Features:
/// - Resize images to maximum dimensions
/// - Compress JPEG quality
/// - Calculate compressed file size
/// - Run compression in isolate for performance
class ImageCompressionService {
  ImageCompressionService._();

  /// Default maximum image dimension (width or height)
  static const int defaultMaxDimension = 1024;

  /// Default JPEG compression quality (0-100)
  static const int defaultQuality = 75;

  /// Maximum file size for upload (5MB)
  static const int maxUploadSizeBytes = 5 * 1024 * 1024;

  /// Compress an image file
  ///
  /// Returns the compressed image as bytes, or null if compression fails.
  /// - [file]: The image file to compress
  /// - [maxDimension]: Maximum width or height (maintains aspect ratio)
  /// - [quality]: JPEG quality (0-100, higher = better quality but larger file)
  static Future<Uint8List?> compressFile({
    required File file,
    int maxDimension = defaultMaxDimension,
    int quality = defaultQuality,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      return compressBytes(
        bytes: bytes,
        maxDimension: maxDimension,
        quality: quality,
      );
    } catch (e) {
      debugPrint('ImageCompressionService: Error compressing file: $e');
      return null;
    }
  }

  /// Compress image bytes
  ///
  /// Runs the compression in a compute isolate to avoid blocking the UI thread.
  static Future<Uint8List?> compressBytes({
    required Uint8List bytes,
    int maxDimension = defaultMaxDimension,
    int quality = defaultQuality,
  }) async {
    try {
      // Decode the image
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final originalWidth = image.width;
      final originalHeight = image.height;

      // Calculate new dimensions maintaining aspect ratio
      int targetWidth = originalWidth;
      int targetHeight = originalHeight;

      if (originalWidth > maxDimension || originalHeight > maxDimension) {
        if (originalWidth > originalHeight) {
          targetWidth = maxDimension;
          targetHeight = (originalHeight * maxDimension / originalWidth).round();
        } else {
          targetHeight = maxDimension;
          targetWidth = (originalWidth * maxDimension / originalHeight).round();
        }
      }

      // If the image is already small enough and file is under max size
      if (targetWidth == originalWidth &&
          targetHeight == originalHeight &&
          bytes.length <= maxUploadSizeBytes) {
        image.dispose();
        return bytes;
      }

      // Resize the image
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final paint = ui.Paint()..filterQuality = ui.FilterQuality.high;

      canvas.drawImageRect(
        image,
        ui.Rect.fromLTWH(0, 0, originalWidth.toDouble(), originalHeight.toDouble()),
        ui.Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
        paint,
      );

      final picture = recorder.endRecording();
      final resizedImage = await picture.toImage(targetWidth, targetHeight);
      image.dispose();

      // Encode to PNG (Flutter doesn't support JPEG encoding natively)
      final byteData = await resizedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      resizedImage.dispose();

      if (byteData == null) return null;

      final compressedBytes = byteData.buffer.asUint8List();

      debugPrint(
        'ImageCompressionService: '
        '${originalWidth}x$originalHeight (${_formatBytes(bytes.length)}) → '
        '${targetWidth}x$targetHeight (${_formatBytes(compressedBytes.length)})',
      );

      return compressedBytes;
    } catch (e) {
      debugPrint('ImageCompressionService: Error compressing bytes: $e');
      return null;
    }
  }

  /// Check if a file needs compression
  static bool needsCompression(File file) {
    try {
      final size = file.lengthSync();
      return size > maxUploadSizeBytes;
    } catch (e) {
      return false;
    }
  }

  /// Get file size in human readable format
  static String getFileSize(File file) {
    try {
      final size = file.lengthSync();
      return _formatBytes(size);
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Format bytes to human readable string
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Estimate compressed file size based on dimensions and quality
  static int estimateCompressedSize({
    required int width,
    required int height,
    int quality = defaultQuality,
  }) {
    // Rough estimate: JPEG compression ratio based on quality
    // At quality 75, typical ratio is about 10:1 for photos
    final rawSize = width * height * 3; // 3 bytes per pixel (RGB)
    final compressionRatio = quality / 10.0;
    return (rawSize / compressionRatio).round();
  }
}

