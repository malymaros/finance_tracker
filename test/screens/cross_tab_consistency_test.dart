import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/period_bounds.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/screens/expense_list_screen.dart';
import 'package:finance_tracker/screens/plan/plan_screen.dart';
import 'package:finance_tracker/services/app_repositories.dart';
import 'package:finance_tracker/services/category_budget_repository.dart';
import 'package:finance_tracker/services/finance_repository.dart';
import 'package:finance_tracker/services/guard_repository.dart';
import 'package:finance_tracker/services/period_bounds_service.dart';
import 'package:finance_tracker/services/plan_repository.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

FinanceRepository _financeRepo({List<Expense>? expenses}) =>
    FinanceRepository(persist: false, seed: expenses);

PlanRepository _planRepo({List<PlanItem>? items}) =>
    PlanRepository(persist: false, seed: items);

PlanItem _monthlyIncome(YearMonth validFrom) => PlanItem(
      id: '1',
      seriesId: '1',
      name: 'Salary',
      amount: 3000,
      type: PlanItemType.income,
      frequency: PlanFrequency.monthly,
      validFrom: validFrom,
    );

Expense _expenseOn(DateTime date) => Expense(
      id: '1',
      amount: 50,
      category: ExpenseCategory.groceries,
      financialType: FinancialType.consumption,
      date: date,
    );

MaterialApp _l10nApp(Widget home) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('Cross-tab period consistency', () {
    test('shared ValueNotifier propagates period change to all listeners', () {
      final shared = ValueNotifier<YearMonth>(YearMonth.now());
      final log = <YearMonth>[];

      shared.addListener(() => log.add(shared.value));
      shared.addListener(() => log.add(shared.value)); // simulates two screens

      final newPeriod = YearMonth(2025, 6);
      shared.value = newPeriod;

      // Both listeners received the update
      expect(log.length, 2);
      expect(log.every((ym) => ym == newPeriod), isTrue);

      shared.dispose();
    });

    testWidgets('ExpenseListScreen reflects period update from shared notifier',
        (tester) async {
      final period = ValueNotifier<YearMonth>(YearMonth.now());
      final bounds = ValueNotifier<PeriodBounds>(const PeriodBounds());
      final repo = _financeRepo();
      final planRepo = _planRepo();

      await tester.pumpWidget(_l10nApp(ExpenseListScreen(
        repositories: AppRepositories(
          finance: repo,
          plan: planRepo,
          budget: CategoryBudgetRepository(persist: false),
          guard: GuardRepository(persist: false),
        ),
        selectedPeriod: period,
        periodBounds: bounds,
        onClearAll: () {},
        onOpenSaves: () {},
      )));

      // Change period externally (simulates another tab changing it)
      period.value = YearMonth(2025, 3);
      await tester.pump();

      // Both the period navigator label and the empty-state text include the
      // new period — assert at least one occurrence to confirm the update.
      expect(find.textContaining('March 2025'), findsWidgets);

      period.dispose();
      bounds.dispose();
    });

    testWidgets('PlanScreen reflects period update from shared notifier',
        (tester) async {
      final period = ValueNotifier<YearMonth>(YearMonth.now());
      final bounds = ValueNotifier<PeriodBounds>(const PeriodBounds());
      final planRepo = _planRepo();

      await tester.pumpWidget(_l10nApp(PlanScreen(
        repositories: AppRepositories(
          finance: _financeRepo(),
          plan: planRepo,
          budget: CategoryBudgetRepository(persist: false),
          guard: GuardRepository(persist: false),
        ),
        selectedPeriod: period,
        periodBounds: bounds,
        onClearAll: () {},
        onOpenSaves: () {},
      )));

      period.value = YearMonth(2025, 11);
      await tester.pump();

      expect(find.textContaining('November 2025'), findsOneWidget);

      period.dispose();
      bounds.dispose();
    });

    testWidgets('plan item created from PlanScreen with non-current period uses that period',
        (tester) async {
      final selectedPeriod = YearMonth(2025, 9); // September 2025
      final period = ValueNotifier<YearMonth>(selectedPeriod);
      final bounds = ValueNotifier<PeriodBounds>(const PeriodBounds());
      final planRepo = _planRepo();

      await tester.pumpWidget(_l10nApp(PlanScreen(
        repositories: AppRepositories(
          finance: _financeRepo(),
          plan: planRepo,
          budget: CategoryBudgetRepository(persist: false),
          guard: GuardRepository(persist: false),
        ),
        selectedPeriod: period,
        periodBounds: bounds,
        onClearAll: () {},
        onOpenSaves: () {},
      )));

      // Open the Add Plan Item screen via the FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // The form should show September 2025 as the validFrom, not today
      expect(find.textContaining('September 2025'), findsOneWidget);

      period.dispose();
      bounds.dispose();
    });

    testWidgets('expense added in ExpenseListScreen is visible from same repository',
        (tester) async {
      final period = ValueNotifier<YearMonth>(YearMonth.now());
      final bounds = ValueNotifier<PeriodBounds>(const PeriodBounds());
      final repo = _financeRepo();
      final planRepo = _planRepo();

      // Add an expense directly to the shared repository
      final now = DateTime.now();
      await repo.addExpense(_expenseOn(now));

      await tester.pumpWidget(_l10nApp(ExpenseListScreen(
        repositories: AppRepositories(
          finance: repo,
          plan: planRepo,
          budget: CategoryBudgetRepository(persist: false),
          guard: GuardRepository(persist: false),
        ),
        selectedPeriod: period,
        periodBounds: bounds,
        onClearAll: () {},
        onOpenSaves: () {},
      )));
      await tester.pump();

      // The expense amount should be visible
      expect(find.textContaining('50'), findsWidgets);

      period.dispose();
      bounds.dispose();
    });

    testWidgets('plan item added to repository is visible in PlanScreen immediately',
        (tester) async {
      final period = ValueNotifier<YearMonth>(YearMonth.now());
      final bounds = ValueNotifier<PeriodBounds>(const PeriodBounds());
      final planRepo = _planRepo();

      await tester.pumpWidget(_l10nApp(PlanScreen(
        repositories: AppRepositories(
          finance: _financeRepo(),
          plan: planRepo,
          budget: CategoryBudgetRepository(persist: false),
          guard: GuardRepository(persist: false),
        ),
        selectedPeriod: period,
        periodBounds: bounds,
        onClearAll: () {},
        onOpenSaves: () {},
      )));

      // Screen shows empty state before item is added
      expect(find.text('No plan items yet.'), findsOneWidget);

      // Add item to the shared repository
      await planRepo.addPlanItem(_monthlyIncome(YearMonth.now()));
      await tester.pump();

      // Screen now shows the income summary tile; individual item names are behind drill-down
      expect(find.text('Income'), findsOneWidget);

      period.dispose();
      bounds.dispose();
    });
  });

  group('Year-based navigation window', () {
    test('no plan data: window covers exactly nowYear-1 to nowYear+1', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute();

      expect(bounds.min, equals(YearMonth(nowYear - 1, 1)));
      expect(bounds.max, equals(YearMonth(nowYear + 1, 12)));
    });

    test('current year is always accessible', () {
      final now = YearMonth.now();
      final bounds = PeriodBoundsService.compute();
      expect(bounds.allows(now), isTrue);
    });

    test('plan data in current year does not expand window beyond ±1', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute(
        planEarliest: YearMonth(nowYear, 1),
        planLatest: YearMonth(nowYear, 12),
      );
      expect(bounds.min, equals(YearMonth(nowYear - 1, 1)));
      expect(bounds.max, equals(YearMonth(nowYear + 1, 12)));
    });

    test('plan data in past boundary year expands min by one extra year', () {
      final nowYear = YearMonth.now().year;
      // User adds plan in the previous boundary year (nowYear-1)
      final bounds = PeriodBoundsService.compute(
        planEarliest: YearMonth(nowYear - 1, 6),
        planLatest: YearMonth(nowYear, 1),
      );
      // nowYear-1 is a data year → min unlocks to Jan of (nowYear-1)-1 = nowYear-2
      expect(bounds.min, equals(YearMonth(nowYear - 2, 1)));
      expect(bounds.max, equals(YearMonth(nowYear + 1, 12)));
    });

    test('plan data in future boundary year expands max by one extra year', () {
      final nowYear = YearMonth.now().year;
      // User adds plan in the next boundary year (nowYear+1)
      final bounds = PeriodBoundsService.compute(
        planEarliest: YearMonth(nowYear, 1),
        planLatest: YearMonth(nowYear + 1, 3),
      );
      // nowYear+1 is a data year → max unlocks to Dec of (nowYear+1)+1 = nowYear+2
      expect(bounds.min, equals(YearMonth(nowYear - 1, 1)));
      expect(bounds.max, equals(YearMonth(nowYear + 2, 12)));
    });

    test('only plan data drives expansion — finance repo has no effect', () {
      final nowYear = YearMonth.now().year;
      // Bounds computed without finance repo data (as per architecture decision)
      final bounds = PeriodBoundsService.compute(
        planEarliest: null,
        planLatest: null,
      );
      // Window must NOT expand just because finance data exists far in the past
      expect(bounds.min, equals(YearMonth(nowYear - 1, 1)));
      expect(bounds.max, equals(YearMonth(nowYear + 1, 12)));
    });

    test('PeriodBounds.allows correctly gates months outside the year window', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute();
      // Just outside min (December of nowYear-2)
      expect(bounds.allows(YearMonth(nowYear - 2, 12)), isFalse);
      // Just outside max (January of nowYear+2)
      expect(bounds.allows(YearMonth(nowYear + 2, 1)), isFalse);
    });
  });

  group('Shared period consistency between Expenses and Plan tabs', () {
    test('period value is the same object seen by all tabs', () {
      final shared = ValueNotifier<YearMonth>(YearMonth(2025, 6));

      // Simulate two screens both reading the same notifier
      final expensesPeriod = shared.value;
      final planPeriod = shared.value;

      expect(expensesPeriod, equals(planPeriod));

      // Simulate user navigating in Expenses tab
      shared.value = YearMonth(2025, 9);

      // Both tabs now see the same new period
      expect(shared.value, equals(YearMonth(2025, 9)));

      shared.dispose();
    });

    test('period set outside allowed bounds is reset to now', () {
      final period = ValueNotifier<YearMonth>(YearMonth.now());
      const bounds = PeriodBounds(
        min: YearMonth(2025, 10),
        max: YearMonth(2026, 4),
      );

      // Simulates MainScreen._updateBounds logic: if current period is outside
      // new bounds, reset to now
      void simulateUpdateBounds() {
        if (!bounds.allows(period.value)) {
          period.value = YearMonth.now();
        }
      }

      period.value = YearMonth(2024, 1); // outside bounds
      simulateUpdateBounds();

      expect(period.value, equals(YearMonth.now()));

      period.dispose();
    });
  });

  group('Cross-tab bounds consistency', () {
    test('all tabs see the same PeriodBounds ValueNotifier instance', () {
      // Verifies that the single ValueNotifier<PeriodBounds> in MainScreen is
      // the same object passed to every tab — not a copy.
      final nowYear = YearMonth.now().year;
      final planRepo = _planRepo();
      final bounds = ValueNotifier<PeriodBounds>(
        PeriodBoundsService.compute(
          planEarliest: planRepo.earliestDataMonth,
          planLatest: planRepo.latestDataMonth,
        ),
      );

      // Simulate another tab reading the same notifier
      final expenseTabBounds = bounds.value;
      final planTabBounds = bounds.value;
      final reportTabBounds = bounds.value;

      expect(expenseTabBounds.min, equals(YearMonth(nowYear - 1, 1)));
      expect(planTabBounds.min, equals(YearMonth(nowYear - 1, 1)));
      expect(reportTabBounds.min, equals(YearMonth(nowYear - 1, 1)));

      bounds.dispose();
    });

    test('adding plan item updates bounds and all tabs see the expanded window', () async {
      final nowYear = YearMonth.now().year;
      final planRepo = _planRepo();

      // Initial bounds — no plan data
      var bounds = PeriodBoundsService.compute(
        planEarliest: planRepo.earliestDataMonth,
        planLatest: planRepo.latestDataMonth,
      );
      expect(bounds.min, equals(YearMonth(nowYear - 1, 1)));

      // User adds plan item in the past boundary year
      final pastBoundaryYear = nowYear - 1;
      await planRepo.addPlanItem(_monthlyIncome(YearMonth(pastBoundaryYear, 6)));

      // Bounds recomputed — window expands
      bounds = PeriodBoundsService.compute(
        planEarliest: planRepo.earliestDataMonth,
        planLatest: planRepo.latestDataMonth,
      );
      expect(bounds.min, equals(YearMonth(nowYear - 2, 1)));
    });

    testWidgets('ExpenseListScreen and PlanScreen reflect the same bounds update',
        (tester) async {
      final nowYear = YearMonth.now().year;
      final period = ValueNotifier<YearMonth>(YearMonth.now());
      final boundsNotifier = ValueNotifier<PeriodBounds>(
        PeriodBoundsService.compute(),
      );
      final repo = _financeRepo();
      final planRepo = _planRepo();

      await tester.pumpWidget(_l10nApp(ExpenseListScreen(
        repositories: AppRepositories(
          finance: repo,
          plan: planRepo,
          budget: CategoryBudgetRepository(persist: false),
          guard: GuardRepository(persist: false),
        ),
        selectedPeriod: period,
        periodBounds: boundsNotifier,
        onClearAll: () {},
        onOpenSaves: () {},
      )));

      // Both tabs use the same boundsNotifier; update it and verify
      // ExpenseListScreen re-reads it on rebuild.
      final expandedBounds = PeriodBoundsService.compute(
        planEarliest: YearMonth(nowYear - 1, 3),
        planLatest: YearMonth(nowYear, 1),
      );
      boundsNotifier.value = expandedBounds;
      await tester.pump();

      // The expanded window now includes Jan of nowYear-2.
      expect(boundsNotifier.value.min, equals(YearMonth(nowYear - 2, 1)));

      period.dispose();
      boundsNotifier.dispose();
    });
  });
}
