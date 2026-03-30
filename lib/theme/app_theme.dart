import 'package:flutter/material.dart';

/// Semantic color constants shared across the entire app.
abstract final class AppColors {
  /// Positive values: income, savings, on-budget.
  static const income = Color(0xFF059669);

  /// Negative values: expenses, costs, over-budget.
  static const expense = Color(0xFFDC2626);

  /// Warning state: near-limit, damaged files, info banners.
  static const warning = Color(0xFFD97706);

  /// Card / surface background (near-white).
  static const surface = Color(0xFFF8F8FF);

  /// Subtle border / divider colour (on light surfaces).
  static const border = Color(0xFFE0E0F2);

  /// Secondary / muted text colour.
  static const textMuted = Color(0xFF6B7280);

  // ── Brand chrome ──────────────────────────────────────────────────────────

  /// Deep navy — Welcome Screen primary blue; used for AppBar + NavBar.
  static const navy = Color(0xFF0D1B4B);

  /// Darkest navy — Welcome Screen gradient edge.
  static const navyDeep = Color(0xFF080D24);

  /// Hairline separator on dark (navy) surfaces.
  static const navyBorder = Color(0xFF1A2E6B);

  /// Warm gold accent — derived from the coin icon; used for titles + active
  /// nav states. Keep usage sparse so it reads as a true accent.
  static const gold = Color(0xFFD4A853);

  // ── GUARD feature ──────────────────────────────────────────────────────────

  /// Dark body text for GUARD item names in the banner and guard screen.
  static const guardItemText = Color(0xFF374151);

  /// Warm amber tint — background for the guard expense strip and banner rows.
  static const guardBannerBackground = Color(0xFFFFF8E8);
}

ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF4F46E5)),
    useMaterial3: true,
    // ── Cards ───────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    // ── Dividers ────────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
    ),
    // ── Segmented button ────────────────────────────────────────────────────
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    // ── List tiles ──────────────────────────────────────────────────────────
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    ),
    // ── App bar ─────────────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 42,
      titleTextStyle: TextStyle(
        color: AppColors.gold,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        // Slightly open spacing — gold on dark reads better with air.
        letterSpacing: 0.5,
        height: 1.1,
      ),
      iconTheme: IconThemeData(color: AppColors.gold),
      actionsIconTheme: IconThemeData(color: AppColors.gold),
      shape: Border(bottom: BorderSide(color: AppColors.navyBorder)),
    ),
    // ── Navigation bar ──────────────────────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.navy,
      elevation: 0,
      height: 60,
      surfaceTintColor: Colors.transparent,
      // Subtle gold pill behind the active icon.
      indicatorColor: AppColors.gold.withAlpha(30),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      // Selected: full gold. Unselected: gold at ~43% — visible but receded.
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          letterSpacing: 0.4,
          color: selected ? AppColors.gold : AppColors.gold.withAlpha(110),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 22,
          color: selected ? AppColors.gold : AppColors.gold.withAlpha(110),
        );
      }),
    ),
  );
}
