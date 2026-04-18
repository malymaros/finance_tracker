import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
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
  electronics,
  clothing,
  education,
  investment,
  gifts,
  taxes,
  medications,
  utilities,
  household,
  personalCare,
  savings,
  debt,
  kids,
  pets,
  fees,
  fuel,
  maintenance,
  donations,
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
      case ExpenseCategory.electronics:   return 'Electronics';
      case ExpenseCategory.clothing:      return 'Clothing';
      case ExpenseCategory.education:     return 'Education';
      case ExpenseCategory.investment:    return 'Investment';
      case ExpenseCategory.gifts:         return 'Gifts';
      case ExpenseCategory.taxes:         return 'Taxes';
      case ExpenseCategory.medications:   return 'Medications';
      case ExpenseCategory.utilities:     return 'Utilities';
      case ExpenseCategory.household:     return 'Household Supplies';
      case ExpenseCategory.personalCare:  return 'Personal Care';
      case ExpenseCategory.savings:       return 'Savings';
      case ExpenseCategory.debt:          return 'Debt';
      case ExpenseCategory.kids:          return 'Kids';
      case ExpenseCategory.pets:          return 'Pets';
      case ExpenseCategory.fees:          return 'Fees';
      case ExpenseCategory.fuel:          return 'Fuel';
      case ExpenseCategory.maintenance:   return 'Maintenance';
      case ExpenseCategory.donations:     return 'Donations';
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
      case ExpenseCategory.electronics:   return Icons.devices;
      case ExpenseCategory.clothing:      return Icons.checkroom;
      case ExpenseCategory.education:     return Icons.school;
      case ExpenseCategory.investment:    return Icons.trending_up;
      case ExpenseCategory.gifts:         return Icons.card_giftcard;
      case ExpenseCategory.taxes:         return Icons.assured_workload;
      case ExpenseCategory.medications:   return Icons.medication;
      case ExpenseCategory.utilities:     return Icons.bolt;
      case ExpenseCategory.household:     return Icons.cleaning_services;
      case ExpenseCategory.personalCare:  return Icons.spa;
      case ExpenseCategory.savings:       return Icons.savings;
      case ExpenseCategory.debt:          return Icons.credit_card;
      case ExpenseCategory.kids:          return Icons.child_care;
      case ExpenseCategory.pets:          return Icons.pets;
      case ExpenseCategory.fees:          return Icons.request_quote;
      case ExpenseCategory.fuel:          return Icons.local_gas_station;
      case ExpenseCategory.maintenance:   return Icons.build;
      case ExpenseCategory.donations:     return Icons.volunteer_activism;
      case ExpenseCategory.other:         return Icons.category;
    }
  }

  Color get color {
  switch (this) {

    // CORE / FIXED
    case ExpenseCategory.housing:       return const Color(0xFF8D6E63);
    case ExpenseCategory.utilities:     return const Color(0xFFFFD600);
    case ExpenseCategory.insurance:     return const Color(0xFF26C6DA);
    case ExpenseCategory.taxes:         return const Color(0xFF546E7A);

    // DAILY LIFE 
    case ExpenseCategory.groceries:     return const Color(0xFF66BB6A);
    case ExpenseCategory.restaurants:   return const Color(0xFFFF7043);
    case ExpenseCategory.personalCare:  return const Color(0xFFF8BBD0);
    case ExpenseCategory.household:     return const Color(0xFF00897B);

    // TRANSPORT
    case ExpenseCategory.transport:     return const Color(0xFF42A5F5);
    case ExpenseCategory.fuel:          return const Color(0xFFFF6B00);
    case ExpenseCategory.maintenance:   return const Color(0xFF616161);

    // LIFESTYLE
    case ExpenseCategory.entertainment: return const Color(0xFF9C27B0);
    case ExpenseCategory.electronics:   return const Color(0xFF1565C0);
    case ExpenseCategory.vacation:      return const Color(0xFFFFA726);
    case ExpenseCategory.clothing:      return const Color(0xFF7E57C2);
    case ExpenseCategory.gifts:         return const Color(0xFFE91E63);

    // DEVELOPMENT
    case ExpenseCategory.education:     return const Color(0xFF6A1B9A);

    // FINANCE
    case ExpenseCategory.investment:    return const Color(0xFF2E7D32);
    case ExpenseCategory.savings:       return AppColors.income;

    // NEGATIVE / COSTS
    case ExpenseCategory.debt:          return const Color(0xFFC62828);
    case ExpenseCategory.fees:          return const Color(0xFF90A4AE);

    // HEALTH
    case ExpenseCategory.health:        return const Color(0xFFEC407A);
    case ExpenseCategory.medications:   return const Color(0xFF26A69A);

    // OTHER LIFE
    case ExpenseCategory.kids:          return const Color(0xFFFFE0B2);
    case ExpenseCategory.pets:          return const Color(0xFFA1887F);

    // SERVICES
    case ExpenseCategory.communication: return const Color(0xFF3949AB);
    case ExpenseCategory.subscriptions: return const Color(0xFF5C6BC0);

    // EXTRA
    case ExpenseCategory.donations:     return const Color(0xFFCE93D8);
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
