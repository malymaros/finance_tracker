// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Finance Tracker';

  @override
  String get welcomeTagline => 'Take control of your money';

  @override
  String get getStarted => 'Get Started';

  @override
  String get tabExpenses => 'Expenses';

  @override
  String get tabPlan => 'Plan';

  @override
  String get tabReports => 'Reports';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionLoad => 'Load';

  @override
  String get actionImport => 'Import';

  @override
  String get actionOverwrite => 'Overwrite';

  @override
  String get labelAmount => 'Amount';

  @override
  String get labelCategory => 'Category';

  @override
  String get labelFinancialType => 'Financial type';

  @override
  String get labelDate => 'Date';

  @override
  String get labelNote => 'Note';

  @override
  String get labelNoteOptional => 'Note (optional)';

  @override
  String get labelGroup => 'Group';

  @override
  String get labelGroupOptional => 'Group (optional)';

  @override
  String get groupHintText => 'e.g. Vacation, Birthday';

  @override
  String get labelName => 'Name';

  @override
  String get labelFrequency => 'Frequency';

  @override
  String get labelValidFrom => 'Valid from';

  @override
  String get labelValidTo => 'Valid to (optional)';

  @override
  String get menuImportExpenses => 'Import Expenses';

  @override
  String get menuExportExpenses => 'Export Expenses';

  @override
  String get menuImport => 'Import';

  @override
  String get menuSaves => 'Saves';

  @override
  String get menuDeleteAll => 'Delete all data';

  @override
  String get menuHowItWorks => 'How it works';

  @override
  String get menuResetWithDummyData => 'Reset with dummy data';

  @override
  String get menuManageBudgets => 'Manage Budgets';

  @override
  String get menuGuard => 'GUARD';

  @override
  String get expenseListTitle => 'Expenses';

  @override
  String get savesTooltip => 'Saves';

  @override
  String get howItWorksTooltip => 'How it works';

  @override
  String get howItWorksQuestion => 'How it works?';

  @override
  String get viewModeItems => 'Items';

  @override
  String get viewModeByCategory => 'Category';

  @override
  String get viewModeByGroup => 'Groups';

  @override
  String get thisMonthsBudget => 'This month\'s budget';

  @override
  String get budgetNotSet => 'Budget not set';

  @override
  String get setIncomeInPlan => 'Set income in Plan';

  @override
  String noExpensesInMonth(String monthName, int year) {
    return 'No expenses in $monthName $year.';
  }

  @override
  String get tapPlusToAddOne => 'Tap + to add one.';

  @override
  String get fixedBillsHint => 'Fixed bills like rent belong in Plan.';

  @override
  String get noGroupsThisMonth => 'No groups this month.';

  @override
  String get addGroupHint =>
      'Add a group when creating\nor editing an expense.';

  @override
  String get howGroupsWorkQuestion => 'How groups work?';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get addExpenseTitle => 'Add Expense';

  @override
  String get editExpenseTitle => 'Edit Expense';

  @override
  String get validationAmountEmpty => 'Enter an amount';

  @override
  String get validationAmountInvalid => 'Enter a valid positive number';

  @override
  String get expenseDetailTitle => 'Expense';

  @override
  String noExpensesInNamedGroup(String name) {
    return 'No expenses in \"$name\".';
  }

  @override
  String get planTitle => 'Plan';

  @override
  String get toggleMonthly => 'Monthly';

  @override
  String get toggleYearly => 'Yearly';

  @override
  String get sectionIncome => 'INCOME';

  @override
  String get sectionFixedCosts => 'FIXED COSTS';

  @override
  String get noIncomeItems => 'No income items.';

  @override
  String get noFixedCostItems => 'No fixed cost items.';

  @override
  String get spendableBudget => 'Spendable budget';

  @override
  String get deleteItemDialogTitle => 'Delete plan item';

  @override
  String get deleteItemFromPeriod => 'From this period';

  @override
  String get deleteItemWholeSeries => 'Entire series';

  @override
  String get planItemDeleted => 'Plan item deleted.';

  @override
  String get addIncomeTitle => 'Add Income';

  @override
  String get addFixedCostTitle => 'Add Fixed Cost';

  @override
  String get editIncomeTitle => 'Edit Income';

  @override
  String get editFixedCostTitle => 'Edit Fixed Cost';

  @override
  String get frequencyOneTime => 'One-time';

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get frequencyYearly => 'Yearly';

  @override
  String get guardSectionLabel => 'GUARD';

  @override
  String get guardTrackPayment => 'Track payment';

  @override
  String get guardDueDayLabel => 'Due day';

  @override
  String get guardOneTimeLabel => 'One-time payment';

  @override
  String get planItemSaved => 'Plan item saved.';

  @override
  String get addNewItemSheetTitle => 'Add New';

  @override
  String get typeIncome => 'Income';

  @override
  String get typeFixedCost => 'Fixed Cost';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get manageBudgetsTitle => 'Manage Budgets';

  @override
  String get noBudgetsSet => 'No budgets set for this period.';

  @override
  String get addFirstBudget => 'Add your first budget.';

  @override
  String get addBudgetTitle => 'Add Budget';

  @override
  String get editBudgetTitle => 'Edit Budget';

  @override
  String get budgetAmount => 'Budget amount';

  @override
  String get effectiveFrom => 'Effective from';

  @override
  String get pastMonthBudgetWarning =>
      'Setting a budget in the past will not affect past spending.';

  @override
  String get budgetSaved => 'Budget saved.';

  @override
  String get budgetDeleted => 'Budget deleted.';

  @override
  String get guardScreenTitle => 'GUARD';

  @override
  String get guardDailyReminderTime => 'Daily reminder time';

  @override
  String get guardTimePicker => 'Daily GUARD reminder time';

  @override
  String get guardMarkPaid => 'Mark paid';

  @override
  String get guardSilence => 'Silence';

  @override
  String get guardStatusPaid => 'Paid';

  @override
  String get guardStatusScheduled => 'Scheduled';

  @override
  String get guardStatusUnpaid => 'Unpaid';

  @override
  String get guardStatusSilenced => 'Silenced';

  @override
  String get noGuardedItems => 'No guarded items.';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportModeMonthly => 'Monthly';

  @override
  String get reportModeYearly => 'Yearly';

  @override
  String get reportModeOverview => 'Overview';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get noExpensesForPeriod => 'No expenses recorded for this period.';

  @override
  String get noIncomeOrSpendingDataForYear =>
      'No income or spending data for this year.';

  @override
  String get pieChartOther => 'Other';

  @override
  String get reportSectionFixedCosts => 'FIXED COSTS';

  @override
  String get reportSectionExpenses => 'EXPENSES';

  @override
  String get noneInPeriod => 'None in this period.';

  @override
  String fixedCostCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fixed costs',
      one: '1 fixed cost',
    );
    return '$_temp0';
  }

  @override
  String expenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '1 expense',
    );
    return '$_temp0';
  }

  @override
  String get noItemsInPeriod => 'No items in this period';

  @override
  String get importTitle => 'Import Expenses';

  @override
  String get importStep1Title => 'Download Template';

  @override
  String get importStep1Description =>
      'Get the official Excel template with all required columns and a guide to valid values.';

  @override
  String get importStep1Button => 'Download Template';

  @override
  String get importStep2Title => 'Fill & Import';

  @override
  String get importStep2Description =>
      'Fill the template in Excel or Google Sheets, then select the file here to import your expenses.';

  @override
  String get importStep2Button => 'Select File (.xlsx or .csv)';

  @override
  String get importInfoText =>
      'Only expenses can be imported. Income and plan items are not supported.\n\nAccepted formats: .xlsx (Excel) and .csv.\nCSV files must have the same column order as the template: Date, Amount, Category, Financial Type, Note, Group.\n\nFiles exported from this app can also be imported directly.';

  @override
  String importReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses ready to import',
      one: '1 expense ready to import',
    );
    return '$_temp0';
  }

  @override
  String importErrorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows could not be read',
      one: '1 row could not be read',
    );
    return '$_temp0';
  }

  @override
  String importErrorCountSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows could not be read — will be skipped',
      one: '1 row could not be read — will be skipped',
    );
    return '$_temp0';
  }

  @override
  String get importNoDataFound => 'No data found in the file.';

  @override
  String get importTapToEdit =>
      'Tap any row to edit or remove it before importing.';

  @override
  String get importRowsWithErrors => 'Rows with errors';

  @override
  String get importNoDataRows => 'No data rows found.';

  @override
  String importConfirmButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count expenses',
      one: 'Import 1 expense',
    );
    return '$_temp0';
  }

  @override
  String importSuccessMessage(int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses imported · $range',
      one: '1 expense imported · $range',
    );
    return '$_temp0';
  }

  @override
  String get importUnsupportedFile =>
      'Unsupported file type. Please select an .xlsx or .csv file.';

  @override
  String get importCouldNotReadFile =>
      'Could not read the file. Please try again.';

  @override
  String importPickerError(Object error) {
    return 'Could not open file picker: $error';
  }

  @override
  String importTemplateError(Object error) {
    return 'Could not generate template: $error';
  }

  @override
  String get tryAnotherFile => 'Try Another File';

  @override
  String get savesTitle => 'Saves';

  @override
  String get sectionAutoBackup => 'AUTO BACKUP';

  @override
  String get sectionSaves => 'SAVES';

  @override
  String get sectionDataTransfer => 'DATA TRANSFER';

  @override
  String get sectionDataDeletion => 'DATA DELETION';

  @override
  String get exportAllData => 'Export all data';

  @override
  String get importAllData => 'Import all data';

  @override
  String get deleteAllData => 'Delete all data';

  @override
  String get emptySlot => 'Empty slot';

  @override
  String savedConfirmation(String name) {
    return '\'$name\' saved.';
  }

  @override
  String loadedConfirmation(String name) {
    return '\'$name\' loaded.';
  }

  @override
  String exportFailed(Object error) {
    return 'Export failed: $error';
  }

  @override
  String importFailedInvalid(Object error) {
    return 'Invalid file: $error';
  }

  @override
  String get importDataSuccess => 'Data imported successfully.';

  @override
  String get couldNotReadSelectedFile => 'Could not read the selected file.';

  @override
  String get importDataDialogTitle => 'Import data?';

  @override
  String get importDataDialogContent =>
      'This will replace ALL current expenses and plan items with the contents of the file. This cannot be undone.';

  @override
  String get saveName => 'Save name';

  @override
  String get saveNameCannotBeEmpty => 'Name cannot be empty';

  @override
  String replacingLabel(String name) {
    return 'Replacing: $name';
  }

  @override
  String get loadDialogDescription =>
      'All current data will be replaced with this saved snapshot.';

  @override
  String get deleteDialogDescription =>
      'This saved snapshot will be permanently deleted.';

  @override
  String get damagedSaveFile => 'Damaged save file';

  @override
  String overBudgetAmount(String amount) {
    return '$amount over';
  }

  @override
  String underBudgetAmount(String amount) {
    return '$amount left';
  }

  @override
  String spentLabel(String amount) {
    return 'Spent: $amount';
  }

  @override
  String budgetLabel(String amount) {
    return 'Budget: $amount';
  }

  @override
  String progressBarLabel(String spent, String budget) {
    return '$spent spent  /  $budget budget';
  }

  @override
  String categoryBudgetOverBy(String category, String amount) {
    return '$category budget: over by $amount';
  }

  @override
  String get deleteAllDataDialogTitle => 'Delete all data?';

  @override
  String get deleteAllDataDialogContent =>
      'This will permanently delete all expenses, income, and plan items. This cannot be undone.';

  @override
  String get deleteAllDataConfirm => 'Delete all';
}
