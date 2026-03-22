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
}
