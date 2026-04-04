import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/widgets/guard_banner.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

PlanItem _item(String id, String name) => PlanItem(
      id: id,
      seriesId: id,
      name: name,
      amount: 100,
      type: PlanItemType.fixedCost,
      frequency: PlanFrequency.monthly,
      validFrom: const YearMonth(2024, 1),
      category: ExpenseCategory.housing,
      financialType: FinancialType.consumption,
      isGuarded: true,
      guardDueDay: 1,
    );

const _period = YearMonth(2024, 3);

Widget _banner({
  List<(PlanItem, YearMonth)> unpaidActive = const [],
  List<(PlanItem, YearMonth)> silenced = const [],
  void Function(String, YearMonth)? onMarkPaid,
  void Function(String, YearMonth)? onSilence,
  void Function(PlanItem, YearMonth)? onTapItem,
}) =>
    MaterialApp(
      home: Scaffold(
        body: GuardBanner(
          unpaidActive: unpaidActive,
          silenced: silenced,
          onMarkPaid: onMarkPaid ?? (_, p1) {},
          onSilence: onSilence ?? (_, p1) {},
          onTapItem: onTapItem,
        ),
      ),
    );

void main() {
  group('GuardBanner', () {
    testWidgets('renders nothing when both lists are empty', (tester) async {
      await tester.pumpWidget(_banner());
      expect(find.byType(GuardBanner), findsOneWidget);
      // No content visible — the widget returns SizedBox.shrink
      expect(find.textContaining('GUARD'), findsNothing);
    });

    testWidgets('shows header with singular count for one item', (tester) async {
      final item = _item('a', 'Rent');
      await tester.pumpWidget(_banner(unpaidActive: [(item, _period)]));
      expect(find.text('GUARD — 1 payment not confirmed'), findsOneWidget);
    });

    testWidgets('shows header with plural count for multiple items',
        (tester) async {
      final a = _item('a', 'Rent');
      final b = _item('b', 'Insurance');
      await tester.pumpWidget(_banner(unpaidActive: [(a, _period), (b, _period)]));
      expect(find.text('GUARD — 2 payments not confirmed'), findsOneWidget);
    });

    testWidgets('silenced items are counted in header total', (tester) async {
      final a = _item('a', 'Rent');
      final b = _item('b', 'Insurance');
      await tester.pumpWidget(_banner(
        unpaidActive: [(a, _period)],
        silenced: [(b, _period)],
      ));
      expect(find.text('GUARD — 2 payments not confirmed'), findsOneWidget);
    });

    testWidgets('shows item names', (tester) async {
      final item = _item('a', 'Monthly Rent');
      await tester.pumpWidget(_banner(unpaidActive: [(item, _period)]));
      expect(find.text('Monthly Rent'), findsOneWidget);
    });

    testWidgets('shows Mark as Paid button for unpaid items', (tester) async {
      final item = _item('a', 'Rent');
      await tester.pumpWidget(_banner(unpaidActive: [(item, _period)]));
      expect(find.text('Paid'), findsOneWidget);
    });

    testWidgets('shows Silence button for unpaid items', (tester) async {
      final item = _item('a', 'Rent');
      await tester.pumpWidget(_banner(unpaidActive: [(item, _period)]));
      expect(find.text('Silence'), findsOneWidget);
    });

    testWidgets('silenced items show Paid button but not Silence', (tester) async {
      final item = _item('a', 'Rent');
      await tester.pumpWidget(_banner(silenced: [(item, _period)]));
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Silence'), findsNothing);
    });

    testWidgets('tapping Paid calls onMarkPaid with correct seriesId and period',
        (tester) async {
      String? capturedId;
      YearMonth? capturedPeriod;
      final item = _item('rent-series', 'Rent');

      await tester.pumpWidget(_banner(
        unpaidActive: [(item, _period)],
        onMarkPaid: (id, p) {
          capturedId = id;
          capturedPeriod = p;
        },
      ));

      await tester.tap(find.text('Paid'));
      expect(capturedId, 'rent-series');
      expect(capturedPeriod, _period);
    });

    testWidgets('tapping Silence calls onSilence with correct seriesId and period',
        (tester) async {
      String? capturedId;
      YearMonth? capturedPeriod;
      final item = _item('rent-series', 'Rent');

      await tester.pumpWidget(_banner(
        unpaidActive: [(item, _period)],
        onSilence: (id, p) {
          capturedId = id;
          capturedPeriod = p;
        },
      ));

      await tester.tap(find.text('Silence'));
      expect(capturedId, 'rent-series');
      expect(capturedPeriod, _period);
    });

    testWidgets('tapping item name calls onTapItem', (tester) async {
      PlanItem? tappedItem;
      YearMonth? tappedPeriod;
      final item = _item('a', 'Tap Me');

      await tester.pumpWidget(_banner(
        unpaidActive: [(item, _period)],
        onTapItem: (i, p) {
          tappedItem = i;
          tappedPeriod = p;
        },
      ));

      await tester.tap(find.text('Tap Me'));
      expect(tappedItem?.id, 'a');
      expect(tappedPeriod, _period);
    });

    testWidgets('silenced items show notifications_off icon', (tester) async {
      final item = _item('a', 'Rent');
      await tester.pumpWidget(_banner(silenced: [(item, _period)]));
      expect(find.byIcon(Icons.notifications_off), findsOneWidget);
    });
  });
}
