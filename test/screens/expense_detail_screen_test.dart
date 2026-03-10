import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/screens/expense_detail_screen.dart';

void main() {
  group('ExpenseDetailScreen', () {
    testWidgets('shows amount prominently', (tester) async {
      final expense = Expense(
        id: '1',
        amount: 42.50,
        category: ExpenseCategory.groceries,
        financialType: FinancialType.consumption,
        date: DateTime(2026, 3, 10),
      );

      await tester.pumpWidget(
          MaterialApp(home: ExpenseDetailScreen(expense: expense)));

      expect(find.text('42.50 €'), findsOneWidget);
    });

    testWidgets('shows category display name', (tester) async {
      final expense = Expense(
        id: '1',
        amount: 10,
        category: ExpenseCategory.housing,
        financialType: FinancialType.consumption,
        date: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
          MaterialApp(home: ExpenseDetailScreen(expense: expense)));

      expect(find.text('Housing'), findsOneWidget);
    });

    testWidgets('shows financial type', (tester) async {
      final expense = Expense(
        id: '1',
        amount: 10,
        category: ExpenseCategory.investment,
        financialType: FinancialType.asset,
        date: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
          MaterialApp(home: ExpenseDetailScreen(expense: expense)));

      expect(find.text('Asset'), findsOneWidget);
    });

    testWidgets('shows formatted date', (tester) async {
      final expense = Expense(
        id: '1',
        amount: 10,
        category: ExpenseCategory.groceries,
        financialType: FinancialType.consumption,
        date: DateTime(2026, 3, 10),
      );

      await tester.pumpWidget(
          MaterialApp(home: ExpenseDetailScreen(expense: expense)));

      expect(find.text('10 March 2026'), findsOneWidget);
    });

    testWidgets('shows note when present', (tester) async {
      final expense = Expense(
        id: '1',
        amount: 10,
        category: ExpenseCategory.groceries,
        financialType: FinancialType.consumption,
        date: DateTime(2026, 1, 1),
        note: 'weekly shopping',
      );

      await tester.pumpWidget(
          MaterialApp(home: ExpenseDetailScreen(expense: expense)));

      expect(find.text('weekly shopping'), findsOneWidget);
    });

    testWidgets('does not show note row when note is absent', (tester) async {
      final expense = Expense(
        id: '1',
        amount: 10,
        category: ExpenseCategory.groceries,
        financialType: FinancialType.consumption,
        date: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
          MaterialApp(home: ExpenseDetailScreen(expense: expense)));

      expect(find.text('Note'), findsNothing);
    });
  });
}
