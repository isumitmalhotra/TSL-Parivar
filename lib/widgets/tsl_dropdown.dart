import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Styled dropdown selector for TSL Parivar app
///
/// Features:
/// - Multiple variants (outlined, filled)
/// - Search functionality
/// - Custom item builder
/// - Validation support
/// - Multi-select option
class TslDropdown<T> extends StatefulWidget {
  /// List of items to display
  final List<T> items;

  /// Currently selected value
  final T? value;

  /// Callback when value changes
  final ValueChanged<T?>? onChanged;

  /// Function to get display text for an item
  final String Function(T) itemLabel;

  /// Function to build custom item widget
  final Widget Function(T, bool isSelected)? itemBuilder;

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

  /// Whether field is required
  final bool isRequired;

  /// Whether field is enabled
  final bool isEnabled;

  /// Whether to enable search
  final bool searchable;

  /// Search hint text
  final String? searchHint;

  /// Dropdown variant
  final TslDropdownVariant variant;

  /// Validator function
  final String? Function(T?)? validator;

  const TslDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    required this.itemLabel,
    this.itemBuilder,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.isRequired = false,
    this.isEnabled = true,
    this.searchable = false,
    this.searchHint,
    this.variant = TslDropdownVariant.outlined,
    this.validator,
  });

  @override
  State<TslDropdown<T>> createState() => _TslDropdownState<T>();
}

class _TslDropdownState<T> extends State<TslDropdown<T>> {
  bool _isOpen = false;

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
        FormField<T>(
          initialValue: widget.value,
          validator: widget.validator,
          builder: (formState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdownButton(hasError || formState.hasError),
                if (formState.hasError && formState.errorText != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    formState.errorText!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            );
          },
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

  Widget _buildDropdownButton(bool hasError) {
    final borderColor = hasError
        ? AppColors.error
        : _isOpen
            ? AppColors.primary
            : AppColors.border;

    return Material(
      color: _getBackgroundColor(),
      borderRadius: AppRadius.radiusButton,
      child: InkWell(
        onTap: widget.isEnabled ? _showDropdown : null,
        borderRadius: AppRadius.radiusButton,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusButton,
            border: widget.variant == TslDropdownVariant.outlined
                ? Border.all(
                    color: widget.isEnabled ? borderColor : AppColors.disabled,
                    width: _isOpen ? 2 : 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                Icon(
                  widget.prefixIcon,
                  size: 20,
                  color: hasError
                      ? AppColors.error
                      : _isOpen
                          ? AppColors.primary
                          : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Text(
                  widget.value != null
                      ? widget.itemLabel(widget.value as T)
                      : widget.hint ?? 'Select...',
                  style: AppTypography.bodyLarge.copyWith(
                    color: widget.value != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              Icon(
                _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: widget.isEnabled
                    ? AppColors.textSecondary
                    : AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!widget.isEnabled) return AppColors.disabled;
    if (widget.variant == TslDropdownVariant.filled) {
      return AppColors.disabled.withValues(alpha: 0.5);
    }
    return Colors.transparent;
  }

  void _showDropdown() {
    if (widget.searchable) {
      _showSearchableDropdown();
    } else {
      _showSimpleDropdown();
    }
  }

  void _showSimpleDropdown() {
    setState(() => _isOpen = true);

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + button.size.height + 4,
        buttonPosition.dx + button.size.width,
        buttonPosition.dy + button.size.height + 300,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusCard,
      ),
      items: widget.items.map((item) {
        final isSelected = item == widget.value;
        return PopupMenuItem<T>(
          value: item,
          child: widget.itemBuilder != null
              ? widget.itemBuilder!(item, isSelected)
              : Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.itemLabel(item),
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.primary,
                      ),
                  ],
                ),
        );
      }).toList(),
    ).then((value) {
      setState(() => _isOpen = false);
      if (value != null) {
        widget.onChanged?.call(value);
      }
    });
  }

  void _showSearchableDropdown() {
    setState(() => _isOpen = true);

    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SearchableDropdownSheet<T>(
        items: widget.items,
        value: widget.value,
        itemLabel: widget.itemLabel,
        itemBuilder: widget.itemBuilder,
        searchHint: widget.searchHint ?? 'Search...',
        label: widget.label,
      ),
    ).then((value) {
      setState(() => _isOpen = false);
      if (value != null) {
        widget.onChanged?.call(value);
      }
    });
  }
}

/// Dropdown variants
enum TslDropdownVariant {
  outlined,
  filled,
}

/// Searchable dropdown bottom sheet
class _SearchableDropdownSheet<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final String Function(T) itemLabel;
  final Widget Function(T, bool isSelected)? itemBuilder;
  final String searchHint;
  final String? label;

  const _SearchableDropdownSheet({
    required this.items,
    this.value,
    required this.itemLabel,
    this.itemBuilder,
    required this.searchHint,
    this.label,
  });

  @override
  State<_SearchableDropdownSheet<T>> createState() =>
      _SearchableDropdownSheetState<T>();
}

class _SearchableDropdownSheetState<T>
    extends State<_SearchableDropdownSheet<T>> {
  late TextEditingController _searchController;
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => widget
                .itemLabel(item)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
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
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.label != null) ...[
                    Text(
                      widget.label!,
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  // Search field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterItems('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusButton,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                    onChanged: _filterItems,
                  ),
                ],
              ),
            ),
            // Items list
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'No items found',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = item == widget.value;

                        return ListTile(
                          onTap: () => Navigator.pop(context, item),
                          selected: isSelected,
                          selectedTileColor: AppColors.primaryContainer,
                          title: widget.itemBuilder != null
                              ? widget.itemBuilder!(item, isSelected)
                              : Text(
                                  widget.itemLabel(item),
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                )
                              : null,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Multi-select dropdown
class TslMultiSelectDropdown<T> extends StatelessWidget {
  /// List of items to display
  final List<T> items;

  /// Currently selected values
  final List<T> values;

  /// Callback when values change
  final ValueChanged<List<T>>? onChanged;

  /// Function to get display text for an item
  final String Function(T) itemLabel;

  /// Field label
  final String? label;

  /// Placeholder/hint text
  final String? hint;

  /// Whether field is required
  final bool isRequired;

  /// Whether field is enabled
  final bool isEnabled;

  /// Maximum selections allowed
  final int? maxSelections;

  const TslMultiSelectDropdown({
    super.key,
    required this.items,
    required this.values,
    this.onChanged,
    required this.itemLabel,
    this.label,
    this.hint,
    this.isRequired = false,
    this.isEnabled = true,
    this.maxSelections,
  });

  @override
  Widget build(BuildContext context) {
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
            onTap: isEnabled ? () => _showMultiSelectSheet(context) : null,
            borderRadius: AppRadius.radiusButton,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: AppRadius.radiusButton,
                border: Border.all(
                  color: isEnabled ? AppColors.border : AppColors.disabled,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (values.isEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hint ?? 'Select items...',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    )
                  else
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        ...values.map((item) => Chip(
                              label: Text(
                                itemLabel(item),
                                style: AppTypography.labelMedium,
                              ),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: isEnabled
                                  ? () {
                                      final newValues = List<T>.from(values)
                                        ..remove(item);
                                      onChanged?.call(newValues);
                                    }
                                  : null,
                              backgroundColor: AppColors.primaryContainer,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.radiusChip,
                              ),
                            )),
                        IconButton(
                          onPressed:
                              isEnabled ? () => _showMultiSelectSheet(context) : null,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.disabled,
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showMultiSelectSheet(BuildContext context) {
    showModalBottomSheet<List<T>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MultiSelectSheet<T>(
        items: items,
        values: values,
        itemLabel: itemLabel,
        label: label,
        maxSelections: maxSelections,
      ),
    ).then((result) {
      if (result != null) {
        onChanged?.call(result);
      }
    });
  }
}

/// Multi-select bottom sheet
class _MultiSelectSheet<T> extends StatefulWidget {
  final List<T> items;
  final List<T> values;
  final String Function(T) itemLabel;
  final String? label;
  final int? maxSelections;

  const _MultiSelectSheet({
    required this.items,
    required this.values,
    required this.itemLabel,
    this.label,
    this.maxSelections,
  });

  @override
  State<_MultiSelectSheet<T>> createState() => _MultiSelectSheetState<T>();
}

class _MultiSelectSheetState<T> extends State<_MultiSelectSheet<T>> {
  late List<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = List<T>.from(widget.values);
  }

  void _toggleItem(T item) {
    setState(() {
      if (_selectedValues.contains(item)) {
        _selectedValues.remove(item);
      } else {
        if (widget.maxSelections == null ||
            _selectedValues.length < widget.maxSelections!) {
          _selectedValues.add(item);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.disabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label ?? 'Select Items',
                        style: AppTypography.h3,
                      ),
                      Text(
                        '${_selectedValues.length} selected',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, _selectedValues),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = _selectedValues.contains(item);
                  final isDisabled = !isSelected &&
                      widget.maxSelections != null &&
                      _selectedValues.length >= widget.maxSelections!;

                  return ListTile(
                    onTap: isDisabled ? null : () => _toggleItem(item),
                    enabled: !isDisabled,
                    title: Text(
                      widget.itemLabel(item),
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDisabled
                            ? AppColors.textDisabled
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: isDisabled
                          ? null
                          : (value) => _toggleItem(item),
                      activeColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

