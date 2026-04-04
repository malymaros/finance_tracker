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
  screens/                       Full-page UI; subfolders: plan/, reports/
  services/                      Business logic and data access
  widgets/                       Reusable UI components
  theme/                         AppColors constants and buildAppTheme()

.claude/
  skills/                        Project-specific Claude Code skill definitions

--------------------------------------------------
MODELS
--------------------------------------------------

Expense          amount, category (ExpenseCategory), financialType, date, note?, group?
PlanItem         name, amount, type (income|fixedCost), frequency, validFrom (YearMonth), validTo (YearMonth)?,
                 seriesId, category?, financialType?; GUARD fields: isGuarded, guardDueDay?,
                 guardDueMonth?, guardOneTime
CategoryBudget   id, seriesId, category, amount, validFrom (YearMonth), validTo (YearMonth)?;
                 same version-series pattern as PlanItem
ReportData       listTotals (all categories), chartTotals (threshold-collapsed), breakdown, grandTotal
YearMonth        year, month; implements Comparable
MonthlySummary   plannedIncome, plannedFixedCosts, spendableBudget, actualExpenses, difference
BudgetStatus     spendableBudget, actualSpent, remaining, percentUsed, isOverBudget
CategoryTotal    category, amount, percentage
ReportLine       category, financialType, amount
SaveSlot         id, name, createdAt, expenseCount, planItemCount, isDamaged
GuardPayment     id, planItemId, seriesId, period (YearMonth), paidAt, isSilenced
GuardState       enum: none | scheduled | unpaidActive | unpaidSilenced | paid

ExpenseCategory enum (17 values): housing, groceries, vacation, transport, insurance,
  subscriptions, communication, health, restaurants, entertainment, clothing,
  education, investment, gifts, taxes, medications, other
  — each value has .displayName, .icon, .color extensions
  — alphabetically sorted in category pickers; 'other' always pinned last

FinancialType enum: asset | consumption | insurance
  — each value has .displayName, .icon, .color extensions

All models implement toJson() / fromJson(). ExpenseCategoryX.fromJson() handles
legacy string values via _fromLegacy(); 'drugstore' maps to other.
PlanItem.fromJson uses .asNameMap()[x] ?? fallback for type/frequency to avoid
crashes on unknown enum strings.

--------------------------------------------------
SERVICES
--------------------------------------------------

AppRepositories     Plain parameter object bundling all four repositories
                    (finance, plan, budget, guard); passed to screens that need
                    access to more than one repo

FinanceRepository   ChangeNotifier; owns expenses list; JSON file persistence
                    (finance_data.json via path_provider);
                    provides expensesForMonth/Year/Group and reportLinesForMonth/Year helpers;
                    exposes restoreFromSnapshot(expenses)

PlanRepository      ChangeNotifier; owns planItems list; JSON file persistence
                    (plan_data.json); supports version control via seriesId;
                    exposes restoreFromSnapshot(items)

CategoryBudgetRepository  ChangeNotifier; owns CategoryBudget list; JSON file persistence
                    (category_budgets.json); key methods: addCategoryBudget,
                    changeCategoryBudgetFrom, endCategoryBudget, deleteEntireSeries,
                    activeBudgetForMonth, allActiveBudgetsForMonth,
                    yearlyTotalForCategory, allYearlyTotals, seriesVersions,
                    activeBudgetRecordForMonth, restoreFromSnapshot, clearAll

GuardRepository     ChangeNotifier; owns GuardPayment list; JSON file persistence
                    (guard_data.json); tracks payment/silence state for guarded
                    fixed-cost plan items; exposes itemStateForPeriod,
                    unpaidActiveItems, markPaid, markSilenced, restoreFromSnapshot

BudgetCalculator    Pure static class; all budget math:
                    activeItemsForMonth, activeItemsForYear,
                    normalizedMonthlyIncome/FixedCosts, yearlyIncome, yearlyFixedCosts,
                    itemMonthlyContribution, itemYearlyContribution,
                    spendableBudget, budgetStatus,
                    planFixedCostReportLinesForMonth, planFixedCostReportLinesForYear,
                    planFinancialTypeTotals, planCategoryTotals,
                    financialTypeIncomeRatios, monthlySummaries

ReportAggregator    Pure static class; mergedLines (deduplicates plan + actual lines),
                    categoryTotals, categoryTotalsForType, applyThreshold (collapses
                    categories below a % into "Other"),
                    buildReportData (assembles full ReportData from lines + threshold
                    in one call)

PdfReportService    Pure static; builds monthly and yearly PDF documents (Uint8List)
                    from pre-assembled MonthlyPdfData / YearlyPdfData; uses pdf package

ImportExportService Pure static; parseImportFile (xlsx → ImportResult),
                    parseCsvFile (csv → ImportResult), exportData (JSON export);
                    ImportResult contains valid ImportedExpense rows + ImportRowError list

DataPortabilityService  Pure static; full JSON export/import of all repository data
                    including categoryBudgets; backward-compatible (missing key = empty)

ShareService        Pure static; wraps share_plus for sharing files via OS sheet

SaveLoadService     Pure static; named snapshots saved to
                    getApplicationDocumentsDirectory()/saves/save_{id}.json;
                    cap of 3 non-damaged named saves (createSave returns 'cap' when hit);
                    methods: listSaves, createSave, loadSave, deleteSave;
                    damaged files surfaced with isDamaged flag;
                    auto-backup: checkAndRotate (called on cold launch) writes daily
                    snapshots to autosave_0.json (Primary) and autosave_1.json (Secondary);
                    listAutoSaves, loadAutoSave manage the two auto-backup slots;
                    all save/load operations include categoryBudgets and guardPayments

PeriodBoundsService Pure static; computes period navigation min/max bounds;
                    default ±1 year from now; expands by 1 extra year if plan
                    data exists at a boundary year

GuardNotificationService  Pure static; schedules local push notifications for
                    guarded fixed costs via flutter_local_notifications;
                    persists notify hour/minute in shared_preferences

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
  finance_data.json        — expenses
  plan_data.json           — planItems
  category_budgets.json    — category budget series
  guard_data.json          — guard payments and silence records
  saves/save_{id}.json     — named snapshots (max 3)
  autosave_0.json          — auto-backup Primary (today)
  autosave_1.json          — auto-backup Secondary (previous day)
  autosave_meta.json       — last auto-backup date

Corrupt/missing files silently start fresh. No database; do not add one
unless explicitly requested.

--------------------------------------------------
DEPENDENCIES
--------------------------------------------------

path_provider              ^2.1.0   — app documents directory for JSON persistence
fl_chart                   ^0.69.0  — pie charts in Reports screen
pdf                        ^3.11.0  — PDF generation
share_plus                 ^9.0.0   — OS share sheet for PDF export
excel                      ^4.0.6   — xlsx file parsing for import
file_picker                ^8.0.7   — file selection for import
flutter_local_notifications ^18.0.0 — GUARD payment reminders
shared_preferences         ^2.2.0   — persist GUARD notification time
timezone / flutter_timezone ^0.9.4/^5.0.0 — required by local notifications

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
- Type-selector bottom sheet before forms: when a form requires a type decision
  (Income vs Fixed Cost), show AddPlanItemTypeSheet first so the choice is explicit
  and the form opens pre-configured — type cannot be changed mid-form

--------------------------------------------------
SCREENS
--------------------------------------------------

WelcomeScreen           Animated entry screen; coin toss interaction with vapor
                        result effect and haptic feedback; navigates to MainScreen
                        via mainScreenBuilder callback using pushReplacement
MainScreen              Root; 3 tabs: Expenses / Plan / Reports
ExpenseListScreen       Month view with navigation, three-mode toggle (items/category/groups);
                        items mode: CategoryBudgetWarningCard for over-budget categories;
                        category mode: CategoryBudgetProgressBar per category group
AddExpenseScreen        Add/edit expense form; includes optional free-text group field
ExpenseDetailScreen     Read-only expense detail; opened by tapping item in list view
CategoryExpenseListScreen  Drill-down from category view; shows individual expenses for one category + period
GroupExpenseListScreen  Drill-down from groups view; shows individual expenses for one group + period
PlanScreen              Monthly/yearly plan view; income section + fixed costs section
                        in collapsible accordions; fixed costs further grouped by
                        financial type accordion, then by category for Consumption items;
                        financial type distribution card at bottom;
                        overflow menu → Manage Budgets, GUARD
AddPlanItemTypeSheet    Bottom sheet shown before AddPlanItemScreen; user selects
                        Income or Fixed Cost before the form opens; type is then locked
                        for the session
AddPlanItemScreen       Add/edit plan item; accepts initialType (pre-selects and locks
                        the type selector); screen title reflects type: "Add Income",
                        "Add Fixed Cost", "Edit Income", "Edit Fixed Cost"; type is
                        also locked when editing an existing item; GUARD fields
                        (isGuarded, guardDueDay, guardDueMonth, guardOneTime) on fixed costs
PlanItemDetailScreen    Read-only plan item detail; opened by tapping item in plan list
ManageBudgetsScreen     Category budget management; own ±2-year period navigator;
                        monthly: list of CategoryBudgetTile (sorted alpha, other last);
                        FAB → AddCategoryBudgetScreen; accessed from PlanScreen overflow menu
AddCategoryBudgetScreen Add/edit category budget form; category locked when editing;
                        past-month inline warning; effective-from month picker
GuardScreen             Lists guarded fixed-cost items with payment/silence status;
                        notification time config; mark-paid and silence actions;
                        accessed from PlanScreen overflow menu
ReportScreen            Monthly / yearly / overview modes; pie charts by category
                        (pie: <5% grouped into Other, list: all categories shown);
                        drill-down → CategoryReportDetailScreen; PDF export
CategoryReportDetailScreen  Drill-down from ReportScreen for one category + period;
                        two sections: FIXED COSTS (PlanItemTile) and EXPENSES (ExpenseListTile);
                        grand total = fixed costs + expenses; monthly or yearly mode
ImportScreen            Multi-step xlsx/csv import: file picker → parse preview →
                        edit/remove rows → confirm → write to FinanceRepository;
                        accessed from overflow menu
SavesScreen             Named saves (max 3) + auto-backup section (Primary/Secondary);
                        FAB to create named save; swipe to delete; load restores all repos;
                        also exposes JSON export/import via DataPortabilityService

--------------------------------------------------
TESTING
--------------------------------------------------

Place tests in test/ mirroring the lib/ structure.

857 tests, all passing. flutter analyze: no issues.

Models:   Expense, YearMonth, ExpenseCategory, FinancialType, ReportData,
          PlanItem (serialization, GUARD fields, copyWith sentinels, unknown enum fallback),
          CategoryBudget (serialization, copyWith + clearValidTo), SaveSlot

Services: FinanceRepository, PlanRepository, CategoryBudgetRepository,
          BudgetCalculator, ReportAggregator, PeriodBoundsService,
          ImportExportService, DataPortabilityService, SaveLoadService,
          GuardRepository

Screens:  AddExpenseScreen, AddPlanItemScreen, PlanScreen, ExpenseDetailScreen,
          PlanItemDetailScreen, ReportScreen (all 3 modes + cache invalidation),
          ManageBudgetsScreen, CategoryReportDetailScreen,
          CrossTabConsistency

Widgets:  PlanCategoryTile, PlanFinancialTypeTile, PeriodNavigator, ExpenseListTile,
          ExpenseListScreen (items/category/group modes + budget warning card),
          AddPlanItemTypeSheet, CategoryBudgetProgressBar, CategoryBudgetWarningCard,
          ExportDateRangeDialog, GuardBanner, GuardItemStatusCard, GuardStatusIcon

When adding logic, add unit tests for services and pure functions.

--------------------------------------------------
COMMANDS
--------------------------------------------------

flutter pub get        Install dependencies
flutter run            Run application
flutter analyze        Static analysis
flutter test           Run tests
flutter build apk      Build Android APK
