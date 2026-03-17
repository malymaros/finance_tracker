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
  theme/                         AppColors constants and buildAppTheme()

.claude/
  skills/                        Project-specific Claude Code skill definitions

--------------------------------------------------
MODELS
--------------------------------------------------

Expense          amount, category (ExpenseCategory), financialType, date, note?, group?
IncomeEntry      amount, date, type (oneTime|monthly), description?
FixedCost        name, amount, recurrence (monthly|yearly), startYear, startMonth, category, financialType
PlanItem         name, amount, type (income|fixedCost), frequency, validFrom (YearMonth), seriesId, category?, financialType?
YearMonth        year, month; implements Comparable
MonthlySummary   plannedIncome, plannedFixedCosts, spendableBudget, actualExpenses, difference
BudgetStatus     spendableBudget, actualSpent, remaining, percentUsed, isOverBudget
CategoryTotal    category, amount, percentage
ReportLine       category, financialType, amount
SaveSlot         id, name, createdAt, expenseCount, incomeCount, planItemCount, isDamaged

ExpenseCategory enum (17 values): housing, groceries, vacation, transport, insurance,
  subscriptions, communication, health, restaurants, entertainment, clothing,
  education, investment, gifts, taxes, medications, other
  — each value has .displayName, .icon, .color extensions
  — alphabetically sorted in category pickers; 'other' always pinned last

FinancialType enum: asset | consumption | insurance
  — each value has .displayName, .icon, .color extensions

All models implement toJson() / fromJson(). ExpenseCategoryX.fromJson() handles
legacy string values via _fromLegacy(); 'drugstore' maps to other.

--------------------------------------------------
SERVICES
--------------------------------------------------

FinanceRepository   ChangeNotifier; owns expenses, income lists;
                    JSON file persistence (finance_data.json via path_provider);
                    provides expensesForMonth/Year/Group and reportLinesForMonth/Year helpers;
                    exposes restoreFromSnapshot(expenses, income)

PlanRepository      ChangeNotifier; owns planItems list; JSON file persistence
                    (plan_data.json); supports version control via seriesId;
                    exposes restoreFromSnapshot(items)

BudgetCalculator    Pure static class; all budget math:
                    activeItemsForMonth, normalizedMonthlyIncome/FixedCosts,
                    spendableBudget, budgetStatus, planFixedCostReportLines,
                    monthlySummaries, cashFlowTotals

ReportAggregator    Pure static class; categoryTotals, applyThreshold (collapses
                    categories below a % into "Other"), financialTypeBreakdown

SaveLoadService     Pure static; local named snapshots saved to
                    getApplicationDocumentsDirectory()/saves/save_{id}.json;
                    cap of 5 non-damaged saves; methods: listSaves, createSave,
                    loadSave, deleteSave; damaged files surfaced with isDamaged flag

PeriodBoundsService Pure static; computes period navigation min/max bounds;
                    default ±1 year from now; expands by 1 extra year if plan
                    data exists at a boundary year

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
  finance_data.json        — expenses, income, fixedCosts
  plan_data.json           — planItems
  saves/save_{id}.json     — named snapshots (max 5)

Corrupt/missing files silently start fresh. No database; do not add one
unless explicitly requested.

--------------------------------------------------
DEPENDENCIES
--------------------------------------------------

path_provider     ^2.1.0   — app documents directory for JSON persistence
fl_chart          ^0.69.0  — pie charts in Reports screen
haptic_feedback   ^0.6.4   — tactile feedback on welcome screen coin toss

Before adding a dependency: explain why, check if Flutter SDK covers it,
keep count minimal.

--------------------------------------------------
KEY PATTERNS
--------------------------------------------------

- Enum extensions for .displayName / .icon / .color (never inline in UI)
- SwipeableTile wraps all list items: long-press → bottom sheet with Edit / Delete actions
- Month navigation is consistent across screens with Dec↔Jan wraparound
- Amounts displayed as X.XX €  (toStringAsFixed(2))
- One widget or screen per file; StatelessWidget unless local state is needed
- Business logic stays in services, never in UI files
- AppColors in lib/theme/app_theme.dart — all semantic + brand colors as constants;
  never use raw Color literals in screens or widgets
- buildAppTheme() in lib/theme/app_theme.dart centralises all ThemeData;
  no inline theme overrides in individual screens
- Navy/gold brand identity: AppColors.navy (0xFF0D1B4B) + AppColors.gold (0xFFD4A853)
  used exclusively for app chrome (AppBar + NavigationBar); body stays light/white
- onOpenSaves / onClearAll VoidCallbacks wired from MainScreen down to all tab screens

--------------------------------------------------
SCREENS
--------------------------------------------------

WelcomeScreen           Animated entry screen; coin toss interaction with vapor
                        result effect and haptic feedback; navigates to MainScreen
                        via mainScreenBuilder callback using pushReplacement
MainScreen              Root; 3 tabs: Expenses / Plan / Reports
ExpenseListScreen       Month view with navigation, budget bar, three-mode toggle (items/category/groups)
AddExpenseScreen        Add/edit expense form; includes optional free-text group field
ExpenseDetailScreen     Read-only expense detail; opened by tapping item in list view
CategoryExpenseListScreen  Drill-down from category view; shows individual expenses for one category + period
GroupExpenseListScreen  Drill-down from groups view; shows individual expenses for one group + period
PlanScreen              Monthly/yearly plan view (income + fixed costs)
AddPlanItemScreen       Add/edit plan item with type, frequency, validFrom
PlanItemDetailScreen    Read-only plan item detail; opened by tapping item in plan list
ReportScreen            Monthly / yearly / overview modes; pie charts by category
                        (pie: <10% grouped into Other, list: all categories shown)
IncomeListScreen        List of income entries
AddIncomeScreen         Add/edit income form
FixedCostListScreen     List of fixed costs
AddFixedCostScreen      Add/edit fixed cost form
SavesScreen             List / create / load / delete named local snapshots (max 5)

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
