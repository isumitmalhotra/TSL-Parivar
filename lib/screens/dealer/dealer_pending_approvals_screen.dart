import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/dealer_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dealer_data_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/widgets.dart';

/// Dealer Pending Approvals Screen (CRITICAL)
///
/// Features:
/// - List of submitted PODs from mistris
/// - Photo gallery with zoom capability
/// - Map view with location comparison
/// - Quantity comparison
/// - Reward calculation display
/// - Approve/Reject/Request Info actions
class DealerPendingApprovalsScreen extends StatefulWidget {
  const DealerPendingApprovalsScreen({super.key});

  @override
  State<DealerPendingApprovalsScreen> createState() =>
      _DealerPendingApprovalsScreenState();
}

class _DealerPendingApprovalsScreenState
    extends State<DealerPendingApprovalsScreen> {
  bool _isSubmittingDecision = false;

  List<PodSubmissionModel> get _submissions =>
      context.watch<DealerDataProvider>().pendingSubmissions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).pendingApprovalsTitle),
        centerTitle: true,
        backgroundColor: AppColors.cardWhite,
        elevation: 0,
        actions: [
          if (_submissions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_submissions.length} pending',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _submissions.isEmpty
          ? Center(
              child: TslEmptyState(
                icon: Icons.task_alt,
                title: 'All Caught Up!',
                message: 'No pending approvals at the moment',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _submissions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < _submissions.length - 1 ? AppSpacing.md : 0,
                  ),
                  child: _PodApprovalCard(
                    submission: _submissions[index],
                    onTap: () => _showApprovalDetail(_submissions[index]),
                  ),
                );
              },
            ),
    );
  }

  void _showApprovalDetail(PodSubmissionModel submission) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PodApprovalDetailSheet(
        submission: submission,
        onApprove: () {
          Navigator.pop(context);
          _handleApprove(submission);
        },
        onReject: () {
          Navigator.pop(context);
          _handleReject(submission);
        },
        onRequestInfo: () {
          Navigator.pop(context);
          _handleRequestInfo(submission);
        },
      ),
    );
  }

  Future<void> _handleApprove(PodSubmissionModel submission) async {
    await _submitPodDecision(
      submission: submission,
      status: PodApprovalStatus.approved,
    );
  }

  void _handleReject(PodSubmissionModel submission) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _RejectPodSheet(
        submission: submission,
        onSubmit: (reason) {
          _submitPodDecision(
            submission: submission,
            status: PodApprovalStatus.rejected,
            reason: reason,
          );
        },
      ),
    );
  }

  Future<void> _handleRequestInfo(PodSubmissionModel submission) async {
    await _submitPodDecision(
      submission: submission,
      status: PodApprovalStatus.needsInfo,
      reason: 'Requested more information',
    );
  }

  Future<void> _submitPodDecision({
    required PodSubmissionModel submission,
    required PodApprovalStatus status,
    String? reason,
  }) async {
    if (_isSubmittingDecision) return;
    setState(() => _isSubmittingDecision = true);

    final auth = context.read<AuthProvider>();
    final dealerId = auth.userId ?? 'unknown_dealer';

    try {
      await FirestoreService.recordPodDecision(
        deliveryId: submission.deliveryId,
        dealerId: dealerId,
        decision: _toPodStatusKey(status),
        reason: reason,
        mistriId: submission.mistriId,
        approvedPoints: status == PodApprovalStatus.approved
            ? submission.totalPoints
            : null,
      );


      if (!mounted) return;
      setState(() => _isSubmittingDecision = false);

      final message = switch (status) {
        PodApprovalStatus.approved =>
          'Approved! ${submission.totalPoints} points transferred to ${submission.mistriName}',
        PodApprovalStatus.rejected => 'POD rejected',
        PodApprovalStatus.needsInfo => 'Requested more info from ${submission.mistriName}',
        PodApprovalStatus.pending => 'POD updated',
      };

      final color = switch (status) {
        PodApprovalStatus.approved => AppColors.success,
        PodApprovalStatus.rejected => AppColors.error,
        PodApprovalStatus.needsInfo => AppColors.info,
        PodApprovalStatus.pending => AppColors.primary,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmittingDecision = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update POD decision. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _toPodStatusKey(PodApprovalStatus status) {
    switch (status) {
      case PodApprovalStatus.pending:
        return 'pending';
      case PodApprovalStatus.approved:
        return 'approved';
      case PodApprovalStatus.rejected:
        return 'rejected';
      case PodApprovalStatus.needsInfo:
        return 'needsInfo';
    }
  }
}

/// POD Approval card
class _PodApprovalCard extends StatelessWidget {
  final PodSubmissionModel submission;
  final VoidCallback? onTap;

  const _PodApprovalCard({
    required this.submission,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.sm,
        border: submission.issueReported != null
            ? Border.all(color: AppColors.warning.withValues(alpha: 0.5), width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          submission.mistriName.substring(0, 1).toUpperCase(),
                          style: AppTypography.h3.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            submission.mistriName,
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            submission.materialType,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(submission.submittedAt),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        _buildLocationBadge(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Quick info row
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.inventory_2,
                      label: '${submission.deliveredQuantity}/${submission.assignedQuantity} ${submission.unit}',
                      color: submission.deliveredQuantity >= submission.assignedQuantity
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildInfoChip(
                      icon: Icons.photo_library,
                      label: '${submission.photoUrls.length} photos',
                      color: AppColors.info,
                    ),
                    const Spacer(),
                    // Points
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: AppColors.secondary),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            '+${submission.totalPoints}',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (submission.issueReported != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, size: 16, color: AppColors.warningDark),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Issue: ${submission.issueReported}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.warningDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                // Tap to review
                Center(
                  child: Text(
                    'Tap to review',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: submission.locationStatusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 12,
            color: submission.locationStatusColor,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '${submission.distanceFromTarget.toInt()}m',
            style: AppTypography.caption.copyWith(
              color: submission.locationStatusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// POD Approval detail sheet
class _PodApprovalDetailSheet extends StatefulWidget {
  final PodSubmissionModel submission;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onRequestInfo;

  const _PodApprovalDetailSheet({
    required this.submission,
    required this.onApprove,
    required this.onReject,
    required this.onRequestInfo,
  });

  @override
  State<_PodApprovalDetailSheet> createState() =>
      _PodApprovalDetailSheetState();
}

class _PodApprovalDetailSheetState extends State<_PodApprovalDetailSheet> {
  int _currentPhotoIndex = 0;
  final PageController _photoController = PageController();

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.disabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      widget.submission.mistriName.substring(0, 1).toUpperCase(),
                      style: AppTypography.h3.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.submission.mistriName,
                        style: AppTypography.h3,
                      ),
                      Text(
                        widget.submission.materialType,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: AppSpacing.xl),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo Gallery
                  _buildPhotoGallery(),
                  const SizedBox(height: AppSpacing.xl),
                  // Map View
                  _buildMapView(),
                  const SizedBox(height: AppSpacing.xl),
                  // Quantity Comparison
                  _buildQuantityComparison(),
                  const SizedBox(height: AppSpacing.xl),
                  // Mistri Notes
                  if (widget.submission.mistriNotes != null)
                    _buildNotesSection(),
                  // Issues
                  if (widget.submission.issueReported != null)
                    _buildIssuesSection(),
                  // Reward Calculation
                  _buildRewardCalculation(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
          // Actions
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_library, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text('Photo Gallery', style: AppTypography.h3),
            const Spacer(),
            Text(
              '${_currentPhotoIndex + 1}/${widget.submission.photoUrls.length}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              PageView.builder(
                controller: _photoController,
                onPageChanged: (index) {
                  setState(() => _currentPhotoIndex = index);
                },
                itemCount: widget.submission.photoUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showFullScreenPhoto(index),
                    child: Container(
                      margin: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.disabled,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.image,
                              size: 60,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Photo ${index + 1}',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Tap to view full screen',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // GPS tag overlay
              Positioned(
                left: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.gps_fixed, size: 12, color: Colors.white),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'GPS Verified',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Navigation arrows
              if (widget.submission.photoUrls.length > 1) ...[
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    onPressed: _currentPhotoIndex > 0
                        ? () => _photoController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    color: _currentPhotoIndex > 0
                        ? AppColors.textPrimary
                        : AppColors.disabled,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    onPressed: _currentPhotoIndex < widget.submission.photoUrls.length - 1
                        ? () => _photoController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    color: _currentPhotoIndex < widget.submission.photoUrls.length - 1
                        ? AppColors.textPrimary
                        : AppColors.disabled,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Indicators
        if (widget.submission.photoUrls.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.submission.photoUrls.length,
                (index) => Container(
                  width: index == _currentPhotoIndex ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: index == _currentPhotoIndex
                        ? AppColors.primary
                        : AppColors.disabled,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showFullScreenPhoto(int index) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Container(
                color: AppColors.disabled,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.image,
                        size: 100,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Photo ${index + 1}',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.xl,
              right: AppSpacing.lg,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.map, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text('Location Verification', style: AppTypography.h3),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Grid pattern
              CustomPaint(
                painter: _GridPainter(),
                size: Size.infinite,
              ),
              // Assigned location (Pin A)
              Positioned(
                left: 80,
                top: 80,
                child: _buildLocationPin(
                  label: 'A',
                  color: AppColors.info,
                  description: 'Assigned',
                ),
              ),
              // Submitted location (Pin B)
              Positioned(
                left: 80 + (widget.submission.distanceFromTarget / 10),
                top: 80 + (widget.submission.distanceFromTarget / 15),
                child: _buildLocationPin(
                  label: 'B',
                  color: widget.submission.locationStatusColor,
                  description: 'Submitted',
                ),
              ),
              // Distance line
              Positioned(
                bottom: AppSpacing.lg,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.xs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLocationInfo(
                        label: 'Distance',
                        value: '${widget.submission.distanceFromTarget.toInt()}m',
                        color: widget.submission.locationStatusColor,
                      ),
                      Container(width: 1, height: 30, color: AppColors.divider),
                      _buildLocationInfo(
                        label: 'Status',
                        value: widget.submission.locationStatus.toUpperCase(),
                        color: widget.submission.locationStatusColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPin({
    required String label,
    required Color color,
    required String description,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          width: 2,
          height: 12,
          color: color,
        ),
        Container(
          width: 8,
          height: 4,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          description,
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityComparison() {
    final difference = widget.submission.deliveredQuantity - widget.submission.assignedQuantity;
    final isMatch = difference == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.straighten, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text('Quantity Comparison', style: AppTypography.h3),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildQuantityCard(
                label: 'Assigned',
                value: widget.submission.assignedQuantity,
                unit: widget.submission.unit,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildQuantityCard(
                label: 'Delivered',
                value: widget.submission.deliveredQuantity,
                unit: widget.submission.unit,
                color: isMatch ? AppColors.success : AppColors.warning,
              ),
            ),
          ],
        ),
        if (!isMatch) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: (difference < 0 ? AppColors.error : AppColors.warning)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: difference < 0 ? AppColors.error : AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  difference < 0
                      ? 'Short by ${difference.abs()} ${widget.submission.unit}'
                      : 'Extra ${difference.abs()} ${widget.submission.unit}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: difference < 0 ? AppColors.error : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuantityCard({
    required String label,
    required double value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value.toStringAsFixed(0),
            style: AppTypography.h1.copyWith(color: color),
          ),
          Text(
            unit,
            style: AppTypography.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.note, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text('Mistri Notes', style: AppTypography.h3),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.submission.mistriNotes!,
            style: AppTypography.bodyMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildIssuesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber, size: 20, color: AppColors.warning),
            const SizedBox(width: AppSpacing.sm),
            Text('Issue Reported', style: AppTypography.h3),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.warningContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.submission.issueReported!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.warningDark,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildRewardCalculation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, size: 20, color: AppColors.secondary),
            const SizedBox(width: AppSpacing.sm),
            Text('Reward Calculation', style: AppTypography.h3),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Base Points',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    '+${widget.submission.basePoints}',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'On-Time Bonus',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    '+${widget.submission.bonusPoints}',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Points',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '+${widget.submission.totalPoints}',
                    style: AppTypography.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onReject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onRequestInfo,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.info,
                  side: const BorderSide(color: AppColors.info),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('More Info'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: widget.onApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check, size: 18),
                    const SizedBox(width: AppSpacing.xs),
                    const Text('Approve'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reject POD sheet
class _RejectPodSheet extends StatefulWidget {
  final PodSubmissionModel submission;
  final void Function(String reason) onSubmit;

  const _RejectPodSheet({
    required this.submission,
    required this.onSubmit,
  });

  @override
  State<_RejectPodSheet> createState() => _RejectPodSheetState();
}

class _RejectPodSheetState extends State<_RejectPodSheet> {
  String? _selectedReason;

  final List<String> _reasons = [
    'Photos are unclear or insufficient',
    'Location doesn\'t match delivery address',
    'Quantity mismatch not explained',
    'Suspected fraud',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.disabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Reject POD', style: AppTypography.h2),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Please select a reason for rejection',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          RadioGroup<String>(
            groupValue: _selectedReason ?? '',
            onChanged: (value) => setState(() => _selectedReason = value),
            child: Column(
              children: List.generate(_reasons.length, (index) {
                final reason = _reasons[index];
                return RadioListTile<String>(
                  value: reason,
                  title: Text(reason),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: TslSecondaryButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedReason != null
                      ? () {
                          final reason = _selectedReason;
                          if (reason == null) return;
                          Navigator.pop(context);
                          widget.onSubmit(reason);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Reject'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Grid painter for map
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;

    const spacing = 30.0;

    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

