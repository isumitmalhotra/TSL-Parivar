import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/design_system.dart';

/// Quantity input with unit selector for TSL Parivar app
///
/// Features:
/// - Numeric input with increment/decrement buttons
/// - Unit selector dropdown
/// - Min/max constraints
/// - Step value customization
/// - Validation support
class TslQuantityInput extends StatefulWidget {
  /// Current quantity value
  final double value;

  /// Callback when quantity changes
  final ValueChanged<double>? onChanged;

  /// Current unit value
  final String? unit;

  /// Available units to select from
  final List<String>? units;

  /// Callback when unit changes
  final ValueChanged<String>? onUnitChanged;

  /// Field label
  final String? label;

  /// Helper text below the field
  final String? helperText;

  /// Error text (shows error state when not null)
  final String? errorText;

  /// Minimum value
  final double minValue;

  /// Maximum value
  final double maxValue;

  /// Step value for increment/decrement
  final double step;

  /// Number of decimal places
  final int decimalPlaces;

  /// Whether field is required
  final bool isRequired;

  /// Whether field is enabled
  final bool isEnabled;

  /// Whether to show increment/decrement buttons
  final bool showButtons;

  /// Prefix text
  final String? prefix;

  const TslQuantityInput({
    super.key,
    required this.value,
    this.onChanged,
    this.unit,
    this.units,
    this.onUnitChanged,
    this.label,
    this.helperText,
    this.errorText,
    this.minValue = 0,
    this.maxValue = double.infinity,
    this.step = 1,
    this.decimalPlaces = 0,
    this.isRequired = false,
    this.isEnabled = true,
    this.showButtons = true,
    this.prefix,
  });

  /// Factory for material quantity input (kg, tonnes, etc.)
  factory TslQuantityInput.material({
    required double value,
    ValueChanged<double>? onChanged,
    String? unit,
    ValueChanged<String>? onUnitChanged,
    String? label,
    String? errorText,
    double minValue = 0,
    double maxValue = 10000,
  }) {
    return TslQuantityInput(
      value: value,
      onChanged: onChanged,
      unit: unit ?? 'kg',
      units: const ['kg', 'tonnes', 'quintal'],
      onUnitChanged: onUnitChanged,
      label: label ?? 'Quantity',
      errorText: errorText,
      minValue: minValue,
      maxValue: maxValue,
      step: 1,
      decimalPlaces: 2,
      isRequired: true,
    );
  }

  /// Factory for count quantity input (pieces, bundles, etc.)
  factory TslQuantityInput.count({
    required double value,
    ValueChanged<double>? onChanged,
    String? unit,
    ValueChanged<String>? onUnitChanged,
    String? label,
    String? errorText,
    double minValue = 1,
    double maxValue = 1000,
  }) {
    return TslQuantityInput(
      value: value,
      onChanged: onChanged,
      unit: unit ?? 'pcs',
      units: const ['pcs', 'bundles', 'packets'],
      onUnitChanged: onUnitChanged,
      label: label ?? 'Quantity',
      errorText: errorText,
      minValue: minValue,
      maxValue: maxValue,
      step: 1,
      decimalPlaces: 0,
      isRequired: true,
    );
  }

  @override
  State<TslQuantityInput> createState() => _TslQuantityInputState();
}

class _TslQuantityInputState extends State<TslQuantityInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatValue(widget.value),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(TslQuantityInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
      _controller.text = _formatValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatValue(double value) {
    if (widget.decimalPlaces == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(widget.decimalPlaces);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _validateAndUpdate(_controller.text);
    }
  }

  void _validateAndUpdate(String text) {
    double? newValue = double.tryParse(text);
    if (newValue == null) {
      newValue = widget.minValue;
    }
    newValue = newValue.clamp(widget.minValue, widget.maxValue);
    _controller.text = _formatValue(newValue);
    widget.onChanged?.call(newValue);
  }

  void _increment() {
    final newValue = (widget.value + widget.step).clamp(
      widget.minValue,
      widget.maxValue,
    );
    _controller.text = _formatValue(newValue);
    widget.onChanged?.call(newValue);
  }

  void _decrement() {
    final newValue = (widget.value - widget.step).clamp(
      widget.minValue,
      widget.maxValue,
    );
    _controller.text = _formatValue(newValue);
    widget.onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          _buildLabel(),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quantity input with buttons
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.radiusButton,
                  border: Border.all(
                    color: hasError
                        ? AppColors.error
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    if (widget.showButtons)
                      _buildButton(
                        icon: Icons.remove,
                        onPressed: widget.value > widget.minValue
                            ? _decrement
                            : null,
                        isLeft: true,
                      ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: widget.isEnabled,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: widget.decimalPlaces > 0,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            widget.decimalPlaces > 0
                                ? RegExp(r'^\d*\.?\d*')
                                : RegExp(r'^\d*'),
                          ),
                        ],
                        decoration: InputDecoration(
                          prefixText: widget.prefix,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.md,
                          ),
                        ),
                        style: AppTypography.h3.copyWith(
                          color: widget.isEnabled
                              ? AppColors.textPrimary
                              : AppColors.textDisabled,
                        ),
                        onSubmitted: _validateAndUpdate,
                      ),
                    ),
                    if (widget.showButtons)
                      _buildButton(
                        icon: Icons.add,
                        onPressed: widget.value < widget.maxValue
                            ? _increment
                            : null,
                        isLeft: false,
                      ),
                  ],
                ),
              ),
            ),
            // Unit selector
            if (widget.units != null && widget.units!.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.radiusButton,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.unit,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      borderRadius: AppRadius.radiusButton,
                      items: widget.units!.map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(
                            unit,
                            style: AppTypography.bodyLarge,
                          ),
                        );
                      }).toList(),
                      onChanged: widget.isEnabled
                          ? (value) => widget.onUnitChanged?.call(value!)
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: AppTypography.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.helperText!,
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
          widget.label!,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        if (widget.isRequired) ...[
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '*',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isLeft,
  }) {
    return Material(
      color: onPressed != null && widget.isEnabled
          ? AppColors.disabled.withValues(alpha: 0.5)
          : AppColors.disabled.withValues(alpha: 0.3),
      borderRadius: BorderRadius.horizontal(
        left: isLeft ? const Radius.circular(10) : Radius.zero,
        right: isLeft ? Radius.zero : const Radius.circular(10),
      ),
      child: InkWell(
        onTap: widget.isEnabled ? onPressed : null,
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(10) : Radius.zero,
          right: isLeft ? Radius.zero : const Radius.circular(10),
        ),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null && widget.isEnabled
                ? AppColors.textPrimary
                : AppColors.textDisabled,
          ),
        ),
      ),
    );
  }
}

/// Simple quantity stepper widget
class TslQuantityStepper extends StatelessWidget {
  /// Current value
  final int value;

  /// Callback when value changes
  final ValueChanged<int>? onChanged;

  /// Minimum value
  final int minValue;

  /// Maximum value
  final int maxValue;

  /// Whether the stepper is enabled
  final bool isEnabled;

  /// Size variant
  final TslQuantityStepperSize size;

  const TslQuantityStepper({
    super.key,
    required this.value,
    this.onChanged,
    this.minValue = 0,
    this.maxValue = 999,
    this.isEnabled = true,
    this.size = TslQuantityStepperSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepperButton(
            icon: Icons.remove,
            onPressed: value > minValue
                ? () => onChanged?.call(value - 1)
                : null,
            dimensions: dimensions,
          ),
          Container(
            width: dimensions.valueWidth,
            alignment: Alignment.center,
            child: Text(
              value.toString(),
              style: dimensions.textStyle,
            ),
          ),
          _buildStepperButton(
            icon: Icons.add,
            onPressed: value < maxValue
                ? () => onChanged?.call(value + 1)
                : null,
            dimensions: dimensions,
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required _StepperDimensions dimensions,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: AppRadius.radiusSm,
        child: Container(
          width: dimensions.buttonSize,
          height: dimensions.buttonSize,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: dimensions.iconSize,
            color: onPressed != null && isEnabled
                ? AppColors.primary
                : AppColors.textDisabled,
          ),
        ),
      ),
    );
  }

  _StepperDimensions _getDimensions() {
    switch (size) {
      case TslQuantityStepperSize.small:
        return _StepperDimensions(
          buttonSize: 28,
          iconSize: 16,
          valueWidth: 32,
          textStyle: AppTypography.labelMedium,
        );
      case TslQuantityStepperSize.medium:
        return _StepperDimensions(
          buttonSize: 36,
          iconSize: 20,
          valueWidth: 40,
          textStyle: AppTypography.bodyLarge,
        );
      case TslQuantityStepperSize.large:
        return _StepperDimensions(
          buttonSize: 44,
          iconSize: 24,
          valueWidth: 48,
          textStyle: AppTypography.h3,
        );
    }
  }
}

/// Quantity stepper size variants
enum TslQuantityStepperSize {
  small,
  medium,
  large,
}

/// Internal class for stepper dimensions
class _StepperDimensions {
  final double buttonSize;
  final double iconSize;
  final double valueWidth;
  final TextStyle textStyle;

  const _StepperDimensions({
    required this.buttonSize,
    required this.iconSize,
    required this.valueWidth,
    required this.textStyle,
  });
}

