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

  /// Subtle border / divider colour.
  static const border = Color(0xFFE0E0F2);

  /// Secondary / muted text colour.
  static const textMuted = Color(0xFF6B7280);
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
    // ── List tiles ──────────────────────────────────────────────────────────
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    ),
  );
}
