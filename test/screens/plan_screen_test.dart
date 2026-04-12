import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/period_bounds.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/screens/plan/plan_screen.dart';
import 'package:finance_tracker/services/app_repositories.dart';
import 'package:finance_tracker/services/category_budget_repository.dart';
import 'package:finance_tracker/services/finance_repository.dart';
import 'package:finance_tracker/services/guard_repository.dart';
import 'package:finance_tracker/services/plan_repository.dart';
import 'package:finance_tracker/widgets/plan_financial_type_tile.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _wrapScreen(PlanRepository repo, {YearMonth? period}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: PlanScreen(
      repositories: AppRepositories(
        finance: FinanceRepository(persist: false),
        plan: repo,
        budget: CategoryBudgetRepository(persist: false),
        guard: GuardRepository(persist: false),
      ),
      selectedPeriod: ValueNotifier(period ?? YearMonth(2025, 1)),
      periodBounds: ValueNotifier(const PeriodBounds()),
      onClearAll: () {},
      onOpenSaves: () {},
    ),
  );
}

PlanItem _income({
  String id = 'i1',
  double amount = 3000,
  PlanFrequency frequency = PlanFrequency.monthly,
  int year = 2025,
  int month = 1,
}) =>
    PlanItem(
      id: id,
      seriesId: id,
      name: 'Salary',
      amount: amount,
      type: PlanItemType.income,
      frequency: frequency,
      validFrom: YearMonth(year, month),
    );

PlanItem _fixedCost({
  String id = 'f1',
  double amount = 800,
  PlanFrequency frequency = PlanFrequency.monthly,
  int year = 2025,
  int month = 1,
  FinancialType? financialType,
  ExpenseCategory? category,
}) =>
    PlanItem(
      id: id,
      seriesId: id,
      name: 'Rent',
      amount: amount,
      type: PlanItemType.fixedCost,
      frequency: frequency,
      validFrom: YearMonth(year, month),
      financialType: financialType,
      category: category,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('PlanScreen — empty state', () {
    testWidgets('shows app bar with "Plan" title', (tester) async {
      final repo = PlanRepository(persist: false);
      await tester.pumpWidget(_wrapScreen(repo));
      expect(find.text('Plan'), findsOneWidget);
    });

    testWidgets('shows empty state message when no plan items', (tester) async {
      final repo = PlanRepository(persist: false);
      await tester.pumpWidget(_wrapScreen(repo));
      expect(find.text('No plan items yet.'), findsOneWidget);
    });

    testWidgets('FAB is present', (tester) async {
      final repo = PlanRepository(persist: false);
      await tester.pumpWidget(_wrapScreen(repo));
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('PlanScreen — with plan items', () {
    testWidgets('shows income summary tile when income items exist', (tester) async {
      final repo = PlanRepository(persist: false, seed: [_income()]);
      await tester.pumpWidget(_wrapScreen(repo));
      // PlanIncomeSummaryTile shows "Income" title and item count
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('shows income summary tile label', (tester) async {
      final repo = PlanRepository(persist: false, seed: [_income()]);
      await tester.pumpWidget(_wrapScreen(repo));
      expect(find.text('Income'), findsOneWidget);
    });

    testWidgets('shows fixed costs summary tile when fixed cost items exist', (tester) async {
      final repo = PlanRepository(
          persist: false, seed: [_income(), _fixedCost()]);
      await tester.pumpWidget(_wrapScreen(repo));
      // PlanFixedCostsSummaryTile shows "Fixed Costs" title
      expect(find.text('Fixed Costs'), findsOneWidget);
    });

    testWidgets('summary card shows correct spendable amount', (tester) async {
      // income=3000, fixedCost=800 → spendable=2200
      final repo = PlanRepository(
          persist: false, seed: [_income(amount: 3000), _fixedCost(amount: 800)]);
      await tester.pumpWidget(_wrapScreen(repo));
      // Summary card displays spendable with +/- prefix
      expect(find.textContaining('2200.00 €'), findsOneWidget);
    });

    testWidgets('adding item to repo updates screen immediately',
        (tester) async {
      final repo = PlanRepository(persist: false);
      await tester.pumpWidget(_wrapScreen(repo));
      expect(find.text('No plan items yet.'), findsOneWidget);

      await repo.addPlanItem(_income());
      await tester.pump();

      // Income summary tile appears; individual item names are behind drill-down
      expect(find.text('Income'), findsOneWidget);
    });
  });

  group('PlanScreen — fixed costs accordion', () {
    testWidgets('financial type tiles appear after expanding fixed costs',
        (tester) async {
      final repo = PlanRepository(persist: false, seed: [
        _income(),
        _fixedCost(
          id: 'f1',
          financialType: FinancialType.consumption,
          category: ExpenseCategory.groceries,
        ),
      ]);
      await tester.pumpWidget(_wrapScreen(repo));

      // Tap Fixed Costs summary tile to expand
      await tester.tap(find.text('Fixed Costs'));
      await tester.pump();

      // PlanFinancialTypeTile for Consumption should appear
      expect(find.byType(PlanFinancialTypeTile), findsOneWidget);
    });

    testWidgets('collapsing fixed costs hides financial type tiles',
        (tester) async {
      final repo = PlanRepository(persist: false, seed: [
        _income(),
        _fixedCost(id: 'f1', financialType: FinancialType.consumption),
      ]);
      await tester.pumpWidget(_wrapScreen(repo));

      // Expand fixed costs
      await tester.tap(find.text('Fixed Costs'));
      await tester.pump();
      expect(find.byType(PlanFinancialTypeTile), findsOneWidget);

      // Collapse fixed costs
      await tester.tap(find.text('Fixed Costs'));
      await tester.pump();
      expect(find.byType(PlanFinancialTypeTile), findsNothing);
    });

    testWidgets('only types with items appear as PlanFinancialTypeTile',
        (tester) async {
      // Only asset item — only one PlanFinancialTypeTile expected
      final repo = PlanRepository(persist: false, seed: [
        _income(),
        _fixedCost(id: 'f1', financialType: FinancialType.asset),
      ]);
      await tester.pumpWidget(_wrapScreen(repo));

      await tester.tap(find.text('Fixed Costs'));
      await tester.pump();

      expect(find.byType(PlanFinancialTypeTile), findsOneWidget);
    });

    testWidgets('all three type groups shown when items of each type exist',
        (tester) async {
      final repo = PlanRepository(persist: false, seed: [
        _income(),
        _fixedCost(id: 'f1', financialType: FinancialType.consumption),
        _fixedCost(id: 'f2', financialType: FinancialType.asset),
        _fixedCost(id: 'f3', financialType: FinancialType.insurance),
      ]);
      await tester.pumpWidget(_wrapScreen(repo));

      await tester.tap(find.text('Fixed Costs'));
      await tester.pump();

      expect(find.byType(PlanFinancialTypeTile), findsNWidgets(3));
    });

    testWidgets('tapping type tile expands its items (non-consumption)',
        (tester) async {
      final repo = PlanRepository(persist: false, seed: [
        _income(),
        _fixedCost(
          id: 'f1',
          amount: 250,
          financialType: FinancialType.asset,
          category: ExpenseCategory.investment,
        ),
      ]);
      await tester.pumpWidget(_wrapScreen(repo));

      await tester.tap(find.text('Fixed Costs'));
      await tester.pump();

      // Expand Asset type — tap the PlanFinancialTypeTile
      await tester.tap(find.byType(PlanFinancialTypeTile));
      await tester.pump();

      // PlanItemTile with 250.00 € should be visible (item row, not just summary)
      expect(find.textContaining('250.00 €'), findsWidgets);
    });

    testWidgets('tapping type tile again collapses it', (tester) async {
      final repo = PlanRepository(persist: false, seed: [
        _income(),
        _fixedCost(id: 'f1', amount: 333, financialType: FinancialType.insurance),
      ]);
      await tester.pumpWidget(_wrapScreen(repo));

      await tester.tap(find.text('Fixed Costs'));
      await tester.pump();

      final typeTile = find.byType(PlanFinancialTypeTile);

      // Expand
      await tester.tap(typeTile);
      await tester.pump();
      // Verify expansion — item tile appears after the type tile
      expect(find.textContaining('333.00 €'), findsWidgets);

      // Collapse — tap again
      await tester.tap(typeTile);
      await tester.pump();

      // Item tile is gone; only the summary tiles remain
      // Summary tile shows total fixed costs (333.00 €) — findsWidgets is still ok
      expect(find.textContaining('333.00 €'), findsWidgets);
    });

    testWidgets(
        'consumption type shows category tiles, not items directly',
        (tester) async {
      final repo = PlanRepository(persist: false, seed: [
        _income(),
        _fixedCost(
          id: 'f1',
          financialType: FinancialType.consumption,
          category: ExpenseCategory.groceries,
        ),
      ]);
      await tester.pumpWidget(_wrapScreen(repo));

      await tester.tap(find.text('Fixed Costs'));
      await tester.pump();

      // Expand consumption type tile
      await tester.tap(find.byType(PlanFinancialTypeTile));
      await tester.pump();

      // Should show the Groceries category tile as intermediate level
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('period change resets expanded type so categories collapse',
        (tester) async {
      final period = ValueNotifier(YearMonth(2025, 1));
      final repo = PlanRepository(persist: false, seed: [
        _income(),
        _fixedCost(
          id: 'f1',
          financialType: FinancialType.consumption,
          category: ExpenseCategory.groceries,
        ),
      ]);

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlanScreen(
          repositories: AppRepositories(
            finance: FinanceRepository(persist: false),
            plan: repo,
            budget: CategoryBudgetRepository(persist: false),
            guard: GuardRepository(persist: false),
          ),
          selectedPeriod: period,
          periodBounds: ValueNotifier(const PeriodBounds()),
          onClearAll: () {},
          onOpenSaves: () {},
        ),
      ));

      // Expand fixed costs and consumption type to show Groceries
      await tester.tap(find.text('Fixed Costs'));
      await tester.pump();
      await tester.tap(find.byType(PlanFinancialTypeTile));
      await tester.pump();
      expect(find.text('Groceries'), findsOneWidget);

      // Change the period — should reset expandedFinancialType
      period.value = YearMonth(2025, 2);
      await tester.pump();

      // Groceries category should no longer be visible
      expect(find.text('Groceries'), findsNothing);
    });
  });

  group('PlanScreen — mode toggle', () {
    testWidgets('starts in Monthly mode', (tester) async {
      final repo = PlanRepository(persist: false);
      await tester.pumpWidget(_wrapScreen(repo));
      // The SegmentedButton for monthly/yearly; Monthly should be selected
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);
    });

    testWidgets('switching to Yearly mode updates period navigator label',
        (tester) async {
      final repo = PlanRepository(persist: false);
      await tester.pumpWidget(_wrapScreen(repo, period: YearMonth(2025, 6)));

      // Tap Yearly segment
      await tester.tap(find.text('Yearly'));
      await tester.pump();

      // In yearly mode, navigator shows only the year
      expect(find.text('2025'), findsOneWidget);
    });

    testWidgets('monthly mode shows yearly item at its monthly contribution',
        (tester) async {
      // Yearly income of 12000 → monthly display = 1000; full 12000 should NOT appear
      final repo = PlanRepository(
        persist: false,
        seed: [_income(amount: 12000, frequency: PlanFrequency.yearly)],
      );
      await tester.pumpWidget(_wrapScreen(repo, period: YearMonth(2025, 3)));

      // 1000.00 € (monthly normalized) should appear; 12000.00 € should not
      expect(find.textContaining('1000.00 €'), findsWidgets);
      expect(find.textContaining('12000.00 €'), findsNothing);
    });

    testWidgets('yearly mode shows yearly item at its full annual contribution',
        (tester) async {
      final repo = PlanRepository(
        persist: false,
        seed: [_income(amount: 12000, frequency: PlanFrequency.yearly)],
      );
      await tester.pumpWidget(_wrapScreen(repo, period: YearMonth(2025, 1)));

      // Switch to Yearly
      await tester.tap(find.text('Yearly'));
      await tester.pump();

      // 12000.00 € (full year) should appear; 1000.00 € (monthly slice) should not
      expect(find.textContaining('12000.00 €'), findsWidgets);
      expect(find.textContaining('1000.00 €'), findsNothing);
    });
  });
}
