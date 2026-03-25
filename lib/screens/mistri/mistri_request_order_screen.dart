import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mistri_models.dart';
import '../../widgets/widgets.dart';

/// Mistri Request New Order Screen
///
/// Features:
/// - Material type dropdown
/// - Quantity input with unit selector
/// - Location picker
/// - Expected delivery date picker
/// - Urgency selector
/// - Customer details form
/// - Submit functionality
class MistriRequestOrderScreen extends StatefulWidget {
  const MistriRequestOrderScreen({super.key});

  @override
  State<MistriRequestOrderScreen> createState() =>
      _MistriRequestOrderScreenState();
}

class _MistriRequestOrderScreenState extends State<MistriRequestOrderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();

  // Form fields
  TslMaterialType? _selectedMaterial;
  double _quantity = 100;
  String _selectedUnit = 'kg';
  DateTime _expectedDate = DateTime.now().add(const Duration(days: 1));
  UrgencyLevel _urgency = UrgencyLevel.normal;
  String _customerName = '';
  String _customerPhone = '';
  String _deliveryAddress = '';
  // ignore: unused_field - will be sent to API when backend is connected
  String _notes = '';

  bool _isSubmitting = false;
  bool _useCurrentLocation = true;

  final List<TslMaterialType> _materials = MockMistriData.mockMaterialTypes; // Product catalog - loaded from Firestore products collection in production

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return _selectedMaterial != null &&
        _quantity > 0 &&
        _customerName.isNotEmpty &&
        _customerPhone.length >= 10 &&
        (_useCurrentLocation || _deliveryAddress.isNotEmpty);
  }

  void _onSubmit() async {
    if (!_canSubmit || !_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate API call
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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).requestOrderTitle),
        centerTitle: true,
        backgroundColor: AppColors.cardWhite,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _animationController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Material Selection
                    _buildMaterialSection(),

                    const SizedBox(height: AppSpacing.lg),

                    // Quantity & Unit
                    _buildQuantitySection(),

                    const SizedBox(height: AppSpacing.lg),

                    // Location
                    _buildLocationSection(),

                    const SizedBox(height: AppSpacing.lg),

                    // Expected Date
                    _buildDateSection(),

                    const SizedBox(height: AppSpacing.lg),

                    // Urgency
                    _buildUrgencySection(),

                    const SizedBox(height: AppSpacing.lg),

                    // Customer Details
                    _buildCustomerSection(),

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
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildMaterialSection() {
    return _buildSectionCard(
      title: AppLocalizations.of(context).requestOrderMaterial,
      icon: Icons.inventory_2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select the material you need',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Material grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.5,
            ),
            itemCount: _materials.length,
            itemBuilder: (context, index) {
              final material = _materials[index];
              final isSelected = _selectedMaterial == material;

              return _buildMaterialChip(material, isSelected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialChip(TslMaterialType material, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() {
          _selectedMaterial = material;
          if (material.availableUnits.isNotEmpty) {
            _selectedUnit = material.availableUnits.first;
          }
        }),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  material.icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    material.name.split(' ').take(2).join(' '),
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySection() {
    return _buildSectionCard(
      title: AppLocalizations.of(context).requestOrderQuantity,
      icon: Icons.straighten,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _quantity > 10
                                ? () => setState(() => _quantity -= 10)
                                : null,
                            icon: const Icon(Icons.remove),
                            color: AppColors.primary,
                          ),
                          Expanded(
                            child: Text(
                              _quantity.toStringAsFixed(0),
                              style: AppTypography.h2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                setState(() => _quantity += 10),
                            icon: const Icon(Icons.add),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedUnit,
                          isExpanded: true,
                          items: (_selectedMaterial?.availableUnits ??
                                  ['kg', 'pcs'])
                              .map<DropdownMenuItem<String>>((String unit) => DropdownMenuItem<String>(
                                    value: unit,
                                    child: Text(unit),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedUnit = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Quick select buttons
          Wrap(
            spacing: AppSpacing.sm,
            children: [100, 250, 500, 1000].map((qty) {
              final isSelected = _quantity == qty.toDouble();
              return ActionChip(
                label: Text('$qty'),
                backgroundColor: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : null,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                onPressed: () => setState(() => _quantity = qty.toDouble()),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return _buildSectionCard(
      title: AppLocalizations.of(context).requestOrderLocation,
      icon: Icons.location_on,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle
          Row(
            children: [
              Expanded(
                child: _buildToggleOption(
                  title: 'Current Location',
                  subtitle: 'Use GPS location',
                  icon: Icons.gps_fixed,
                  isSelected: _useCurrentLocation,
                  onTap: () => setState(() => _useCurrentLocation = true),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildToggleOption(
                  title: 'Custom Address',
                  subtitle: 'Enter manually',
                  icon: Icons.edit_location,
                  isSelected: !_useCurrentLocation,
                  onTap: () => setState(() => _useCurrentLocation = false),
                ),
              ),
            ],
          ),
          if (_useCurrentLocation) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Sector 62, Noida, UP (via GPS)',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter delivery address',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
              onChanged: (value) => _deliveryAddress = value,
              validator: (value) {
                if (!_useCurrentLocation &&
                    (value == null || value.isEmpty)) {
                  return 'Please enter delivery address';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return _buildSectionCard(
      title: AppLocalizations.of(context).expectedDelivery,
      icon: Icons.calendar_today,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick date options
          Row(
            children: [
              Expanded(
                child: _buildDateChip('Tomorrow', 1),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildDateChip('In 2 Days', 2),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildDateChip('In 3 Days', 3),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Custom date picker
          Material(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _selectDate(),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Date',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _formatDate(_expectedDate),
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.edit,
                      color: AppColors.textSecondary,
                      size: 20,
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

  Widget _buildDateChip(String label, int daysFromNow) {
    final date = DateTime.now().add(Duration(days: daysFromNow));
    final isSelected = _expectedDate.day == date.day &&
        _expectedDate.month == date.month &&
        _expectedDate.year == date.year;

    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.backgroundLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _expectedDate = date),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() => _expectedDate = date);
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildUrgencySection() {
    return _buildSectionCard(
      title: AppLocalizations.of(context).requestOrderUrgency,
      icon: Icons.speed,
      child: Row(
        children: UrgencyLevel.values.map((urgency) {
          final isSelected = _urgency == urgency;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: urgency != UrgencyLevel.asap ? AppSpacing.sm : 0,
              ),
              child: Material(
                color: isSelected
                    ? urgency.color.withValues(alpha: 0.1)
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => setState(() => _urgency = urgency),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? urgency.color : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          urgency == UrgencyLevel.normal
                              ? Icons.schedule
                              : urgency == UrgencyLevel.urgent
                                  ? Icons.priority_high
                                  : Icons.flash_on,
                          color: isSelected
                              ? urgency.color
                              : AppColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          urgency.displayName,
                          style: AppTypography.labelMedium.copyWith(
                            color: isSelected
                                ? urgency.color
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return _buildSectionCard(
      title: AppLocalizations.of(context).customerDetails,
      icon: Icons.person,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Customer Name',
              hintText: 'Enter customer name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => _customerName = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter customer name';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter phone number',
              prefixIcon: const Icon(Icons.phone_outlined),
              prefixText: '+91 ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) => _customerPhone = value,
            validator: (value) {
              if (value == null || value.length < 10) {
                return 'Please enter valid phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildSectionCard(
      title: AppLocalizations.of(context).requestOrderNotes,
      icon: Icons.note,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'Any special instructions or requirements...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        maxLines: 3,
        onChanged: (value) => _notes = value,
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  title,
                  style: AppTypography.h3,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
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
            // Summary
            if (_selectedMaterial != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '${_quantity.toStringAsFixed(0)} $_selectedUnit of ${_selectedMaterial!.name}',
                          style: AppTypography.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: TslPrimaryButton(
                label: AppLocalizations.of(context).requestOrderSubmit,
                leadingIcon: Icons.send,
                onPressed: _canSubmit ? _onSubmit : null,
                isLoading: _isSubmitting,
              ),
            ),
          ],
        ),
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
              'Request Submitted!',
              style: AppTypography.h2,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your order request has been sent to the dealer. You will be notified once it\'s approved.',
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

