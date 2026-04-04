import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/category_budget.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/period_bounds.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/screens/expense_list_screen.dart';
import 'package:finance_tracker/screens/add_expense_screen.dart';
import 'package:finance_tracker/services/app_repositories.dart';
import 'package:finance_tracker/services/category_budget_repository.dart';
import 'package:finance_tracker/services/finance_repository.dart';
import 'package:finance_tracker/services/guard_repository.dart';
import 'package:finance_tracker/services/plan_repository.dart';
import 'package:finance_tracker/widgets/category_budget_progress_bar.dart';
import 'package:finance_tracker/widgets/category_budget_warning_card.dart';
import 'package:finance_tracker/widgets/expense_category_group.dart';
import 'package:finance_tracker/widgets/expense_group_tile.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _period = YearMonth(2024, 1); // stable past period

Expense _expense({
  String id = 'e1',
  double amount = 50,
  ExpenseCategory category = ExpenseCategory.groceries,
  String? group,
}) =>
    Expense(
      id: id,
      amount: amount,
      category: category,
      financialType: FinancialType.consumption,
      date: DateTime(2024, 1, 15),
      group: group,
    );

Widget _wrapScreen({
  FinanceRepository? financeRepo,
  CategoryBudgetRepository? budgetRepo,
}) =>
    MaterialApp(
      home: ExpenseListScreen(
        repositories: AppRepositories(
          finance: financeRepo ?? FinanceRepository(persist: false),
          plan: PlanRepository(persist: false),
          budget: budgetRepo ?? CategoryBudgetRepository(persist: false),
          guard: GuardRepository(persist: false),
        ),
        selectedPeriod: ValueNotifier(_period),
        periodBounds: ValueNotifier(const PeriodBounds()),
        onClearAll: () {},
        onOpenSaves: () {},
      ),
    );

// Keep legacy helper used by the original tests.
Widget wrapInMaterial(FinanceRepository repo) => MaterialApp(
      home: ExpenseListScreen(
        repositories: AppRepositories(
          finance: repo,
          plan: PlanRepository(persist: false),
          budget: CategoryBudgetRepository(persist: false),
          guard: GuardRepository(persist: false),
        ),
        selectedPeriod: ValueNotifier(YearMonth.now()),
        periodBounds: ValueNotifier(const PeriodBounds()),
        onClearAll: () {},
        onOpenSaves: () {},
      ),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Original smoke tests (preserved) ─────────────────────────────────────

  group('ExpenseListScreen', () {
    late FinanceRepository repo;

    setUp(() => repo = FinanceRepository(persist: false));

    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(wrapInMaterial(repo));
      expect(find.text('Expenses'), findsOneWidget);
    });

    testWidgets('shows empty state on first load', (tester) async {
      await tester.pumpWidget(wrapInMaterial(repo));
      expect(find.textContaining('No expenses in'), findsOneWidget);
      expect(find.text('Tap + to add one.'), findsOneWidget);
    });

    testWidgets('shows receipt icon in empty state', (tester) async {
      await tester.pumpWidget(wrapInMaterial(repo));
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });

    testWidgets('FAB is present', (tester) async {
      await tester.pumpWidget(wrapInMaterial(repo));
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping FAB navigates to AddExpenseScreen', (tester) async {
      await tester.pumpWidget(wrapInMaterial(repo));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(AddExpenseScreen), findsOneWidget);
    });
  });

  // ── Mode toggle ───────────────────────────────────────────────────────────

  group('ExpenseListScreen — mode toggle', () {
    testWidgets('toggle has Items, Category, Groups segments', (tester) async {
      await tester.pumpWidget(_wrapScreen());
      expect(find.text('Items'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Groups'), findsOneWidget);
    });
  });

  // ── Category mode ─────────────────────────────────────────────────────────

  group('ExpenseListScreen — category mode', () {
    testWidgets('switching to category mode shows ExpenseCategoryGroup widgets',
        (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(id: 'e1', category: ExpenseCategory.groceries),
        _expense(id: 'e2', category: ExpenseCategory.transport),
      ]);
      await tester.pumpWidget(_wrapScreen(financeRepo: repo));
      await tester.tap(find.text('Category'));
      await tester.pump();

      expect(find.byType(ExpenseCategoryGroup), findsNWidgets(2));
    });

    testWidgets('category mode shows category display names', (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(id: 'e1', category: ExpenseCategory.housing),
      ]);
      await tester.pumpWidget(_wrapScreen(financeRepo: repo));
      await tester.tap(find.text('Category'));
      await tester.pump();

      expect(find.textContaining('Housing'), findsOneWidget);
    });

    testWidgets('category mode sorts groups by total descending', (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(id: 'e1', amount: 20, category: ExpenseCategory.transport),
        _expense(id: 'e2', amount: 150, category: ExpenseCategory.housing),
      ]);
      await tester.pumpWidget(_wrapScreen(financeRepo: repo));
      await tester.tap(find.text('Category'));
      await tester.pump();

      final groups = tester
          .widgetList<ExpenseCategoryGroup>(find.byType(ExpenseCategoryGroup))
          .toList();
      // Housing (150) must come before Transport (20).
      expect(groups.first.category, ExpenseCategory.housing);
      expect(groups.last.category, ExpenseCategory.transport);
    });

    testWidgets(
        'category mode shows CategoryBudgetProgressBar when budget is set',
        (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(category: ExpenseCategory.groceries, amount: 80),
      ]);
      final budgetRepo = CategoryBudgetRepository(
        persist: false,
        seed: [
          CategoryBudget(
            id: 'b1',
            seriesId: 'b1',
            category: ExpenseCategory.groceries,
            amount: 200,
            validFrom: YearMonth(2024, 1),
          ),
        ],
      );
      await tester.pumpWidget(
          _wrapScreen(financeRepo: repo, budgetRepo: budgetRepo));
      await tester.tap(find.text('Category'));
      await tester.pump();

      expect(find.byType(CategoryBudgetProgressBar), findsOneWidget);
    });

    testWidgets(
        'category mode shows no progress bar when no budget is set',
        (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(category: ExpenseCategory.groceries),
      ]);
      await tester.pumpWidget(_wrapScreen(financeRepo: repo));
      await tester.tap(find.text('Category'));
      await tester.pump();

      expect(find.byType(CategoryBudgetProgressBar), findsNothing);
    });
  });

  // ── Group mode ────────────────────────────────────────────────────────────

  group('ExpenseListScreen — group mode', () {
    testWidgets('shows "No groups yet." when no expenses have a group',
        (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(), // no group
      ]);
      await tester.pumpWidget(_wrapScreen(financeRepo: repo));
      await tester.tap(find.text('Groups'));
      await tester.pump();

      expect(find.text('No groups yet.'), findsOneWidget);
    });

    testWidgets('shows ExpenseGroupTile for each group in the month',
        (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(id: 'e1', group: 'Vacation'),
        _expense(id: 'e2', group: 'Birthday'),
      ]);
      await tester.pumpWidget(_wrapScreen(financeRepo: repo));
      await tester.tap(find.text('Groups'));
      await tester.pump();

      expect(find.byType(ExpenseGroupTile), findsNWidgets(2));
      expect(find.textContaining('Vacation'), findsOneWidget);
      expect(find.textContaining('Birthday'), findsOneWidget);
    });
  });

  // ── Budget warning card in items mode ─────────────────────────────────────

  group('ExpenseListScreen — budget warning card', () {
    testWidgets('warning card is absent when no budgets are set',
        (tester) async {
      final repo = FinanceRepository(persist: false, seed: [_expense()]);
      await tester.pumpWidget(_wrapScreen(financeRepo: repo));
      await tester.pump();

      // CategoryBudgetWarningCard renders SizedBox.shrink when no overages.
      expect(find.textContaining('over by'), findsNothing);
    });

    testWidgets('warning card shows when a category exceeds its budget',
        (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(category: ExpenseCategory.groceries, amount: 350),
      ]);
      final budgetRepo = CategoryBudgetRepository(
        persist: false,
        seed: [
          CategoryBudget(
            id: 'b1',
            seriesId: 'b1',
            category: ExpenseCategory.groceries,
            amount: 200, // 350 > 200 → overage
            validFrom: YearMonth(2024, 1),
          ),
        ],
      );
      await tester.pumpWidget(
          _wrapScreen(financeRepo: repo, budgetRepo: budgetRepo));
      await tester.pump();

      expect(find.byType(CategoryBudgetWarningCard), findsOneWidget);
      // Warning text contains the full sentence from CategoryBudgetWarningCard.
      expect(find.textContaining('Groceries budget: over by'), findsOneWidget);
    });

    testWidgets('warning card is not shown in category mode', (tester) async {
      final repo = FinanceRepository(persist: false, seed: [
        _expense(category: ExpenseCategory.groceries, amount: 350),
      ]);
      final budgetRepo = CategoryBudgetRepository(
        persist: false,
        seed: [
          CategoryBudget(
            id: 'b1',
            seriesId: 'b1',
            category: ExpenseCategory.groceries,
            amount: 200,
            validFrom: YearMonth(2024, 1),
          ),
        ],
      );
      await tester.pumpWidget(
          _wrapScreen(financeRepo: repo, budgetRepo: budgetRepo));
      await tester.tap(find.text('Category'));
      await tester.pump();

      // Warning card is items-mode only.
      expect(find.textContaining('over by'), findsNothing);
    });
  });
}
