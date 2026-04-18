import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/category_preferences.dart';
import 'package:finance_tracker/models/expense_category.dart';

void main() {
  group('CategoryPreferences.visibleForExpenses', () {
    test('empty prefs returns all default categories', () {
      const prefs = CategoryPreferences.empty();
      final visible = prefs.visibleForExpenses;
      for (final cat in CategoryPreferences.defaultExpenses) {
        expect(visible, contains(cat));
      }
    });

    test('always includes other regardless of deltas', () {
      final prefs = CategoryPreferences(
        expensesAdded: const {},
        expensesRemoved: {ExpenseCategory.other},
        planAdded: const {},
        planRemoved: const {},
      );
      expect(prefs.visibleForExpenses, contains(ExpenseCategory.other));
    });

    test('expensesAdded makes non-default category visible', () {
      final prefs = CategoryPreferences(
        expensesAdded: {ExpenseCategory.fuel},
        expensesRemoved: const {},
        planAdded: const {},
        planRemoved: const {},
      );
      expect(prefs.visibleForExpenses, contains(ExpenseCategory.fuel));
    });

    test('expensesRemoved hides a default category', () {
      final prefs = CategoryPreferences(
        expensesAdded: const {},
        expensesRemoved: {ExpenseCategory.clothing},
        planAdded: const {},
        planRemoved: const {},
      );
      expect(prefs.visibleForExpenses, isNot(contains(ExpenseCategory.clothing)));
    });

    test('non-default category not in added is not visible', () {
      const prefs = CategoryPreferences.empty();
      expect(prefs.visibleForExpenses, isNot(contains(ExpenseCategory.fuel)));
    });
  });

  group('CategoryPreferences.visibleForPlan', () {
    test('empty prefs returns all default plan categories', () {
      const prefs = CategoryPreferences.empty();
      final visible = prefs.visibleForPlan;
      for (final cat in CategoryPreferences.defaultPlan) {
        expect(visible, contains(cat));
      }
    });

    test('always includes other', () {
      final prefs = CategoryPreferences(
        expensesAdded: const {},
        expensesRemoved: const {},
        planAdded: const {},
        planRemoved: {ExpenseCategory.other},
      );
      expect(prefs.visibleForPlan, contains(ExpenseCategory.other));
    });

    test('planAdded makes non-default category visible in plan', () {
      final prefs = CategoryPreferences(
        expensesAdded: const {},
        expensesRemoved: const {},
        planAdded: {ExpenseCategory.fuel},
        planRemoved: const {},
      );
      expect(prefs.visibleForPlan, contains(ExpenseCategory.fuel));
    });

    test('planRemoved hides a default plan category', () {
      final prefs = CategoryPreferences(
        expensesAdded: const {},
        expensesRemoved: const {},
        planAdded: const {},
        planRemoved: {ExpenseCategory.housing},
      );
      expect(prefs.visibleForPlan, isNot(contains(ExpenseCategory.housing)));
    });
  });

  group('CategoryPreferences.toJson / fromJson', () {
    test('round-trips empty prefs', () {
      const original = CategoryPreferences.empty();
      final restored = CategoryPreferences.fromJson(original.toJson());
      expect(restored.expensesAdded, isEmpty);
      expect(restored.expensesRemoved, isEmpty);
      expect(restored.planAdded, isEmpty);
      expect(restored.planRemoved, isEmpty);
    });

    test('round-trips non-empty prefs', () {
      final original = CategoryPreferences(
        expensesAdded: {ExpenseCategory.fuel, ExpenseCategory.kids},
        expensesRemoved: {ExpenseCategory.clothing},
        planAdded: {ExpenseCategory.donations},
        planRemoved: {ExpenseCategory.housing},
      );
      final restored = CategoryPreferences.fromJson(original.toJson());
      expect(restored.expensesAdded, containsAll([ExpenseCategory.fuel, ExpenseCategory.kids]));
      expect(restored.expensesRemoved, contains(ExpenseCategory.clothing));
      expect(restored.planAdded, contains(ExpenseCategory.donations));
      expect(restored.planRemoved, contains(ExpenseCategory.housing));
    });

    test('includes version key', () {
      const prefs = CategoryPreferences.empty();
      expect(prefs.toJson()['version'], equals(1));
    });

    test('fromJson with missing keys defaults to empty sets', () {
      final restored = CategoryPreferences.fromJson({'version': 1});
      expect(restored.expensesAdded, isEmpty);
      expect(restored.expensesRemoved, isEmpty);
      expect(restored.planAdded, isEmpty);
      expect(restored.planRemoved, isEmpty);
    });

    test('fromJson unknown category name maps to other', () {
      final restored = CategoryPreferences.fromJson({
        'expensesAdded': ['unknownCategory'],
        'expensesRemoved': [],
        'planAdded': [],
        'planRemoved': [],
      });
      expect(restored.expensesAdded, contains(ExpenseCategory.other));
    });
  });

  group('CategoryPreferences.copyWith', () {
    test('returns unchanged fields when no args provided', () {
      final original = CategoryPreferences(
        expensesAdded: {ExpenseCategory.fuel},
        expensesRemoved: const {},
        planAdded: const {},
        planRemoved: const {},
      );
      final copy = original.copyWith();
      expect(copy.expensesAdded, equals(original.expensesAdded));
    });

    test('overrides only specified fields', () {
      final original = CategoryPreferences(
        expensesAdded: {ExpenseCategory.fuel},
        expensesRemoved: {ExpenseCategory.clothing},
        planAdded: const {},
        planRemoved: const {},
      );
      final copy = original.copyWith(expensesAdded: {ExpenseCategory.kids});
      expect(copy.expensesAdded, equals({ExpenseCategory.kids}));
      expect(copy.expensesRemoved, equals({ExpenseCategory.clothing}));
    });
  });
}
