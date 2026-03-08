import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/screens/expense_list_screen.dart';
import 'package:finance_tracker/screens/add_expense_screen.dart';
import 'package:finance_tracker/services/finance_repository.dart';
import 'package:finance_tracker/services/plan_repository.dart';

Widget wrapInMaterial(FinanceRepository repo) => MaterialApp(
      home: ExpenseListScreen(
        repository: repo,
        planRepository: PlanRepository(persist: false),
      ),
    );

void main() {
  group('ExpenseListScreen', () {
    late FinanceRepository repo;

    setUp(() => repo = FinanceRepository(persist: false));

    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(wrapInMaterial(repo));
      expect(find.text('Expenses'), findsOneWidget);
    });

    testWidgets('shows empty state on first load', (tester) async {
      await tester.pumpWidget(wrapInMaterial(repo));
      expect(find.text('No expenses yet.'), findsOneWidget);
      expect(find.text('Tap + to add one.'), findsOneWidget);
    });

    testWidgets('shows receipt icon in empty state', (tester) async {
      await tester.pumpWidget(wrapInMaterial(repo));
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });

    testWidgets('FAB is present', (tester) async {
      await tester.pumpWidget(wrapInMaterial(repo));
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping FAB navigates to AddExpenseScreen', (tester) async {
      await tester.pumpWidget(wrapInMaterial(repo));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(AddExpenseScreen), findsOneWidget);
    });
  });
}
