import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Finance Tracker'**
  String get appTitle;

  /// Welcome screen subtitle below the app name
  ///
  /// In en, this message translates to:
  /// **'Take control of your money'**
  String get welcomeTagline;

  /// Welcome screen primary action button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Bottom navigation tab label
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get tabExpenses;

  /// Bottom navigation tab label
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get tabPlan;

  /// Bottom navigation tab label
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get tabReports;

  /// Generic edit action label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// Generic delete action label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Generic save / submit button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Load a saved snapshot
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get actionLoad;

  /// Generic import button label
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actionImport;

  /// Overwrite a save slot
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get actionOverwrite;

  /// Form field label for monetary amount
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get labelAmount;

  /// Form field / detail row label for expense category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get labelCategory;

  /// Form section / detail row label for financial type
  ///
  /// In en, this message translates to:
  /// **'Financial type'**
  String get labelFinancialType;

  /// Form field / detail row label for date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get labelDate;

  /// Detail row label for note
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get labelNote;

  /// Form field label for optional note
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get labelNoteOptional;

  /// Detail row label for group
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get labelGroup;

  /// Form field label for optional group
  ///
  /// In en, this message translates to:
  /// **'Group (optional)'**
  String get labelGroupOptional;

  /// Hint text inside the group text field
  ///
  /// In en, this message translates to:
  /// **'e.g. Vacation, Birthday'**
  String get groupHintText;

  /// Form field label for item name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelName;

  /// Form field label for payment frequency
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get labelFrequency;

  /// Form field label for start period
  ///
  /// In en, this message translates to:
  /// **'Valid from'**
  String get labelValidFrom;

  /// Form field label for optional end period
  ///
  /// In en, this message translates to:
  /// **'Valid to (optional)'**
  String get labelValidTo;

  /// Overflow menu item on the Expenses screen
  ///
  /// In en, this message translates to:
  /// **'Import Expenses'**
  String get menuImportExpenses;

  /// Overflow menu item on the Expenses screen
  ///
  /// In en, this message translates to:
  /// **'Export Expenses'**
  String get menuExportExpenses;

  /// Overflow menu item for generic import
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get menuImport;

  /// Overflow menu item to open the saves screen
  ///
  /// In en, this message translates to:
  /// **'Saves'**
  String get menuSaves;

  /// Overflow menu item to delete all data
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get menuDeleteAll;

  /// Overflow menu item to open the how-it-works explainer
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get menuHowItWorks;

  /// Debug-only overflow menu item
  ///
  /// In en, this message translates to:
  /// **'Reset with dummy data'**
  String get menuResetWithDummyData;

  /// Overflow menu item on Plan tab
  ///
  /// In en, this message translates to:
  /// **'Manage Budgets'**
  String get menuManageBudgets;

  /// Overflow menu item to open the GUARD screen
  ///
  /// In en, this message translates to:
  /// **'GUARD'**
  String get menuGuard;

  /// AppBar title for the expense list screen
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenseListTitle;

  /// Tooltip for the saves icon button in the AppBar
  ///
  /// In en, this message translates to:
  /// **'Saves'**
  String get savesTooltip;

  /// Tooltip for the help icon button
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorksTooltip;

  /// Link text to open the how-it-works sheet
  ///
  /// In en, this message translates to:
  /// **'How it works?'**
  String get howItWorksQuestion;

  /// Segmented toggle label for item-list view
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get viewModeItems;

  /// Segmented toggle label for category-group view
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get viewModeByCategory;

  /// Segmented toggle label for group view
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get viewModeByGroup;

  /// Label on the budget card / progress bar
  ///
  /// In en, this message translates to:
  /// **'This month\'s budget'**
  String get thisMonthsBudget;

  /// Shown on the no-budget card when no income is planned
  ///
  /// In en, this message translates to:
  /// **'Budget not set'**
  String get budgetNotSet;

  /// Call-to-action on the no-budget card
  ///
  /// In en, this message translates to:
  /// **'Set income in Plan'**
  String get setIncomeInPlan;

  /// Empty state message on the expense list screen for the selected month
  ///
  /// In en, this message translates to:
  /// **'No expenses in {monthName} {year}.'**
  String noExpensesInMonth(String monthName, int year);

  /// Empty state hint on the expense list screen
  ///
  /// In en, this message translates to:
  /// **'Tap + to add one.'**
  String get tapPlusToAddOne;

  /// Empty state secondary hint on the expense list screen
  ///
  /// In en, this message translates to:
  /// **'Fixed bills like rent belong in Plan.'**
  String get fixedBillsHint;

  /// Empty state when no expenses have a group in this month
  ///
  /// In en, this message translates to:
  /// **'No groups this month.'**
  String get noGroupsThisMonth;

  /// Secondary hint below the no-groups empty state
  ///
  /// In en, this message translates to:
  /// **'Add a group when creating\nor editing an expense.'**
  String get addGroupHint;

  /// Link text to open the how-groups-work sheet
  ///
  /// In en, this message translates to:
  /// **'How groups work?'**
  String get howGroupsWorkQuestion;

  /// Number of items in a category or group header
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// AppBar title when adding a new expense
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpenseTitle;

  /// AppBar title when editing an existing expense
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpenseTitle;

  /// Validation error when amount field is empty
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get validationAmountEmpty;

  /// Validation error when amount is zero or non-numeric
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive number'**
  String get validationAmountInvalid;

  /// AppBar title for the expense detail screen
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseDetailTitle;

  /// Empty state in the group expense list screen
  ///
  /// In en, this message translates to:
  /// **'No expenses in \"{name}\".'**
  String noExpensesInNamedGroup(String name);

  /// AppBar title for the Plan tab
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planTitle;

  /// Toggle label for monthly view mode
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get toggleMonthly;

  /// Toggle label for yearly view mode
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get toggleYearly;

  /// Section header in the Plan screen
  ///
  /// In en, this message translates to:
  /// **'INCOME'**
  String get sectionIncome;

  /// Section header in the Plan screen
  ///
  /// In en, this message translates to:
  /// **'FIXED COSTS'**
  String get sectionFixedCosts;

  /// Empty state inside the income accordion
  ///
  /// In en, this message translates to:
  /// **'No income items.'**
  String get noIncomeItems;

  /// Empty state inside the fixed costs accordion
  ///
  /// In en, this message translates to:
  /// **'No fixed cost items.'**
  String get noFixedCostItems;

  /// Label for the spendable budget amount in the Plan screen header
  ///
  /// In en, this message translates to:
  /// **'Spendable budget'**
  String get spendableBudget;

  /// Title of the dialog when deleting a plan item
  ///
  /// In en, this message translates to:
  /// **'Delete plan item'**
  String get deleteItemDialogTitle;

  /// Option to remove item from the current period only
  ///
  /// In en, this message translates to:
  /// **'From this period'**
  String get deleteItemFromPeriod;

  /// Option to delete all versions of the plan item
  ///
  /// In en, this message translates to:
  /// **'Entire series'**
  String get deleteItemWholeSeries;

  /// Snackbar confirmation after deleting a plan item
  ///
  /// In en, this message translates to:
  /// **'Plan item deleted.'**
  String get planItemDeleted;

  /// AppBar title when adding a new income item
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncomeTitle;

  /// AppBar title when adding a new fixed cost item
  ///
  /// In en, this message translates to:
  /// **'Add Fixed Cost'**
  String get addFixedCostTitle;

  /// AppBar title when editing an existing income item
  ///
  /// In en, this message translates to:
  /// **'Edit Income'**
  String get editIncomeTitle;

  /// AppBar title when editing an existing fixed cost item
  ///
  /// In en, this message translates to:
  /// **'Edit Fixed Cost'**
  String get editFixedCostTitle;

  /// Frequency option label
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get frequencyOneTime;

  /// Frequency option label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get frequencyMonthly;

  /// Frequency option label
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get frequencyYearly;

  /// Section label for GUARD fields in add plan item screen
  ///
  /// In en, this message translates to:
  /// **'GUARD'**
  String get guardSectionLabel;

  /// GUARD toggle label in add plan item screen
  ///
  /// In en, this message translates to:
  /// **'Track payment'**
  String get guardTrackPayment;

  /// GUARD due day picker label
  ///
  /// In en, this message translates to:
  /// **'Due day'**
  String get guardDueDayLabel;

  /// GUARD one-time toggle label
  ///
  /// In en, this message translates to:
  /// **'One-time payment'**
  String get guardOneTimeLabel;

  /// Snackbar confirmation after saving a plan item
  ///
  /// In en, this message translates to:
  /// **'Plan item saved.'**
  String get planItemSaved;

  /// Title of the type-selector bottom sheet before adding a plan item
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNewItemSheetTitle;

  /// Plan item type label
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get typeIncome;

  /// Plan item type label
  ///
  /// In en, this message translates to:
  /// **'Fixed Cost'**
  String get typeFixedCost;

  /// Shown when a plan item has no end date
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// AppBar title for the manage budgets screen
  ///
  /// In en, this message translates to:
  /// **'Manage Budgets'**
  String get manageBudgetsTitle;

  /// Empty state message on the manage budgets screen
  ///
  /// In en, this message translates to:
  /// **'No budgets set for this period.'**
  String get noBudgetsSet;

  /// Empty state call-to-action on the manage budgets screen
  ///
  /// In en, this message translates to:
  /// **'Add your first budget.'**
  String get addFirstBudget;

  /// AppBar title when adding a new category budget
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get addBudgetTitle;

  /// AppBar title when editing an existing category budget
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudgetTitle;

  /// Form field label for the budget amount
  ///
  /// In en, this message translates to:
  /// **'Budget amount'**
  String get budgetAmount;

  /// Form field label for the budget start month
  ///
  /// In en, this message translates to:
  /// **'Effective from'**
  String get effectiveFrom;

  /// Inline warning when user picks a past month for a budget
  ///
  /// In en, this message translates to:
  /// **'Setting a budget in the past will not affect past spending.'**
  String get pastMonthBudgetWarning;

  /// Snackbar confirmation after saving a category budget
  ///
  /// In en, this message translates to:
  /// **'Budget saved.'**
  String get budgetSaved;

  /// Snackbar confirmation after deleting a category budget
  ///
  /// In en, this message translates to:
  /// **'Budget deleted.'**
  String get budgetDeleted;

  /// AppBar title for the GUARD screen
  ///
  /// In en, this message translates to:
  /// **'GUARD'**
  String get guardScreenTitle;

  /// Label for the daily GUARD reminder time setting
  ///
  /// In en, this message translates to:
  /// **'Daily reminder time'**
  String get guardDailyReminderTime;

  /// Help text in the time picker dialog for GUARD reminders
  ///
  /// In en, this message translates to:
  /// **'Daily GUARD reminder time'**
  String get guardTimePicker;

  /// Action to mark a GUARD item as paid
  ///
  /// In en, this message translates to:
  /// **'Mark paid'**
  String get guardMarkPaid;

  /// Action to silence a GUARD reminder
  ///
  /// In en, this message translates to:
  /// **'Silence'**
  String get guardSilence;

  /// GUARD payment status label
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get guardStatusPaid;

  /// GUARD payment status label
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get guardStatusScheduled;

  /// GUARD payment status label
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get guardStatusUnpaid;

  /// GUARD payment status label
  ///
  /// In en, this message translates to:
  /// **'Silenced'**
  String get guardStatusSilenced;

  /// Empty state message on the GUARD screen
  ///
  /// In en, this message translates to:
  /// **'No guarded items.'**
  String get noGuardedItems;

  /// AppBar title for the reports screen
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// Report mode tab label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get reportModeMonthly;

  /// Report mode tab label
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get reportModeYearly;

  /// Report mode tab label
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get reportModeOverview;

  /// Button to export the current report as a PDF
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// Empty state on the report screen (monthly/yearly modes)
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded for this period.'**
  String get noExpensesForPeriod;

  /// Overview mode empty state on the report screen
  ///
  /// In en, this message translates to:
  /// **'No income or spending data for this year.'**
  String get noIncomeOrSpendingDataForYear;

  /// Label for the collapsed small-category slice in pie charts
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pieChartOther;

  /// Section header in the category report detail screen
  ///
  /// In en, this message translates to:
  /// **'FIXED COSTS'**
  String get reportSectionFixedCosts;

  /// Section header in the category report detail screen
  ///
  /// In en, this message translates to:
  /// **'EXPENSES'**
  String get reportSectionExpenses;

  /// Empty state within a section of the category report detail screen
  ///
  /// In en, this message translates to:
  /// **'None in this period.'**
  String get noneInPeriod;

  /// Count of fixed costs in category report header
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 fixed cost} other{{count} fixed costs}}'**
  String fixedCostCount(int count);

  /// Count of expenses in category report header
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense} other{{count} expenses}}'**
  String expenseCount(int count);

  /// Subtitle in category report header when there are no items
  ///
  /// In en, this message translates to:
  /// **'No items in this period'**
  String get noItemsInPeriod;

  /// AppBar title for the import screen
  ///
  /// In en, this message translates to:
  /// **'Import Expenses'**
  String get importTitle;

  /// Step card title on the import idle screen
  ///
  /// In en, this message translates to:
  /// **'Download Template'**
  String get importStep1Title;

  /// Step card description on the import idle screen
  ///
  /// In en, this message translates to:
  /// **'Get the official Excel template with all required columns and a guide to valid values.'**
  String get importStep1Description;

  /// Step card button label on the import idle screen
  ///
  /// In en, this message translates to:
  /// **'Download Template'**
  String get importStep1Button;

  /// Step card title on the import idle screen
  ///
  /// In en, this message translates to:
  /// **'Fill & Import'**
  String get importStep2Title;

  /// Step card description on the import idle screen
  ///
  /// In en, this message translates to:
  /// **'Fill the template in Excel or Google Sheets, then select the file here to import your expenses.'**
  String get importStep2Description;

  /// Step card button label on the import idle screen
  ///
  /// In en, this message translates to:
  /// **'Select File (.xlsx or .csv)'**
  String get importStep2Button;

  /// Informational text on the import idle screen
  ///
  /// In en, this message translates to:
  /// **'Only expenses can be imported. Income and plan items are not supported.\n\nAccepted formats: .xlsx (Excel) and .csv.\nCSV files must have the same column order as the template: Date, Amount, Category, Financial Type, Note, Group.\n\nFiles exported from this app can also be imported directly.'**
  String get importInfoText;

  /// Summary line showing how many valid rows were parsed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense ready to import} other{{count} expenses ready to import}}'**
  String importReadyCount(int count);

  /// Error count line when no valid rows are present
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 row could not be read} other{{count} rows could not be read}}'**
  String importErrorCount(int count);

  /// Error count line when valid rows are also present
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 row could not be read — will be skipped} other{{count} rows could not be read — will be skipped}}'**
  String importErrorCountSkipped(int count);

  /// Shown when file parses successfully but contains no rows
  ///
  /// In en, this message translates to:
  /// **'No data found in the file.'**
  String get importNoDataFound;

  /// Hint text on the import preview screen
  ///
  /// In en, this message translates to:
  /// **'Tap any row to edit or remove it before importing.'**
  String get importTapToEdit;

  /// Section header above error rows in the import preview
  ///
  /// In en, this message translates to:
  /// **'Rows with errors'**
  String get importRowsWithErrors;

  /// Empty state when both valid and invalid row lists are empty
  ///
  /// In en, this message translates to:
  /// **'No data rows found.'**
  String get importNoDataRows;

  /// Confirm button label on the import preview screen
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 expense} other{Import {count} expenses}}'**
  String importConfirmButton(int count);

  /// Snackbar shown after a successful import
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense imported · {range}} other{{count} expenses imported · {range}}}'**
  String importSuccessMessage(int count, String range);

  /// Snackbar when the selected file has an unsupported extension
  ///
  /// In en, this message translates to:
  /// **'Unsupported file type. Please select an .xlsx or .csv file.'**
  String get importUnsupportedFile;

  /// Snackbar when file bytes could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Could not read the file. Please try again.'**
  String get importCouldNotReadFile;

  /// Snackbar when the file picker throws an exception
  ///
  /// In en, this message translates to:
  /// **'Could not open file picker: {error}'**
  String importPickerError(Object error);

  /// Snackbar when the template download fails
  ///
  /// In en, this message translates to:
  /// **'Could not generate template: {error}'**
  String importTemplateError(Object error);

  /// Button to reset to the idle phase after a hard parse error
  ///
  /// In en, this message translates to:
  /// **'Try Another File'**
  String get tryAnotherFile;

  /// AppBar title for the saves screen
  ///
  /// In en, this message translates to:
  /// **'Saves'**
  String get savesTitle;

  /// Section header on the saves screen
  ///
  /// In en, this message translates to:
  /// **'AUTO BACKUP'**
  String get sectionAutoBackup;

  /// Section header on the saves screen
  ///
  /// In en, this message translates to:
  /// **'SAVES'**
  String get sectionSaves;

  /// Section header on the saves screen
  ///
  /// In en, this message translates to:
  /// **'DATA TRANSFER'**
  String get sectionDataTransfer;

  /// Section header on the saves screen
  ///
  /// In en, this message translates to:
  /// **'DATA DELETION'**
  String get sectionDataDeletion;

  /// Action button to export all data as JSON
  ///
  /// In en, this message translates to:
  /// **'Export all data'**
  String get exportAllData;

  /// Action button to import all data from JSON
  ///
  /// In en, this message translates to:
  /// **'Import all data'**
  String get importAllData;

  /// Destructive action button to wipe all data
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// Placeholder for an unused save slot
  ///
  /// In en, this message translates to:
  /// **'Empty slot'**
  String get emptySlot;

  /// Snackbar after creating or overwriting a save slot
  ///
  /// In en, this message translates to:
  /// **'\'{name}\' saved.'**
  String savedConfirmation(String name);

  /// Snackbar after loading a save slot
  ///
  /// In en, this message translates to:
  /// **'\'{name}\' loaded.'**
  String loadedConfirmation(String name);

  /// Snackbar when any export fails
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(Object error);

  /// Snackbar when JSON import fails due to invalid content
  ///
  /// In en, this message translates to:
  /// **'Invalid file: {error}'**
  String importFailedInvalid(Object error);

  /// Snackbar after a successful full-data JSON import
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully.'**
  String get importDataSuccess;

  /// Snackbar when the selected file bytes are unavailable
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file.'**
  String get couldNotReadSelectedFile;

  /// Title of the confirmation dialog before importing full data
  ///
  /// In en, this message translates to:
  /// **'Import data?'**
  String get importDataDialogTitle;

  /// Body text of the confirmation dialog before importing full data
  ///
  /// In en, this message translates to:
  /// **'This will replace ALL current expenses and plan items with the contents of the file. This cannot be undone.'**
  String get importDataDialogContent;

  /// Text field label in the save name dialog
  ///
  /// In en, this message translates to:
  /// **'Save name'**
  String get saveName;

  /// Validation error in the save name dialog
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get saveNameCannotBeEmpty;

  /// Subtitle in the overwrite save dialog showing which slot will be replaced
  ///
  /// In en, this message translates to:
  /// **'Replacing: {name}'**
  String replacingLabel(String name);

  /// Description text in the load confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'All current data will be replaced with this saved snapshot.'**
  String get loadDialogDescription;

  /// Description text in the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This saved snapshot will be permanently deleted.'**
  String get deleteDialogDescription;

  /// Label shown when a save file is corrupted
  ///
  /// In en, this message translates to:
  /// **'Damaged save file'**
  String get damagedSaveFile;

  /// Budget progress bar label when spending exceeds budget
  ///
  /// In en, this message translates to:
  /// **'{amount} over'**
  String overBudgetAmount(String amount);

  /// Budget progress bar label when spending is under budget
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String underBudgetAmount(String amount);

  /// Budget progress bar detail line
  ///
  /// In en, this message translates to:
  /// **'Spent: {amount}'**
  String spentLabel(String amount);

  /// Budget progress bar detail line
  ///
  /// In en, this message translates to:
  /// **'Budget: {amount}'**
  String budgetLabel(String amount);

  /// Single-line label on the category budget progress bar
  ///
  /// In en, this message translates to:
  /// **'{spent} spent  /  {budget} budget'**
  String progressBarLabel(String spent, String budget);

  /// Warning card entry showing how much a category is over budget
  ///
  /// In en, this message translates to:
  /// **'{category} budget: over by {amount}'**
  String categoryBudgetOverBy(String category, String amount);

  /// Title of the confirmation dialog before wiping all data
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteAllDataDialogTitle;

  /// Body text of the confirmation dialog before wiping all data
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all expenses, income, and plan items. This cannot be undone.'**
  String get deleteAllDataDialogContent;

  /// Confirm button label in the delete-all dialog
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAllDataConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
