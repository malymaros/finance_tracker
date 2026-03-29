import 'package:flutter/material.dart';

import 'financial_type.dart';

enum ExpenseCategory {
  housing,
  groceries,
  vacation,
  transport,
  insurance,
  subscriptions,
  communication,
  health,
  restaurants,
  entertainment,
  clothing,
  education,
  investment,
  gifts,
  taxes,
  medications,
  other,
}

extension ExpenseCategoryX on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.housing:       return 'Housing';
      case ExpenseCategory.groceries:     return 'Groceries';
      case ExpenseCategory.vacation:      return 'Vacation';
      case ExpenseCategory.transport:     return 'Transport';
      case ExpenseCategory.insurance:     return 'Insurance';
      case ExpenseCategory.subscriptions: return 'Subscriptions';
      case ExpenseCategory.communication: return 'Communication';
      case ExpenseCategory.health:        return 'Health';
      case ExpenseCategory.restaurants:   return 'Restaurants';
      case ExpenseCategory.entertainment: return 'Entertainment';
      case ExpenseCategory.clothing:      return 'Clothing';
      case ExpenseCategory.education:     return 'Education';
      case ExpenseCategory.investment:    return 'Investment';
      case ExpenseCategory.gifts:         return 'Gifts';
      case ExpenseCategory.taxes:         return 'Taxes';
      case ExpenseCategory.medications:   return 'Medications';
      case ExpenseCategory.other:         return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.housing:       return Icons.home;
      case ExpenseCategory.groceries:     return Icons.local_grocery_store;
      case ExpenseCategory.vacation:      return Icons.beach_access;
      case ExpenseCategory.transport:     return Icons.directions_car;
      case ExpenseCategory.insurance:     return Icons.security;
      case ExpenseCategory.subscriptions: return Icons.subscriptions;
      case ExpenseCategory.communication: return Icons.phone;
      case ExpenseCategory.health:        return Icons.favorite;
      case ExpenseCategory.restaurants:   return Icons.restaurant;
      case ExpenseCategory.entertainment: return Icons.movie;
      case ExpenseCategory.clothing:      return Icons.checkroom;
      case ExpenseCategory.education:     return Icons.school;
      case ExpenseCategory.investment:    return Icons.trending_up;
      case ExpenseCategory.gifts:         return Icons.card_giftcard;
      case ExpenseCategory.taxes:         return Icons.account_balance;
      case ExpenseCategory.medications:   return Icons.medication;
      case ExpenseCategory.other:         return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.housing:       return const Color(0xFF8D6E63);
      case ExpenseCategory.groceries:     return const Color(0xFF66BB6A);
      case ExpenseCategory.vacation:      return const Color(0xFFFFA726);
      case ExpenseCategory.transport:     return const Color(0xFF42A5F5);
      case ExpenseCategory.insurance:     return const Color(0xFF26C6DA);
      case ExpenseCategory.subscriptions: return const Color(0xFFAB47BC);
      case ExpenseCategory.communication: return const Color(0xFF5C6BC0);
      case ExpenseCategory.health:        return const Color(0xFFEF5350);
      case ExpenseCategory.restaurants:   return const Color(0xFFFF7043);
      case ExpenseCategory.entertainment: return const Color(0xFFEC407A);
      case ExpenseCategory.clothing:      return const Color(0xFF7E57C2);
      case ExpenseCategory.education:     return const Color(0xFF29B6F6);
      case ExpenseCategory.investment:    return const Color(0xFF2E7D32);
      case ExpenseCategory.gifts:         return const Color(0xFFE91E63);
      case ExpenseCategory.taxes:         return const Color(0xFF546E7A);
      case ExpenseCategory.medications:   return const Color(0xFF00ACC1);
      case ExpenseCategory.other:         return const Color(0xFF9E9E9E);
    }
  }

  /// The financial type this category defaults to when creating an expense.
  /// [ExpenseCategory.investment] → asset, [ExpenseCategory.insurance] →
  /// insurance, everything else → consumption.
  FinancialType get defaultFinancialType {
    switch (this) {
      case ExpenseCategory.investment:
        return FinancialType.asset;
      case ExpenseCategory.insurance:
        return FinancialType.insurance;
      default:
        return FinancialType.consumption;
    }
  }

  /// Parses from persisted value. Handles new enum names ('groceries') and
  /// legacy free-text strings ('Food', 'Transport', etc.).
  static ExpenseCategory fromJson(String value) {
    try {
      return ExpenseCategory.values.byName(value);
    } catch (_) {
      return _fromLegacy(value);
    }
  }

  static ExpenseCategory _fromLegacy(String value) {
    switch (value.toLowerCase()) {
      case 'drugstore': return ExpenseCategory.other;
      case 'food':      return ExpenseCategory.groceries;
      case 'transport': return ExpenseCategory.transport;
      case 'shopping':  return ExpenseCategory.clothing;
      case 'health':    return ExpenseCategory.health;
      default:          return ExpenseCategory.other;
    }
  }
}
