import 'dart:io';

import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import 'tsl_primary_button.dart';
import 'tsl_secondary_button.dart';

/// Photo capture interface for TSL Parivar app
///
/// Features:
/// - Camera capture
/// - Gallery selection
/// - Multiple photos support
/// - Auto geo-tagging
/// - Image preview
/// - Delete functionality
class TslPhotoCapture extends StatelessWidget {
  /// List of captured photo paths
  final List<String> photos;

  /// Callback when photos change
  final ValueChanged<List<String>>? onPhotosChanged;

  /// Callback to capture photo from camera
  final Future<String?> Function()? onCapturePhoto;

  /// Callback to pick photo from gallery
  final Future<String?> Function()? onPickFromGallery;

  /// Callback to pick multiple photos from gallery
  final Future<List<String>?> Function()? onPickMultipleFromGallery;

  /// Field label
  final String? label;

  /// Helper text below the field
  final String? helperText;

  /// Error text (shows error state when not null)
  final String? errorText;

  /// Minimum required photos
  final int minPhotos;

  /// Maximum allowed photos
  final int maxPhotos;

  /// Whether field is required
  final bool isRequired;

  /// Whether field is enabled
  final bool isEnabled;

  /// Whether to show geo-tag indicator
  final bool showGeoTag;

  /// Geo coordinates for captured photos
  final Map<String, String>? geoCoordinates;

  const TslPhotoCapture({
    super.key,
    this.photos = const [],
    this.onPhotosChanged,
    this.onCapturePhoto,
    this.onPickFromGallery,
    this.onPickMultipleFromGallery,
    this.label,
    this.helperText,
    this.errorText,
    this.minPhotos = 0,
    this.maxPhotos = 10,
    this.isRequired = false,
    this.isEnabled = true,
    this.showGeoTag = false,
    this.geoCoordinates,
  });

  /// Factory for POD (Proof of Delivery) photo capture
  factory TslPhotoCapture.pod({
    List<String> photos = const [],
    ValueChanged<List<String>>? onPhotosChanged,
    Future<String?> Function()? onCapturePhoto,
    String? errorText,
    Map<String, String>? geoCoordinates,
  }) {
    return TslPhotoCapture(
      photos: photos,
      onPhotosChanged: onPhotosChanged,
      onCapturePhoto: onCapturePhoto,
      label: 'Delivery Photos',
      helperText: 'Minimum 2 photos required for proof of delivery',
      errorText: errorText,
      minPhotos: 2,
      maxPhotos: 5,
      isRequired: true,
      showGeoTag: true,
      geoCoordinates: geoCoordinates,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final canAddMore = photos.length < maxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          _buildLabel(),
          const SizedBox(height: AppSpacing.sm),
        ],
        // Photo grid
        if (photos.isNotEmpty) ...[
          _buildPhotoGrid(context),
          const SizedBox(height: AppSpacing.md),
        ],
        // Add photo buttons
        if (canAddMore && isEnabled) _buildAddButtons(context),
        // Progress indicator
        if (minPhotos > 0) ...[
          const SizedBox(height: AppSpacing.md),
          _buildProgressIndicator(),
        ],
        // Error or helper text
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: AppTypography.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ] else if (helperText != null && !hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            helperText!,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Text(
          label!,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '*',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
        const Spacer(),
        Text(
          '${photos.length}/$maxPhotos',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return _PhotoThumbnail(
          photoPath: photos[index],
          onDelete: isEnabled
              ? () {
                  final newPhotos = List<String>.from(photos)
                    ..removeAt(index);
                  onPhotosChanged?.call(newPhotos);
                }
              : null,
          onTap: () => _showPhotoPreview(context, index),
          geoCoordinate: showGeoTag && geoCoordinates != null
              ? geoCoordinates![photos[index]]
              : null,
        );
      },
    );
  }

  Widget _buildAddButtons(BuildContext context) {
    final hasCamera = onCapturePhoto != null;
    final hasGallery = onPickFromGallery != null || onPickMultipleFromGallery != null;

    if (!hasCamera && !hasGallery) {
      return _buildPlaceholder();
    }

    if (photos.isEmpty) {
      return _buildEmptyState(context);
    }

    return Row(
      children: [
        if (hasCamera)
          Expanded(
            child: TslSecondaryButton(
              label: 'Camera',
              leadingIcon: Icons.camera_alt_outlined,
              onPressed: () => _capturePhoto(context),
              size: TslButtonSize.small,
            ),
          ),
        if (hasCamera && hasGallery) const SizedBox(width: AppSpacing.md),
        if (hasGallery)
          Expanded(
            child: TslSecondaryButton(
              label: 'Gallery',
              leadingIcon: Icons.photo_library_outlined,
              onPressed: () => _pickFromGallery(context),
              size: TslButtonSize.small,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.disabled.withValues(alpha: 0.3),
        borderRadius: AppRadius.radiusCard,
        border: Border.all(
          color: AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAddPhotoOptions(context),
          borderRadius: AppRadius.radiusCard,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Add Photos',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Tap to capture or select',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.disabled.withValues(alpha: 0.3),
        borderRadius: AppRadius.radiusCard,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 40,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Photo capture not available',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = photos.length / minPhotos;
    final isComplete = photos.length >= minPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isComplete ? 'Minimum photos captured' : 'Progress',
              style: AppTypography.caption.copyWith(
                color: isComplete ? AppColors.success : AppColors.textSecondary,
              ),
            ),
            Text(
              '${photos.length}/$minPhotos required',
              style: AppTypography.caption.copyWith(
                color: isComplete ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: AppColors.disabled,
          valueColor: AlwaysStoppedAnimation<Color>(
            isComplete ? AppColors.success : AppColors.primary,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  void _showAddPhotoOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.disabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Add Photo',
                style: AppTypography.h3,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (onCapturePhoto != null)
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('Take Photo'),
                  subtitle: const Text('Use camera to capture'),
                  onTap: () {
                    Navigator.pop(context);
                    _capturePhoto(context);
                  },
                ),
              if (onPickFromGallery != null || onPickMultipleFromGallery != null)
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.secondary,
                    ),
                  ),
                  title: const Text('Choose from Gallery'),
                  subtitle: const Text('Select existing photos'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery(context);
                  },
                ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _capturePhoto(BuildContext context) async {
    final photo = await onCapturePhoto?.call();
    if (photo != null) {
      final newPhotos = List<String>.from(photos)..add(photo);
      onPhotosChanged?.call(newPhotos);
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    if (onPickMultipleFromGallery != null) {
      final selectedPhotos = await onPickMultipleFromGallery?.call();
      if (selectedPhotos != null && selectedPhotos.isNotEmpty) {
        final remaining = maxPhotos - photos.length;
        final newPhotos = List<String>.from(photos)
          ..addAll(selectedPhotos.take(remaining));
        onPhotosChanged?.call(newPhotos);
      }
    } else if (onPickFromGallery != null) {
      final photo = await onPickFromGallery?.call();
      if (photo != null) {
        final newPhotos = List<String>.from(photos)..add(photo);
        onPhotosChanged?.call(newPhotos);
      }
    }
  }

  void _showPhotoPreview(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => _PhotoPreviewScreen(
          photos: photos,
          initialIndex: initialIndex,
          onDelete: isEnabled
              ? (index) {
                  final newPhotos = List<String>.from(photos)
                    ..removeAt(index);
                  onPhotosChanged?.call(newPhotos);
                }
              : null,
          geoCoordinates: geoCoordinates,
        ),
      ),
    );
  }
}

/// Photo thumbnail widget
class _PhotoThumbnail extends StatelessWidget {
  final String photoPath;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final String? geoCoordinate;

  const _PhotoThumbnail({
    required this.photoPath,
    this.onDelete,
    this.onTap,
    this.geoCoordinate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo
          Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.radiusSm,
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImage(),
          ),
          // Geo-tag indicator
          if (geoCoordinate != null)
            Positioned(
              left: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 10,
                      color: AppColors.textOnPrimary,
                    ),
                    SizedBox(width: 2),
                    Text(
                      'GPS',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Delete button
          if (onDelete != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    // Check if it's a network URL or local file
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return Image.network(
        photoPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(photoPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: AppColors.disabled,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Photo preview screen
class _PhotoPreviewScreen extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  final void Function(int)? onDelete;
  final Map<String, String>? geoCoordinates;

  const _PhotoPreviewScreen({
    required this.photos,
    required this.initialIndex,
    this.onDelete,
    this.geoCoordinates,
  });

  @override
  State<_PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<_PhotoPreviewScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPhoto = widget.photos[_currentIndex];
    final geoCoord = widget.geoCoordinates?[currentPhoto];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${widget.photos.length}'),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              onPressed: () {
                widget.onDelete?.call(_currentIndex);
                if (widget.photos.length == 1) {
                  Navigator.pop(context);
                } else if (_currentIndex >= widget.photos.length - 1) {
                  setState(() {
                    _currentIndex = widget.photos.length - 2;
                  });
                  _pageController.jumpToPage(_currentIndex);
                }
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final photo = widget.photos[index];
                return InteractiveViewer(
                  child: Center(
                    child: _buildFullImage(photo),
                  ),
                );
              },
            ),
          ),
          if (geoCoord != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: Colors.black.withValues(alpha: 0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    geoCoord,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFullImage(String photoPath) {
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return Image.network(
        photoPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.broken_image_outlined,
          color: Colors.white54,
          size: 64,
        ),
      );
    } else {
      return Image.file(
        File(photoPath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.broken_image_outlined,
          color: Colors.white54,
          size: 64,
        ),
      );
    }
  }
}

