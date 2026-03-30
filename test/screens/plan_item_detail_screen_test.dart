import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/screens/plan/plan_item_detail_screen.dart';

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
      await tester
          .pumpWidget(MaterialApp(home: PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.text('Salary'), findsOneWidget);
    });

    testWidgets('shows Income type badge', (tester) async {
      await tester
          .pumpWidget(MaterialApp(home: PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.text('Income'), findsOneWidget);
    });

    testWidgets('shows amount with frequency suffix', (tester) async {
      await tester
          .pumpWidget(MaterialApp(home: PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.textContaining('3000.00 €'), findsOneWidget);
      expect(find.textContaining('/ month'), findsOneWidget);
    });

    testWidgets('shows frequency label', (tester) async {
      await tester
          .pumpWidget(MaterialApp(home: PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.text('Monthly'), findsOneWidget);
    });

    testWidgets('shows valid from month', (tester) async {
      await tester
          .pumpWidget(MaterialApp(home: PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.text('January 2025'), findsOneWidget);
    });

    testWidgets('shows Ongoing for income with no end date', (tester) async {
      await tester
          .pumpWidget(MaterialApp(home: PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.text('Ongoing'), findsOneWidget);
    });

    testWidgets('shows note', (tester) async {
      await tester
          .pumpWidget(MaterialApp(home: PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
      expect(find.text('main income'), findsOneWidget);
    });

    testWidgets('does not show category or financial type rows',
        (tester) async {
      await tester
          .pumpWidget(MaterialApp(home: PlanItemDetailScreen(item: salary, period: const YearMonth(2025, 1))));
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
      await tester
          .pumpWidget(MaterialApp(home: PlanItemDetailScreen(item: rent, period: const YearMonth(2025, 1))));
      expect(find.text('Fixed Cost'), findsOneWidget);
    });

    testWidgets('shows category', (tester) async {
      await tester
          .pumpWidget(MaterialApp(home: PlanItemDetailScreen(item: rent, period: const YearMonth(2025, 1))));
      expect(find.text('Housing'), findsOneWidget);
    });

    testWidgets('shows financial type', (tester) async {
      await tester
          .pumpWidget(MaterialApp(home: PlanItemDetailScreen(item: rent, period: const YearMonth(2025, 1))));
      expect(find.text('Consumption'), findsOneWidget);
    });

    testWidgets('shows validTo date', (tester) async {
      await tester
          .pumpWidget(MaterialApp(home: PlanItemDetailScreen(item: rent, period: const YearMonth(2025, 1))));
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

      await tester
          .pumpWidget(MaterialApp(home: PlanItemDetailScreen(item: noEnd, period: const YearMonth(2025, 1))));
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

      await tester
          .pumpWidget(MaterialApp(home: PlanItemDetailScreen(item: oneTime, period: const YearMonth(2025, 6))));
      expect(find.text('Active until'), findsNothing);
      expect(find.textContaining('(one-time)'), findsOneWidget);
    });
  });
}
