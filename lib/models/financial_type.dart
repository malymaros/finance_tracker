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
      case FinancialType.asset:       return Icons.trending_up;
      case FinancialType.consumption: return Icons.shopping_cart;
      case FinancialType.insurance:   return Icons.security;
    }
  }

  Color get color {
    switch (this) {
      case FinancialType.asset:       return const Color(0xFF1E88E5);
      case FinancialType.consumption: return const Color(0xFFFF7043);
      case FinancialType.insurance:   return const Color(0xFF00897B);
    }
  }
}
