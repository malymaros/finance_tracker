import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/fixed_cost.dart';
import 'package:finance_tracker/models/income_entry.dart';
import 'package:finance_tracker/services/finance_repository.dart';

Expense makeExpense({String id = '1', double amount = 10.0}) => Expense(
      id: id,
      amount: amount,
      category: 'Food',
      date: DateTime(2024, 1, 1),
    );

IncomeEntry makeIncome({
  String id = '1',
  double amount = 1000.0,
  DateTime? date,
  IncomeType type = IncomeType.monthly,
}) =>
    IncomeEntry(
      id: id,
      amount: amount,
      date: date ?? DateTime(2024, 3, 1),
      type: type,
    );

FixedCost makeFixedCost({
  String id = '1',
  String name = 'Rent',
  double amount = 800.0,
  Recurrence recurrence = Recurrence.monthly,
  int startYear = 2024,
  int startMonth = 1,
}) =>
    FixedCost(
      id: id,
      name: name,
      amount: amount,
      recurrence: recurrence,
      startYear: startYear,
      startMonth: startMonth,
    );

void main() {
  group('FinanceRepository — expenses', () {
    test('starts empty', () {
      expect(FinanceRepository(persist: false).expenses, isEmpty);
    });

    test('addExpense increases list length', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(makeExpense());
      expect(repo.expenses.length, 1);
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

    test('notifies listeners when expense is added', () async {
      final repo = FinanceRepository(persist: false);
      var notified = false;
      repo.addListener(() => notified = true);
      await repo.addExpense(makeExpense());
      expect(notified, isTrue);
    });

    test('removeExpense removes by id', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(makeExpense(id: 'a'));
      await repo.addExpense(makeExpense(id: 'b'));
      await repo.removeExpense('a');
      expect(repo.expenses.length, 1);
      expect(repo.expenses.first.id, 'b');
    });

    test('updateExpense replaces the matching item', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(makeExpense(id: '1', amount: 10.0));
      await repo.updateExpense(makeExpense(id: '1', amount: 99.0));
      expect(repo.expenses.length, 1);
      expect(repo.expenses.first.amount, 99.0);
    });
  });

  group('FinanceRepository — income', () {
    test('starts with no income', () {
      expect(FinanceRepository(persist: false).income, isEmpty);
    });

    test('addIncome increases list length', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addIncome(makeIncome());
      expect(repo.income.length, 1);
    });

    test('income preserves all fields', () async {
      final repo = FinanceRepository(persist: false);
      final date = DateTime(2024, 5, 10);
      await repo.addIncome(IncomeEntry(
        id: 'x',
        amount: 2500.0,
        date: date,
        type: IncomeType.oneTime,
        description: 'Bonus',
      ));
      final stored = repo.income.first;
      expect(stored.id, 'x');
      expect(stored.amount, 2500.0);
      expect(stored.date, date);
      expect(stored.type, IncomeType.oneTime);
      expect(stored.description, 'Bonus');
    });

    test('incomeForMonth filters by year and month', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addIncome(makeIncome(id: '1', date: DateTime(2024, 3, 1)));
      await repo.addIncome(makeIncome(id: '2', date: DateTime(2024, 3, 15)));
      await repo.addIncome(makeIncome(id: '3', date: DateTime(2024, 4, 1)));
      expect(repo.incomeForMonth(2024, 3).length, 2);
      expect(repo.incomeForMonth(2024, 4).length, 1);
      expect(repo.incomeForMonth(2024, 5).length, 0);
    });

    test('totalIncomeForMonth sums correctly', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addIncome(makeIncome(amount: 1000, date: DateTime(2024, 3, 1)));
      await repo.addIncome(makeIncome(amount: 500, date: DateTime(2024, 3, 15)));
      await repo.addIncome(makeIncome(amount: 200, date: DateTime(2024, 4, 1)));
      expect(repo.totalIncomeForMonth(2024, 3), 1500.0);
      expect(repo.totalIncomeForMonth(2024, 4), 200.0);
    });

    test('notifies listeners when income is added', () async {
      final repo = FinanceRepository(persist: false);
      var notified = false;
      repo.addListener(() => notified = true);
      await repo.addIncome(makeIncome());
      expect(notified, isTrue);
    });

    test('removeIncome removes by id', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addIncome(makeIncome(id: 'a'));
      await repo.addIncome(makeIncome(id: 'b'));
      await repo.removeIncome('a');
      expect(repo.income.length, 1);
      expect(repo.income.first.id, 'b');
    });

    test('updateIncome replaces the matching item', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addIncome(makeIncome(id: '1', amount: 1000.0));
      await repo.updateIncome(makeIncome(id: '1', amount: 2000.0));
      expect(repo.income.length, 1);
      expect(repo.income.first.amount, 2000.0);
    });
  });

  group('FinanceRepository — fixed costs', () {
    test('starts with no fixed costs', () {
      expect(FinanceRepository(persist: false).fixedCosts, isEmpty);
    });

    test('addFixedCost increases list length', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addFixedCost(makeFixedCost());
      expect(repo.fixedCosts.length, 1);
    });

    test('monthly fixed cost applies after start month', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addFixedCost(
          makeFixedCost(recurrence: Recurrence.monthly, startYear: 2024, startMonth: 3));
      expect(repo.fixedCostsForMonth(2024, 2), isEmpty);
      expect(repo.fixedCostsForMonth(2024, 3).length, 1);
      expect(repo.fixedCostsForMonth(2024, 4).length, 1);
      expect(repo.fixedCostsForMonth(2025, 1).length, 1);
    });

    test('yearly fixed cost applies only in start month each year', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addFixedCost(
          makeFixedCost(recurrence: Recurrence.yearly, startYear: 2024, startMonth: 6));
      expect(repo.fixedCostsForMonth(2024, 5), isEmpty);
      expect(repo.fixedCostsForMonth(2024, 6).length, 1);
      expect(repo.fixedCostsForMonth(2024, 7), isEmpty);
      expect(repo.fixedCostsForMonth(2025, 6).length, 1);
      expect(repo.fixedCostsForMonth(2023, 6), isEmpty);
    });

    test('totalFixedCostsForMonth sums correctly', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addFixedCost(makeFixedCost(
          id: '1', amount: 800, recurrence: Recurrence.monthly, startYear: 2024, startMonth: 1));
      await repo.addFixedCost(makeFixedCost(
          id: '2', amount: 50, recurrence: Recurrence.monthly, startYear: 2024, startMonth: 1));
      expect(repo.totalFixedCostsForMonth(2024, 6), 850.0);
    });

    test('totalFixedCostsForYear counts monthly costs per active month', () async {
      final repo = FinanceRepository(persist: false);
      // Starts July 2024 — active for 6 months in 2024
      await repo.addFixedCost(makeFixedCost(
          amount: 100, recurrence: Recurrence.monthly, startYear: 2024, startMonth: 7));
      expect(repo.totalFixedCostsForYear(2024), 600.0);
      expect(repo.totalFixedCostsForYear(2025), 1200.0);
    });

    test('totalFixedCostsForYear includes yearly cost once', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addFixedCost(makeFixedCost(
          amount: 600, recurrence: Recurrence.yearly, startYear: 2024, startMonth: 3));
      expect(repo.totalFixedCostsForYear(2023), 0.0);
      expect(repo.totalFixedCostsForYear(2024), 600.0);
      expect(repo.totalFixedCostsForYear(2025), 600.0);
    });

    test('notifies listeners when fixed cost is added', () async {
      final repo = FinanceRepository(persist: false);
      var notified = false;
      repo.addListener(() => notified = true);
      await repo.addFixedCost(makeFixedCost());
      expect(notified, isTrue);
    });

    test('removeFixedCost removes by id', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addFixedCost(makeFixedCost(id: 'a'));
      await repo.addFixedCost(makeFixedCost(id: 'b'));
      await repo.removeFixedCost('a');
      expect(repo.fixedCosts.length, 1);
      expect(repo.fixedCosts.first.id, 'b');
    });

    test('updateFixedCost replaces the matching item', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addFixedCost(makeFixedCost(id: '1', amount: 800.0));
      await repo.updateFixedCost(makeFixedCost(id: '1', amount: 1200.0));
      expect(repo.fixedCosts.length, 1);
      expect(repo.fixedCosts.first.amount, 1200.0);
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
      final restored = Expense.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.amount, original.amount);
      expect(restored.category, original.category);
      expect(restored.date, original.date);
      expect(restored.note, original.note);
    });
  });

  group('IncomeEntry serialization', () {
    test('toJson and fromJson round-trip', () {
      final original = IncomeEntry(
        id: 'i1',
        amount: 1500.0,
        date: DateTime(2024, 4, 1),
        type: IncomeType.monthly,
        description: 'Salary',
      );
      final restored = IncomeEntry.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.amount, original.amount);
      expect(restored.date, original.date);
      expect(restored.type, original.type);
      expect(restored.description, original.description);
    });

    test('fromJson handles null description', () {
      final entry = IncomeEntry.fromJson({
        'id': '1',
        'amount': 100.0,
        'date': '2024-01-01T00:00:00.000',
        'type': 'oneTime',
        'description': null,
      });
      expect(entry.description, isNull);
    });
  });

  group('FixedCost serialization', () {
    test('toJson and fromJson round-trip', () {
      final original = FixedCost(
        id: 'fc1',
        name: 'Rent',
        amount: 800.0,
        recurrence: Recurrence.monthly,
        startYear: 2024,
        startMonth: 1,
      );
      final restored = FixedCost.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.amount, original.amount);
      expect(restored.recurrence, original.recurrence);
      expect(restored.startYear, original.startYear);
      expect(restored.startMonth, original.startMonth);
    });
  });
}
