import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/period_bounds.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/screens/plan/plan_screen.dart';
import 'package:finance_tracker/services/plan_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _wrapScreen(PlanRepository repo, {YearMonth? period}) {
  return MaterialApp(
    home: PlanScreen(
      planRepository: repo,
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
}) =>
    PlanItem(
      id: id,
      seriesId: id,
      name: 'Rent',
      amount: amount,
      type: PlanItemType.fixedCost,
      frequency: frequency,
      validFrom: YearMonth(year, month),
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
    testWidgets('shows income item name in list', (tester) async {
      final repo = PlanRepository(persist: false, seed: [_income()]);
      await tester.pumpWidget(_wrapScreen(repo));
      expect(find.text('Salary'), findsOneWidget);
    });

    testWidgets('shows INCOME section header', (tester) async {
      final repo = PlanRepository(persist: false, seed: [_income()]);
      await tester.pumpWidget(_wrapScreen(repo));
      // "INCOME" appears in both the section header and summary card label
      expect(find.text('INCOME'), findsWidgets);
    });

    testWidgets('shows FIXED COSTS section header', (tester) async {
      final repo = PlanRepository(
          persist: false, seed: [_income(), _fixedCost()]);
      await tester.pumpWidget(_wrapScreen(repo));
      // "FIXED COSTS" appears in both the section header and summary card label
      expect(find.text('FIXED COSTS'), findsWidgets);
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

      expect(find.text('Salary'), findsOneWidget);
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
