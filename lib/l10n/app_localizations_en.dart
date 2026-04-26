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
  String get menuGuard => 'GUARD settings';

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
  String get howGuardWorkQuestion => 'How GUARD works?';

  @override
  String get howCategoryBudgetsWorkQuestion => 'How category budgets work?';

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
  String get sectionIncome => 'Income';

  @override
  String get sectionFixedCosts => 'Fixed Costs';

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

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get monthAbbrJan => 'Jan';

  @override
  String get monthAbbrFeb => 'Feb';

  @override
  String get monthAbbrMar => 'Mar';

  @override
  String get monthAbbrApr => 'Apr';

  @override
  String get monthAbbrMay => 'May';

  @override
  String get monthAbbrJun => 'Jun';

  @override
  String get monthAbbrJul => 'Jul';

  @override
  String get monthAbbrAug => 'Aug';

  @override
  String get monthAbbrSep => 'Sep';

  @override
  String get monthAbbrOct => 'Oct';

  @override
  String get monthAbbrNov => 'Nov';

  @override
  String get monthAbbrDec => 'Dec';

  @override
  String get categoryHousing => 'Housing';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryVacation => 'Vacation';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryInsurance => 'Insurance';

  @override
  String get categorySubscriptions => 'Subscriptions';

  @override
  String get categoryCommunication => 'Communication';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryRestaurants => 'Restaurants';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryClothing => 'Clothing';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryInvestment => 'Investment';

  @override
  String get categoryGifts => 'Gifts';

  @override
  String get categoryTaxes => 'Taxes';

  @override
  String get categoryMedications => 'Medications';

  @override
  String get categoryUtilities => 'Utilities';

  @override
  String get categoryHousehold => 'Household Supplies';

  @override
  String get categoryPersonalCare => 'Personal Care';

  @override
  String get categorySavings => 'Savings';

  @override
  String get categoryDebt => 'Debt';

  @override
  String get categoryKids => 'Kids';

  @override
  String get categoryPets => 'Pets';

  @override
  String get categoryFees => 'Fees';

  @override
  String get categoryFuel => 'Fuel';

  @override
  String get categoryMaintenance => 'Maintenance';

  @override
  String get categoryDonations => 'Donations';

  @override
  String get categoryOther => 'Other';

  @override
  String get financialTypeAsset => 'Asset';

  @override
  String get financialTypeConsumption => 'Consumption';

  @override
  String get financialTypeInsurance => 'Insurance';

  @override
  String get addPlanItemTitle => 'Add Plan Item';

  @override
  String get addMonthlyIncomeTitle => 'Add Monthly Income';

  @override
  String get addYearlyIncomeTitle => 'Add Yearly Income';

  @override
  String get addOneTimeIncomeTitle => 'Add One-time Income';

  @override
  String get addMonthlyFixedCostTitle => 'Add Monthly Fixed Cost';

  @override
  String get addYearlyFixedCostTitle => 'Add Yearly Fixed Cost';

  @override
  String get editMonthlyIncomeTitle => 'Edit Monthly Income';

  @override
  String get editYearlyIncomeTitle => 'Edit Yearly Income';

  @override
  String get editOneTimeIncomeTitle => 'Edit One-time Income';

  @override
  String get editMonthlyFixedCostTitle => 'Edit Monthly Fixed Cost';

  @override
  String get editYearlyFixedCostTitle => 'Edit Yearly Fixed Cost';

  @override
  String get labelType => 'Type';

  @override
  String get labelMonth => 'Month';

  @override
  String get labelYear => 'Year';

  @override
  String get labelDayOfMonth => 'Day of month';

  @override
  String get nameHintText => 'e.g. Salary, Rent, Insurance';

  @override
  String get validationEnterName => 'Enter a name';

  @override
  String get selectMonthTitle => 'Select month';

  @override
  String get lastRenewalYearTitle => 'Last renewal year';

  @override
  String lastMonthRenewal(String monthName) {
    return 'Last $monthName renewal';
  }

  @override
  String lastActiveMonthInfo(String label) {
    return 'Last active month: $label';
  }

  @override
  String get setEndDate => 'Set end date';

  @override
  String untilLabel(String validToLabel) {
    return 'Until: $validToLabel';
  }

  @override
  String lastActiveMonthNote(String label) {
    return '$label is the last active month.';
  }

  @override
  String get endMonthAfterStart => 'End month must be after start month.';

  @override
  String get fromFieldLabel => 'From';

  @override
  String renewedEachMonth(String monthName) {
    return 'Renewed each $monthName. Dates are fixed.';
  }

  @override
  String get untilFieldLabel => 'Until';

  @override
  String lastActiveMonthParens(String label) {
    return '$label (last active month)';
  }

  @override
  String get openEnded => 'Open-ended';

  @override
  String fromDateLabel(String validFromLabel) {
    return 'From: $validFromLabel';
  }

  @override
  String get samePeriodInPlace =>
      'Same month as original — will update in place.';

  @override
  String get differentPeriodNewVersion =>
      'Different month — will create a new version.';

  @override
  String get applyChangesToTitle => 'Apply changes to...';

  @override
  String get applyToWholeSeries => 'Whole series';

  @override
  String applyToWholeSeriesSubtitle(String seriesStartLabel) {
    return 'All periods from $seriesStartLabel onwards';
  }

  @override
  String applyFromOnwards(String nextLabel) {
    return 'From $nextLabel onwards';
  }

  @override
  String applyFromSubtitle(String capLabel, String nextLabel) {
    return 'Original series ends $capLabel.\nNew series starts $nextLabel.';
  }

  @override
  String get applyFromUnavailable =>
      'No future period available in this series.';

  @override
  String get yearlyItemsOnlyAtRenewal =>
      'Yearly items can only be changed at their renewal month.';

  @override
  String get guardRemindMe => 'Remind me to confirm this payment';

  @override
  String get guardShorterMonths => 'Shorter months will use their last day.';

  @override
  String get dueDayMonthly => 'Due day (repeats monthly)';

  @override
  String dueDayYearly(String monthName) {
    return 'Due day (repeats every $monthName)';
  }

  @override
  String dueDayMonthlyLabel(int day) {
    return 'Day $day of each month';
  }

  @override
  String dueDayYearlyLabel(int day, String monthName) {
    return 'Day $day of $monthName each year';
  }

  @override
  String get guardDailyReminder => 'Daily reminder';

  @override
  String get guardChangeNotifTime => 'Tap to change the notification time';

  @override
  String get guardNoGuardedItemsHint =>
      'Enable GUARD on a fixed cost to track payments.';

  @override
  String guardedItemsCount(int count) {
    return 'Guarded items · $count';
  }

  @override
  String get planItemTitle => 'Plan Item';

  @override
  String get activeFrom => 'Active from';

  @override
  String get activeUntil => 'Active until';

  @override
  String get perMonth => '/ month';

  @override
  String get perYear => '/ year';

  @override
  String get oneTimeSuffix => '(one-time)';

  @override
  String get noEndDate => 'No end date';

  @override
  String get guardNotEnabled => 'Not enabled';

  @override
  String removeIncomeEntirely(String name) {
    return '\"$name\" will be removed entirely.';
  }

  @override
  String removeIncomeFromOnwards(String name, String from, String prev) {
    return '\"$name\" will stop from $from onwards. $prev and earlier will remain planned.';
  }

  @override
  String get actionRemoveAllCaps => 'REMOVE';

  @override
  String get removeBudgetAllCaps => 'REMOVE BUDGET';

  @override
  String removeFromOnwardsTitle(String label) {
    return 'From $label onwards';
  }

  @override
  String removeCycleSubtitle(String start, String end) {
    return 'This cycle ($start – $end) and all future cycles are removed.';
  }

  @override
  String removeHistoryKept(String prev) {
    return 'History up to $prev is kept.';
  }

  @override
  String get silenceReminderTitle => 'Silence this reminder?';

  @override
  String silenceReminderBody(String periodLabel) {
    return 'The $periodLabel payment will still be shown as unconfirmed. You can mark it as paid at any time.';
  }

  @override
  String get yesSilence => 'Yes, Silence';

  @override
  String get addPlanItemTooltip => 'Add Plan Item';

  @override
  String get spendableThisMonth => 'Spendable this month';

  @override
  String get spendableThisYear => 'Spendable this year';

  @override
  String get noPlanItemsYet => 'No plan items yet.';

  @override
  String get tapPlusToAddPlanItems => 'Tap + to add income or fixed costs.';

  @override
  String get removeWholeSeries => 'Whole series';

  @override
  String removeWholeSeriesSubtitle(String seriesStartLabel) {
    return 'All periods from $seriesStartLabel are removed.';
  }

  @override
  String get clearAllDataAction => 'DELETE';

  @override
  String get clearAllDataDescription =>
      'Expenses, plan items, budgets and guard payments will be permanently deleted. This cannot be undone.';

  @override
  String get clearAllDataPreservedNote =>
      'Saved snapshots and auto-backups are not affected.';

  @override
  String get allCategoriesBudgeted =>
      'All categories already have a budget for this month. Select a different month to add another.';

  @override
  String get selectCategoryHint => 'Select a category';

  @override
  String get validationSelectCategory => 'Select a category';

  @override
  String get monthlyBudgetLabel => 'Monthly budget';

  @override
  String effectiveFromLabel(String validFromLabel) {
    return 'Effective from: $validFromLabel';
  }

  @override
  String pastMonthBudgetCreateWarning(String fromLabel) {
    return 'You are creating a budget for a past month. It will apply retroactively from $fromLabel.';
  }

  @override
  String pastMonthBudgetEditWarning(
    String catName,
    String fromLabel,
    String prevLabel,
  ) {
    return 'This will change the $catName budget back to $fromLabel. Months $fromLabel–$prevLabel will use the new amount.';
  }

  @override
  String get noFixedCostsPlanned => 'No fixed costs planned';

  @override
  String get noIncomePlanned => 'No income planned';

  @override
  String saveSlotSubtitle(String date, int expenseCount, int planItemCount) {
    return '$date · $expenseCount expenses · $planItemCount plan items';
  }

  @override
  String get saveSlotDamagedSubtitle => 'File is damaged and cannot be loaded';

  @override
  String get howGroupsTitle => 'Groups';

  @override
  String get howGroupsSubtitle0 => 'What a group is and how it works';

  @override
  String get howGroupsSubtitle1 => 'How to take advantage of it';

  @override
  String get howGroupsSubtitle2 => 'Where groups surface in the app';

  @override
  String get howGroupsLabel0 => 'Tag';

  @override
  String get howGroupsLabel1 => 'Be creative';

  @override
  String get howGroupsLabel2 => 'Record';

  @override
  String get howGroupsRule1 =>
      'A group is an optional free-text label you attach to any expense.';

  @override
  String get howGroupsRule2 =>
      'You type any string — there is no fixed list and no validation.';

  @override
  String get howGroupsRule3 =>
      'Two expenses belong to the same group only when their labels match exactly, character for character.';

  @override
  String get howGroupsRule4 =>
      'Case is preserved — \"Trip\" and \"trip\" are treated as two different groups.';

  @override
  String get howGroupsRule5 =>
      'The field is optional. Leave it blank and the expense simply has no group.';

  @override
  String get howGroupsHint =>
      'Set the group when creating or editing any expense.';

  @override
  String get howGroupsUseIntro =>
      'Use it whenever you want to track a slice of spending that cuts across categories.';

  @override
  String howGroupsExample1Label(int year) {
    return 'Barcelona $year';
  }

  @override
  String get howGroupsExample1Desc =>
      'Attach to every expense on a trip — flights, hotels, meals, tickets. See the total cost of the whole trip in one tap.';

  @override
  String howGroupsExample2Label(int year) {
    return 'McDonald\'s $year';
  }

  @override
  String get howGroupsExample2Desc =>
      'Use a consistent name all year. At year-end you know exactly what you spent at that one place.';

  @override
  String get howGroupsExample3Label => 'Home renovation Q1';

  @override
  String get howGroupsExample3Desc =>
      'Span multiple months with the same label. The Groups tab collects everything under that name.';

  @override
  String get howGroupsPrecision =>
      'The more precise your label, the more useful the summary.';

  @override
  String get howGroupsRecord0Title => 'Groups tab in Expenses';

  @override
  String get howGroupsRecord0Body =>
      'Every group that has at least one expense in the current month appears here as a single row showing the item count and total. Tap a group to drill down and see each individual expense behind it.';

  @override
  String get howGroupsRecord1Title => 'Monthly Report in Reports';

  @override
  String get howGroupsRecord1Body =>
      'When you export a monthly PDF from the Reports screen, groups with expenses in that month get a dedicated \"Expense Groups\" page — each group listed with its expenses, amounts, and a group total.';

  @override
  String get howGroupsMonthlyNote =>
      'Groups are not included in the yearly report — they are a monthly lens.';

  @override
  String get howGroupsExampleGroupName => 'My group';

  @override
  String get otherCategories => 'Other categories';

  @override
  String noCategoryExpenses(String category, String period) {
    return 'No $category expenses\nin $period.';
  }

  @override
  String guardDueDate(String monthName, int day, int year) {
    return 'Due $monthName $day, $year';
  }

  @override
  String get guardNotYetDue => 'Not yet due';

  @override
  String guardNextReminder(String label) {
    return 'Next: $label';
  }

  @override
  String guardLastReminder(String label) {
    return 'Last: $label';
  }

  @override
  String get guardChangeDay => 'Change day';

  @override
  String get guardRemoveAction => 'Remove GUARD';

  @override
  String get guardMarkUnpaidTitle => 'Mark as unpaid?';

  @override
  String guardMarkUnpaidBody(String monthName, int year) {
    return 'This will remove the payment confirmation for $monthName $year.';
  }

  @override
  String get guardMarkUnpaidAction => 'Mark as Unpaid';

  @override
  String get guardMarkAsPaid => 'Mark as Paid';

  @override
  String get guardRemoveTitle => 'Remove GUARD?';

  @override
  String guardRemoveBody(String name) {
    return 'GUARD will be disabled for \"$name\". Existing payment records are kept but no new reminders will fire.';
  }

  @override
  String get guardRemoveConfirm => 'Remove';

  @override
  String get guardSelectPaidDate => 'Select paid date';

  @override
  String guardPaidOn(String date) {
    return 'Paid $date';
  }

  @override
  String howItWorksStep(int n) {
    return 'STEP $n';
  }

  @override
  String get planSubtitle0 => 'Your salary and committed monthly bills';

  @override
  String get planSubtitle1 => 'How your fixed costs are classified';

  @override
  String get planSubtitle2 => 'How much of your income each type consumes';

  @override
  String get planSubStep0 => 'Cashflow';

  @override
  String get planSubStep1 => 'Classification';

  @override
  String get planSubStep2 => 'Allocation';

  @override
  String get howItWorksPlanIncomeBody =>
      'Enter your salary and committed monthly bills — rent, insurance, subscriptions. These are real, known numbers, not estimates or goals.';

  @override
  String get howItWorksTypeConsumptionDesc =>
      'Day-to-day spending — groceries, rent, dining, transport';

  @override
  String get howItWorksTypeAssetDesc =>
      'Investments and savings that grow your wealth over time';

  @override
  String get howItWorksTypeInsuranceDesc =>
      'Protection costs — car, health, and life insurance';

  @override
  String get howItWorksFinancialTypesBody =>
      'Each fixed cost is tagged with a financial type. This lets the app show how your income is distributed across spending, savings, and protection.';

  @override
  String get howItWorksSpendingVsIncomeTitle => 'Spending vs Income';

  @override
  String get howItWorksSpendingVsIncomeBody =>
      'The Plan tab shows how much of your income goes to each financial type — so you can see at a glance whether you spend, save, or protect the right share of what you earn.';

  @override
  String get expSubtitle0 => 'Your available budget, calculated from Plan';

  @override
  String get expSubtitle1 => 'Day-to-day spending you record';

  @override
  String get expSubtitle2 => 'Did you stay within budget?';

  @override
  String get subStepBudget => 'Budget';

  @override
  String get subStepSpending => 'Spending';

  @override
  String get subStepResult => 'Result';

  @override
  String get howItWorksBudgetBody =>
      'The app subtracts your fixed costs from your income and shows the result here. You don\'t set this number — it comes from your Plan.';

  @override
  String get howItWorksSpendingBody =>
      'Log groceries, meals, shopping and other variable spending. Fixed monthly bills like rent belong in Plan, not here.';

  @override
  String get howItWorksResultBody =>
      'At the end of the month the Expenses tab shows which outcome you had.';

  @override
  String get repSubtitle0 => 'Where did your money go?';

  @override
  String get repSubtitle1 => 'Your finances on paper';

  @override
  String get repSubtitle2 => 'The big picture, month by month';

  @override
  String get repSubStep0 => 'Breakdown';

  @override
  String get repSubStep1 => 'Export';

  @override
  String get repSubStep2 => 'Overview';

  @override
  String get howItWorksBreakdownBody =>
      'Breakdown shows your spending by category for any month or year. Tap a slice or category row to drill into the individual expenses and fixed costs behind it.';

  @override
  String get pdfFeatureCategoryTotals => 'Category totals';

  @override
  String get pdfFeatureBudgetVsActual => 'Budget vs actual';

  @override
  String get pdfFeatureTypeSplit => 'Financial type split';

  @override
  String get pdfFeatureAllExpenses => 'All expenses listed';

  @override
  String get pdfFeatureCategoryBudgets => 'Category budgets';

  @override
  String get pdfFeatureGroupSummaries => 'Group summaries';

  @override
  String get pdfFeature12MonthOverview => '12-month overview';

  @override
  String get pdfFeatureAnnualTotals => 'Annual totals';

  @override
  String get pdfFeatureMonthlyBreakdown => 'Monthly breakdown';

  @override
  String get pdfFeaturePlanVsActual => 'Plan vs actual';

  @override
  String get pdfFeatureTypeRatios => 'Type ratios';

  @override
  String get pdfFeatureActivePlanItems => 'Active plan items';

  @override
  String get howItWorksExportBody =>
      'Use the PDF button in Breakdown to export. Reports are shareable via any app on your device.';

  @override
  String get howItWorksMoreMonths => '· · · 9 more months';

  @override
  String get howItWorksOverviewBody =>
      'Overview shows all 12 months side by side — how much you earned, what went into assets, and what was consumed. Tap any month to jump to that period in the Plan.';

  @override
  String overBudgetBy(String amount) {
    return 'Over budget by $amount';
  }

  @override
  String savedAmount(String amount) {
    return 'Saved $amount';
  }

  @override
  String get loadingLabel => 'Loading…';

  @override
  String get autoBackupTitle => 'Auto Backup';

  @override
  String get autoBackupNoBackupYet => 'No backup yet';

  @override
  String get autoBackupSubtitleExpand => 'Updated daily · tap to expand';

  @override
  String get autoBackupSubtitleCollapse => 'Updated daily · tap to collapse';

  @override
  String get actionRestoreAllCaps => 'RESTORE';

  @override
  String get actionRestore => 'Restore';

  @override
  String get autoBackupRestoreDescription =>
      'Restoring will replace all current data with the backup.';

  @override
  String autoBackupRestored(String date) {
    return 'Backup from $date restored.';
  }

  @override
  String get autoBackupRestoreFailed => 'Failed to restore backup.';

  @override
  String get autoBackupPrimary => 'Primary backup';

  @override
  String get autoBackupSecondary => 'Secondary backup';

  @override
  String get frequencyPickerFixed => 'How often does it recur?';

  @override
  String get frequencyMonthlyFixedSubtitle =>
      'Rent, subscriptions, recurring bills';

  @override
  String get frequencyYearlyFixedSubtitle =>
      'Annual subscriptions, insurance, memberships';

  @override
  String get frequencyPickerIncome => 'How often do you receive it?';

  @override
  String get frequencyMonthlyIncomeSubtitle =>
      'Salary, pension, regular transfers';

  @override
  String get frequencyYearlyIncomeSubtitle =>
      'Annual bonus, tax refund, dividends';

  @override
  String get frequencyOneTimeIncomeSubtitle =>
      'Gift, windfall, one-off payment';

  @override
  String get typePickerTitle => 'What are you adding?';

  @override
  String get typeIncomeSubtitle => 'Salary, bonus, pension, gifts';

  @override
  String get typeFixedCostSubtitle => 'Rent, insurance, subscriptions';

  @override
  String get languagePickerTitle => 'Language';

  @override
  String get currencyPickerTitle => 'Currency';

  @override
  String get currencyCustom => 'Custom';

  @override
  String get currencyCustomSubtitle => 'Define your own code and symbol';

  @override
  String get currencyCustomTitle => 'Custom Currency';

  @override
  String get currencyCodeLabel => 'Code';

  @override
  String get currencyCodeHint => 'e.g. USD';

  @override
  String get currencySymbolLabel => 'Symbol';

  @override
  String get currencySymbolHint => 'e.g. \$';

  @override
  String get removeFromImport => 'Remove from import';

  @override
  String get exportExpensesTitle => 'Export Expenses';

  @override
  String get selectDateRangeHint => 'Select the date range to export:';

  @override
  String get startDateLabel => 'Start Date';

  @override
  String get endDateLabel => 'End Date';

  @override
  String get tapToSelectDate => 'Tap to select';

  @override
  String get endDateAfterStart => 'End date must be on or after start date.';

  @override
  String get actionExport => 'Export';

  @override
  String overspendWarning(String period, String amount) {
    return 'This $period you spent $amount more than you earned!';
  }

  @override
  String get periodMonth => 'month';

  @override
  String get periodYear => 'year';

  @override
  String guardBannerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'GUARD — $count payments not confirmed',
      one: 'GUARD — 1 payment not confirmed',
    );
    return '$_temp0';
  }

  @override
  String get guardSilencedBadge => 'silenced';

  @override
  String guardExpenseStripPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guarded payments pending',
      one: '1 guarded payment pending',
    );
    return '$_temp0';
  }

  @override
  String importErrorRowLabel(int row, String field) {
    return 'Row $row — $field';
  }

  @override
  String earnedLabel(String amount) {
    return 'Earned: $amount';
  }

  @override
  String fromDateShort(String label) {
    return 'from $label';
  }

  @override
  String untilDateShort(String label) {
    return 'until $label';
  }

  @override
  String get guardEnableToggle => 'Enable GUARD';

  @override
  String get guardEnableToggleSubtitle => 'Track payment and receive reminders';

  @override
  String get actionOk => 'OK';

  @override
  String get labelTotal => 'Total';

  @override
  String get categoryBudgetsTitle => 'Category Budgets';

  @override
  String get noCategoryBudgetsSet => 'No category budgets set.';

  @override
  String removeBudgetDialogTitle(String category) {
    return 'Remove $category budget';
  }

  @override
  String endBudgetFromTitle(String from) {
    return 'End from $from';
  }

  @override
  String endBudgetFromDescription(String from) {
    return 'Stops the budget from $from onwards. Earlier months keep their historical budget.';
  }

  @override
  String get deleteBudgetSeriesTitle => 'Delete entire series';

  @override
  String get deleteBudgetSeriesConfirm => 'Delete series';

  @override
  String deleteBudgetSeriesDescription(String range) {
    return 'Permanently removes all records ($range). No budget will appear for any month in this series. This cannot be undone.';
  }

  @override
  String budgetRangePresent(String start) {
    return '$start – present';
  }

  @override
  String get pdfMonthlyReport => 'Monthly Report';

  @override
  String get pdfYearlyReport => 'Yearly Report';

  @override
  String pdfMonthlyReportHeader(String month, int year) {
    return 'MONTHLY REPORT FOR $month $year';
  }

  @override
  String pdfYearlyReportHeader(int year) {
    return 'YEARLY REPORT FOR $year';
  }

  @override
  String get pdfPartialYear => '(partial year)';

  @override
  String get pdfSectionSpendingVsIncome => 'SPENDING VS INCOME';

  @override
  String get pdfSectionCategorySummary => 'CATEGORY SUMMARY';

  @override
  String get pdfSectionCashFlowSummary => 'CASH FLOW SUMMARY';

  @override
  String get pdfSectionExpenseGroups => 'EXPENSE GROUPS';

  @override
  String get pdfSectionExpenseDetails => 'EXPENSE DETAILS';

  @override
  String get pdfSectionYearlyOverview => 'YEARLY OVERVIEW';

  @override
  String get pdfSectionSpendingByCategory => 'SPENDING BY CATEGORY AND MONTH';

  @override
  String get pdfIncomeHeader => 'INCOME';

  @override
  String get pdfFixedCostsHeader => 'FIXED COSTS';

  @override
  String get pdfTotal => 'TOTAL';

  @override
  String get pdfColTotal => 'Total';

  @override
  String get pdfEarnedThisMonth => 'Earned this month';

  @override
  String get pdfEarnedThisYear => 'Earned this year';

  @override
  String get pdfGroupTotal => 'Group total (this month)';

  @override
  String get pdfAllPeriodsTotal => 'All periods total';

  @override
  String pdfItemsThisMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items this month',
      one: '1 item this month',
    );
    return '$_temp0';
  }

  @override
  String get pdfNormalized => ' (normalized)';

  @override
  String get pdfAnnualized => ' (annualized)';

  @override
  String get pdfPartialYearNote =>
      'Partial year - months without data show zeros. Year-to-date totals only.';

  @override
  String pdfPage(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get pdfNoData => 'No data.';

  @override
  String get howItWorksExampleSalary => 'Salary';

  @override
  String get howItWorksExampleBonus => 'Bonus';

  @override
  String get howItWorksExampleRent => 'Rent';

  @override
  String get howItWorksExampleInsurance => 'Insurance';

  @override
  String get howItWorksExampleEtfFonds => 'ETF fonds';

  @override
  String get addBudgetTooltip => 'Add budget';

  @override
  String get selectCategoryTitle => 'Select category';

  @override
  String get showAllCategories => 'Show all categories';

  @override
  String get showLessCategories => 'Show less';

  @override
  String get allCategoriesTitle => 'All Categories';

  @override
  String get howCategoryBudgetsSubtitle0 => 'Limit your spending by category!';

  @override
  String get howCategoryBudgetsSubtitle1 => 'Creating a budget';

  @override
  String get howCategoryBudgetsSubtitle2 => 'Reading the bar';

  @override
  String get howCategoryBudgetsLabel0 => 'Limit';

  @override
  String get howCategoryBudgetsLabel1 => 'Set up';

  @override
  String get howCategoryBudgetsLabel2 => 'Progress';

  @override
  String get howCategoryBudgetsWhatIntro =>
      'Set a monthly cap for any category — restaurants, groceries, entertainment. Spend what you planned, nothing more.';

  @override
  String get howCategoryBudgetsRule1 =>
      'Pick the categories where you tend to overspend. Set a limit only there.';

  @override
  String get howCategoryBudgetsRule2 =>
      'Each budget is a simple monthly cap — for example: Restaurants → 100 € per month.';

  @override
  String get howCategoryBudgetsRule3 =>
      'Budgets are optional. Set as many or as few as you like.';

  @override
  String get howCategoryBudgetsRule4 =>
      'You can have one budget per category, across as many categories as you need.';

  @override
  String get howCategoryBudgetsSetupIntro =>
      'Tap + on the Manage Budgets screen. Pick a category, enter an amount, choose when it starts. Done.';

  @override
  String get howCategoryBudgetsSetupRule1 =>
      'Pick a category — for example, Restaurants.';

  @override
  String get howCategoryBudgetsSetupRule2 =>
      'Enter your monthly limit — for example, 100 €.';

  @override
  String get howCategoryBudgetsSetupRule3 =>
      'Choose the month it starts from. It applies going forward from that point.';

  @override
  String get howCategoryBudgetsSetupRule4 =>
      'Once saved, the category is locked — create a new budget to change it later.';

  @override
  String get howCategoryBudgetsPastMonthHint =>
      'Choosing a past month will apply the budget retroactively. A confirmation appears before you save.';

  @override
  String get howCategoryBudgetsProgressIntro =>
      'The progress bar shows exactly where you stand — at a glance, every time you open Expenses.';

  @override
  String get howCategoryBudgetsProgressRule1 =>
      'Green — below 80%: you\'re on track. Keep going.';

  @override
  String get howCategoryBudgetsProgressRule2 =>
      'Amber — 80–100%: getting close. Time to slow down.';

  @override
  String get howCategoryBudgetsProgressRule3 =>
      'Red — over 100%: limit exceeded. A warning card appears at the top of your Expenses.';

  @override
  String get howCategoryBudgetsWhereTitle => 'Where it appears';

  @override
  String get howCategoryBudgetsWhere1 =>
      'Expenses — a progress bar appears below each category row when a budget is active.';

  @override
  String get howCategoryBudgetsWhere2 =>
      'Category view — each budgeted category shows its fill status inline.';

  @override
  String get howCategoryBudgetsWhere3 =>
      'Monthly PDF report — budgets are included in your spending summary.';

  @override
  String get howCategoryBudgetsResetHint =>
      'Budgets reset each month — unused amounts don\'t carry over.';

  @override
  String get howGuardSubtitle0 => 'Your payment reminder';

  @override
  String get howGuardSubtitle1 => 'Setting it up';

  @override
  String get howGuardSubtitle2 => 'How it repeats';

  @override
  String get howGuardLabel0 => 'Reminder';

  @override
  String get howGuardLabel1 => 'Settings';

  @override
  String get howGuardLabel2 => 'Recurring';

  @override
  String get howGuardWhatIntro =>
      'GUARD reminds you when a regular bill is coming due — rent, Netflix, insurance. Nothing slips through.';

  @override
  String get howGuardRule1 =>
      'On the due date, a notification appears on your phone. No action needed in advance.';

  @override
  String get howGuardRule2 =>
      'Tap \"Paid\" to confirm. Or silence it if you want to skip this time.';

  @override
  String get howGuardRule3 =>
      'Every guarded bill shows its current state at a glance.';

  @override
  String get howGuardStateUnpaid => 'Due — waiting for your confirmation';

  @override
  String get howGuardStatePaid => 'Paid — confirmed for this period';

  @override
  String get howGuardStateSilenced => 'Silenced — reminder dismissed';

  @override
  String get howGuardActivateIntro =>
      'Open any Fixed Cost, tap Edit, and switch GUARD on. Set when the bill is due — that\'s all.';

  @override
  String get howGuardActivateRule1 =>
      'Set the due day — the day of the month you expect to pay. For example: rent on the 1st, Netflix on the 15th.';

  @override
  String get howGuardActivateRule2 =>
      'From that day, a daily reminder repeats until you mark it paid or silence it.';

  @override
  String get howGuardActivateRule3 =>
      'For yearly bills — like insurance — also pick the due month.';

  @override
  String get howGuardActivateRule4 =>
      'You can change the daily reminder time in GUARD settings.';

  @override
  String get howGuardFixedCostOnlyHint =>
      'Only Fixed Cost items can have GUARD enabled.';

  @override
  String get howGuardActIntro =>
      'GUARD resets on its own at the start of each new period. You never need to reset anything manually.';

  @override
  String get howGuardActRule1 =>
      'Monthly bills — like rent or subscriptions — get a fresh reminder every month.';

  @override
  String get howGuardActRule2 =>
      'Yearly bills — like insurance or annual fees — reset once a year.';

  @override
  String get howGuardActRule3 =>
      'Once you mark a bill as paid, it stays confirmed until the next period begins.';

  @override
  String get howGuardPerPeriodHint =>
      'Paid or silenced — it only applies to the current period. The next one always starts fresh.';
}
