import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/screens/reports/category_report_detail_screen.dart';
import 'package:finance_tracker/services/finance_repository.dart';
import 'package:finance_tracker/services/plan_repository.dart';
import 'package:finance_tracker/widgets/expense_list_tile.dart';
import 'package:finance_tracker/widgets/plan_item_tile.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Expense _expense({
  String id = 'e1',
  double amount = 100,
  ExpenseCategory category = ExpenseCategory.groceries,
  int year = 2024,
  int month = 1,
}) =>
    Expense(
      id: id,
      amount: amount,
      category: category,
      financialType: FinancialType.consumption,
      date: DateTime(year, month, 15),
    );

PlanItem _fixedCost({
  String id = 'p1',
  double amount = 50,
  ExpenseCategory category = ExpenseCategory.groceries,
}) =>
    PlanItem(
      id: id,
      seriesId: id,
      name: 'Fixed $id',
      amount: amount,
      type: PlanItemType.fixedCost,
      frequency: PlanFrequency.monthly,
      validFrom: YearMonth(2024, 1),
      category: category,
      financialType: FinancialType.consumption,
    );

Widget _wrapMonthly({
  FinanceRepository? financeRepo,
  PlanRepository? planRepo,
  ExpenseCategory category = ExpenseCategory.groceries,
  int year = 2024,
  int month = 1,
}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CategoryReportDetailScreen(
        category: category,
        year: year,
        month: month,
        repository: financeRepo ?? FinanceRepository(persist: false),
        planRepository: planRepo ?? PlanRepository(persist: false),
      ),
    );

Widget _wrapYearly({
  FinanceRepository? financeRepo,
  PlanRepository? planRepo,
  ExpenseCategory category = ExpenseCategory.groceries,
  int year = 2024,
}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CategoryReportDetailScreen(
        category: category,
        year: year,
        repository: financeRepo ?? FinanceRepository(persist: false),
        planRepository: planRepo ?? PlanRepository(persist: false),
      ),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── AppBar ────────────────────────────────────────────────────────────────

  group('CategoryReportDetailScreen — app bar', () {
    testWidgets('shows category display name in title', (tester) async {
      await tester.pumpWidget(_wrapMonthly(category: ExpenseCategory.housing));
      expect(find.text('Housing'), findsOneWidget);
    });

    testWidgets('shows month + year label in monthly mode', (tester) async {
      await tester.pumpWidget(
          _wrapMonthly(category: ExpenseCategory.groceries, year: 2024, month: 3));
      expect(find.textContaining('March 2024'), findsOneWidget);
    });

    testWidgets('shows year-only label in yearly mode', (tester) async {
      await tester.pumpWidget(
          _wrapYearly(category: ExpenseCategory.groceries, year: 2024));
      expect(find.textContaining('2024'), findsWidgets);
    });
  });

  // ── Section headers ───────────────────────────────────────────────────────

  group('CategoryReportDetailScreen — section headers', () {
    testWidgets('both FIXED COSTS and EXPENSES headers are visible',
        (tester) async {
      await tester.pumpWidget(_wrapMonthly());
      expect(find.text('FIXED COSTS'), findsOneWidget);
      expect(find.text('EXPENSES'), findsOneWidget);
    });
  });

  // ── Empty state ───────────────────────────────────────────────────────────

  group('CategoryReportDetailScreen — empty state', () {
    testWidgets('shows "None in this period." for both sections when empty',
        (tester) async {
      await tester.pumpWidget(_wrapMonthly());
      // Two empty-row messages — one per section.
      expect(find.text('None in this period.'), findsNWidgets(2));
    });

    testWidgets('header subtitle is "No items in this period" when empty',
        (tester) async {
      await tester.pumpWidget(_wrapMonthly());
      expect(find.text('No items in this period'), findsOneWidget);
    });

    testWidgets('grand total shows 0.00 € when no data', (tester) async {
      await tester.pumpWidget(_wrapMonthly());
      expect(find.text('0.00 €'), findsOneWidget);
    });
  });

  // ── Expenses section ──────────────────────────────────────────────────────

  group('CategoryReportDetailScreen — expenses section', () {
    testWidgets('shows ExpenseListTile for each matching expense',
        (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(id: 'e1', amount: 80, category: ExpenseCategory.groceries),
        _expense(id: 'e2', amount: 40, category: ExpenseCategory.groceries),
      ]);
      await tester.pumpWidget(_wrapMonthly(financeRepo: repo));

      expect(find.byType(ExpenseListTile), findsNWidgets(2));
    });

    testWidgets('filters out expenses from other categories', (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(id: 'e1', category: ExpenseCategory.groceries),
        _expense(id: 'e2', category: ExpenseCategory.transport), // different cat
      ]);
      await tester.pumpWidget(
          _wrapMonthly(financeRepo: repo, category: ExpenseCategory.groceries));

      expect(find.byType(ExpenseListTile), findsOneWidget);
    });

    testWidgets('expenses section shows "None in this period." when no expenses',
        (tester) async {
      final planRepo = PlanRepository(persist: false, seed: [_fixedCost()]);
      await tester.pumpWidget(
          _wrapMonthly(planRepo: planRepo));

      // Only one empty row — for the EXPENSES section; FIXED COSTS has an item.
      expect(find.text('None in this period.'), findsOneWidget);
    });

    testWidgets('expense total appears in EXPENSES section trailing', (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(id: 'e1', amount: 120),
        _expense(id: 'e2', amount: 80),
      ]);
      await tester.pumpWidget(_wrapMonthly(financeRepo: repo));

      // Trailing for EXPENSES section: "N · X.XX €"
      expect(find.textContaining('200.00 €'), findsWidgets);
    });
  });

  // ── Fixed costs section ───────────────────────────────────────────────────

  group('CategoryReportDetailScreen — fixed costs section', () {
    testWidgets('shows PlanItemTile for each matching fixed cost', (tester) async {
      final planRepo = PlanRepository(persist: false, seed: [
        _fixedCost(id: 'p1', category: ExpenseCategory.groceries),
        _fixedCost(id: 'p2', category: ExpenseCategory.groceries),
      ]);
      await tester.pumpWidget(_wrapMonthly(planRepo: planRepo));

      expect(find.byType(PlanItemTile), findsNWidgets(2));
    });

    testWidgets('filters out fixed costs from other categories', (tester) async {
      final planRepo = PlanRepository(persist: false, seed: [
        _fixedCost(id: 'p1', category: ExpenseCategory.groceries),
        _fixedCost(id: 'p2', category: ExpenseCategory.transport), // other cat
      ]);
      await tester.pumpWidget(
          _wrapMonthly(planRepo: planRepo, category: ExpenseCategory.groceries));

      expect(find.byType(PlanItemTile), findsOneWidget);
    });

    testWidgets('income plan items are not shown in fixed costs section',
        (tester) async {
      final incomeItem = PlanItem(
        id: 'i1',
        seriesId: 'i1',
        name: 'Salary',
        amount: 3000,
        type: PlanItemType.income,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2024, 1),
        category: ExpenseCategory.groceries,
        financialType: FinancialType.consumption,
      );
      final planRepo = PlanRepository(persist: false, seed: [incomeItem]);
      await tester.pumpWidget(_wrapMonthly(planRepo: planRepo));

      expect(find.byType(PlanItemTile), findsNothing);
      // Both sections empty.
      expect(find.text('None in this period.'), findsNWidgets(2));
    });
  });

  // ── Grand total ───────────────────────────────────────────────────────────

  group('CategoryReportDetailScreen — grand total', () {
    testWidgets('grand total = fixed costs + expenses', (tester) async {
      final financeRepo = FinanceRepository(persist: false, seed: [
        _expense(amount: 70, category: ExpenseCategory.groceries),
      ]);
      final planRepo = PlanRepository(persist: false, seed: [
        _fixedCost(amount: 30, category: ExpenseCategory.groceries),
      ]);
      await tester.pumpWidget(
          _wrapMonthly(financeRepo: financeRepo, planRepo: planRepo));

      // 70 expenses + 30 fixed cost = 100.00 €
      expect(find.text('100.00 €'), findsOneWidget);
    });

    testWidgets('header subtitle lists fixed cost and expense counts',
        (tester) async {
      final financeRepo = FinanceRepository(persist: false, seed: [
        _expense(amount: 50),
      ]);
      final planRepo = PlanRepository(persist: false, seed: [
        _fixedCost(amount: 30),
      ]);
      await tester.pumpWidget(
          _wrapMonthly(financeRepo: financeRepo, planRepo: planRepo));

      // Subtitle contains "1 fixed cost" and "1 expense"
      expect(find.textContaining('1 fixed cost'), findsOneWidget);
      expect(find.textContaining('1 expense'), findsOneWidget);
    });
  });

  // ── Yearly mode ───────────────────────────────────────────────────────────

  group('CategoryReportDetailScreen — yearly mode', () {
    testWidgets('aggregates expenses across all months of the year',
        (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(id: 'e1', month: 2, amount: 60),
        _expense(id: 'e2', month: 7, amount: 90),
      ]);
      await tester.pumpWidget(_wrapYearly(financeRepo: repo));

      expect(find.byType(ExpenseListTile), findsNWidgets(2));
    });

    testWidgets('expenses from other years are excluded in yearly mode',
        (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(id: 'e1', year: 2024, month: 6, amount: 100),
        _expense(id: 'e2', year: 2023, month: 6, amount: 200), // different year
      ]);
      await tester.pumpWidget(_wrapYearly(financeRepo: repo, year: 2024));

      expect(find.byType(ExpenseListTile), findsOneWidget);
    });

    testWidgets('monthly mode only shows expenses for the selected month',
        (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(id: 'e1', month: 1, amount: 100),
        _expense(id: 'e2', month: 2, amount: 200), // different month
      ]);
      await tester.pumpWidget(_wrapMonthly(financeRepo: repo, month: 1));

      expect(find.byType(ExpenseListTile), findsOneWidget);
    });
  });
}
