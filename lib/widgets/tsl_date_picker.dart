import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../design_system/design_system.dart';

/// Date picker component for TSL Parivar app
///
/// Features:
/// - Single date picker
/// - Date range picker
/// - Custom date format
/// - Min/max date constraints
/// - Locale support
class TslDatePicker extends StatelessWidget {
  /// Currently selected date
  final DateTime? value;

  /// Callback when date changes
  final ValueChanged<DateTime?>? onChanged;

  /// Field label
  final String? label;

  /// Placeholder/hint text
  final String? hint;

  /// Helper text below the field
  final String? helperText;

  /// Error text (shows error state when not null)
  final String? errorText;

  /// Minimum selectable date
  final DateTime? minDate;

  /// Maximum selectable date
  final DateTime? maxDate;

  /// Date format pattern
  final String dateFormat;

  /// Prefix icon
  final IconData prefixIcon;

  /// Whether field is required
  final bool isRequired;

  /// Whether field is enabled
  final bool isEnabled;

  /// Picker mode
  final TslDatePickerMode mode;

  const TslDatePicker({
    super.key,
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.minDate,
    this.maxDate,
    this.dateFormat = 'dd MMM yyyy',
    this.prefixIcon = Icons.calendar_today_outlined,
    this.isRequired = false,
    this.isEnabled = true,
    this.mode = TslDatePickerMode.date,
  });

  /// Factory for delivery date picker
  factory TslDatePicker.delivery({
    DateTime? value,
    ValueChanged<DateTime?>? onChanged,
    String? errorText,
  }) {
    return TslDatePicker(
      value: value,
      onChanged: onChanged,
      label: 'Expected Delivery Date',
      hint: 'Select delivery date',
      errorText: errorText,
      minDate: DateTime.now(),
      maxDate: DateTime.now().add(const Duration(days: 90)),
      isRequired: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final formattedDate =
        value != null ? DateFormat(dateFormat).format(value!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          _buildLabel(),
          const SizedBox(height: AppSpacing.sm),
        ],
        Material(
          color: Colors.transparent,
          borderRadius: AppRadius.radiusButton,
          child: InkWell(
            onTap: isEnabled ? () => _showPicker(context) : null,
            borderRadius: AppRadius.radiusButton,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md + 2,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.radiusButton,
                border: Border.all(
                  color: hasError
                      ? AppColors.error
                      : isEnabled
                          ? AppColors.border
                          : AppColors.disabled,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    prefixIcon,
                    size: 20,
                    color: hasError
                        ? AppColors.error
                        : isEnabled
                            ? AppColors.textSecondary
                            : AppColors.textDisabled,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      formattedDate ?? hint ?? 'Select date',
                      style: AppTypography.bodyLarge.copyWith(
                        color: formattedDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (value != null && isEnabled)
                    IconButton(
                      onPressed: () => onChanged?.call(null),
                      icon: const Icon(Icons.clear, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: AppTypography.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ] else if (helperText != null) ...[
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
      ],
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    DateTime? result;

    switch (mode) {
      case TslDatePickerMode.date:
        result = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: minDate ?? DateTime(2000),
          lastDate: maxDate ?? DateTime(2100),
          builder: (context, child) => _buildPickerTheme(context, child),
        );
        break;

      case TslDatePickerMode.time:
        final time = await showTimePicker(
          context: context,
          initialTime: value != null
              ? TimeOfDay.fromDateTime(value!)
              : TimeOfDay.now(),
          builder: (context, child) => _buildPickerTheme(context, child),
        );
        if (time != null) {
          final now = value ?? DateTime.now();
          result = DateTime(now.year, now.month, now.day, time.hour, time.minute);
        }
        break;

      case TslDatePickerMode.dateTime:
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: minDate ?? DateTime(2000),
          lastDate: maxDate ?? DateTime(2100),
          builder: (context, child) => _buildPickerTheme(context, child),
        );
        if (date != null && context.mounted) {
          final time = await showTimePicker(
            context: context,
            initialTime: value != null
                ? TimeOfDay.fromDateTime(value!)
                : TimeOfDay.now(),
            builder: (context, child) => _buildPickerTheme(context, child),
          );
          if (time != null) {
            result = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          }
        }
        break;
    }

    if (result != null) {
      onChanged?.call(result);
    }
  }

  Widget _buildPickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          surface: AppColors.cardWhite,
          onSurface: AppColors.textPrimary,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.cardWhite,
        ),
      ),
      child: child!,
    );
  }
}

/// Date picker modes
enum TslDatePickerMode {
  date,
  time,
  dateTime,
}

/// Date range picker component
class TslDateRangePicker extends StatelessWidget {
  /// Currently selected date range
  final DateTimeRange? value;

  /// Callback when date range changes
  final ValueChanged<DateTimeRange?>? onChanged;

  /// Field label
  final String? label;

  /// Placeholder/hint text
  final String? hint;

  /// Error text (shows error state when not null)
  final String? errorText;

  /// Minimum selectable date
  final DateTime? minDate;

  /// Maximum selectable date
  final DateTime? maxDate;

  /// Date format pattern
  final String dateFormat;

  /// Whether field is required
  final bool isRequired;

  /// Whether field is enabled
  final bool isEnabled;

  const TslDateRangePicker({
    super.key,
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.errorText,
    this.minDate,
    this.maxDate,
    this.dateFormat = 'dd MMM',
    this.isRequired = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final formatter = DateFormat(dateFormat);
    String? displayText;
    if (value != null) {
      displayText =
          '${formatter.format(value!.start)} - ${formatter.format(value!.end)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
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
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Material(
          color: Colors.transparent,
          borderRadius: AppRadius.radiusButton,
          child: InkWell(
            onTap: isEnabled ? () => _showPicker(context) : null,
            borderRadius: AppRadius.radiusButton,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md + 2,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.radiusButton,
                border: Border.all(
                  color: hasError
                      ? AppColors.error
                      : isEnabled
                          ? AppColors.border
                          : AppColors.disabled,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range_outlined,
                    size: 20,
                    color: hasError
                        ? AppColors.error
                        : isEnabled
                            ? AppColors.textSecondary
                            : AppColors.textDisabled,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      displayText ?? hint ?? 'Select date range',
                      style: AppTypography.bodyLarge.copyWith(
                        color: displayText != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (value != null && isEnabled)
                    IconButton(
                      onPressed: () => onChanged?.call(null),
                      icon: const Icon(Icons.clear, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: AppTypography.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: minDate ?? DateTime(2000),
      lastDate: maxDate ?? DateTime(2100),
      initialDateRange: value,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.cardWhite,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      onChanged?.call(result);
    }
  }
}

/// Quick date selector chips
class TslQuickDateSelector extends StatelessWidget {
  /// Currently selected date
  final DateTime? value;

  /// Callback when date changes
  final ValueChanged<DateTime?>? onChanged;

  /// Quick options to show
  final List<TslQuickDateOption> options;

  const TslQuickDateSelector({
    super.key,
    this.value,
    this.onChanged,
    this.options = const [
      TslQuickDateOption.today,
      TslQuickDateOption.tomorrow,
      TslQuickDateOption.thisWeek,
      TslQuickDateOption.nextWeek,
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final optionDate = option.date;
        final isSelected = value != null &&
            value!.year == optionDate.year &&
            value!.month == optionDate.month &&
            value!.day == optionDate.day;

        return ChoiceChip(
          label: Text(option.label),
          selected: isSelected,
          onSelected: (selected) {
            onChanged?.call(selected ? optionDate : null);
          },
          selectedColor: AppColors.primaryContainer,
          backgroundColor: AppColors.disabled.withValues(alpha: 0.5),
          labelStyle: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
          side: isSelected
              ? BorderSide(color: AppColors.primary)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusChip,
          ),
        );
      }).toList(),
    );
  }
}

/// Quick date options
enum TslQuickDateOption {
  today('Today'),
  tomorrow('Tomorrow'),
  thisWeek('This Week'),
  nextWeek('Next Week'),
  thisMonth('This Month'),
  nextMonth('Next Month');

  final String label;

  const TslQuickDateOption(this.label);

  DateTime get date {
    final now = DateTime.now();
    switch (this) {
      case TslQuickDateOption.today:
        return now;
      case TslQuickDateOption.tomorrow:
        return now.add(const Duration(days: 1));
      case TslQuickDateOption.thisWeek:
        return now.add(Duration(days: 7 - now.weekday));
      case TslQuickDateOption.nextWeek:
        return now.add(Duration(days: 14 - now.weekday));
      case TslQuickDateOption.thisMonth:
        return DateTime(now.year, now.month + 1, 0);
      case TslQuickDateOption.nextMonth:
        return DateTime(now.year, now.month + 2, 0);
    }
  }
}

