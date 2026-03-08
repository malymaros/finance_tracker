import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/screens/expense_list_screen.dart';
import 'package:finance_tracker/screens/add_expense_screen.dart';

Widget wrapInMaterial() => const MaterialApp(home: ExpenseListScreen());

void main() {
  group('ExpenseListScreen', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(wrapInMaterial());
      expect(find.text('Expenses'), findsOneWidget);
    });

    testWidgets('shows empty state on first load', (tester) async {
      await tester.pumpWidget(wrapInMaterial());
      expect(find.text('No expenses yet.'), findsOneWidget);
      expect(find.text('Tap + to add one.'), findsOneWidget);
    });

    testWidgets('shows receipt icon in empty state', (tester) async {
      await tester.pumpWidget(wrapInMaterial());
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });

    testWidgets('FAB is present', (tester) async {
      await tester.pumpWidget(wrapInMaterial());
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping FAB navigates to AddExpenseScreen', (tester) async {
      await tester.pumpWidget(wrapInMaterial());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(AddExpenseScreen), findsOneWidget);
    });
  });
}
