import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/screens/plan/add_plan_item_screen.dart';
import 'package:finance_tracker/services/plan_repository.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

PlanRepository _repo() => PlanRepository(persist: false);

void main() {
  group('AddPlanItemScreen — initialValidFrom (Bug 1)', () {
    testWidgets('new item defaults validFrom to initialValidFrom when provided',
        (tester) async {
      final selectedMonth = YearMonth(2025, 9); // September 2025
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: _repo(),
        initialValidFrom: selectedMonth,
      )));

      // The "From:" button label must show the selected month, not today.
      expect(find.textContaining('September 2025'), findsOneWidget);
    });

    testWidgets('new item defaults validFrom to YearMonth.now() when initialValidFrom is null',
        (tester) async {
      final now = YearMonth.now();
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: _repo(),
      )));

      final monthNames = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      expect(
        find.textContaining('${monthNames[now.month]} ${now.year}'),
        findsOneWidget,
      );
    });

    testWidgets('saving new item uses initialValidFrom, not today',
        (tester) async {
      // Use a tall viewport at 1:1 pixel ratio so the entire form (including
      // the end-date section added for income items) fits without scrolling or
      // layout overflow.
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final selectedMonth = YearMonth(2025, 9);
      final repo = _repo();
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: repo,
        initialValidFrom: selectedMonth,
      )));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Name'), 'Test Income');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), '1000');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.items.length, 1);
      expect(repo.items.first.validFrom, equals(selectedMonth));
    });

    testWidgets(
        'editing recurring fixedCost defaults new-version validFrom to initialValidFrom',
        (tester) async {
      // Fixed costs use versioning: edit from a new month creates a new version,
      // so the form should start with the selected period as validFrom.
      final repo = _repo();
      final original = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Rent',
        amount: 800,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2025, 1),
        category: ExpenseCategory.housing,
        financialType: FinancialType.consumption,
      );
      await repo.addPlanItem(original);

      final selectedMonth = YearMonth(2025, 10);
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: repo,
        existing: original,
        initialValidFrom: selectedMonth,
      )));

      // The "From:" button must show the selected period, not the item's original month.
      expect(find.textContaining('October 2025'), findsOneWidget);
    });

    testWidgets(
        'editing income defaults validFrom to the item\'s own start, not selected period',
        (tester) async {
      // Income is always updated in place — the form starts from the item's
      // own validFrom so the user sees and can change the actual start date.
      final repo = _repo();
      final original = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Salary',
        amount: 3000,
        type: PlanItemType.income,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2025, 1),
      );
      await repo.addPlanItem(original);

      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: repo,
        existing: original,
        initialValidFrom: YearMonth(2025, 10), // different from item's start
      )));

      // The "From:" button must show the item's original validFrom (January),
      // not the selected period (October).
      expect(find.textContaining('January 2025'), findsOneWidget);
    });

    testWidgets('editing income updates in place without creating a new version',
        (tester) async {
      final repo = _repo();
      final original = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Salary',
        amount: 3000,
        type: PlanItemType.income,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2025, 1),
      );
      await repo.addPlanItem(original);

      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: repo,
        existing: original,
        initialValidFrom: YearMonth(2025, 10),
      )));

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), '4000');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Still one item — no new version created
      expect(repo.items.length, 1);
      expect(repo.items.first.id, '1');
      expect(repo.items.first.amount, 4000);
      expect(repo.items.first.validFrom, YearMonth(2025, 1));
    });

    testWidgets('editing one-time item keeps original validFrom, ignores initialValidFrom',
        (tester) async {
      final repo = _repo();
      final original = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Bonus',
        amount: 500,
        type: PlanItemType.income,
        frequency: PlanFrequency.oneTime,
        validFrom: YearMonth(2025, 3),
      );
      await repo.addPlanItem(original);

      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: repo,
        existing: original,
        initialValidFrom: YearMonth(2025, 10), // different from original
      )));

      // One-time items always keep their original validFrom on edit.
      expect(find.textContaining('March 2025'), findsOneWidget);
    });
  });

  group('AddPlanItemScreen — screen title', () {
    testWidgets('shows "Add Monthly Income" for monthly income', (tester) async {
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: _repo(),
        initialType: PlanItemType.income,
        initialFrequency: PlanFrequency.monthly,
      )));
      expect(find.text('Add Monthly Income'), findsOneWidget);
    });

    testWidgets('shows "Add Yearly Income" for yearly income', (tester) async {
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: _repo(),
        initialType: PlanItemType.income,
        initialFrequency: PlanFrequency.yearly,
      )));
      expect(find.text('Add Yearly Income'), findsOneWidget);
    });

    testWidgets('shows "Add One-time Income" for one-time income',
        (tester) async {
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: _repo(),
        initialType: PlanItemType.income,
        initialFrequency: PlanFrequency.oneTime,
      )));
      expect(find.text('Add One-time Income'), findsOneWidget);
    });

    testWidgets('shows "Add Monthly Fixed Cost" for monthly fixed cost',
        (tester) async {
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: _repo(),
        initialType: PlanItemType.fixedCost,
        initialFrequency: PlanFrequency.monthly,
      )));
      expect(find.text('Add Monthly Fixed Cost'), findsOneWidget);
    });

    testWidgets('shows "Add Yearly Fixed Cost" for yearly fixed cost',
        (tester) async {
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: _repo(),
        initialType: PlanItemType.fixedCost,
        initialFrequency: PlanFrequency.yearly,
      )));
      expect(find.text('Add Yearly Fixed Cost'), findsOneWidget);
    });

    testWidgets('shows generic "Add Plan Item" when no initialType',
        (tester) async {
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: _repo(),
      )));
      expect(find.text('Add Plan Item'), findsOneWidget);
    });

    testWidgets('shows "Edit Monthly Income" when editing a monthly income item',
        (tester) async {
      final repo = _repo();
      final item = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Salary',
        amount: 3000,
        type: PlanItemType.income,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2025, 1),
      );
      await repo.addPlanItem(item);
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: repo,
        existing: item,
      )));
      expect(find.text('Edit Monthly Income'), findsOneWidget);
    });

    testWidgets('shows "Edit Yearly Income" when editing a yearly income item',
        (tester) async {
      final repo = _repo();
      final item = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Annual Bonus',
        amount: 5000,
        type: PlanItemType.income,
        frequency: PlanFrequency.yearly,
        validFrom: YearMonth(2025, 1),
      );
      await repo.addPlanItem(item);
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: repo,
        existing: item,
      )));
      expect(find.text('Edit Yearly Income'), findsOneWidget);
    });

    testWidgets('shows "Edit One-time Income" when editing a one-time income item',
        (tester) async {
      final repo = _repo();
      final item = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Bonus',
        amount: 2000,
        type: PlanItemType.income,
        frequency: PlanFrequency.oneTime,
        validFrom: YearMonth(2025, 6),
      );
      await repo.addPlanItem(item);
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: repo,
        existing: item,
      )));
      expect(find.text('Edit One-time Income'), findsOneWidget);
    });

    testWidgets('shows "Edit Monthly Fixed Cost" when editing a monthly fixed cost',
        (tester) async {
      final repo = _repo();
      final item = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Rent',
        amount: 800,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2025, 1),
        category: ExpenseCategory.housing,
        financialType: FinancialType.consumption,
      );
      await repo.addPlanItem(item);
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: repo,
        existing: item,
      )));
      expect(find.text('Edit Monthly Fixed Cost'), findsOneWidget);
    });

    testWidgets('shows "Edit Yearly Fixed Cost" when editing a yearly fixed cost',
        (tester) async {
      final repo = _repo();
      final item = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Insurance',
        amount: 1200,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.yearly,
        validFrom: YearMonth(2025, 1),
        category: ExpenseCategory.insurance,
        financialType: FinancialType.insurance,
      );
      await repo.addPlanItem(item);
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: repo,
        existing: item,
      )));
      expect(find.text('Edit Yearly Fixed Cost'), findsOneWidget);
    });
  });

  group('AddPlanItemScreen — type selector visibility', () {
    testWidgets('type selector is hidden when initialType is set',
        (tester) async {
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: _repo(),
        initialType: PlanItemType.income,
      )));
      // The "Type" label above the selector should not be visible.
      expect(
        find.text('Type'),
        findsNothing,
      );
    });

    testWidgets('type selector is hidden when editing an existing item',
        (tester) async {
      final repo = _repo();
      final item = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Salary',
        amount: 3000,
        type: PlanItemType.income,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2025, 1),
      );
      await repo.addPlanItem(item);
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: repo,
        existing: item,
      )));
      expect(find.text('Type'), findsNothing);
    });

    testWidgets('type selector is visible when no initialType and no existing',
        (tester) async {
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: _repo(),
      )));
      expect(find.text('Type'), findsOneWidget);
    });
  });
}
