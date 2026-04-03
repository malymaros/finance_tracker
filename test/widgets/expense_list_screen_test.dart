import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/period_bounds.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/screens/expense_list_screen.dart';
import 'package:finance_tracker/screens/add_expense_screen.dart';
import 'package:finance_tracker/services/app_repositories.dart';
import 'package:finance_tracker/services/category_budget_repository.dart';
import 'package:finance_tracker/services/finance_repository.dart';
import 'package:finance_tracker/services/guard_repository.dart';
import 'package:finance_tracker/services/plan_repository.dart';

Widget wrapInMaterial(FinanceRepository repo) => MaterialApp(
      home: ExpenseListScreen(
        repositories: AppRepositories(
          finance: repo,
          plan: PlanRepository(persist: false),
          budget: CategoryBudgetRepository(persist: false),
          guard: GuardRepository(persist: false),
        ),
        selectedPeriod: ValueNotifier(YearMonth.now()),
        periodBounds: ValueNotifier(const PeriodBounds()),
        onClearAll: () {},
        onOpenSaves: () {},
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
      // Text includes the current month name — use a partial match.
      expect(
        find.textContaining('No expenses in'),
        findsOneWidget,
      );
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
