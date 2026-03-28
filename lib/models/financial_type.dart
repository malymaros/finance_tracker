import 'package:flutter/material.dart';

enum FinancialType { asset, consumption, insurance }

extension FinancialTypeX on FinancialType {
  String get displayName {
    switch (this) {
      case FinancialType.asset:       return 'Asset';
      case FinancialType.consumption: return 'Consumption';
      case FinancialType.insurance:   return 'Insurance';
    }
  }

  IconData get icon {
    switch (this) {
      case FinancialType.asset:       return Icons.show_chart;
      case FinancialType.consumption: return Icons.payments;
      case FinancialType.insurance:   return Icons.health_and_safety;
    }
  }

  Color get color {
    switch (this) {
      case FinancialType.asset:       return const Color(0xFF43A047);
      case FinancialType.consumption: return const Color(0xFFE53935);
      case FinancialType.insurance:   return const Color(0xFF1565C0);
    }
  }

  /// Very subtle background wash (~5% opacity) for Asset and Insurance rows.
  /// Consumption returns transparent — it is the default/majority state.
  Color get tintColor {
    switch (this) {
      case FinancialType.asset:       return const Color(0x0D43A047);
      case FinancialType.consumption: return Colors.transparent;
      case FinancialType.insurance:   return const Color(0x0D1565C0);
    }
  }

  /// Parses from a display name string (case-insensitive).
  /// Unknown or blank values fall back to [FinancialType.consumption].
  static FinancialType fromDisplayName(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return FinancialType.consumption;
    for (final type in FinancialType.values) {
      if (type.displayName.toLowerCase() == normalized) return type;
    }
    return FinancialType.consumption;
  }
}
