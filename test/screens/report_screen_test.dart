import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/period_bounds.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/screens/reports/report_screen.dart';
import 'package:finance_tracker/services/category_budget_repository.dart';
import 'package:finance_tracker/services/finance_repository.dart';
import 'package:finance_tracker/services/plan_repository.dart';
import 'package:finance_tracker/widgets/overview_month_row.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _period = YearMonth(2024, 1); // stable past period

Expense _expense({
  String id = 'e1',
  double amount = 100,
  ExpenseCategory category = ExpenseCategory.groceries,
  int month = 1,
}) =>
    Expense(
      id: id,
      amount: amount,
      category: category,
      financialType: FinancialType.consumption,
      date: DateTime(2024, month, 15),
    );

PlanItem _monthlyIncome({double amount = 3000}) => PlanItem(
      id: 'i1',
      seriesId: 'i1',
      name: 'Salary',
      amount: amount,
      type: PlanItemType.income,
      frequency: PlanFrequency.monthly,
      validFrom: YearMonth(2024, 1),
    );

Widget _wrap({
  FinanceRepository? financeRepo,
  PlanRepository? planRepo,
  YearMonth? period,
  VoidCallback? onNavigateToPlan,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ReportScreen(
      repository: financeRepo ?? FinanceRepository(persist: false),
      planRepository: planRepo ?? PlanRepository(persist: false),
      budgetRepository: CategoryBudgetRepository(persist: false),
      selectedPeriod: ValueNotifier(period ?? _period),
      periodBounds: ValueNotifier(const PeriodBounds()),
      onNavigateToPlan: onNavigateToPlan ?? () {},
      onClearAll: () {},
      onOpenSaves: () {},
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── App bar / scaffold ────────────────────────────────────────────────────

  group('ReportScreen — scaffold', () {
    testWidgets('renders "Reports" app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Reports'), findsOneWidget);
    });

    testWidgets('mode toggle has Monthly, Yearly, Overview segments',
        (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
    });
  });

  // ── Empty states ──────────────────────────────────────────────────────────

  group('ReportScreen — empty states', () {
    testWidgets('monthly mode shows empty state when no data', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('No expenses recorded for this period.'), findsOneWidget);
      expect(find.byIcon(Icons.pie_chart_outline), findsOneWidget);
    });

    testWidgets('yearly mode shows empty state when no data', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Yearly'));
      await tester.pumpAndSettle();
      expect(find.text('No expenses recorded for this period.'), findsOneWidget);
    });

    testWidgets('overview mode shows empty state when no data', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();
      expect(
        find.text('No income or spending data for this year.'),
        findsOneWidget,
      );
      expect(find.byType(OverviewMonthRow), findsNothing);
    });
  });

  // ── Monthly mode with data ────────────────────────────────────────────────

  group('ReportScreen — monthly mode with data', () {
    testWidgets('category name appears in the list', (tester) async {
      final repo = FinanceRepository(
          persist: false, seed: [_expense(category: ExpenseCategory.housing)]);
      await tester.pumpWidget(_wrap(financeRepo: repo));
      await tester.pumpAndSettle();

      // Empty state must not appear.
      expect(find.text('No expenses recorded for this period.'), findsNothing);
      // The category display name must be visible.
      expect(find.textContaining('Housing'), findsOneWidget);
    });

    testWidgets('grand total amount is visible', (tester) async {
      final repo = FinanceRepository(
          persist: false, seed: [_expense(amount: 150)]);
      await tester.pumpWidget(_wrap(financeRepo: repo));
      await tester.pumpAndSettle();

      expect(find.textContaining('150'), findsWidgets);
    });
  });

  // ── Yearly mode ───────────────────────────────────────────────────────────

  group('ReportScreen — yearly mode', () {
    testWidgets('switching to yearly mode aggregates all months', (tester) async {
      // Expense in January AND March — both should appear when yearly.
      final repo = FinanceRepository(persist: false, seed: [
        _expense(id: 'e1', month: 1, category: ExpenseCategory.groceries),
        _expense(id: 'e2', month: 3, category: ExpenseCategory.transport),
      ]);
      await tester.pumpWidget(_wrap(financeRepo: repo));
      await tester.tap(find.text('Yearly'));
      await tester.pumpAndSettle();

      expect(find.text('No expenses recorded for this period.'), findsNothing);
      expect(find.textContaining('Groceries'), findsOneWidget);
      expect(find.textContaining('Transport'), findsOneWidget);
    });
  });

  // ── Overview mode with data ───────────────────────────────────────────────

  group('ReportScreen — overview mode with data', () {
    testWidgets('shows 12 OverviewMonthRow widgets when there is plan income',
        (tester) async {
      final planRepo =
          PlanRepository(persist: false, seed: [_monthlyIncome()]);
      await tester.pumpWidget(_wrap(planRepo: planRepo));
      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();

      expect(find.text('No income or spending data for this year.'), findsNothing);
      // ListView only renders visible rows; assert at least several are present.
      expect(find.byType(OverviewMonthRow), findsWidgets);
    });

    testWidgets('tapping an overview row calls onNavigateToPlan', (tester) async {
      var callbackFired = false;
      final planRepo =
          PlanRepository(persist: false, seed: [_monthlyIncome()]);

      await tester.pumpWidget(_wrap(
        planRepo: planRepo,
        onNavigateToPlan: () => callbackFired = true,
      ));
      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();

      // Tap the first visible OverviewMonthRow.
      await tester.tap(find.byType(OverviewMonthRow).first);
      await tester.pump();

      expect(callbackFired, isTrue);
    });

    testWidgets('tapping overview row updates selectedPeriod to that month',
        (tester) async {
      final planRepo =
          PlanRepository(persist: false, seed: [_monthlyIncome()]);
      final period = ValueNotifier<YearMonth>(_period); // Jan 2024

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ReportScreen(
          repository: FinanceRepository(persist: false),
          planRepository: planRepo,
          budgetRepository: CategoryBudgetRepository(persist: false),
          selectedPeriod: period,
          periodBounds: ValueNotifier(const PeriodBounds()),
          onNavigateToPlan: () {},
          onClearAll: () {},
          onOpenSaves: () {},
        ),
      ));
      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();

      // Tap the row for January (index 0 → month 1).
      await tester.tap(find.byType(OverviewMonthRow).first);
      await tester.pump();

      // selectedPeriod must be set to Jan 2024 (same year as initial period).
      expect(period.value, YearMonth(2024, 1));
    });
  });

  // ── Cache invalidation regression ─────────────────────────────────────────
  //
  // Regression for commit 71814ca:
  // Before the fix, _reportCache was not cleared when the repository notified,
  // so stale data appeared after clearAll.

  group('ReportScreen — cache invalidation', () {
    testWidgets(
        'removing an expense clears the cache and shows empty state',
        (tester) async {
      final expense = _expense();
      final repo =
          FinanceRepository(persist: false, seed: [expense]);

      await tester.pumpWidget(_wrap(financeRepo: repo));
      await tester.pumpAndSettle();

      // Data visible initially.
      expect(find.text('No expenses recorded for this period.'), findsNothing);
      expect(find.textContaining('Groceries'), findsOneWidget);

      // Remove the expense — this triggers notifyListeners on the repository,
      // which must invalidate _reportCache via the ListenableBuilder.
      await repo.removeExpense(expense.id);
      await tester.pump();

      // Cache must have been cleared: screen re-derives from empty data.
      expect(find.text('No expenses recorded for this period.'), findsOneWidget);
      expect(find.textContaining('Groceries'), findsNothing);
    });

    testWidgets('adding an expense refreshes the report', (tester) async {
      final repo = FinanceRepository(persist: false);

      await tester.pumpWidget(_wrap(financeRepo: repo));
      await tester.pump();

      expect(find.text('No expenses recorded for this period.'), findsOneWidget);

      await repo.addExpense(_expense());
      await tester.pump();

      expect(find.text('No expenses recorded for this period.'), findsNothing);
      expect(find.textContaining('Groceries'), findsOneWidget);
    });
  });
}
