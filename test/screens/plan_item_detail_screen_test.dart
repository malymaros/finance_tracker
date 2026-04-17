import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/guard_payment.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/screens/plan/plan_item_detail_screen.dart';
import 'package:finance_tracker/services/guard_repository.dart';
import 'package:finance_tracker/services/plan_repository.dart';
import 'package:finance_tracker/widgets/guard_item_status_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

void main() {
  group('PlanItemDetailScreen — income item', () {
    late PlanItem salary;

    setUp(() {
      salary = const PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Salary',
        amount: 3000,
        type: PlanItemType.income,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2025, 1),
        note: 'main income',
      );
    });

    testWidgets('shows item name', (tester) async {
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.text('Salary'), findsOneWidget);
    });

    testWidgets('shows Income type badge', (tester) async {
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.text('Income'), findsOneWidget);
    });

    testWidgets('shows amount with frequency suffix', (tester) async {
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.textContaining('3000.00 €'), findsOneWidget);
      expect(find.textContaining('/ month'), findsOneWidget);
    });

    testWidgets('shows frequency label', (tester) async {
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.text('Monthly'), findsOneWidget);
    });

    testWidgets('shows valid from month', (tester) async {
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.text('January 2025'), findsOneWidget);
    });

    testWidgets('shows Ongoing for income with no end date', (tester) async {
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.text('Ongoing'), findsOneWidget);
    });

    testWidgets('shows note', (tester) async {
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.text('main income'), findsOneWidget);
    });

    testWidgets('does not show category or financial type rows',
        (tester) async {
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.text('Category'), findsNothing);
      expect(find.text('Financial type'), findsNothing);
    });
  });

  group('PlanItemDetailScreen — fixed cost item', () {
    late PlanItem rent;

    setUp(() {
      rent = const PlanItem(
        id: '2',
        seriesId: '2',
        name: 'Rent',
        amount: 800,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2025, 1),
        validTo: YearMonth(2025, 12),
        category: ExpenseCategory.housing,
        financialType: FinancialType.consumption,
      );
    });

    testWidgets('shows Fixed Cost type badge', (tester) async {
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(item: rent, period: const YearMonth(2025, 1))));
      expect(find.text('Fixed Cost'), findsOneWidget);
    });

    testWidgets('shows category', (tester) async {
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(item: rent, period: const YearMonth(2025, 1))));
      expect(find.text('Housing'), findsOneWidget);
    });

    testWidgets('shows financial type', (tester) async {
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(item: rent, period: const YearMonth(2025, 1))));
      expect(find.text('Consumption'), findsOneWidget);
    });

    testWidgets('shows validTo date', (tester) async {
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(item: rent, period: const YearMonth(2025, 1))));
      expect(find.text('December 2025'), findsOneWidget);
    });

    testWidgets('shows No end date when validTo is null', (tester) async {
      final noEnd = const PlanItem(
        id: '3',
        seriesId: '3',
        name: 'Internet',
        amount: 30,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2025, 1),
        category: ExpenseCategory.subscriptions,
        financialType: FinancialType.consumption,
      );

      await tester.pumpWidget(_wrap(PlanItemDetailScreen(item: noEnd, period: const YearMonth(2025, 1))));
      expect(find.text('No end date'), findsOneWidget);
    });

    testWidgets('one-time item does not show active until row', (tester) async {
      final oneTime = const PlanItem(
        id: '4',
        seriesId: '4',
        name: 'Annual fee',
        amount: 120,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.oneTime,
        validFrom: YearMonth(2025, 6),
        category: ExpenseCategory.insurance,
        financialType: FinancialType.insurance,
      );

      await tester.pumpWidget(_wrap(PlanItemDetailScreen(item: oneTime, period: const YearMonth(2025, 6))));
      expect(find.text('Active until'), findsNothing);
      expect(find.textContaining('(one-time)'), findsOneWidget);
    });
  });

  // ── GUARD card visibility ─────────────────────────────────────────────────

  group('PlanItemDetailScreen — GUARD card visibility', () {
    // Use a past period (Jan 2024) so itemStateForPeriod returns unpaidActive.
    const pastPeriod = YearMonth(2024, 1);

    final guardedFixedCost = PlanItem(
      id: '10',
      seriesId: '10',
      name: 'Guarded Rent',
      amount: 800,
      type: PlanItemType.fixedCost,
      frequency: PlanFrequency.monthly,
      validFrom: pastPeriod,
      category: ExpenseCategory.housing,
      financialType: FinancialType.consumption,
      isGuarded: true,
      guardDueDay: 1,
    );

    // GuardItemStatusCard is below the fold in PlanItemDetailScreen's ListView.
    // Use skipOffstage: false so that off-screen widgets are included in finds.
    testWidgets('shows GuardItemStatusCard for guarded fixed cost',
        (tester) async {
      final planRepo = PlanRepository(persist: false, seed: [guardedFixedCost]);
      final guardRepo = GuardRepository(persist: false);
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(
        item: guardedFixedCost,
        period: pastPeriod,
        planRepository: planRepo,
        guardRepository: guardRepo,
      )));
      expect(find.byType(GuardItemStatusCard, skipOffstage: false), findsOneWidget);
    });

    testWidgets('does not show GUARD section when planRepository is null',
        (tester) async {
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(
        item: guardedFixedCost,
        period: pastPeriod,
        // neither planRepository nor guardRepository
      )));
      expect(find.byType(GuardItemStatusCard, skipOffstage: false), findsNothing);
      expect(find.text('GUARD'), findsNothing);
    });

    testWidgets('hides GUARD section when item is guarded but guardRepository is null',
        (tester) async {
      final planRepo = PlanRepository(persist: false, seed: [guardedFixedCost]);
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(
        item: guardedFixedCost,
        period: pastPeriod,
        planRepository: planRepo,
        // no guardRepository — section must be hidden, not show "Not enabled"
      )));
      expect(find.byType(GuardItemStatusCard, skipOffstage: false), findsNothing);
      expect(find.text('Not enabled'), findsNothing);
      expect(find.text('GUARD'), findsNothing);
    });

    testWidgets('does not show GUARD section for income item',
        (tester) async {
      const income = PlanItem(
        id: '11',
        seriesId: '11',
        name: 'Salary',
        amount: 3000,
        type: PlanItemType.income,
        frequency: PlanFrequency.monthly,
        validFrom: pastPeriod,
        isGuarded: true, // income items are ignored by GUARD
      );
      final planRepo = PlanRepository(persist: false, seed: [income]);
      final guardRepo = GuardRepository(persist: false);
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(
        item: income,
        period: pastPeriod,
        planRepository: planRepo,
        guardRepository: guardRepo,
      )));
      expect(find.byType(GuardItemStatusCard, skipOffstage: false), findsNothing);
      expect(find.text('GUARD'), findsNothing);
    });

    testWidgets('shows Mark as Paid button after scrolling to GUARD card',
        (tester) async {
      final planRepo = PlanRepository(persist: false, seed: [guardedFixedCost]);
      final guardRepo = GuardRepository(persist: false);
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(
        item: guardedFixedCost,
        period: pastPeriod,
        planRepository: planRepo,
        guardRepository: guardRepo,
      )));
      await tester.ensureVisible(
          find.byType(GuardItemStatusCard, skipOffstage: false));
      await tester.pump();
      expect(find.text('Mark as Paid'), findsOneWidget);
    });

    testWidgets('shows Mark as Unpaid after scrolling when payment is confirmed',
        (tester) async {
      final paidPayment = GuardPayment(
        id: 'p1',
        planItemSeriesId: '10',
        period: pastPeriod,
        paidAt: DateTime(2024, 1, 10),
      );
      final planRepo = PlanRepository(persist: false, seed: [guardedFixedCost]);
      final guardRepo = GuardRepository(persist: false, seed: [paidPayment]);
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(
        item: guardedFixedCost,
        period: pastPeriod,
        planRepository: planRepo,
        guardRepository: guardRepo,
      )));
      await tester.ensureVisible(
          find.byType(GuardItemStatusCard, skipOffstage: false));
      await tester.pump();
      expect(find.text('Mark as Unpaid'), findsOneWidget);
    });

    testWidgets('shows Not enabled row for unguarded fixed cost',
        (tester) async {
      const unguarded = PlanItem(
        id: '12',
        seriesId: '12',
        name: 'Electricity',
        amount: 60,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: pastPeriod,
        isGuarded: false,
      );
      final planRepo = PlanRepository(persist: false, seed: [unguarded]);
      final guardRepo = GuardRepository(persist: false);
      await tester.pumpWidget(_wrap(PlanItemDetailScreen(
        item: unguarded,
        period: pastPeriod,
        planRepository: planRepo,
        guardRepository: guardRepo,
      )));
      expect(find.text('Not enabled'), findsOneWidget);
      expect(find.text('GUARD'), findsOneWidget);
      expect(find.byType(GuardItemStatusCard, skipOffstage: false), findsNothing);
    });
  });
}
