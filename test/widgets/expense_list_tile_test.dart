import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/widgets/expense_list_tile.dart';

Widget wrapInMaterial(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  final date = DateTime(2024, 3, 5);

  group('ExpenseListTile', () {
    test('renders without errors', () {
      final expense = Expense(
        id: '1',
        amount: 25.0,
        category: 'Food',
        date: date,
      );
      expect(() => ExpenseListTile(expense: expense), returnsNormally);
    });

    testWidgets('shows category name', (tester) async {
      await tester.pumpWidget(wrapInMaterial(ExpenseListTile(
        expense: Expense(id: '1', amount: 25.0, category: 'Food', date: date),
      )));
      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('shows formatted amount', (tester) async {
      await tester.pumpWidget(wrapInMaterial(ExpenseListTile(
        expense: Expense(id: '1', amount: 25.5, category: 'Food', date: date),
      )));
      expect(find.text('25.50 €'), findsOneWidget);
    });

    testWidgets('shows note when provided', (tester) async {
      await tester.pumpWidget(wrapInMaterial(ExpenseListTile(
        expense: Expense(
            id: '1',
            amount: 10.0,
            category: 'Transport',
            date: date,
            note: 'Bus ticket'),
      )));
      expect(find.text('Bus ticket · 2024-03-05'), findsOneWidget);
    });

    testWidgets('shows formatted date when note is null', (tester) async {
      await tester.pumpWidget(wrapInMaterial(ExpenseListTile(
        expense: Expense(
            id: '1', amount: 10.0, category: 'Transport', date: date),
      )));
      expect(find.text('2024-03-05'), findsOneWidget);
    });

    testWidgets('shows category icon in avatar', (tester) async {
      await tester.pumpWidget(wrapInMaterial(ExpenseListTile(
        expense: Expense(id: '1', amount: 10.0, category: 'Health', date: date),
      )));
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}
