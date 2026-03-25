import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// TSL Parivar Design System - Theme Configuration
///
/// This file contains the complete Material 3 theme configuration
/// for both light and dark modes.
abstract final class AppTheme {
  // ============================================
  // LIGHT THEME
  // ============================================

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: _lightColorScheme,
        textTheme: AppTypography.textTheme,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        appBarTheme: _lightAppBarTheme,
        cardTheme: _cardTheme,
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textButtonTheme: _textButtonTheme,
        floatingActionButtonTheme: _fabTheme,
        inputDecorationTheme: _inputDecorationTheme,
        chipTheme: _chipTheme,
        bottomNavigationBarTheme: _bottomNavTheme,
        navigationBarTheme: _navigationBarTheme,
        dialogTheme: _dialogTheme,
        bottomSheetTheme: _bottomSheetTheme,
        snackBarTheme: _snackBarTheme,
        tabBarTheme: _tabBarTheme,
        dividerTheme: _dividerTheme,
        listTileTheme: _listTileTheme,
        switchTheme: _switchTheme,
        checkboxTheme: _checkboxTheme,
        radioTheme: _radioTheme,
        progressIndicatorTheme: _progressIndicatorTheme,
        iconTheme: _iconTheme,
        primaryIconTheme: _primaryIconTheme,
        tooltipTheme: _tooltipTheme,
        popupMenuTheme: _popupMenuTheme,
        drawerTheme: _drawerTheme,
        datePickerTheme: _datePickerTheme,
        timePickerTheme: _timePickerTheme,
        dropdownMenuTheme: _dropdownMenuTheme,
        searchBarTheme: _searchBarTheme,
        segmentedButtonTheme: _segmentedButtonTheme,
        badgeTheme: _badgeTheme,
        pageTransitionsTheme: _pageTransitionsTheme,
        splashFactory: InkRipple.splashFactory,
        visualDensity: VisualDensity.standard,
      );

  // ============================================
  // DARK THEME
  // ============================================

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _darkColorScheme,
        textTheme: AppTypography.textThemeDark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: _darkAppBarTheme,
        cardTheme: _darkCardTheme,
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _darkOutlinedButtonTheme,
        textButtonTheme: _textButtonTheme,
        floatingActionButtonTheme: _fabTheme,
        inputDecorationTheme: _darkInputDecorationTheme,
        chipTheme: _darkChipTheme,
        bottomNavigationBarTheme: _darkBottomNavTheme,
        navigationBarTheme: _darkNavigationBarTheme,
        dialogTheme: _darkDialogTheme,
        bottomSheetTheme: _darkBottomSheetTheme,
        snackBarTheme: _snackBarTheme,
        tabBarTheme: _darkTabBarTheme,
        dividerTheme: _darkDividerTheme,
        listTileTheme: _darkListTileTheme,
        switchTheme: _switchTheme,
        checkboxTheme: _checkboxTheme,
        radioTheme: _radioTheme,
        progressIndicatorTheme: _progressIndicatorTheme,
        iconTheme: _darkIconTheme,
        primaryIconTheme: _primaryIconTheme,
        tooltipTheme: _darkTooltipTheme,
        popupMenuTheme: _darkPopupMenuTheme,
        drawerTheme: _darkDrawerTheme,
        datePickerTheme: _darkDatePickerTheme,
        timePickerTheme: _darkTimePickerTheme,
        dropdownMenuTheme: _darkDropdownMenuTheme,
        searchBarTheme: _darkSearchBarTheme,
        segmentedButtonTheme: _darkSegmentedButtonTheme,
        badgeTheme: _badgeTheme,
        pageTransitionsTheme: _pageTransitionsTheme,
        splashFactory: InkRipple.splashFactory,
        visualDensity: VisualDensity.standard,
      );

  // ============================================
  // COLOR SCHEMES
  // ============================================

  static ColorScheme get _lightColorScheme => const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.info,
        onTertiary: AppColors.onInfo,
        tertiaryContainer: AppColors.infoContainer,
        onTertiaryContainer: AppColors.onInfoContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        shadow: AppColors.shadow,
        scrim: AppColors.scrim,
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.surface,
        inversePrimary: AppColors.primaryLight,
        surfaceTint: AppColors.primary,
      );

  static ColorScheme get _darkColorScheme => const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.primaryDark,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.secondaryDark,
        secondaryContainer: AppColors.secondaryDark,
        onSecondaryContainer: AppColors.secondaryContainer,
        tertiary: AppColors.infoLight,
        onTertiary: AppColors.infoDark,
        tertiaryContainer: AppColors.infoDark,
        onTertiaryContainer: AppColors.infoContainer,
        error: AppColors.errorLight,
        onError: AppColors.errorDark,
        errorContainer: AppColors.errorDark,
        onErrorContainer: AppColors.errorContainer,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        onSurfaceVariant: AppColors.darkTextSecondary,
        outline: AppColors.darkTextTertiary,
        outlineVariant: AppColors.darkSurfaceVariant,
        shadow: AppColors.shadow,
        scrim: AppColors.scrim,
        inverseSurface: AppColors.darkTextPrimary,
        onInverseSurface: AppColors.darkSurface,
        inversePrimary: AppColors.primary,
        surfaceTint: AppColors.primaryLight,
      );

  // ============================================
  // APP BAR THEMES
  // ============================================

  static AppBarTheme get _lightAppBarTheme => AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: AppColors.surface,
        shadowColor: AppColors.shadow.withValues(alpha: 0.1),
        centerTitle: false,
        titleTextStyle: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppSpacing.iconMd,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppSpacing.iconMd,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      );

  static AppBarTheme get _darkAppBarTheme => AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        surfaceTintColor: AppColors.darkSurface,
        shadowColor: AppColors.shadow.withValues(alpha: 0.2),
        centerTitle: false,
        titleTextStyle:
            AppTypography.h3.copyWith(color: AppColors.darkTextPrimary),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: AppSpacing.iconMd,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: AppSpacing.iconMd,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      );

  // ============================================
  // CARD THEMES
  // ============================================

  static CardThemeData get _cardTheme => CardThemeData(
        elevation: 0,
        color: AppColors.cardWhite,
        surfaceTintColor: AppColors.cardWhite,
        shadowColor: AppColors.shadow.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusCard,
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
      );

  static CardThemeData get _darkCardTheme => CardThemeData(
        elevation: 0,
        color: AppColors.darkCard,
        surfaceTintColor: AppColors.darkCard,
        shadowColor: AppColors.shadow.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusCard,
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
      );

  // ============================================
  // BUTTON THEMES
  // ============================================

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.lg,
          ),
          minimumSize: const Size(88, AppSpacing.buttonHeightLg),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusButton,
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.lg,
          ),
          minimumSize: const Size(88, AppSpacing.buttonHeightLg),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusButton,
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTypography.buttonMedium,
        ),
      );

  static OutlinedButtonThemeData get _darkOutlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          disabledForegroundColor: AppColors.darkTextTertiary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.lg,
          ),
          minimumSize: const Size(88, AppSpacing.buttonHeightLg),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusButton,
          ),
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          textStyle: AppTypography.buttonMedium,
        ),
      );

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(64, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusButton,
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      );

  static FloatingActionButtonThemeData get _fabTheme =>
      FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
        disabledElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusFab,
        ),
        extendedTextStyle: AppTypography.buttonMedium,
      );

  // ============================================
  // INPUT DECORATION THEME
  // ============================================

  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: AppRadius.inputBorder(),
        enabledBorder: AppRadius.inputBorder(),
        focusedBorder: AppRadius.inputBorderFocused(),
        errorBorder: AppRadius.inputBorderError(),
        focusedErrorBorder: AppRadius.inputBorderError(width: 2),
        disabledBorder: AppRadius.inputBorderDisabled(),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.primary,
        ),
        errorStyle: AppTypography.caption.copyWith(
          color: AppColors.error,
        ),
        helperStyle: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        errorMaxLines: 2,
        isDense: false,
      );

  static InputDecorationTheme get _darkInputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: AppRadius.inputBorder(color: AppColors.darkSurfaceVariant),
        enabledBorder:
            AppRadius.inputBorder(color: AppColors.darkSurfaceVariant),
        focusedBorder: AppRadius.inputBorderFocused(color: AppColors.primaryLight),
        errorBorder: AppRadius.inputBorderError(color: AppColors.errorLight),
        focusedErrorBorder:
            AppRadius.inputBorderError(color: AppColors.errorLight, width: 2),
        disabledBorder:
            AppRadius.inputBorderDisabled(color: AppColors.darkTextTertiary),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextTertiary,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        floatingLabelStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.primaryLight,
        ),
        errorStyle: AppTypography.caption.copyWith(
          color: AppColors.errorLight,
        ),
        helperStyle: AppTypography.caption.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        prefixIconColor: AppColors.darkTextSecondary,
        suffixIconColor: AppColors.darkTextSecondary,
        errorMaxLines: 2,
        isDense: false,
      );

  // ============================================
  // CHIP THEME
  // ============================================

  static ChipThemeData get _chipTheme => ChipThemeData(
        backgroundColor: AppColors.backgroundLight,
        deleteIconColor: AppColors.textSecondary,
        disabledColor: AppColors.border,
        selectedColor: AppColors.primaryContainer,
        secondarySelectedColor: AppColors.secondaryContainer,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelMedium,
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusChip,
        ),
        side: const BorderSide(color: AppColors.border),
        iconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: AppSpacing.iconSm,
        ),
      );

  static ChipThemeData get _darkChipTheme => ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        deleteIconColor: AppColors.darkTextSecondary,
        disabledColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.primaryDark,
        secondarySelectedColor: AppColors.secondaryDark,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusChip,
        ),
        side: const BorderSide(color: AppColors.darkSurfaceVariant),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextSecondary,
          size: AppSpacing.iconSm,
        ),
      );

  // ============================================
  // BOTTOM NAVIGATION THEME
  // ============================================

  static BottomNavigationBarThemeData get _bottomNavTheme =>
      BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
        selectedIconTheme: const IconThemeData(
          size: AppSpacing.iconMd,
        ),
        unselectedIconTheme: const IconThemeData(
          size: AppSpacing.iconMd,
        ),
      );

  static BottomNavigationBarThemeData get _darkBottomNavTheme =>
      BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkTextSecondary,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryLight,
        ),
        unselectedLabelStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
        selectedIconTheme: const IconThemeData(
          size: AppSpacing.iconMd,
        ),
        unselectedIconTheme: const IconThemeData(
          size: AppSpacing.iconMd,
        ),
      );

  // ============================================
  // NAVIGATION BAR THEME (Material 3)
  // ============================================

  static NavigationBarThemeData get _navigationBarTheme =>
      NavigationBarThemeData(
        height: AppSpacing.bottomNavHeight,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        surfaceTintColor: AppColors.surface,
        elevation: 0,
        shadowColor: AppColors.shadow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
              size: AppSpacing.iconMd,
            );
          }
          return const IconThemeData(
            color: AppColors.textSecondary,
            size: AppSpacing.iconMd,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      );

  static NavigationBarThemeData get _darkNavigationBarTheme =>
      NavigationBarThemeData(
        height: AppSpacing.bottomNavHeight,
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primaryDark,
        surfaceTintColor: AppColors.darkSurface,
        elevation: 0,
        shadowColor: AppColors.shadow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.labelSmall.copyWith(
            color: AppColors.darkTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primaryLight,
              size: AppSpacing.iconMd,
            );
          }
          return const IconThemeData(
            color: AppColors.darkTextSecondary,
            size: AppSpacing.iconMd,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      );

  // ============================================
  // DIALOG THEME
  // ============================================

  static DialogThemeData get _dialogTheme => DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 6,
        shadowColor: AppColors.shadow.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXxl,
        ),
        titleTextStyle: AppTypography.h3,
        contentTextStyle: AppTypography.bodyMedium,
        actionsPadding: const EdgeInsets.all(AppSpacing.lg),
      );

  static DialogThemeData get _darkDialogTheme => DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: AppColors.darkSurface,
        elevation: 6,
        shadowColor: AppColors.shadow.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXxl,
        ),
        titleTextStyle: AppTypography.h3.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        actionsPadding: const EdgeInsets.all(AppSpacing.lg),
      );

  // ============================================
  // BOTTOM SHEET THEME
  // ============================================

  static BottomSheetThemeData get _bottomSheetTheme => BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        modalElevation: 0,
        elevation: 0,
        shadowColor: AppColors.shadow.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusTopXxl,
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.border,
        dragHandleSize: const Size(32, 4),
        constraints: const BoxConstraints(maxWidth: 640),
      );

  static BottomSheetThemeData get _darkBottomSheetTheme => BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: AppColors.darkSurface,
        modalBackgroundColor: AppColors.darkSurface,
        modalElevation: 0,
        elevation: 0,
        shadowColor: AppColors.shadow.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusTopXxl,
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.darkSurfaceVariant,
        dragHandleSize: const Size(32, 4),
        constraints: const BoxConstraints(maxWidth: 640),
      );

  // ============================================
  // SNACK BAR THEME
  // ============================================

  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.surface,
        ),
        actionTextColor: AppColors.primaryLight,
        disabledActionTextColor: AppColors.textDisabled,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusCard,
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        showCloseIcon: false,
        closeIconColor: AppColors.surface,
      );

  // ============================================
  // TAB BAR THEME
  // ============================================

  static TabBarThemeData get _tabBarTheme => TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelLarge,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.border,
        overlayColor: WidgetStateProperty.all(
          AppColors.primary.withValues(alpha: 0.1),
        ),
        splashFactory: InkRipple.splashFactory,
      );

  static TabBarThemeData get _darkTabBarTheme => TabBarThemeData(
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.darkTextSecondary,
        labelStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryLight,
        ),
        unselectedLabelStyle: AppTypography.labelLarge.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primaryLight,
            width: 2,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.darkSurfaceVariant,
        overlayColor: WidgetStateProperty.all(
          AppColors.primaryLight.withValues(alpha: 0.1),
        ),
        splashFactory: InkRipple.splashFactory,
      );

  // ============================================
  // DIVIDER THEME
  // ============================================

  static DividerThemeData get _dividerTheme => const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
        indent: 0,
        endIndent: 0,
      );

  static DividerThemeData get _darkDividerTheme => const DividerThemeData(
        color: AppColors.darkSurfaceVariant,
        thickness: 1,
        space: 1,
        indent: 0,
        endIndent: 0,
      );

  // ============================================
  // LIST TILE THEME
  // ============================================

  static ListTileThemeData get _listTileTheme => ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primaryContainer.withValues(alpha: 0.5),
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        minVerticalPadding: AppSpacing.sm,
        horizontalTitleGap: AppSpacing.lg,
        minLeadingWidth: AppSpacing.iconMd,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusCard,
        ),
        titleTextStyle: AppTypography.bodyLarge,
        subtitleTextStyle: AppTypography.bodySmall,
        leadingAndTrailingTextStyle: AppTypography.labelMedium,
        dense: false,
        enableFeedback: true,
        visualDensity: VisualDensity.standard,
      );

  static ListTileThemeData get _darkListTileTheme => ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primaryDark.withValues(alpha: 0.3),
        iconColor: AppColors.darkTextSecondary,
        textColor: AppColors.darkTextPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        minVerticalPadding: AppSpacing.sm,
        horizontalTitleGap: AppSpacing.lg,
        minLeadingWidth: AppSpacing.iconMd,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusCard,
        ),
        titleTextStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        leadingAndTrailingTextStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        dense: false,
        enableFeedback: true,
        visualDensity: VisualDensity.standard,
      );

  // ============================================
  // SWITCH THEME
  // ============================================

  static SwitchThemeData get _switchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.onPrimary;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.border;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        splashRadius: 20,
      );

  // ============================================
  // CHECKBOX THEME
  // ============================================

  static CheckboxThemeData get _checkboxTheme => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.onPrimary),
        overlayColor: WidgetStateProperty.all(
          AppColors.primary.withValues(alpha: 0.1),
        ),
        side: const BorderSide(color: AppColors.textSecondary, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        splashRadius: 20,
        visualDensity: VisualDensity.standard,
      );

  // ============================================
  // RADIO THEME
  // ============================================

  static RadioThemeData get _radioTheme => RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
        overlayColor: WidgetStateProperty.all(
          AppColors.primary.withValues(alpha: 0.1),
        ),
        splashRadius: 20,
        visualDensity: VisualDensity.standard,
      );

  // ============================================
  // PROGRESS INDICATOR THEME
  // ============================================

  static ProgressIndicatorThemeData get _progressIndicatorTheme =>
      const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
        circularTrackColor: AppColors.border,
        linearMinHeight: 4,
      );

  // ============================================
  // ICON THEMES
  // ============================================

  static IconThemeData get _iconTheme => const IconThemeData(
        color: AppColors.textSecondary,
        size: AppSpacing.iconMd,
      );

  static IconThemeData get _darkIconTheme => const IconThemeData(
        color: AppColors.darkTextSecondary,
        size: AppSpacing.iconMd,
      );

  static IconThemeData get _primaryIconTheme => const IconThemeData(
        color: AppColors.primary,
        size: AppSpacing.iconMd,
      );

  // ============================================
  // TOOLTIP THEME
  // ============================================

  static TooltipThemeData get _tooltipTheme => TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.9),
          borderRadius: AppRadius.radiusSm,
        ),
        textStyle: AppTypography.caption.copyWith(
          color: AppColors.surface,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        preferBelow: true,
        waitDuration: const Duration(milliseconds: 500),
        showDuration: const Duration(seconds: 2),
      );

  static TooltipThemeData get _darkTooltipTheme => TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkTextPrimary.withValues(alpha: 0.9),
          borderRadius: AppRadius.radiusSm,
        ),
        textStyle: AppTypography.caption.copyWith(
          color: AppColors.darkSurface,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        preferBelow: true,
        waitDuration: const Duration(milliseconds: 500),
        showDuration: const Duration(seconds: 2),
      );

  // ============================================
  // POPUP MENU THEME
  // ============================================

  static PopupMenuThemeData get _popupMenuTheme => PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 4,
        shadowColor: AppColors.shadow.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusCard,
        ),
        textStyle: AppTypography.bodyMedium,
        labelTextStyle: WidgetStateProperty.all(AppTypography.bodyMedium),
      );

  static PopupMenuThemeData get _darkPopupMenuTheme => PopupMenuThemeData(
        color: AppColors.darkSurface,
        surfaceTintColor: AppColors.darkSurface,
        elevation: 4,
        shadowColor: AppColors.shadow.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusCard,
        ),
        textStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        labelTextStyle: WidgetStateProperty.all(
          AppTypography.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
        ),
      );

  // ============================================
  // DRAWER THEME
  // ============================================

  static DrawerThemeData get _drawerTheme => DrawerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 1,
        shadowColor: AppColors.shadow.withValues(alpha: 0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      );

  static DrawerThemeData get _darkDrawerTheme => DrawerThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: AppColors.darkSurface,
        elevation: 1,
        shadowColor: AppColors.shadow.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      );

  // ============================================
  // DATE PICKER THEME
  // ============================================

  static DatePickerThemeData get _datePickerTheme => DatePickerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 6,
        shadowColor: AppColors.shadow.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXxl,
        ),
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: AppColors.onPrimary,
        headerHeadlineStyle: AppTypography.h2,
        headerHelpStyle: AppTypography.bodyMedium,
        dayStyle: AppTypography.bodyMedium,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.onPrimary;
          }
          return AppColors.textPrimary;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        todayForegroundColor: WidgetStateProperty.all(AppColors.primary),
        todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
        todayBorder: const BorderSide(color: AppColors.primary),
        yearStyle: AppTypography.bodyMedium,
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.onPrimary;
          }
          return AppColors.textPrimary;
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        rangePickerBackgroundColor: AppColors.surface,
        rangePickerSurfaceTintColor: AppColors.surface,
        rangePickerElevation: 6,
        rangePickerShadowColor: AppColors.shadow.withValues(alpha: 0.2),
        rangeSelectionBackgroundColor:
            AppColors.primaryContainer.withValues(alpha: 0.5),
      );

  static DatePickerThemeData get _darkDatePickerTheme => DatePickerThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: AppColors.darkSurface,
        elevation: 6,
        shadowColor: AppColors.shadow.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXxl,
        ),
        headerBackgroundColor: AppColors.primaryDark,
        headerForegroundColor: AppColors.primaryContainer,
        headerHeadlineStyle: AppTypography.h2.copyWith(
          color: AppColors.primaryContainer,
        ),
        headerHelpStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.primaryContainer,
        ),
        dayStyle: AppTypography.bodyMedium,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDark;
          }
          return AppColors.darkTextPrimary;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return Colors.transparent;
        }),
        todayForegroundColor: WidgetStateProperty.all(AppColors.primaryLight),
        todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
        todayBorder: const BorderSide(color: AppColors.primaryLight),
        yearStyle: AppTypography.bodyMedium,
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDark;
          }
          return AppColors.darkTextPrimary;
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return Colors.transparent;
        }),
        rangePickerBackgroundColor: AppColors.darkSurface,
        rangePickerSurfaceTintColor: AppColors.darkSurface,
        rangePickerElevation: 6,
        rangePickerShadowColor: AppColors.shadow.withValues(alpha: 0.4),
        rangeSelectionBackgroundColor:
            AppColors.primaryDark.withValues(alpha: 0.3),
      );

  // ============================================
  // TIME PICKER THEME
  // ============================================

  static TimePickerThemeData get _timePickerTheme => TimePickerThemeData(
        backgroundColor: AppColors.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXxl,
        ),
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusCard,
        ),
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusSm,
        ),
        dayPeriodColor: AppColors.primaryContainer,
        dayPeriodTextColor: AppColors.primary,
        hourMinuteColor: AppColors.backgroundLight,
        hourMinuteTextColor: AppColors.textPrimary,
        dialHandColor: AppColors.primary,
        dialBackgroundColor: AppColors.backgroundLight,
        dialTextColor: AppColors.textPrimary,
        entryModeIconColor: AppColors.textSecondary,
        helpTextStyle: AppTypography.labelLarge,
        hourMinuteTextStyle: AppTypography.displayMedium,
        dayPeriodTextStyle: AppTypography.labelLarge,
      );

  static TimePickerThemeData get _darkTimePickerTheme => TimePickerThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXxl,
        ),
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusCard,
        ),
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusSm,
        ),
        dayPeriodColor: AppColors.primaryDark,
        dayPeriodTextColor: AppColors.primaryLight,
        hourMinuteColor: AppColors.darkSurfaceVariant,
        hourMinuteTextColor: AppColors.darkTextPrimary,
        dialHandColor: AppColors.primaryLight,
        dialBackgroundColor: AppColors.darkSurfaceVariant,
        dialTextColor: AppColors.darkTextPrimary,
        entryModeIconColor: AppColors.darkTextSecondary,
        helpTextStyle: AppTypography.labelLarge.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        hourMinuteTextStyle: AppTypography.displayMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        dayPeriodTextStyle: AppTypography.labelLarge.copyWith(
          color: AppColors.primaryLight,
        ),
      );

  // ============================================
  // DROPDOWN MENU THEME
  // ============================================

  static DropdownMenuThemeData get _dropdownMenuTheme => DropdownMenuThemeData(
        textStyle: AppTypography.bodyMedium,
        inputDecorationTheme: _inputDecorationTheme,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.surface),
          surfaceTintColor: WidgetStateProperty.all(AppColors.surface),
          elevation: WidgetStateProperty.all(4),
          shadowColor:
              WidgetStateProperty.all(AppColors.shadow.withValues(alpha: 0.2)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: AppRadius.radiusCard,
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          ),
        ),
      );

  static DropdownMenuThemeData get _darkDropdownMenuTheme =>
      DropdownMenuThemeData(
        textStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        inputDecorationTheme: _darkInputDecorationTheme,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.darkSurface),
          surfaceTintColor: WidgetStateProperty.all(AppColors.darkSurface),
          elevation: WidgetStateProperty.all(4),
          shadowColor:
              WidgetStateProperty.all(AppColors.shadow.withValues(alpha: 0.4)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: AppRadius.radiusCard,
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          ),
        ),
      );

  // ============================================
  // SEARCH BAR THEME
  // ============================================

  static SearchBarThemeData get _searchBarTheme => SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(AppColors.backgroundLight),
        surfaceTintColor: WidgetStateProperty.all(AppColors.backgroundLight),
        elevation: WidgetStateProperty.all(0),
        shadowColor:
            WidgetStateProperty.all(AppColors.shadow.withValues(alpha: 0.1)),
        overlayColor: WidgetStateProperty.all(
          AppColors.primary.withValues(alpha: 0.05),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: AppRadius.radiusFull,
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        textStyle: WidgetStateProperty.all(AppTypography.bodyMedium),
        hintStyle: WidgetStateProperty.all(
          AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
        ),
        constraints: const BoxConstraints(
          minHeight: AppSpacing.inputHeightMd,
          maxHeight: AppSpacing.inputHeightMd,
        ),
      );

  static SearchBarThemeData get _darkSearchBarTheme => SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(AppColors.darkSurfaceVariant),
        surfaceTintColor:
            WidgetStateProperty.all(AppColors.darkSurfaceVariant),
        elevation: WidgetStateProperty.all(0),
        shadowColor:
            WidgetStateProperty.all(AppColors.shadow.withValues(alpha: 0.2)),
        overlayColor: WidgetStateProperty.all(
          AppColors.primaryLight.withValues(alpha: 0.05),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: AppRadius.radiusFull,
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        textStyle: WidgetStateProperty.all(
          AppTypography.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
        ),
        hintStyle: WidgetStateProperty.all(
          AppTypography.bodyMedium.copyWith(color: AppColors.darkTextTertiary),
        ),
        constraints: const BoxConstraints(
          minHeight: AppSpacing.inputHeightMd,
          maxHeight: AppSpacing.inputHeightMd,
        ),
      );

  // ============================================
  // SEGMENTED BUTTON THEME
  // ============================================

  static SegmentedButtonThemeData get _segmentedButtonTheme =>
      SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryContainer;
            }
            return AppColors.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.textSecondary;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.border),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: AppRadius.radiusFull,
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          textStyle: WidgetStateProperty.all(AppTypography.labelLarge),
        ),
      );

  static SegmentedButtonThemeData get _darkSegmentedButtonTheme =>
      SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryDark;
            }
            return AppColors.darkSurface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryLight;
            }
            return AppColors.darkTextSecondary;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.darkSurfaceVariant),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: AppRadius.radiusFull,
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          textStyle: WidgetStateProperty.all(
            AppTypography.labelLarge.copyWith(color: AppColors.darkTextPrimary),
          ),
        ),
      );

  // ============================================
  // BADGE THEME
  // ============================================

  static BadgeThemeData get _badgeTheme => BadgeThemeData(
        backgroundColor: AppColors.error,
        textColor: AppColors.onError,
        smallSize: 8,
        largeSize: 16,
        textStyle: AppTypography.badge,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      );

  // ============================================
  // PAGE TRANSITIONS
  // ============================================

  static PageTransitionsTheme get _pageTransitionsTheme =>
      const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      );
}

