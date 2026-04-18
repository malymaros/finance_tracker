import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/screens/add_expense_screen.dart';
import 'package:finance_tracker/services/category_preferences_repository.dart';
import 'package:finance_tracker/services/finance_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

FinanceRepository _repo() => FinanceRepository(persist: false);
CategoryPreferencesRepository _prefs() => CategoryPreferencesRepository();

Expense _makeExpense({
  required double amount,
  required ExpenseCategory category,
}) =>
    Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: category,
      date: DateTime(2026, 3, 1),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('AddExpenseScreen — new expense', () {
    testWidgets('renders with "Add Expense" title', (tester) async {
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: _repo(), prefsRepository: _prefs())));
      expect(find.text('Add Expense'), findsOneWidget);
    });

    testWidgets('default category is Groceries', (tester) async {
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: _repo(), prefsRepository: _prefs())));
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('default financial type is Consumption', (tester) async {
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: _repo(), prefsRepository: _prefs())));
      expect(find.text('Consumption'), findsOneWidget);
    });

    testWidgets('Save button is present', (tester) async {
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: _repo(), prefsRepository: _prefs())));
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('shows validation error for empty amount', (tester) async {
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: _repo(), prefsRepository: _prefs())));
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('Enter an amount'), findsOneWidget);
    });

    testWidgets('shows validation error for zero amount', (tester) async {
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: _repo(), prefsRepository: _prefs())));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), '0');
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('Enter a valid positive number'), findsOneWidget);
    });

    testWidgets('shows validation error for negative amount', (tester) async {
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: _repo(), prefsRepository: _prefs())));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), '-10');
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('Enter a valid positive number'), findsOneWidget);
    });

    testWidgets('shows validation error for non-numeric amount', (tester) async {
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: _repo(), prefsRepository: _prefs())));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), 'abc');
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('Enter a valid positive number'), findsOneWidget);
    });

    testWidgets('valid amount saves expense and navigates back', (tester) async {
      final repo = _repo();
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: repo, prefsRepository: _prefs())));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), '42.50');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.expenses.length, 1);
      expect(repo.expenses.first.amount, 42.50);
    });

    testWidgets('saves expense with default Groceries category', (tester) async {
      final repo = _repo();
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: repo, prefsRepository: _prefs())));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), '10');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.expenses.first.category, ExpenseCategory.groceries);
    });

    testWidgets('saves expense with default consumption financial type',
        (tester) async {
      final repo = _repo();
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: repo, prefsRepository: _prefs())));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), '10');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.expenses.first.financialType, FinancialType.consumption);
    });

    testWidgets('note is stored when provided', (tester) async {
      final repo = _repo();
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: repo, prefsRepository: _prefs())));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), '25');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Note (optional)'), 'lunch');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.expenses.first.note, 'lunch');
    });

    testWidgets('note is null when left empty', (tester) async {
      final repo = _repo();
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: repo, prefsRepository: _prefs())));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), '25');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.expenses.first.note, isNull);
    });

    testWidgets('group is stored when provided', (tester) async {
      final repo = _repo();
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: repo, prefsRepository: _prefs())));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), '99');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Group (optional)'), 'Vacation');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.expenses.first.group, 'Vacation');
    });

    testWidgets('group is null when left empty', (tester) async {
      final repo = _repo();
      await tester.pumpWidget(_wrap(AddExpenseScreen(repository: repo, prefsRepository: _prefs())));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), '99');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.expenses.first.group, isNull);
    });

    testWidgets('initialDate pre-fills the date button label', (tester) async {
      final date = DateTime(2026, 7, 15);
      await tester.pumpWidget(
        _wrap(AddExpenseScreen(repository: _repo(), prefsRepository: _prefs(), initialDate: date)),
      );
      expect(find.text('2026-07-15'), findsOneWidget);
    });
  });

  group('AddExpenseScreen — edit mode', () {
    testWidgets('renders with "Edit Expense" title', (tester) async {
      final repo = _repo();
      await repo.addExpense(
          _makeExpense(amount: 50, category: ExpenseCategory.transport));
      await tester.pumpWidget(_wrap(
        AddExpenseScreen(repository: repo, prefsRepository: _prefs(), existing: repo.expenses.first),
      ));
      expect(find.text('Edit Expense'), findsOneWidget);
    });

    testWidgets('pre-fills amount from existing expense', (tester) async {
      final repo = _repo();
      await repo.addExpense(
          _makeExpense(amount: 77.50, category: ExpenseCategory.transport));
      await tester.pumpWidget(_wrap(
        AddExpenseScreen(repository: repo, prefsRepository: _prefs(), existing: repo.expenses.first),
      ));
      expect(find.text('77.5'), findsOneWidget);
    });

    testWidgets('updating expense replaces the existing entry', (tester) async {
      final repo = _repo();
      await repo.addExpense(
          _makeExpense(amount: 10, category: ExpenseCategory.transport));
      final original = repo.expenses.first;

      await tester.pumpWidget(_wrap(
        AddExpenseScreen(repository: repo, prefsRepository: _prefs(), existing: original),
      ));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), '200');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.expenses.length, 1);
      expect(repo.expenses.first.amount, 200);
    });
  });
}
