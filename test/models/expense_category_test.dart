import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';

void main() {
  group('ExpenseCategoryX.defaultFinancialType', () {
    test('investment → asset', () {
      expect(ExpenseCategory.investment.defaultFinancialType,
          FinancialType.asset);
    });

    test('insurance → insurance', () {
      expect(ExpenseCategory.insurance.defaultFinancialType,
          FinancialType.insurance);
    });

    test('all other categories → consumption', () {
      const consumptionCategories = [
        ExpenseCategory.housing,
        ExpenseCategory.groceries,
        ExpenseCategory.vacation,
        ExpenseCategory.transport,
        ExpenseCategory.subscriptions,
        ExpenseCategory.communication,
        ExpenseCategory.health,
        ExpenseCategory.restaurants,
        ExpenseCategory.entertainment,
        ExpenseCategory.clothing,
        ExpenseCategory.education,
        ExpenseCategory.gifts,
        ExpenseCategory.taxes,
        ExpenseCategory.medications,
        ExpenseCategory.other,
      ];
      for (final cat in consumptionCategories) {
        expect(
          cat.defaultFinancialType,
          FinancialType.consumption,
          reason: '${cat.name} should default to consumption',
        );
      }
    });

    test('covers every ExpenseCategory value', () {
      // Ensures no category is accidentally unhandled if enum grows.
      for (final cat in ExpenseCategory.values) {
        expect(
          () => cat.defaultFinancialType,
          returnsNormally,
          reason: '${cat.name} must have a defaultFinancialType',
        );
      }
    });
  });
}
