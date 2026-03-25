import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../design_system/design_system.dart';
import '../providers/language_provider.dart';

/// Language toggle widget for switching between EN/HI
///
/// Features:
/// - Toggle button style
/// - Animated switch
/// - Persisted language preference
/// - Multiple style variants
class TslLanguageToggle extends StatelessWidget {
  /// Toggle style variant
  final TslLanguageToggleStyle style;

  /// Callback when language changes
  final ValueChanged<AppLocale>? onChanged;

  /// Custom active color
  final Color? activeColor;

  /// Whether to show flag icons
  final bool showFlags;

  const TslLanguageToggle({
    super.key,
    this.style = TslLanguageToggleStyle.button,
    this.onChanged,
    this.activeColor,
    this.showFlags = false,
  });

  /// Factory constructor for compact style (small button)
  const factory TslLanguageToggle.compact({
    Key? key,
    ValueChanged<AppLocale>? onChanged,
    Color? activeColor,
  }) = _CompactLanguageToggle;

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    switch (style) {
      case TslLanguageToggleStyle.button:
        return _ButtonStyle(
          languageProvider: languageProvider,
          onChanged: onChanged,
          activeColor: activeColor,
        );
      case TslLanguageToggleStyle.toggle:
        return _ToggleStyle(
          languageProvider: languageProvider,
          onChanged: onChanged,
          activeColor: activeColor,
        );
      case TslLanguageToggleStyle.dropdown:
        return _DropdownStyle(
          languageProvider: languageProvider,
          onChanged: onChanged,
          showFlags: showFlags,
        );
      case TslLanguageToggleStyle.segmented:
        return _SegmentedStyle(
          languageProvider: languageProvider,
          onChanged: onChanged,
          activeColor: activeColor,
        );
    }
  }
}

/// Language toggle style variants
enum TslLanguageToggleStyle {
  button,
  toggle,
  dropdown,
  segmented,
}

/// Compact language toggle (small button with just text)
class _CompactLanguageToggle extends TslLanguageToggle {
  const _CompactLanguageToggle({
    super.key,
    super.onChanged,
    super.activeColor,
  }) : super(style: TslLanguageToggleStyle.button);

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () async {
          await languageProvider.toggleLocale();
          onChanged?.call(languageProvider.currentLocale);
        },
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              languageProvider.isEnglish ? 'EN' : 'हिं',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            Icon(
              Icons.swap_horiz,
              size: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

/// Button style toggle
class _ButtonStyle extends StatelessWidget {
  final LanguageProvider languageProvider;
  final ValueChanged<AppLocale>? onChanged;
  final Color? activeColor;

  const _ButtonStyle({
    required this.languageProvider,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await languageProvider.toggleLocale();
        onChanged?.call(languageProvider.currentLocale);
      },
      style: TextButton.styleFrom(
        foregroundColor: activeColor ?? AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Text(
            languageProvider.isEnglish ? 'HI' : 'EN',
            style: AppTypography.labelMedium.copyWith(
              color: activeColor ?? AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Toggle switch style
class _ToggleStyle extends StatelessWidget {
  final LanguageProvider languageProvider;
  final ValueChanged<AppLocale>? onChanged;
  final Color? activeColor;

  const _ToggleStyle({
    required this.languageProvider,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.disabled,
        borderRadius: AppRadius.radiusChip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleOption(
            label: 'EN',
            isSelected: languageProvider.isEnglish,
            onTap: () async {
              if (!languageProvider.isEnglish) {
                await languageProvider.setLocale(AppLocale.english);
                onChanged?.call(AppLocale.english);
              }
            },
            activeColor: activeColor,
          ),
          _ToggleOption(
            label: 'HI',
            isSelected: languageProvider.isHindi,
            onTap: () async {
              if (!languageProvider.isHindi) {
                await languageProvider.setLocale(AppLocale.hindi);
                onChanged?.call(AppLocale.hindi);
              }
            },
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }
}

/// Toggle option button
class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor ?? AppColors.primary
              : Colors.transparent,
          borderRadius: AppRadius.radiusChip,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected
                ? AppColors.textOnPrimary
                : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Dropdown style toggle
class _DropdownStyle extends StatelessWidget {
  final LanguageProvider languageProvider;
  final ValueChanged<AppLocale>? onChanged;
  final bool showFlags;

  const _DropdownStyle({
    required this.languageProvider,
    this.onChanged,
    this.showFlags = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppLocale>(
      initialValue: languageProvider.currentLocale,
      onSelected: (locale) async {
        await languageProvider.setLocale(locale);
        onChanged?.call(locale);
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusCard,
      ),
      itemBuilder: (context) => AppLocale.values.map((locale) {
        return PopupMenuItem<AppLocale>(
          value: locale,
          child: Row(
            children: [
              if (showFlags) ...[
                Text(
                  locale == AppLocale.english ? '🇺🇸' : '🇮🇳',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                locale.displayName,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: locale == languageProvider.currentLocale
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (locale == languageProvider.currentLocale)
                Icon(
                  Icons.check,
                  size: 18,
                  color: AppColors.primary,
                ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: AppRadius.radiusSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(
              languageProvider.currentLocale.code,
              style: AppTypography.labelMedium,
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }
}

/// Segmented control style
class _SegmentedStyle extends StatelessWidget {
  final LanguageProvider languageProvider;
  final ValueChanged<AppLocale>? onChanged;
  final Color? activeColor;

  const _SegmentedStyle({
    required this.languageProvider,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AppLocale>(
      segments: AppLocale.values
          .map(
            (locale) => ButtonSegment<AppLocale>(
              value: locale,
              label: Text(locale.code),
            ),
          )
          .toList(),
      selected: {languageProvider.currentLocale},
      onSelectionChanged: (selection) async {
        if (selection.isNotEmpty) {
          final locale = selection.first;
          await languageProvider.setLocale(locale);
          onChanged?.call(locale);
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return activeColor ?? AppColors.primary;
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.textOnPrimary;
          }
          return AppColors.textSecondary;
        }),
      ),
    );
  }
}

/// Standalone language selector page/bottom sheet
class TslLanguageSelector extends StatelessWidget {
  /// Callback when language is selected
  final ValueChanged<AppLocale>? onSelected;

  /// Whether this is displayed as a bottom sheet
  final bool isBottomSheet;

  const TslLanguageSelector({
    super.key,
    this.onSelected,
    this.isBottomSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Container(
      padding: EdgeInsets.only(
        top: isBottomSheet ? AppSpacing.md : AppSpacing.xl,
        bottom: isBottomSheet
            ? MediaQuery.of(context).padding.bottom + AppSpacing.lg
            : AppSpacing.xl,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBottomSheet) ...[
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
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(
            'Select Language',
            style: AppTypography.h2,
          ),
          Text(
            'भाषा चुनें',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...AppLocale.values.map((locale) {
            final isSelected = locale == languageProvider.currentLocale;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Material(
                color: isSelected
                    ? AppColors.primaryContainer
                    : AppColors.cardWhite,
                borderRadius: AppRadius.radiusCard,
                child: InkWell(
                  onTap: () async {
                    await languageProvider.setLocale(locale);
                    onSelected?.call(locale);
                  },
                  borderRadius: AppRadius.radiusCard,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.radiusCard,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          locale == AppLocale.english ? '🇺🇸' : '🇮🇳',
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                locale.displayName,
                                style: AppTypography.h3.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                locale == AppLocale.english
                                    ? 'English'
                                    : 'Hindi',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: AppColors.textOnPrimary,
                            ),
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
    );
  }

  /// Show as bottom sheet
  static Future<AppLocale?> showAsBottomSheet(BuildContext context) {
    return showModalBottomSheet<AppLocale>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => TslLanguageSelector(
        isBottomSheet: true,
        onSelected: (locale) => Navigator.pop(context, locale),
      ),
    );
  }
}

