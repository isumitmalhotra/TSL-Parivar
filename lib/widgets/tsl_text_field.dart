import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/design_system.dart';

/// Styled text input field for TSL Parivar app
///
/// Features:
/// - Multiple variants (outlined, filled, underlined)
/// - Validation support
/// - Prefix/suffix icons
/// - Character counter
/// - Helper text
/// - Error states
class TslTextField extends StatefulWidget {
  /// Text editing controller
  final TextEditingController? controller;

  /// Field label
  final String? label;

  /// Placeholder/hint text
  final String? hint;

  /// Helper text below the field
  final String? helperText;

  /// Error text (shows error state when not null)
  final String? errorText;

  /// Prefix icon
  final IconData? prefixIcon;

  /// Suffix icon
  final IconData? suffixIcon;

  /// Callback when suffix icon is tapped
  final VoidCallback? onSuffixTap;

  /// Prefix widget (overrides prefixIcon)
  final Widget? prefix;

  /// Suffix widget (overrides suffixIcon)
  final Widget? suffix;

  /// Input field variant
  final TslTextFieldVariant variant;

  /// Whether field is required
  final bool isRequired;

  /// Whether field is read-only
  final bool isReadOnly;

  /// Whether field is enabled
  final bool isEnabled;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Maximum number of lines
  final int maxLines;

  /// Minimum number of lines
  final int? minLines;

  /// Maximum character length
  final int? maxLength;

  /// Whether to show character counter
  final bool showCounter;

  /// Keyboard type
  final TextInputType keyboardType;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Validator function
  final String? Function(String?)? validator;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Callback when field is submitted
  final ValueChanged<String>? onSubmitted;

  /// Callback when field gains/loses focus
  final ValueChanged<bool>? onFocusChange;

  /// Auto-validation mode
  final AutovalidateMode autovalidateMode;

  /// Text capitalization
  final TextCapitalization textCapitalization;

  /// Focus node
  final FocusNode? focusNode;

  /// Autofill hints
  final Iterable<String>? autofillHints;

  const TslTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.prefix,
    this.suffix,
    this.variant = TslTextFieldVariant.outlined,
    this.isRequired = false,
    this.isReadOnly = false,
    this.isEnabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChange,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.autofillHints,
  });

  /// Factory for phone number input
  factory TslTextField.phone({
    TextEditingController? controller,
    String? label,
    String? hint,
    String? errorText,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return TslTextField(
      controller: controller,
      label: label ?? 'Phone Number',
      hint: hint ?? 'Enter your phone number',
      errorText: errorText,
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      showCounter: false,
      onChanged: onChanged,
      validator: validator,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      autofillHints: const [AutofillHints.telephoneNumber],
    );
  }

  /// Factory for email input
  factory TslTextField.email({
    TextEditingController? controller,
    String? label,
    String? hint,
    String? errorText,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return TslTextField(
      controller: controller,
      label: label ?? 'Email',
      hint: hint ?? 'Enter your email',
      errorText: errorText,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      validator: validator,
      autofillHints: const [AutofillHints.email],
    );
  }

  /// Factory for password input - returns a password field widget
  /// Note: Use TslPasswordField directly for password inputs
  static Widget password({
    TextEditingController? controller,
    String? label,
    String? hint,
    String? errorText,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return _PasswordTextField(
      controller: controller,
      label: label ?? 'Password',
      hint: hint ?? 'Enter your password',
      errorText: errorText,
      onChanged: onChanged,
      validator: validator,
    );
  }

  /// Factory for search input
  factory TslTextField.search({
    TextEditingController? controller,
    String? hint,
    ValueChanged<String>? onChanged,
    VoidCallback? onClear,
  }) {
    return TslTextField(
      controller: controller,
      hint: hint ?? 'Search...',
      prefixIcon: Icons.search,
      suffixIcon: Icons.clear,
      onSuffixTap: onClear,
      variant: TslTextFieldVariant.filled,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
    );
  }

  /// Factory for multiline text input
  factory TslTextField.multiline({
    TextEditingController? controller,
    String? label,
    String? hint,
    String? errorText,
    int maxLines = 4,
    int? maxLength,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return TslTextField(
      controller: controller,
      label: label,
      hint: hint,
      errorText: errorText,
      maxLines: maxLines,
      minLines: 2,
      maxLength: maxLength,
      showCounter: maxLength != null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
      validator: validator,
    );
  }

  @override
  State<TslTextField> createState() => _TslTextFieldState();
}

class _TslTextFieldState extends State<TslTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    widget.onFocusChange?.call(_isFocused);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final decoration = _buildDecoration(hasError);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          _buildLabel(),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: decoration,
          obscureText: widget.obscureText,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          autovalidateMode: widget.autovalidateMode,
          textCapitalization: widget.textCapitalization,
          readOnly: widget.isReadOnly,
          enabled: widget.isEnabled,
          autofillHints: widget.autofillHints,
          style: AppTypography.bodyLarge.copyWith(
            color: widget.isEnabled
                ? AppColors.textPrimary
                : AppColors.textDisabled,
          ),
          buildCounter: widget.showCounter
              ? null
              : (context, {required currentLength, required isFocused, maxLength}) =>
                  null,
        ),
        if (widget.helperText != null && !hasError) ...[
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

  InputDecoration _buildDecoration(bool hasError) {
    final borderColor = hasError
        ? AppColors.error
        : _isFocused
            ? AppColors.primary
            : AppColors.border;

    Widget? prefixWidget = widget.prefix;
    if (prefixWidget == null && widget.prefixIcon != null) {
      prefixWidget = Icon(
        widget.prefixIcon,
        size: 20,
        color: hasError
            ? AppColors.error
            : _isFocused
                ? AppColors.primary
                : AppColors.textSecondary,
      );
    }

    Widget? suffixWidget = widget.suffix;
    if (suffixWidget == null && widget.suffixIcon != null) {
      suffixWidget = IconButton(
        onPressed: widget.onSuffixTap,
        icon: Icon(
          widget.suffixIcon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
    }

    switch (widget.variant) {
      case TslTextFieldVariant.outlined:
        return InputDecoration(
          hintText: widget.hint,
          errorText: widget.errorText,
          prefixIcon: prefixWidget != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: prefixWidget,
                )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffixWidget != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffixWidget,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          filled: false,
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusButton,
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusButton,
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusButton,
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusButton,
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusButton,
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusButton,
            borderSide: BorderSide(color: AppColors.disabled),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        );

      case TslTextFieldVariant.filled:
        return InputDecoration(
          hintText: widget.hint,
          errorText: widget.errorText,
          prefixIcon: prefixWidget,
          suffixIcon: suffixWidget,
          filled: true,
          fillColor: widget.isEnabled
              ? AppColors.disabled.withValues(alpha: 0.5)
              : AppColors.disabled,
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusButton,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusButton,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusButton,
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusButton,
            borderSide: BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        );

      case TslTextFieldVariant.underlined:
        return InputDecoration(
          hintText: widget.hint,
          errorText: widget.errorText,
          prefixIcon: prefixWidget,
          suffixIcon: suffixWidget,
          filled: false,
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),
        );
    }
  }
}

/// Text field variants
enum TslTextFieldVariant {
  outlined,
  filled,
  underlined,
}

/// Password text field with visibility toggle
class _PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const _PasswordTextField({
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.onChanged,
    this.validator,
  });

  @override
  State<_PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TslTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      errorText: widget.errorText,
      prefixIcon: Icons.lock_outline,
      suffixIcon: _obscureText ? Icons.visibility_off : Icons.visibility,
      onSuffixTap: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      validator: widget.validator,
      autofillHints: const [AutofillHints.password],
    );
  }
}

