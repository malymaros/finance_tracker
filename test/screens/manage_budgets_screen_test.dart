import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/category_budget.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/screens/plan/add_category_budget_screen.dart';
import 'package:finance_tracker/screens/plan/manage_budgets_screen.dart';
import 'package:finance_tracker/services/category_budget_repository.dart';
import 'package:finance_tracker/widgets/category_budget_tile.dart';
import 'package:finance_tracker/widgets/period_navigator.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _wrap(CategoryBudgetRepository repo) => MaterialApp(
      home: ManageBudgetsScreen(budgetRepository: repo),
    );

CategoryBudget _budget({
  String id = 'b1',
  ExpenseCategory category = ExpenseCategory.groceries,
  double amount = 200,
  YearMonth? validFrom,
}) =>
    CategoryBudget(
      id: id,
      seriesId: id,
      category: category,
      amount: amount,
      validFrom: validFrom ?? YearMonth(YearMonth.now().year - 1, 1),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Scaffold ──────────────────────────────────────────────────────────────

  group('ManageBudgetsScreen — scaffold', () {
    testWidgets('renders "Category Budgets" app bar title', (tester) async {
      await tester.pumpWidget(_wrap(CategoryBudgetRepository(persist: false)));
      expect(find.text('Category Budgets'), findsOneWidget);
    });

    testWidgets('PeriodNavigator is present', (tester) async {
      await tester.pumpWidget(_wrap(CategoryBudgetRepository(persist: false)));
      expect(find.byType(PeriodNavigator), findsOneWidget);
    });

    testWidgets('FAB with add icon is present', (tester) async {
      await tester.pumpWidget(_wrap(CategoryBudgetRepository(persist: false)));
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  // ── Empty state ───────────────────────────────────────────────────────────

  group('ManageBudgetsScreen — empty state', () {
    testWidgets('shows empty state text when no budgets', (tester) async {
      await tester.pumpWidget(_wrap(CategoryBudgetRepository(persist: false)));
      expect(find.text('No category budgets set.'), findsOneWidget);
      expect(find.text('Tap + to add one.'), findsOneWidget);
    });

    testWidgets('shows tune icon in empty state', (tester) async {
      await tester.pumpWidget(_wrap(CategoryBudgetRepository(persist: false)));
      expect(find.byIcon(Icons.tune_outlined), findsOneWidget);
    });

    testWidgets('no CategoryBudgetTile when empty', (tester) async {
      await tester.pumpWidget(_wrap(CategoryBudgetRepository(persist: false)));
      expect(find.byType(CategoryBudgetTile), findsNothing);
    });
  });

  // ── With budgets ──────────────────────────────────────────────────────────

  group('ManageBudgetsScreen — active budgets', () {
    testWidgets('shows CategoryBudgetTile for each active budget',
        (tester) async {
      final repo = CategoryBudgetRepository(
        persist: false,
        seed: [
          _budget(id: 'b1', category: ExpenseCategory.groceries),
          _budget(id: 'b2', category: ExpenseCategory.transport),
        ],
      );
      await tester.pumpWidget(_wrap(repo));

      expect(find.byType(CategoryBudgetTile), findsNWidgets(2));
    });

    testWidgets('shows category display name in tile', (tester) async {
      final repo = CategoryBudgetRepository(
        persist: false,
        seed: [_budget(category: ExpenseCategory.housing, amount: 800)],
      );
      await tester.pumpWidget(_wrap(repo));

      expect(find.textContaining('Housing'), findsOneWidget);
    });

    testWidgets('shows budget amount formatted as X.XX €/month', (tester) async {
      final repo = CategoryBudgetRepository(
        persist: false,
        seed: [_budget(amount: 350)],
      );
      await tester.pumpWidget(_wrap(repo));

      expect(find.text('350.00 €/month'), findsOneWidget);
    });

    testWidgets('empty state is absent when budgets exist', (tester) async {
      final repo = CategoryBudgetRepository(
        persist: false,
        seed: [_budget()],
      );
      await tester.pumpWidget(_wrap(repo));

      expect(find.text('No category budgets set.'), findsNothing);
    });
  });

  // ── Budget sorted alphabetically, other last ──────────────────────────────

  group('ManageBudgetsScreen — sort order', () {
    testWidgets('tiles are sorted alphabetically, other pinned last',
        (tester) async {
      final repo = CategoryBudgetRepository(
        persist: false,
        seed: [
          _budget(
              id: 'b1',
              category: ExpenseCategory.other,
              validFrom: YearMonth(YearMonth.now().year - 1, 1)),
          _budget(
              id: 'b2',
              category: ExpenseCategory.transport,
              validFrom: YearMonth(YearMonth.now().year - 1, 1)),
          _budget(
              id: 'b3',
              category: ExpenseCategory.groceries,
              validFrom: YearMonth(YearMonth.now().year - 1, 1)),
        ],
      );
      await tester.pumpWidget(_wrap(repo));

      final tiles = tester
          .widgetList<CategoryBudgetTile>(find.byType(CategoryBudgetTile))
          .toList();

      expect(tiles.length, 3);
      // Groceries < Transport alphabetically; Other always last.
      expect(tiles[0].budget.category, ExpenseCategory.groceries);
      expect(tiles[1].budget.category, ExpenseCategory.transport);
      expect(tiles[2].budget.category, ExpenseCategory.other);
    });
  });

  // ── FAB navigation ────────────────────────────────────────────────────────

  group('ManageBudgetsScreen — navigation', () {
    testWidgets('tapping FAB navigates to AddCategoryBudgetScreen',
        (tester) async {
      await tester.pumpWidget(
          _wrap(CategoryBudgetRepository(persist: false)));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AddCategoryBudgetScreen), findsOneWidget);
    });

    testWidgets('AddCategoryBudgetScreen shows "Add Budget" title',
        (tester) async {
      await tester.pumpWidget(
          _wrap(CategoryBudgetRepository(persist: false)));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add Budget'), findsOneWidget);
    });
  });

  // ── Reactivity ────────────────────────────────────────────────────────────

  group('ManageBudgetsScreen — reactivity', () {
    testWidgets('adding a budget updates the list without restart',
        (tester) async {
      final repo = CategoryBudgetRepository(persist: false);
      await tester.pumpWidget(_wrap(repo));

      // Empty initially.
      expect(find.text('No category budgets set.'), findsOneWidget);

      await repo.addCategoryBudget(_budget());
      await tester.pump();

      expect(find.text('No category budgets set.'), findsNothing);
      expect(find.byType(CategoryBudgetTile), findsOneWidget);
    });
  });
}
