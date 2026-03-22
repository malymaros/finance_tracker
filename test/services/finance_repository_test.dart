import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/services/finance_repository.dart';

Expense makeExpense({String id = '1', double amount = 10.0}) => Expense(
      id: id,
      amount: amount,
      category: ExpenseCategory.groceries,
      date: DateTime(2024, 1, 1),
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

  group('FinanceRepository — expensesForGroup', () {
    test('returns expenses matching group and period', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(Expense(
        id: '1',
        amount: 50.0,
        category: ExpenseCategory.groceries,
        date: DateTime(2024, 3, 1),
        group: 'Vacation',
      ));
      await repo.addExpense(Expense(
        id: '2',
        amount: 30.0,
        category: ExpenseCategory.transport,
        date: DateTime(2024, 3, 10),
        group: 'Vacation',
      ));
      await repo.addExpense(Expense(
        id: '3',
        amount: 20.0,
        category: ExpenseCategory.groceries,
        date: DateTime(2024, 3, 5),
        group: 'Birthday',
      ));

      final result = repo.expensesForGroup('Vacation', 2024, 3);
      expect(result.length, 2);
      expect(result.map((e) => e.id), containsAll(['1', '2']));
    });

    test('excludes expenses with different group name', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(Expense(
        id: '1',
        amount: 100.0,
        category: ExpenseCategory.groceries,
        date: DateTime(2024, 3, 1),
        group: 'Vacation',
      ));
      await repo.addExpense(Expense(
        id: '2',
        amount: 40.0,
        category: ExpenseCategory.groceries,
        date: DateTime(2024, 3, 5),
        group: 'Birthday',
      ));

      expect(repo.expensesForGroup('Vacation', 2024, 3).length, 1);
      expect(repo.expensesForGroup('Birthday', 2024, 3).length, 1);
    });

    test('excludes expenses with no group', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(Expense(
        id: '1',
        amount: 10.0,
        category: ExpenseCategory.groceries,
        date: DateTime(2024, 3, 1),
      ));
      await repo.addExpense(Expense(
        id: '2',
        amount: 20.0,
        category: ExpenseCategory.groceries,
        date: DateTime(2024, 3, 5),
        group: 'Vacation',
      ));

      expect(repo.expensesForGroup('Vacation', 2024, 3).length, 1);
    });

    test('excludes expenses outside the requested period', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(Expense(
        id: '1',
        amount: 50.0,
        category: ExpenseCategory.groceries,
        date: DateTime(2024, 3, 1),
        group: 'Vacation',
      ));
      await repo.addExpense(Expense(
        id: '2',
        amount: 50.0,
        category: ExpenseCategory.groceries,
        date: DateTime(2024, 4, 1),
        group: 'Vacation',
      ));

      expect(repo.expensesForGroup('Vacation', 2024, 3).length, 1);
      expect(repo.expensesForGroup('Vacation', 2024, 4).length, 1);
    });

    test('returns empty when no expenses match', () {
      final repo = FinanceRepository(persist: false);
      expect(repo.expensesForGroup('Vacation', 2024, 3), isEmpty);
    });
  });

  group('FinanceRepository — groupSummariesForMonth', () {
    test('returns groups visible in the month with all-time expenses', () async {
      final repo = FinanceRepository(persist: false);
      // Jan expense
      await repo.addExpense(Expense(
        id: '1', amount: 100.0, category: ExpenseCategory.vacation,
        date: DateTime(2024, 1, 10), group: 'Vacation',
      ));
      // Dec expense — same group
      await repo.addExpense(Expense(
        id: '2', amount: 100.0, category: ExpenseCategory.vacation,
        date: DateTime(2024, 12, 5), group: 'Vacation',
      ));

      final janSummaries = repo.groupSummariesForMonth(2024, 1);
      expect(janSummaries.length, 1);
      expect(janSummaries.first.key, 'Vacation');
      // All-time total: both expenses, not just January
      expect(janSummaries.first.value.length, 2);
      expect(janSummaries.first.value.fold(0.0, (s, e) => s + e.amount), 200.0);

      final decSummaries = repo.groupSummariesForMonth(2024, 12);
      expect(decSummaries.length, 1);
      expect(decSummaries.first.value.fold(0.0, (s, e) => s + e.amount), 200.0);
    });

    test('excludes groups with no expense in the month', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(Expense(
        id: '1', amount: 50.0, category: ExpenseCategory.vacation,
        date: DateTime(2024, 3, 1), group: 'Vacation',
      ));

      // June has no expenses — group should not appear
      expect(repo.groupSummariesForMonth(2024, 6), isEmpty);
    });

    test('returns multiple groups sorted by all-time total descending', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(Expense(
        id: '1', amount: 30.0, category: ExpenseCategory.groceries,
        date: DateTime(2024, 3, 1), group: 'Birthday',
      ));
      await repo.addExpense(Expense(
        id: '2', amount: 200.0, category: ExpenseCategory.vacation,
        date: DateTime(2024, 3, 5), group: 'Vacation',
      ));
      // Extra Vacation expense in a different month — counted in all-time total
      await repo.addExpense(Expense(
        id: '3', amount: 150.0, category: ExpenseCategory.vacation,
        date: DateTime(2024, 1, 10), group: 'Vacation',
      ));

      final summaries = repo.groupSummariesForMonth(2024, 3);
      expect(summaries.length, 2);
      // Vacation all-time = 350, Birthday = 30 → Vacation first
      expect(summaries[0].key, 'Vacation');
      expect(summaries[0].value.fold(0.0, (s, e) => s + e.amount), 350.0);
      expect(summaries[1].key, 'Birthday');
    });

    test('returns empty when no expenses in month', () {
      final repo = FinanceRepository(persist: false);
      expect(repo.groupSummariesForMonth(2024, 3), isEmpty);
    });
  });

  group('FinanceRepository — cross-month group totalling', () {
    test('all expenses for a group are accessible regardless of month', () async {
      // Jan 100€ + Dec 100€ — both months should be able to see 200€ total
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(Expense(
        id: '1',
        amount: 100.0,
        category: ExpenseCategory.vacation,
        date: DateTime(2024, 1, 10),
        group: 'Vacation',
      ));
      await repo.addExpense(Expense(
        id: '2',
        amount: 100.0,
        category: ExpenseCategory.vacation,
        date: DateTime(2024, 12, 5),
        group: 'Vacation',
      ));

      // All-time total for the group
      final allForGroup =
          repo.expenses.where((e) => e.group == 'Vacation').toList();
      final total = allForGroup.fold(0.0, (s, e) => s + e.amount);

      expect(allForGroup.length, 2);
      expect(total, 200.0);

      // Group is visible in January (has ≥1 expense there)
      expect(repo.expensesForGroup('Vacation', 2024, 1).length, 1);
      // Group is visible in December (has ≥1 expense there)
      expect(repo.expensesForGroup('Vacation', 2024, 12).length, 1);
      // Group is NOT visible in a month with no expense
      expect(repo.expensesForGroup('Vacation', 2024, 6), isEmpty);
    });
  });

  group('FinanceRepository — restoreFromSnapshot preserves group', () {
    test('group field is preserved after restoreFromSnapshot', () async {
      final repo = FinanceRepository(persist: false);
      final expenses = [
        Expense(
          id: '1',
          amount: 75.0,
          category: ExpenseCategory.vacation,
          date: DateTime(2024, 6, 1),
          group: 'Summer Trip',
        ),
        Expense(
          id: '2',
          amount: 30.0,
          category: ExpenseCategory.groceries,
          date: DateTime(2024, 6, 5),
        ),
      ];

      await repo.restoreFromSnapshot(expenses);

      expect(repo.expenses.length, 2);
      expect(repo.expenses.firstWhere((e) => e.id == '1').group, 'Summer Trip');
      expect(repo.expenses.firstWhere((e) => e.id == '2').group, isNull);
    });
  });

  group('Expense serialization', () {
    test('toJson and fromJson round-trip', () {
      final original = Expense(
        id: 'abc',
        amount: 42.5,
        category: ExpenseCategory.restaurants,
        date: DateTime(2024, 3, 15),
        note: 'lunch',
      );
      final restored = Expense.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.amount, original.amount);
      expect(restored.category, original.category);
      expect(restored.financialType, original.financialType);
      expect(restored.date, original.date);
      expect(restored.note, original.note);
    });
  });

  group('FinanceRepository — reportLinesForMonth', () {
    test('empty repo returns empty list', () {
      final repo = FinanceRepository(persist: false);
      expect(repo.reportLinesForMonth(2024, 3), isEmpty);
    });

    test('returns one line per expense in the month', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(Expense(
        id: '1',
        amount: 50.0,
        category: ExpenseCategory.groceries,
        financialType: FinancialType.consumption,
        date: DateTime(2024, 3, 10),
      ));
      await repo.addExpense(Expense(
        id: '2',
        amount: 200.0,
        category: ExpenseCategory.investment,
        financialType: FinancialType.asset,
        date: DateTime(2024, 3, 20),
      ));
      final lines = repo.reportLinesForMonth(2024, 3);
      expect(lines.length, 2);
    });

    test('preserves category and financialType from expense', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(Expense(
        id: '1',
        amount: 300.0,
        category: ExpenseCategory.investment,
        financialType: FinancialType.asset,
        date: DateTime(2024, 3, 5),
      ));
      final line = repo.reportLinesForMonth(2024, 3).first;
      expect(line.category, ExpenseCategory.investment);
      expect(line.financialType, FinancialType.asset);
      expect(line.amount, 300.0);
    });

    test('excludes expenses from other months', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(Expense(
        id: '1',
        amount: 50.0,
        category: ExpenseCategory.groceries,
        date: DateTime(2024, 3, 1),
      ));
      await repo.addExpense(Expense(
        id: '2',
        amount: 99.0,
        category: ExpenseCategory.groceries,
        date: DateTime(2024, 4, 1),
      ));
      expect(repo.reportLinesForMonth(2024, 3).length, 1);
      expect(repo.reportLinesForMonth(2024, 4).length, 1);
      expect(repo.reportLinesForMonth(2024, 5).length, 0);
    });
  });

  group('FinanceRepository — reportLinesForYear', () {
    test('empty repo returns empty list', () {
      expect(FinanceRepository(persist: false).reportLinesForYear(2024), isEmpty);
    });

    test('returns one line per expense in the year', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(Expense(
          id: '1', amount: 10, category: ExpenseCategory.groceries,
          date: DateTime(2024, 1, 1)));
      await repo.addExpense(Expense(
          id: '2', amount: 20, category: ExpenseCategory.transport,
          date: DateTime(2024, 12, 31)));
      // Expense in different year — excluded
      await repo.addExpense(Expense(
          id: '3', amount: 30, category: ExpenseCategory.groceries,
          date: DateTime(2025, 1, 1)));
      expect(repo.reportLinesForYear(2024).length, 2);
    });
  });
}
