import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/services/finance_repository.dart';

Expense makeExpense({String id = '1', double amount = 10.0}) => Expense(
      id: id,
      amount: amount,
      category: 'Food',
      date: DateTime(2024, 1, 1),
    );

void main() {
  group('FinanceRepository', () {
    test('starts empty', () {
      final repo = FinanceRepository(persist: false);
      expect(repo.expenses, isEmpty);
    });

    test('addExpense increases list length', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(makeExpense());
      expect(repo.expenses.length, 1);
    });

    test('addExpense accumulates multiple expenses', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(makeExpense(id: '1'));
      await repo.addExpense(makeExpense(id: '2'));
      await repo.addExpense(makeExpense(id: '3'));
      expect(repo.expenses.length, 3);
    });

    test('expenses are returned in insertion order', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(makeExpense(id: 'a'));
      await repo.addExpense(makeExpense(id: 'b'));
      expect(repo.expenses[0].id, 'a');
      expect(repo.expenses[1].id, 'b');
    });

    test('expenses list is unmodifiable', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(makeExpense());
      expect(() => (repo.expenses as dynamic).add(makeExpense(id: '99')),
          throwsUnsupportedError);
    });

    test('seed initializes repository with expenses', () {
      final repo = FinanceRepository(
        persist: false,
        seed: [makeExpense(id: 'seeded')],
      );
      expect(repo.expenses.length, 1);
      expect(repo.expenses.first.id, 'seeded');
    });

    test('stored expense preserves all fields', () async {
      final repo = FinanceRepository(persist: false);
      final date = DateTime(2024, 6, 15);
      await repo.addExpense(Expense(
        id: 'x',
        amount: 99.99,
        category: 'Health',
        date: date,
        note: 'Doctor visit',
      ));
      final stored = repo.expenses.first;
      expect(stored.id, 'x');
      expect(stored.amount, 99.99);
      expect(stored.category, 'Health');
      expect(stored.date, date);
      expect(stored.note, 'Doctor visit');
    });

    test('notifies listeners when expense is added', () async {
      final repo = FinanceRepository(persist: false);
      var notified = false;
      repo.addListener(() => notified = true);
      await repo.addExpense(makeExpense());
      expect(notified, isTrue);
    });
  });

  group('Expense serialization', () {
    test('toJson and fromJson round-trip', () {
      final original = Expense(
        id: 'abc',
        amount: 42.5,
        category: 'Food',
        date: DateTime(2024, 3, 15),
        note: 'lunch',
      );
      final json = original.toJson();
      final restored = Expense.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.amount, original.amount);
      expect(restored.category, original.category);
      expect(restored.date, original.date);
      expect(restored.note, original.note);
    });

    test('fromJson handles null note', () {
      final expense = Expense.fromJson({
        'id': '1',
        'amount': 10.0,
        'category': 'Other',
        'date': '2024-01-01T00:00:00.000',
        'note': null,
      });
      expect(expense.note, isNull);
    });
  });
}
