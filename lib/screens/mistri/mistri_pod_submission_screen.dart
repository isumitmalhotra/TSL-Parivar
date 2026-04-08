import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mistri_models.dart';
import '../../providers/delivery_provider.dart';
import '../../widgets/widgets.dart';

/// Mistri POD (Proof of Delivery) Submission Screen
///
/// Features:
/// - Delivery summary section
/// - Location verification status
/// - Photo capture interface
/// - Quantity comparison
/// - Issue reporting dropdown
/// - Submit functionality with loading state
class MistriPodSubmissionScreen extends StatefulWidget {
  final String deliveryId;

  const MistriPodSubmissionScreen({
    super.key,
    required this.deliveryId,
  });

  @override
  State<MistriPodSubmissionScreen> createState() =>
      _MistriPodSubmissionScreenState();
}

class _MistriPodSubmissionScreenState extends State<MistriPodSubmissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late DeliveryModel _delivery;
  bool _hasDelivery = false;

  final List<String> _capturedPhotos = [];
  double _deliveredQuantity = 0;
  String? _selectedIssue;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;
  bool _locationVerified = false;

  final List<String> _issueOptions = [
    'No Issues',
    'Partial Delivery',
    'Damaged Goods',
    'Wrong Product',
    'Customer Not Available',
    'Address Not Found',
    'Access Issues',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    final allDeliveries = context.read<DeliveryProvider>().allDeliveries;
    final index = allDeliveries.indexWhere((d) => d.id == widget.deliveryId);
    if (index >= 0) {
      _delivery = allDeliveries[index];
      _hasDelivery = true;
    }

    _deliveredQuantity = _hasDelivery ? _delivery.quantity : 0;
    _selectedIssue = _issueOptions.first;

    // Simulate location verification
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _locationVerified = true);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return _capturedPhotos.length >= 2 &&
        _locationVerified &&
        _selectedIssue != null;
  }

  void _onSubmit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    // Simulate submission
    await Future<void>.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSubmitting = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SuccessDialog(
        onDone: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasDelivery) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.cardWhite,
          elevation: 0,
          title: const Text('POD unavailable'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: TslEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Delivery unavailable',
              message: 'Unable to submit POD because delivery details were not found.',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).podTitle),
        centerTitle: true,
        backgroundColor: AppColors.cardWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _animationController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Summary
                  _buildDeliverySummary(),

                  const SizedBox(height: AppSpacing.lg),

                  // Location Verification
                  _buildLocationVerification(),

                  const SizedBox(height: AppSpacing.lg),

                  // Photo Capture
                  _buildPhotoCapture(),

                  const SizedBox(height: AppSpacing.lg),

                  // Quantity Comparison
                  _buildQuantitySection(),

                  const SizedBox(height: AppSpacing.lg),

                  // Issue Reporting
                  _buildIssueReporting(),

                  const SizedBox(height: AppSpacing.lg),

                  // Notes
                  _buildNotesSection(),

                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildDeliverySummary() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                       colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _delivery.productName,
                        style: AppTypography.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${_delivery.quantity} ${_delivery.unit}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TslStatusPill.inProgress(),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Divider(color: AppColors.divider),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _delivery.customerName,
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _delivery.customerAddress,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationVerification() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: _locationVerified
            ? AppColors.successContainer
            : AppColors.warningContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _locationVerified
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _locationVerified
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: _locationVerified
                  ? const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 26,
                    )
                  : const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation(AppColors.warning),
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _locationVerified
                        ? 'Location Verified'
                        : 'Verifying Location...',
                    style: AppTypography.labelLarge.copyWith(
                      color: _locationVerified
                          ? AppColors.success
                          : AppColors.warningDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _locationVerified
                        ? 'You are within 500m of delivery location'
                        : 'Please wait while we verify your location',
                    style: AppTypography.bodySmall.copyWith(
                      color: _locationVerified
                          ? AppColors.success
                          : AppColors.warningDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCapture() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Delivery Photos',
                style: AppTypography.h3,
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: _capturedPhotos.length >= 2
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_capturedPhotos.length}/2 min',
                  style: AppTypography.caption.copyWith(
                    color: _capturedPhotos.length >= 2
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Take at least 2 photos of the delivered materials',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.xs,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Photo grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1,
                    ),
                    itemCount: _capturedPhotos.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _capturedPhotos.length) {
                        return _buildAddPhotoButton();
                      }
                      return _buildPhotoThumbnail(index);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          // Simulate adding a photo
          setState(() {
            _capturedPhotos.add('photo_${_capturedPhotos.length + 1}');
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Add Photo',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.disabled,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              Icons.image,
              color: AppColors.textSecondary,
              size: 40,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _capturedPhotos.removeAt(index);
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        // Geo tag indicator
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 10,
                  color: Colors.white,
                ),
                const SizedBox(width: 2),
                Text(
                  'GPS',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    final difference = _deliveredQuantity - _delivery.quantity;
    final isMatch = difference == 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantity Verification',
            style: AppTypography.h3,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.xs,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuantityCard(
                          label: 'Assigned',
                          value: _delivery.quantity,
                          unit: _delivery.unit,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildQuantityCard(
                          label: 'Delivered',
                          value: _deliveredQuantity,
                          unit: _delivery.unit,
                          color: isMatch ? AppColors.success : AppColors.warning,
                          isEditable: true,
                          onChanged: (value) {
                            setState(() => _deliveredQuantity = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  if (!isMatch) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: difference < 0
                            ? AppColors.errorContainer
                            : AppColors.warningContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: difference < 0
                                ? AppColors.error
                                : AppColors.warningDark,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              difference < 0
                                  ? 'Short delivery: ${difference.abs()} ${_delivery.unit}'
                                  : 'Extra delivery: ${difference.abs()} ${_delivery.unit}',
                              style: AppTypography.bodySmall.copyWith(
                                color: difference < 0
                                    ? AppColors.error
                                    : AppColors.warningDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityCard({
    required String label,
    required double value,
    required String unit,
    required Color color,
    bool isEditable = false,
    ValueChanged<double>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (isEditable)
            GestureDetector(
              onTap: () => _showQuantityEditor(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.toStringAsFixed(0),
                    style: AppTypography.h2.copyWith(
                      color: color,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: color,
                  ),
                ],
              ),
            )
          else
            Text(
              value.toStringAsFixed(0),
              style: AppTypography.h2.copyWith(
                color: color,
              ),
            ),
          Text(
            unit,
            style: AppTypography.caption.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuantityEditor() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _QuantityEditorSheet(
        initialValue: _deliveredQuantity,
        unit: _delivery.unit,
        maxValue: _delivery.quantity * 1.5,
        onSave: (value) {
          setState(() => _deliveredQuantity = value);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildIssueReporting() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Issue Reporting',
            style: AppTypography.h3,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.xs,
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TslDropdown<String>(
              label: 'Select Issue (if any)',
              hint: 'Select an issue',
              value: _selectedIssue,
              items: _issueOptions,
              itemLabel: (item) => item,
              onChanged: (value) => setState(() => _selectedIssue = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Notes',
            style: AppTypography.h3,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.xs,
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter any additional notes or observations...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.cardWhite,
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checklist
            if (!_canSubmit)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChecklistItem(
                      label: 'Photos',
                      isComplete: _capturedPhotos.length >= 2,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    _buildChecklistItem(
                      label: 'Location',
                      isComplete: _locationVerified,
                    ),
                  ],
                ),
              ),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: TslPrimaryButton(
                label: AppLocalizations.of(context).podSubmitDelivery,
                onPressed: _canSubmit ? _onSubmit : null,
                isLoading: _isSubmitting,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required String label,
    required bool isComplete,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isComplete ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: isComplete ? AppColors.success : AppColors.disabled,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isComplete ? AppColors.success : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Quantity editor bottom sheet
class _QuantityEditorSheet extends StatefulWidget {
  final double initialValue;
  final String unit;
  final double maxValue;
  final ValueChanged<double> onSave;

  const _QuantityEditorSheet({
    required this.initialValue,
    required this.unit,
    required this.maxValue,
    required this.onSave,
  });

  @override
  State<_QuantityEditorSheet> createState() => _QuantityEditorSheetState();
}

class _QuantityEditorSheetState extends State<_QuantityEditorSheet> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
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
            'Delivered Quantity',
            style: AppTypography.h3,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: _value > 0
                    ? () => setState(() => _value -= 10)
                    : null,
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Column(
                children: [
                  Text(
                    _value.toStringAsFixed(0),
                    style: AppTypography.h1.copyWith(
                      fontSize: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    widget.unit,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.xl),
              IconButton.filled(
                onPressed: _value < widget.maxValue
                    ? () => setState(() => _value += 10)
                    : null,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Slider(
            value: _value,
            min: 0,
            max: widget.maxValue,
            divisions: (widget.maxValue / 10).round(),
            activeColor: AppColors.primary,
            onChanged: (value) => setState(() => _value = value),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: TslPrimaryButton(
              label: 'Save',
              onPressed: () => widget.onSave(_value),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/// Success dialog
class _SuccessDialog extends StatefulWidget {
  final VoidCallback onDone;

  const _SuccessDialog({required this.onDone});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: Curves.elasticOut,
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'POD Submitted!',
              style: AppTypography.h2,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your proof of delivery has been submitted successfully. Points will be credited after dealer approval.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: TslPrimaryButton(
                label: 'Done',
                onPressed: widget.onDone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

