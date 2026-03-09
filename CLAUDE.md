# CLAUDE.md

Guidance for Claude Code when working in this repository.

--------------------------------------------------
PROJECT OVERVIEW
--------------------------------------------------

Finance Tracker is a Flutter mobile app for tracking personal expenses,
planning budgets, and analyzing spending habits.

Target platforms: Android (primary), iOS (secondary).

--------------------------------------------------
DEVELOPMENT PRIORITIES
--------------------------------------------------

1. Simplicity and readability
2. Small, reusable widgets
3. Minimal dependencies
4. Consistency with existing patterns

Avoid overengineering. Propose a plan before large changes.

--------------------------------------------------
PROJECT STRUCTURE
--------------------------------------------------

lib/
  main.dart                      Entry point; creates repositories, runs app
  models/                        Data classes and enums
  screens/                       Full-page UI; subfolders: fixed_costs/, income/, plan/, reports/
  services/                      Business logic and data access
  widgets/                       Reusable UI components

--------------------------------------------------
MODELS
--------------------------------------------------

Expense          amount, category (ExpenseCategory), financialType, date, note?
IncomeEntry      amount, date, type (oneTime|monthly), description?
FixedCost        name, amount, recurrence (monthly|yearly), startYear, startMonth, category, financialType
PlanItem         name, amount, type (income|fixedCost), frequency, validFrom (YearMonth), seriesId, category?, financialType?
YearMonth        year, month; implements Comparable
MonthlySummary   plannedIncome, plannedFixedCosts, spendableBudget, actualExpenses, difference
BudgetStatus     spendableBudget, actualSpent, remaining, percentUsed, isOverBudget
CategoryTotal    category, amount, percentage
ReportLine       category, financialType, amount

ExpenseCategory enum (15 values): housing, groceries, vacation, transport, insurance,
  subscriptions, communication, health, restaurants, entertainment, clothing,
  education, investment, gifts, other
  — each value has .displayName, .icon, .color extensions

FinancialType enum: asset | consumption | insurance
  — each value has .displayName, .icon, .color extensions

All models implement toJson() / fromJson(). ExpenseCategoryX.fromJson() handles
legacy string values via _fromLegacy(); 'drugstore' maps to other.

--------------------------------------------------
SERVICES
--------------------------------------------------

FinanceRepository   ChangeNotifier; owns expenses, income, fixedCosts lists;
                    JSON file persistence (finance_data.json via path_provider);
                    provides reportLinesForMonth/Year helpers

PlanRepository      ChangeNotifier; owns planItems list; JSON file persistence
                    (plan_data.json); supports version control via seriesId

BudgetCalculator    Pure static class; all budget math:
                    activeItemsForMonth, normalizedMonthlyIncome/FixedCosts,
                    spendableBudget, budgetStatus, planFixedCostReportLines,
                    monthlySummaries, cashFlowTotals

ReportAggregator    Pure static class; categoryTotals, applyThreshold (collapses
                    categories below a % into "Other"), financialTypeBreakdown

SeedData            Debug only; applyIfEmpty (auto-seed on first debug launch),
                    reset (clear all and reseed)

--------------------------------------------------
STATE MANAGEMENT
--------------------------------------------------

- FinanceRepository and PlanRepository extend ChangeNotifier
- Screens rebuild via ListenableBuilder(listenable: Listenable.merge([...]))
- Local UI state (month navigation, view toggles) uses setState
- Cross-tab signaling: ValueNotifier<YearMonth?> in MainScreen

Do NOT introduce Riverpod, Bloc, or Provider.

--------------------------------------------------
DATA PERSISTENCE
--------------------------------------------------

JSON files in getApplicationDocumentsDirectory():
  finance_data.json  — expenses, income, fixedCosts
  plan_data.json     — planItems

Corrupt/missing files silently start fresh. No database; do not add one
unless explicitly requested.

--------------------------------------------------
DEPENDENCIES
--------------------------------------------------

path_provider  ^2.1.0   — app documents directory for JSON persistence
fl_chart       ^0.69.0  — pie charts in Reports screen

Before adding a dependency: explain why, check if Flutter SDK covers it,
keep count minimal.

--------------------------------------------------
KEY PATTERNS
--------------------------------------------------

- Enum extensions for .displayName / .icon / .color (never inline in UI)
- SwipeableTile wraps all list items: swipe-left = delete, swipe-right = edit
- Month navigation is consistent across screens with Dec↔Jan wraparound
- Amounts displayed as X.XX €  (toStringAsFixed(2))
- One widget or screen per file; StatelessWidget unless local state is needed
- Business logic stays in services, never in UI files

--------------------------------------------------
SCREENS
--------------------------------------------------

MainScreen              Root; 3 tabs: Expenses / Plan / Reports
ExpenseListScreen       Month view with navigation, budget bar, items/by-category toggle
AddExpenseScreen        Add/edit expense form
PlanScreen              Monthly/yearly plan view (income + fixed costs)
AddPlanItemScreen       Add/edit plan item with type, frequency, validFrom
ReportScreen            Monthly / yearly / overview modes; pie charts by category
                        (pie: <10% grouped into Other, list: all categories shown)
IncomeListScreen        List of income entries
AddIncomeScreen         Add/edit income form
FixedCostListScreen     List of fixed costs
AddFixedCostScreen      Add/edit fixed cost form

--------------------------------------------------
TESTING
--------------------------------------------------

Place tests in test/ mirroring the lib/ structure.

Covered: models (Expense, YearMonth), services (FinanceRepository,
PlanRepository, BudgetCalculator, ReportAggregator), basic widget tests.

When adding logic, add unit tests for services and pure functions.

--------------------------------------------------
COMMANDS
--------------------------------------------------

flutter pub get        Install dependencies
flutter run            Run application
flutter analyze        Static analysis
flutter test           Run tests
flutter build apk      Build Android APK
