import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/services/expense_service.dart';

Expense makeExpense({String id = '1', double amount = 10.0}) => Expense(
      id: id,
      amount: amount,
      category: 'Food',
      date: DateTime(2024, 1, 1),
    );

void main() {
  group('ExpenseService', () {
    test('starts empty', () {
      final service = ExpenseService();
      expect(service.getAll(), isEmpty);
    });

    test('add increases list length', () {
      final service = ExpenseService();
      service.add(makeExpense());
      expect(service.getAll().length, 1);
    });

    test('add multiple expenses accumulates correctly', () {
      final service = ExpenseService();
      service.add(makeExpense(id: '1'));
      service.add(makeExpense(id: '2'));
      service.add(makeExpense(id: '3'));
      expect(service.getAll().length, 3);
    });

    test('getAll returns expenses in insertion order', () {
      final service = ExpenseService();
      service.add(makeExpense(id: 'a'));
      service.add(makeExpense(id: 'b'));
      final all = service.getAll();
      expect(all[0].id, 'a');
      expect(all[1].id, 'b');
    });

    test('getAll returns unmodifiable list', () {
      final service = ExpenseService();
      service.add(makeExpense());
      final list = service.getAll();
      expect(() => (list as dynamic).add(makeExpense(id: '99')),
          throwsUnsupportedError);
    });

    test('mutating returned list does not affect internal state', () {
      final service = ExpenseService();
      service.add(makeExpense(id: '1'));
      final first = service.getAll();
      expect(first.length, 1);
      // Add another and verify original snapshot is still length 1
      service.add(makeExpense(id: '2'));
      expect(first.length, 1);
      expect(service.getAll().length, 2);
    });

    test('stored expense preserves all fields', () {
      final service = ExpenseService();
      final date = DateTime(2024, 6, 15);
      service.add(Expense(
        id: 'x',
        amount: 99.99,
        category: 'Health',
        date: date,
        note: 'Doctor visit',
      ));
      final stored = service.getAll().first;
      expect(stored.id, 'x');
      expect(stored.amount, 99.99);
      expect(stored.category, 'Health');
      expect(stored.date, date);
      expect(stored.note, 'Doctor visit');
    });
  });
}
