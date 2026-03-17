import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';

void main() {
  group('Expense', () {
    final date = DateTime(2024, 1, 15);

    test('stores all required fields', () {
      final expense = Expense(
        id: '1',
        amount: 42.5,
        category: ExpenseCategory.groceries,
        date: date,
      );

      expect(expense.id, '1');
      expect(expense.amount, 42.5);
      expect(expense.category, ExpenseCategory.groceries);
      expect(expense.financialType, FinancialType.consumption);
      expect(expense.date, date);
      expect(expense.note, isNull);
    });

    test('stores optional note when provided', () {
      final expense = Expense(
        id: '2',
        amount: 10.0,
        category: ExpenseCategory.transport,
        date: date,
        note: 'Bus ticket',
      );

      expect(expense.note, 'Bus ticket');
    });

    test('note defaults to null when omitted', () {
      final expense = Expense(
        id: '3',
        amount: 5.0,
        category: ExpenseCategory.other,
        date: date,
      );

      expect(expense.note, isNull);
    });

    test('supports zero amount', () {
      final expense = Expense(
        id: '4',
        amount: 0.0,
        category: ExpenseCategory.other,
        date: date,
      );

      expect(expense.amount, 0.0);
    });

    test('supports large amount', () {
      final expense = Expense(
        id: '5',
        amount: 999999.99,
        category: ExpenseCategory.clothing,
        date: date,
      );

      expect(expense.amount, 999999.99);
    });

    test('financialType defaults to consumption', () {
      final expense = Expense(
        id: '6',
        amount: 50.0,
        category: ExpenseCategory.health,
        date: date,
      );

      expect(expense.financialType, FinancialType.consumption);
    });

    test('financialType can be set to asset', () {
      final expense = Expense(
        id: '7',
        amount: 100.0,
        category: ExpenseCategory.investment,
        date: date,
        financialType: FinancialType.asset,
      );

      expect(expense.financialType, FinancialType.asset);
    });

    group('serialization', () {
      test('toJson and fromJson round-trip preserves all fields', () {
        final expense = Expense(
          id: 'abc',
          amount: 29.99,
          category: ExpenseCategory.restaurants,
          financialType: FinancialType.consumption,
          date: date,
          note: 'Lunch',
        );

        final json = expense.toJson();
        final restored = Expense.fromJson(json);

        expect(restored.id, expense.id);
        expect(restored.amount, expense.amount);
        expect(restored.category, expense.category);
        expect(restored.financialType, expense.financialType);
        expect(restored.date, expense.date);
        expect(restored.note, expense.note);
        expect(restored.group, isNull);
      });

      test('toJson and fromJson round-trip preserves group', () {
        final expense = Expense(
          id: 'g1',
          amount: 150.0,
          category: ExpenseCategory.vacation,
          date: date,
          group: 'Summer Trip',
        );

        final restored = Expense.fromJson(expense.toJson());

        expect(restored.group, 'Summer Trip');
      });

      test('group defaults to null when missing from JSON (backward compat)', () {
        final json = {
          'id': 'old5',
          'amount': 10.0,
          'category': 'groceries',
          'financialType': 'consumption',
          'date': date.toIso8601String(),
          'note': null,
        };
        final expense = Expense.fromJson(json);
        expect(expense.group, isNull);
      });

      test('group null is preserved through round-trip', () {
        final expense = Expense(
          id: 'ng1',
          amount: 20.0,
          category: ExpenseCategory.groceries,
          date: date,
        );
        final restored = Expense.fromJson(expense.toJson());
        expect(restored.group, isNull);
      });

      test('fromJson handles missing financialType (legacy records)', () {
        final json = {
          'id': 'old1',
          'amount': 15.0,
          'category': 'groceries',
          'date': date.toIso8601String(),
          'note': null,
        };
        final expense = Expense.fromJson(json);
        expect(expense.financialType, FinancialType.consumption);
      });

      test('fromJson maps legacy string category Food to groceries', () {
        final json = {
          'id': 'old2',
          'amount': 10.0,
          'category': 'Food',
          'date': date.toIso8601String(),
          'note': null,
        };
        final expense = Expense.fromJson(json);
        expect(expense.category, ExpenseCategory.groceries);
      });

      test('fromJson maps legacy string category Shopping to clothing', () {
        final json = {
          'id': 'old3',
          'amount': 20.0,
          'category': 'Shopping',
          'date': date.toIso8601String(),
          'note': null,
        };
        final expense = Expense.fromJson(json);
        expect(expense.category, ExpenseCategory.clothing);
      });

      test('fromJson maps unknown legacy string to other', () {
        final json = {
          'id': 'old4',
          'amount': 5.0,
          'category': 'UnknownCategory',
          'date': date.toIso8601String(),
          'note': null,
        };
        final expense = Expense.fromJson(json);
        expect(expense.category, ExpenseCategory.other);
      });
    });
  });
}
