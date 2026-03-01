import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'app_colors.dart';
import 'app_typography.dart';

enum AppThemeType { predator, precision, strike }

class AppTheme {
  AppTheme._();

  static ThemeData from(AppColors colors) {
    final textTheme = AppTypography.textTheme(colors);
    final isDark = colors.background.computeLuminance() < 0.5;
    final radius8 = BorderRadius.circular(AppSpacing.radiusMedium);
    final radius10 = BorderRadius.circular(AppSpacing.radiusCard);
    final radius12 = BorderRadius.circular(AppSpacing.radiusLarge);
    final radius16 = BorderRadius.circular(AppSpacing.radiusXl);

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colors.primary,
        onPrimary: Colors.white,
        secondary: colors.primary,
        onSecondary: Colors.white,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        error: colors.error,
        onError: Colors.white,
        shadow: colors.shadowColor,
      ),
      textTheme: textTheme,

      // AppBar — 52px toolbar, subtle bg, no elevation
      appBarTheme: AppBarTheme(
        backgroundColor: colors.toolbarBackground,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: AppSpacing.toolbarHeight,
        shape: Border(
          bottom: BorderSide(color: colors.dividerSubtle, width: 0.5),
        ),
      ),

      // Buttons — 32px height, 8px radius, no elevation
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, AppSpacing.buttonHeight),
          tapTargetSize: MaterialTapTargetSize.padded,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingH,
            vertical: AppSpacing.buttonPaddingV,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: radius8),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(0, AppSpacing.buttonHeight),
          tapTargetSize: MaterialTapTargetSize.padded,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingH,
            vertical: AppSpacing.buttonPaddingV,
          ),
          shape: RoundedRectangleBorder(borderRadius: radius8),
          side: BorderSide(color: colors.primary),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.textPrimary,
          minimumSize: const Size(0, AppSpacing.buttonHeight),
          tapTargetSize: MaterialTapTargetSize.padded,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingH,
            vertical: AppSpacing.buttonPaddingV,
          ),
          shape: RoundedRectangleBorder(borderRadius: radius8),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Cards — 10px radius, shadow via shadowColor, no border
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 1,
        shadowColor: colors.shadowColor,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: radius10),
      ),

      // Inputs — filled bg, no outline, 8px radius, focus ring only
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingH,
          vertical: 8,
        ),
        border: OutlineInputBorder(
          borderRadius: radius8,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius8,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius8,
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius8,
          borderSide: BorderSide(color: colors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius8,
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        isDense: true,
        labelStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
        hintStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
      ),

      // Dividers — 0.5px, subtle
      dividerTheme: DividerThemeData(
        color: colors.dividerSubtle,
        thickness: 0.5,
        space: 0,
      ),

      // Dialogs — 16px radius, elevated shadow
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        elevation: 24,
        shadowColor: colors.shadowColor,
        shape: RoundedRectangleBorder(borderRadius: radius16),
      ),

      // Chips — no border, surfaceSecondary bg, 8px radius
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceSecondary,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: radius8),
        labelStyle: textTheme.bodySmall,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ListTile — compact density, rounded shape
      listTileTheme: ListTileThemeData(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: radius8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),

      // Scrollbar — thin overlay
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(6),
        radius: const Radius.circular(3),
        thumbVisibility: WidgetStateProperty.all(false),
      ),

      // SegmentedButton — primary bg when selected, no border
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return colors.primary;
            return colors.surfaceSecondary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return colors.textPrimary;
          }),
          side: WidgetStateProperty.all(BorderSide.none),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: radius8),
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),

      // BottomSheet — 16px top radius, drag handle
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        showDragHandle: true,
      ),

      // SnackBar — floating, rounded, surface bg
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? colors.surface : colors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: radius10),
      ),

      // NavigationBar — toolbar bg, selection highlight indicator
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.toolbarBackground,
        indicatorColor: colors.selectionHighlight,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(color: colors.textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.primary, size: 22);
          }
          return IconThemeData(color: colors.textSecondary, size: 22);
        }),
      ),

      // NavigationRail — sidebar bg, selection highlight
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.sidebarBackground,
        indicatorColor: colors.selectionHighlight,
        selectedIconTheme: IconThemeData(color: colors.primary, size: 22),
        unselectedIconTheme:
            IconThemeData(color: colors.textSecondary, size: 22),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: colors.textSecondary,
        ),
      ),

      // Tooltip — dark rounded pill
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? colors.surface : colors.textPrimary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: isDark ? colors.textPrimary : colors.background,
          fontSize: 12,
        ),
      ),

      // FAB — 12px radius
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: radius12),
      ),

      // Icon theme
      iconTheme: IconThemeData(color: colors.textSecondary, size: 20),
    );
  }

  // 6 pre-built variations
  static final predatorLight = from(AppColors.predatorLight);
  static final predatorDark = from(AppColors.predatorDark);
  static final precisionLight = from(AppColors.precisionLight);
  static final precisionDark = from(AppColors.precisionDark);
  static final strikeLight = from(AppColors.strikeLight);
  static final strikeDark = from(AppColors.strikeDark);
}
