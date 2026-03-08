import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';

void main() {
  group('Expense', () {
    final date = DateTime(2024, 1, 15);

    test('stores all required fields', () {
      final expense = Expense(
        id: '1',
        amount: 42.5,
        category: 'Food',
        date: date,
      );

      expect(expense.id, '1');
      expect(expense.amount, 42.5);
      expect(expense.category, 'Food');
      expect(expense.date, date);
      expect(expense.note, isNull);
    });

    test('stores optional note when provided', () {
      final expense = Expense(
        id: '2',
        amount: 10.0,
        category: 'Transport',
        date: date,
        note: 'Bus ticket',
      );

      expect(expense.note, 'Bus ticket');
    });

    test('note defaults to null when omitted', () {
      final expense = Expense(
        id: '3',
        amount: 5.0,
        category: 'Other',
        date: date,
      );

      expect(expense.note, isNull);
    });

    test('supports zero amount', () {
      final expense = Expense(
        id: '4',
        amount: 0.0,
        category: 'Other',
        date: date,
      );

      expect(expense.amount, 0.0);
    });

    test('supports large amount', () {
      final expense = Expense(
        id: '5',
        amount: 999999.99,
        category: 'Shopping',
        date: date,
      );

      expect(expense.amount, 999999.99);
    });
  });
}
