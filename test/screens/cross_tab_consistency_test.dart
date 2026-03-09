import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/period_bounds.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/screens/expense_list_screen.dart';
import 'package:finance_tracker/screens/plan/plan_screen.dart';
import 'package:finance_tracker/services/finance_repository.dart';
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

      await tester.pumpWidget(MaterialApp(
        home: ExpenseListScreen(
          repository: repo,
          planRepository: planRepo,
          selectedPeriod: period,
          periodBounds: bounds,
        ),
      ));

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

      await tester.pumpWidget(MaterialApp(
        home: PlanScreen(
          planRepository: planRepo,
          selectedPeriod: period,
          periodBounds: bounds,
        ),
      ));

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

      await tester.pumpWidget(MaterialApp(
        home: PlanScreen(
          planRepository: planRepo,
          selectedPeriod: period,
          periodBounds: bounds,
        ),
      ));

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

      await tester.pumpWidget(MaterialApp(
        home: ExpenseListScreen(
          repository: repo,
          planRepository: planRepo,
          selectedPeriod: period,
          periodBounds: bounds,
        ),
      ));
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

      await tester.pumpWidget(MaterialApp(
        home: PlanScreen(
          planRepository: planRepo,
          selectedPeriod: period,
          periodBounds: bounds,
        ),
      ));

      // Screen shows empty state before item is added
      expect(find.text('No plan items yet.'), findsOneWidget);

      // Add item to the shared repository
      await planRepo.addPlanItem(_monthlyIncome(YearMonth.now()));
      await tester.pump();

      // Screen now shows the item
      expect(find.text('Salary'), findsOneWidget);

      period.dispose();
      bounds.dispose();
    });
  });

  group('PeriodBounds prevents navigation to pre-data periods', () {
    test('bounds min equals earliest data month (no past buffer)', () {
      final planRepo = _planRepo(items: [
        _monthlyIncome(YearMonth(2025, 10)),
      ]);

      // earliestDataMonth is 2025-10; bounds min must equal that, not 2025-09
      expect(planRepo.earliestDataMonth, equals(YearMonth(2025, 10)));
    });

    test('navigation before earliest data month is disallowed by PeriodBounds', () {
      const bounds = PeriodBounds(
        min: YearMonth(2025, 10),
        max: YearMonth(2026, 4),
      );

      expect(bounds.allows(YearMonth(2025, 10)), isTrue);
      expect(bounds.allows(YearMonth(2025, 9)), isFalse); // one month before min
      expect(bounds.allows(YearMonth(2024, 12)), isFalse); // year before
    });

    test('navigation one month ahead of latest data is allowed', () {
      const bounds = PeriodBounds(
        min: YearMonth(2025, 10),
        max: YearMonth(2026, 4),
      );
      expect(bounds.allows(YearMonth(2026, 4)), isTrue);
      expect(bounds.allows(YearMonth(2026, 5)), isFalse);
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
}
