import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/architect_models.dart';
import '../../widgets/widgets.dart';

/// Architect Create Specification Screen
///
/// Features:
/// - Project name + type selector
/// - Material selector
/// - Quantity + grade inputs
/// - Associated dealer(s) multi-select
/// - Project location input
/// - Timeline input
/// - Create + Save Draft functionality
class ArchitectCreateSpecScreen extends StatefulWidget {
  final ArchitectProject? existingProject;

  const ArchitectCreateSpecScreen({
    super.key,
    this.existingProject,
  });

  @override
  State<ArchitectCreateSpecScreen> createState() =>
      _ArchitectCreateSpecScreenState();
}

class _ArchitectCreateSpecScreenState extends State<ArchitectCreateSpecScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  int _currentStep = 0;
  bool _isSubmitting = false;

  // Form data
  String _projectName = '';
  ProjectType? _projectType;
  String? _selectedMaterial;
  double _quantity = 100;
  String _selectedUnit = 'kg';
  MaterialGrade _selectedGrade = MaterialGrade.fe550sd;
  final Set<String> _selectedDealers = {};
  String _location = '';
  DateTime? _expectedDate;
  String _notes = '';

  final List<AssociatedDealer> _dealers = MockArchitectData.mockDealers; // Loaded from Firestore in production
  final List<String> _materials = MockArchitectData.materialTypes; // Product catalog from Firestore

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    // Pre-fill if editing existing project
    if (widget.existingProject != null) {
      _projectName = widget.existingProject!.name;
      _projectType = widget.existingProject!.type;
      _location = widget.existingProject!.location;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitSpec() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future<void>.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);

    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF43A047).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Specification Created!', style: AppTypography.h2),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your specification has been submitted to the selected dealer(s).',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: AppColors.secondary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '+150 Points Earned',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: TslPrimaryButton(
                  label: 'Done',
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).createSpecTitle),
        centerTitle: true,
        backgroundColor: AppColors.cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveDraft,
            child: const Text('Save Draft'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            // Form pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildProjectStep(),
                  _buildMaterialStep(),
                  _buildDealerStep(),
                ],
              ),
            ),
            // Bottom actions
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      color: AppColors.cardWhite,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              _buildStepDot(0, 'Project'),
              _buildStepLine(0),
              _buildStepDot(1, 'Material'),
              _buildStepLine(1),
              _buildStepDot(2, 'Dealers'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCurrent ? 36 : 28,
            height: isCurrent ? 36 : 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                    )
                  : null,
              color: isActive ? null : AppColors.disabled,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: const Color(0xFF43A047).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isActive && _currentStep > step
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: isCurrent ? 14 : 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int beforeStep) {
    final isActive = _currentStep > beforeStep;

    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                )
              : null,
          color: isActive ? null : AppColors.disabled,
        ),
      ),
    );
  }

  Widget _buildProjectStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Project Details', style: AppTypography.h2),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enter your project information',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Project name
          _buildFormCard(
            title: 'Project Name',
            icon: Icons.business,
            child: TextFormField(
              initialValue: _projectName,
              decoration: InputDecoration(
                hintText: 'e.g., Green Valley Residences',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => _projectName = value,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter project name' : null,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Project type
          _buildFormCard(
            title: 'Project Type',
            icon: Icons.category,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: ProjectType.values.map((type) {
                final isSelected = _projectType == type;
                return FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type.icon,
                        size: 16,
                        color: isSelected ? Colors.white : type.color,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(type.displayName),
                    ],
                  ),
                  selectedColor: type.color,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  onSelected: (selected) {
                    setState(() => _projectType = selected ? type : null);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Location
          _buildFormCard(
            title: 'Project Location',
            icon: Icons.location_on,
            child: TextFormField(
              initialValue: _location,
              decoration: InputDecoration(
                hintText: 'Enter project location',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => _location = value,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter location' : null,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Expected delivery
          _buildFormCard(
            title: 'Expected Delivery',
            icon: Icons.calendar_today,
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _expectedDate ?? DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _expectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      _expectedDate != null
                          ? '${_expectedDate!.day}/${_expectedDate!.month}/${_expectedDate!.year}'
                          : 'Select expected delivery date',
                      style: AppTypography.bodyMedium.copyWith(
                        color: _expectedDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Material Specification', style: AppTypography.h2),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Select material type and quantity',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Material type
          _buildFormCard(
            title: 'Material Type',
            icon: Icons.inventory_2,
            child: Column(
              children: [
                ..._materials.map((material) {
                  final isSelected = _selectedMaterial == material;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Material(
                      color: isSelected
                          ? const Color(0xFF43A047).withValues(alpha: 0.1)
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => setState(() => _selectedMaterial = material),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: const Color(0xFF43A047), width: 2)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.construction,
                                color: isSelected
                                    ? const Color(0xFF43A047)
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: Text(material)),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF43A047),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Quantity and unit
          _buildFormCard(
            title: 'Quantity',
            icon: Icons.straighten,
            child: Column(
              children: [
                Row(
                  children: [
                    // Decrease button
                    IconButton(
                      onPressed: _quantity > 10
                          ? () => setState(() => _quantity -= 10)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primary,
                    ),
                    // Quantity display
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _quantity.toStringAsFixed(0),
                            style: AppTypography.h1.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Increase button
                    IconButton(
                      onPressed: () => setState(() => _quantity += 10),
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Unit selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['kg', 'pcs', 'tonnes'].map((unit) {
                    final isSelected = _selectedUnit == unit;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      child: ChoiceChip(
                        selected: isSelected,
                        label: Text(unit),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedUnit = unit);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                // Quick quantity buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [100, 500, 1000, 5000].map((qty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                      child: ActionChip(
                        label: Text('$qty'),
                        onPressed: () => setState(() => _quantity = qty.toDouble()),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Grade selector
          _buildFormCard(
            title: 'Material Grade',
            icon: Icons.grade,
            child: Row(
              children: MaterialGrade.values.map((grade) {
                final isSelected = _selectedGrade == grade;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                    child: Material(
                      color: isSelected
                          ? const Color(0xFF43A047)
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => setState(() => _selectedGrade = grade),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.lg,
                          ),
                          child: Center(
                            child: Text(
                              grade.displayName,
                              style: AppTypography.labelMedium.copyWith(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealerStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Dealers', style: AppTypography.h2),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Choose dealers to receive this specification',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Dealer list
          ..._dealers.map((dealer) {
            final isSelected = _selectedDealers.contains(dealer.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Material(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDealers.remove(dealer.id);
                      } else {
                        _selectedDealers.add(dealer.id);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(color: const Color(0xFF43A047), width: 2)
                          : null,
                      boxShadow: AppShadows.xs,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              dealer.name.substring(0, 1).toUpperCase(),
                              style: AppTypography.h2.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dealer.name,
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                dealer.shopName,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: AppSpacing.xxs),
                                  Text(
                                    dealer.location,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber[600],
                                  ),
                                  const SizedBox(width: AppSpacing.xxs),
                                  Text(
                                    dealer.rating.toString(),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFF43A047)
                                : AppColors.backgroundLight,
                            border: isSelected
                                ? null
                                : Border.all(color: AppColors.divider),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          // Notes
          _buildFormCard(
            title: 'Additional Notes (Optional)',
            icon: Icons.note,
            child: TextFormField(
              initialValue: _notes,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any special requirements or instructions...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => _notes = value,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Summary card
          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize, color: Colors.white),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Specification Summary',
                style: AppTypography.h3.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSummaryRow('Project', _projectName.isEmpty ? '-' : _projectName),
          _buildSummaryRow('Type', _projectType?.displayName ?? '-'),
          _buildSummaryRow('Material', _selectedMaterial ?? '-'),
          _buildSummaryRow('Quantity', '${_quantity.toStringAsFixed(0)} $_selectedUnit'),
          _buildSummaryRow('Grade', _selectedGrade.displayName),
          _buildSummaryRow('Dealers', '${_selectedDealers.length} selected'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF43A047)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
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
            if (_currentStep > 0)
              Expanded(
                child: TslSecondaryButton(
                  label: 'Back',
                  leadingIcon: Icons.arrow_back,
                  onPressed: _previousStep,
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: TslPrimaryButton(
                label: _currentStep < 2 ? AppLocalizations.of(context).commonNext : AppLocalizations.of(context).createSpecCreate,
                trailingIcon: _currentStep < 2 ? Icons.arrow_forward : Icons.check,
                isLoading: _isSubmitting,
                onPressed: _currentStep < 2 ? _nextStep : _submitSpec,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

