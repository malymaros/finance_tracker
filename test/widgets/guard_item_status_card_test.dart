import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/guard_payment.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/services/guard_repository.dart';
import 'package:finance_tracker/widgets/guard_item_status_card.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

// A past period where itemStateForPeriod returns unpaidActive (no record, day 1).
const _pastPeriod = YearMonth(2024, 1);

// A far-future period that is always after YearMonth.now().
const _futurePeriod = YearMonth(2099, 12);

PlanItem _guardedItem({int guardDueDay = 1}) => PlanItem(
      id: 'i1',
      seriesId: 's1',
      name: 'Rent',
      amount: 800,
      type: PlanItemType.fixedCost,
      frequency: PlanFrequency.monthly,
      validFrom: const YearMonth(2024, 1),
      category: ExpenseCategory.housing,
      financialType: FinancialType.consumption,
      isGuarded: true,
      guardDueDay: guardDueDay,
    );

PlanItem _nonGuardedItem() => const PlanItem(
      id: 'i2',
      seriesId: 's2',
      name: 'Internet',
      amount: 30,
      type: PlanItemType.fixedCost,
      frequency: PlanFrequency.monthly,
      validFrom: YearMonth(2024, 1),
      isGuarded: false,
    );

Widget _card({
  required PlanItem item,
  required YearMonth period,
  required GuardRepository guardRepo,
  bool showIfScheduled = false,
  VoidCallback? onChangeDueDay,
  VoidCallback? onDeleteGuard,
}) =>
    MaterialApp(
      home: Scaffold(
        body: ListenableBuilder(
          listenable: guardRepo,
          builder: (_, _) => GuardItemStatusCard(
            item: item,
            period: period,
            state: guardRepo.itemStateForPeriod(item, period),
            guardRepository: guardRepo,
            showIfScheduled: showIfScheduled,
            onChangeDueDay: onChangeDueDay,
            onDeleteGuard: onDeleteGuard,
          ),
        ),
      ),
    );

void main() {
  group('GuardItemStatusCard — GuardState.none', () {
    testWidgets('renders nothing for a non-guarded item', (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _nonGuardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));
      expect(find.textContaining('GUARD'), findsNothing);
      expect(find.byType(Card), findsNothing);
    });
  });

  group('GuardItemStatusCard — GuardState.scheduled', () {
    testWidgets('renders nothing by default (showIfScheduled=false)',
        (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _futurePeriod,
        guardRepo: repo,
        showIfScheduled: false,
      ));
      expect(find.textContaining('GUARD'), findsNothing);
    });

    testWidgets('renders card when showIfScheduled=true', (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _futurePeriod,
        guardRepo: repo,
        showIfScheduled: true,
      ));
      expect(find.textContaining('GUARD'), findsWidgets);
      expect(find.text('Not yet due'), findsOneWidget);
    });

    testWidgets('scheduled card shows due date label', (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(guardDueDay: 15),
        period: _futurePeriod,
        guardRepo: repo,
        showIfScheduled: true,
      ));
      expect(find.textContaining('15'), findsWidgets);
    });
  });

  group('GuardItemStatusCard — GuardState.unpaidActive', () {
    testWidgets('shows item name and GUARD header', (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));
      expect(find.textContaining('GUARD'), findsWidgets);
      expect(find.text('Rent'), findsOneWidget);
    });

    testWidgets('shows Mark as Paid button', (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));
      expect(find.text('Mark as Paid'), findsOneWidget);
    });

    testWidgets('shows Silence button', (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));
      expect(find.text('Silence'), findsOneWidget);
    });

    testWidgets('shows amount label', (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));
      expect(find.textContaining('800.00 €'), findsOneWidget);
    });

    testWidgets('tapping Mark as Paid calls confirmPayment and card rebuilds to paid state',
        (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));

      await tester.tap(find.text('Mark as Paid'));
      await tester.pump();

      // After payment, state transitions to paid
      expect(find.textContaining('Paid'), findsWidgets);
      expect(find.text('Mark as Unpaid'), findsOneWidget);
    });

    testWidgets('tapping Silence calls silencePayment and card rebuilds to silenced state',
        (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));

      // Silence requires a confirmation dialog
      await tester.tap(find.text('Silence'));
      await tester.pumpAndSettle();

      expect(find.text('Yes, Silence'), findsOneWidget);
      await tester.tap(find.text('Yes, Silence'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Silenced'), findsOneWidget);
    });
  });

  group('GuardItemStatusCard — GuardState.silenced', () {
    testWidgets('shows silenced indicator and Mark as Paid', (tester) async {
      final silenced = GuardPayment(
        id: 'g1',
        planItemSeriesId: 's1',
        period: _pastPeriod,
        silencedAt: DateTime(2024, 1, 5),
      );
      final repo = GuardRepository(persist: false, seed: [silenced]);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));

      expect(find.textContaining('Silenced'), findsOneWidget);
      expect(find.text('Mark as Paid'), findsOneWidget);
    });

    testWidgets('silenced state does not show Silence button', (tester) async {
      final silenced = GuardPayment(
        id: 'g1',
        planItemSeriesId: 's1',
        period: _pastPeriod,
        silencedAt: DateTime(2024, 1, 5),
      );
      final repo = GuardRepository(persist: false, seed: [silenced]);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));

      expect(find.text('Silence'), findsNothing);
    });
  });

  group('GuardItemStatusCard — GuardState.paid', () {
    testWidgets('shows paid confirmation and Mark as Unpaid', (tester) async {
      final payment = GuardPayment(
        id: 'g1',
        planItemSeriesId: 's1',
        period: _pastPeriod,
        paidAt: DateTime(2024, 1, 10),
      );
      final repo = GuardRepository(persist: false, seed: [payment]);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));

      expect(find.textContaining('Paid'), findsWidgets);
      expect(find.text('Mark as Unpaid'), findsOneWidget);
    });

    testWidgets('paid state does not show Mark as Paid or Silence buttons',
        (tester) async {
      final payment = GuardPayment(
        id: 'g1',
        planItemSeriesId: 's1',
        period: _pastPeriod,
        paidAt: DateTime(2024, 1, 10),
      );
      final repo = GuardRepository(persist: false, seed: [payment]);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));

      expect(find.text('Mark as Paid'), findsNothing);
      expect(find.text('Silence'), findsNothing);
    });

    testWidgets('tapping Mark as Unpaid shows confirmation dialog',
        (tester) async {
      final payment = GuardPayment(
        id: 'g1',
        planItemSeriesId: 's1',
        period: _pastPeriod,
        paidAt: DateTime(2024, 1, 10),
      );
      final repo = GuardRepository(persist: false, seed: [payment]);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));

      await tester.tap(find.text('Mark as Unpaid'));
      await tester.pumpAndSettle();

      expect(find.text('Mark as unpaid?'), findsOneWidget);
    });

    testWidgets('confirming Mark as Unpaid revokes payment', (tester) async {
      final payment = GuardPayment(
        id: 'g1',
        planItemSeriesId: 's1',
        period: _pastPeriod,
        paidAt: DateTime(2024, 1, 10),
      );
      final repo = GuardRepository(persist: false, seed: [payment]);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));

      await tester.tap(find.text('Mark as Unpaid'));
      await tester.pumpAndSettle();
      // Tap the FilledButton in the dialog (distinct from the TextButton in the card)
      await tester.tap(find.widgetWithText(FilledButton, 'Mark as Unpaid'));
      await tester.pumpAndSettle();

      // Card should now show unpaid state
      expect(find.text('Mark as Paid'), findsOneWidget);
    });
  });

  group('GuardItemStatusCard — optional buttons', () {
    testWidgets('shows Change day button when onChangeDueDay is provided',
        (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
        onChangeDueDay: () {},
      ));
      expect(find.text('Change day'), findsOneWidget);
    });

    testWidgets('does not show Change day button when onChangeDueDay is null',
        (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));
      expect(find.text('Change day'), findsNothing);
    });

    testWidgets('shows Remove GUARD button when onDeleteGuard is provided',
        (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
        onDeleteGuard: () {},
      ));
      expect(find.text('Remove GUARD'), findsOneWidget);
    });

    testWidgets('does not show Remove GUARD button when onDeleteGuard is null',
        (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));
      expect(find.text('Remove GUARD'), findsNothing);
    });

    testWidgets('tapping Remove GUARD shows confirmation dialog', (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
        onDeleteGuard: () {},
      ));

      await tester.tap(find.text('Remove GUARD'));
      await tester.pumpAndSettle();

      expect(find.text('Remove GUARD?'), findsOneWidget);
    });

    testWidgets('confirming Remove GUARD calls onDeleteGuard callback',
        (tester) async {
      var called = false;
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
        onDeleteGuard: () => called = true,
      ));

      await tester.tap(find.text('Remove GUARD'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('cancelling Remove GUARD dialog does not call onDeleteGuard',
        (tester) async {
      var called = false;
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
        onDeleteGuard: () => called = true,
      ));

      await tester.tap(find.text('Remove GUARD'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(called, isFalse);
    });
  });

  group('GuardItemStatusCard — reactivity', () {
    testWidgets('card rebuilds when guardRepository notifies', (tester) async {
      final repo = GuardRepository(persist: false);
      await tester.pumpWidget(_card(
        item: _guardedItem(),
        period: _pastPeriod,
        guardRepo: repo,
      ));

      expect(find.text('Mark as Paid'), findsOneWidget);

      // Confirm payment externally
      await repo.confirmPayment('s1', _pastPeriod);
      await tester.pump();

      expect(find.text('Mark as Paid'), findsNothing);
      expect(find.text('Mark as Unpaid'), findsOneWidget);
    });
  });
}
