import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_sk.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('hu'),
    Locale('pl'),
    Locale('sk'),
  ];

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
  /// **'GUARD settings'**
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

  /// Link text to open the how-guard-works sheet from the GUARD empty state
  ///
  /// In en, this message translates to:
  /// **'How GUARD works?'**
  String get howGuardWorkQuestion;

  /// Link text to open the how-category-budgets-work sheet from the empty state
  ///
  /// In en, this message translates to:
  /// **'How category budgets work?'**
  String get howCategoryBudgetsWorkQuestion;

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
  /// **'Income'**
  String get sectionIncome;

  /// Section header in the Plan screen
  ///
  /// In en, this message translates to:
  /// **'Fixed Costs'**
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

  /// Full month name
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// Full month name
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// Full month name
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// Full month name
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// Full month name
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// Full month name
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// Full month name
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// Full month name
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// Full month name
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// Full month name
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// Full month name
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// Full month name
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// Abbreviated month name
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthAbbrJan;

  /// Abbreviated month name
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthAbbrFeb;

  /// Abbreviated month name
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthAbbrMar;

  /// Abbreviated month name
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthAbbrApr;

  /// Abbreviated month name
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthAbbrMay;

  /// Abbreviated month name
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthAbbrJun;

  /// Abbreviated month name
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthAbbrJul;

  /// Abbreviated month name
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAbbrAug;

  /// Abbreviated month name
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthAbbrSep;

  /// Abbreviated month name
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthAbbrOct;

  /// Abbreviated month name
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthAbbrNov;

  /// Abbreviated month name
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthAbbrDec;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get categoryHousing;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get categoryGroceries;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Vacation'**
  String get categoryVacation;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get categoryInsurance;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get categorySubscriptions;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get categoryCommunication;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get categoryRestaurants;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get categoryClothing;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get categoryInvestment;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get categoryGifts;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get categoryTaxes;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get categoryMedications;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get categoryUtilities;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Household Supplies'**
  String get categoryHousehold;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Personal Care'**
  String get categoryPersonalCare;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get categorySavings;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get categoryDebt;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get categoryKids;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get categoryPets;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get categoryFees;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get categoryFuel;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get categoryMaintenance;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Donations'**
  String get categoryDonations;

  /// Expense category display name
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// Financial type display name
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get financialTypeAsset;

  /// Financial type display name
  ///
  /// In en, this message translates to:
  /// **'Consumption'**
  String get financialTypeConsumption;

  /// Financial type display name
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get financialTypeInsurance;

  /// AppBar title for the add plan item screen when no type is pre-selected
  ///
  /// In en, this message translates to:
  /// **'Add Plan Item'**
  String get addPlanItemTitle;

  /// AppBar title for adding a monthly income item
  ///
  /// In en, this message translates to:
  /// **'Add Monthly Income'**
  String get addMonthlyIncomeTitle;

  /// AppBar title for adding a yearly income item
  ///
  /// In en, this message translates to:
  /// **'Add Yearly Income'**
  String get addYearlyIncomeTitle;

  /// AppBar title for adding a one-time income item
  ///
  /// In en, this message translates to:
  /// **'Add One-time Income'**
  String get addOneTimeIncomeTitle;

  /// AppBar title for adding a monthly fixed cost item
  ///
  /// In en, this message translates to:
  /// **'Add Monthly Fixed Cost'**
  String get addMonthlyFixedCostTitle;

  /// AppBar title for adding a yearly fixed cost item
  ///
  /// In en, this message translates to:
  /// **'Add Yearly Fixed Cost'**
  String get addYearlyFixedCostTitle;

  /// AppBar title for editing a monthly income item
  ///
  /// In en, this message translates to:
  /// **'Edit Monthly Income'**
  String get editMonthlyIncomeTitle;

  /// AppBar title for editing a yearly income item
  ///
  /// In en, this message translates to:
  /// **'Edit Yearly Income'**
  String get editYearlyIncomeTitle;

  /// AppBar title for editing a one-time income item
  ///
  /// In en, this message translates to:
  /// **'Edit One-time Income'**
  String get editOneTimeIncomeTitle;

  /// AppBar title for editing a monthly fixed cost item
  ///
  /// In en, this message translates to:
  /// **'Edit Monthly Fixed Cost'**
  String get editMonthlyFixedCostTitle;

  /// AppBar title for editing a yearly fixed cost item
  ///
  /// In en, this message translates to:
  /// **'Edit Yearly Fixed Cost'**
  String get editYearlyFixedCostTitle;

  /// Form section label for plan item type (Income / Fixed Cost)
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get labelType;

  /// Dropdown label in the month/year picker dialog
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get labelMonth;

  /// Dropdown label in the month/year picker dialog
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get labelYear;

  /// Dropdown label in the GUARD due-day picker dialog
  ///
  /// In en, this message translates to:
  /// **'Day of month'**
  String get labelDayOfMonth;

  /// Hint text inside the name text field on the add plan item screen
  ///
  /// In en, this message translates to:
  /// **'e.g. Salary, Rent, Insurance'**
  String get nameHintText;

  /// Validation error when the name field is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get validationEnterName;

  /// Dialog title for the month/year picker
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get selectMonthTitle;

  /// Dialog title for the yearly end-year picker
  ///
  /// In en, this message translates to:
  /// **'Last renewal year'**
  String get lastRenewalYearTitle;

  /// Dropdown label in the yearly end-year picker showing the anchor month
  ///
  /// In en, this message translates to:
  /// **'Last {monthName} renewal'**
  String lastMonthRenewal(String monthName);

  /// Informational text in the yearly end-year picker dialog
  ///
  /// In en, this message translates to:
  /// **'Last active month: {label}'**
  String lastActiveMonthInfo(String label);

  /// Switch label for enabling an optional end date on a plan item
  ///
  /// In en, this message translates to:
  /// **'Set end date'**
  String get setEndDate;

  /// Button label showing the current end date
  ///
  /// In en, this message translates to:
  /// **'Until: {validToLabel}'**
  String untilLabel(String validToLabel);

  /// Hint text below the Until button for yearly items
  ///
  /// In en, this message translates to:
  /// **'{label} is the last active month.'**
  String lastActiveMonthNote(String label);

  /// Inline error when the end month is not after the start month
  ///
  /// In en, this message translates to:
  /// **'End month must be after start month.'**
  String get endMonthAfterStart;

  /// Label for the locked From field when editing a yearly fixed cost
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromFieldLabel;

  /// Hint text below the locked From field for yearly fixed costs
  ///
  /// In en, this message translates to:
  /// **'Renewed each {monthName}. Dates are fixed.'**
  String renewedEachMonth(String monthName);

  /// Label for the locked Until field when editing a yearly fixed cost
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get untilFieldLabel;

  /// Value shown in the locked Until field for yearly items
  ///
  /// In en, this message translates to:
  /// **'{label} (last active month)'**
  String lastActiveMonthParens(String label);

  /// Value shown in the locked Until field when no end date is set
  ///
  /// In en, this message translates to:
  /// **'Open-ended'**
  String get openEnded;

  /// Button label showing the current start date
  ///
  /// In en, this message translates to:
  /// **'From: {validFromLabel}'**
  String fromDateLabel(String validFromLabel);

  /// Hint shown when the new start month matches the existing item's start month
  ///
  /// In en, this message translates to:
  /// **'Same month as original — will update in place.'**
  String get samePeriodInPlace;

  /// Hint shown when the new start month differs from the existing item's start month
  ///
  /// In en, this message translates to:
  /// **'Different month — will create a new version.'**
  String get differentPeriodNewVersion;

  /// Dialog title for the yearly fixed cost save-choice dialog
  ///
  /// In en, this message translates to:
  /// **'Apply changes to...'**
  String get applyChangesToTitle;

  /// Option title in the yearly save dialog — apply changes to all periods
  ///
  /// In en, this message translates to:
  /// **'Whole series'**
  String get applyToWholeSeries;

  /// Subtitle for the whole-series option in the yearly save dialog
  ///
  /// In en, this message translates to:
  /// **'All periods from {seriesStartLabel} onwards'**
  String applyToWholeSeriesSubtitle(String seriesStartLabel);

  /// Option title in the yearly save dialog — split from a future period
  ///
  /// In en, this message translates to:
  /// **'From {nextLabel} onwards'**
  String applyFromOnwards(String nextLabel);

  /// Subtitle for the split option in the yearly save dialog
  ///
  /// In en, this message translates to:
  /// **'Original series ends {capLabel}.\nNew series starts {nextLabel}.'**
  String applyFromSubtitle(String capLabel, String nextLabel);

  /// Subtitle for the split option when no future period exists
  ///
  /// In en, this message translates to:
  /// **'No future period available in this series.'**
  String get applyFromUnavailable;

  /// Snackbar shown when a yearly item edit is rejected due to invalid boundary
  ///
  /// In en, this message translates to:
  /// **'Yearly items can only be changed at their renewal month.'**
  String get yearlyItemsOnlyAtRenewal;

  /// Subtitle under the GUARD toggle on the add plan item screen
  ///
  /// In en, this message translates to:
  /// **'Remind me to confirm this payment'**
  String get guardRemindMe;

  /// Hint shown when the GUARD due day is > 28
  ///
  /// In en, this message translates to:
  /// **'Shorter months will use their last day.'**
  String get guardShorterMonths;

  /// Dialog title for the GUARD due-day picker for monthly items
  ///
  /// In en, this message translates to:
  /// **'Due day (repeats monthly)'**
  String get dueDayMonthly;

  /// Dialog title for the GUARD due-day picker for yearly items
  ///
  /// In en, this message translates to:
  /// **'Due day (repeats every {monthName})'**
  String dueDayYearly(String monthName);

  /// Button label showing the selected due day for a monthly item
  ///
  /// In en, this message translates to:
  /// **'Day {day} of each month'**
  String dueDayMonthlyLabel(int day);

  /// Button label showing the selected due day for a yearly item
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {monthName} each year'**
  String dueDayYearlyLabel(int day, String monthName);

  /// Tile title for the notification time setting on the GUARD screen
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get guardDailyReminder;

  /// Tile subtitle for the notification time setting on the GUARD screen
  ///
  /// In en, this message translates to:
  /// **'Tap to change the notification time'**
  String get guardChangeNotifTime;

  /// Secondary empty-state text on the GUARD screen
  ///
  /// In en, this message translates to:
  /// **'Enable GUARD on a fixed cost to track payments.'**
  String get guardNoGuardedItemsHint;

  /// Section header showing the number of guarded items on the GUARD screen
  ///
  /// In en, this message translates to:
  /// **'Guarded items · {count}'**
  String guardedItemsCount(int count);

  /// AppBar title for the plan item detail screen
  ///
  /// In en, this message translates to:
  /// **'Plan Item'**
  String get planItemTitle;

  /// Detail row label for the plan item start period
  ///
  /// In en, this message translates to:
  /// **'Active from'**
  String get activeFrom;

  /// Detail row label for the plan item end period
  ///
  /// In en, this message translates to:
  /// **'Active until'**
  String get activeUntil;

  /// Amount suffix for monthly plan items
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get perMonth;

  /// Amount suffix for yearly plan items
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get perYear;

  /// Amount suffix for one-time plan items
  ///
  /// In en, this message translates to:
  /// **'(one-time)'**
  String get oneTimeSuffix;

  /// Value shown for the active-until field when a fixed cost has no end date
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get noEndDate;

  /// GUARD section subtitle when GUARD is not yet set up for an item
  ///
  /// In en, this message translates to:
  /// **'Not enabled'**
  String get guardNotEnabled;

  /// Confirmation dialog description when removing an income item that starts at the selected period
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be removed entirely.'**
  String removeIncomeEntirely(String name);

  /// Confirmation dialog description when removing an income item from a mid-series period
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will stop from {from} onwards. {prev} and earlier will remain planned.'**
  String removeIncomeFromOnwards(String name, String from, String prev);

  /// All-caps action label shown prominently in the fixed cost delete dialog
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get actionRemoveAllCaps;

  /// All-caps action label shown prominently in the budget delete dialog
  ///
  /// In en, this message translates to:
  /// **'REMOVE BUDGET'**
  String get removeBudgetAllCaps;

  /// Option title in the fixed cost delete dialog — remove from the selected period
  ///
  /// In en, this message translates to:
  /// **'From {label} onwards'**
  String removeFromOnwardsTitle(String label);

  /// Subtitle for the from-period option when deleting a yearly fixed cost
  ///
  /// In en, this message translates to:
  /// **'This cycle ({start} – {end}) and all future cycles are removed.'**
  String removeCycleSubtitle(String start, String end);

  /// Subtitle for the from-period option when deleting a monthly fixed cost
  ///
  /// In en, this message translates to:
  /// **'History up to {prev} is kept.'**
  String removeHistoryKept(String prev);

  /// Dialog title when the user silences a GUARD reminder from the Plan screen
  ///
  /// In en, this message translates to:
  /// **'Silence this reminder?'**
  String get silenceReminderTitle;

  /// Dialog body when the user silences a GUARD reminder
  ///
  /// In en, this message translates to:
  /// **'The {periodLabel} payment will still be shown as unconfirmed. You can mark it as paid at any time.'**
  String silenceReminderBody(String periodLabel);

  /// Confirm button label in the silence-reminder dialog
  ///
  /// In en, this message translates to:
  /// **'Yes, Silence'**
  String get yesSilence;

  /// FAB tooltip on the Plan screen
  ///
  /// In en, this message translates to:
  /// **'Add Plan Item'**
  String get addPlanItemTooltip;

  /// Label for the spendable amount card in monthly plan view
  ///
  /// In en, this message translates to:
  /// **'Spendable this month'**
  String get spendableThisMonth;

  /// Label for the spendable amount card in yearly plan view
  ///
  /// In en, this message translates to:
  /// **'Spendable this year'**
  String get spendableThisYear;

  /// Empty-state primary text on the Plan screen
  ///
  /// In en, this message translates to:
  /// **'No plan items yet.'**
  String get noPlanItemsYet;

  /// Empty-state secondary text on the Plan screen
  ///
  /// In en, this message translates to:
  /// **'Tap + to add income or fixed costs.'**
  String get tapPlusToAddPlanItems;

  /// Option title in the fixed cost delete dialog — remove the entire series
  ///
  /// In en, this message translates to:
  /// **'Whole series'**
  String get removeWholeSeries;

  /// Subtitle for the whole-series option in the fixed cost delete dialog
  ///
  /// In en, this message translates to:
  /// **'All periods from {seriesStartLabel} are removed.'**
  String removeWholeSeriesSubtitle(String seriesStartLabel);

  /// All-caps action label shown prominently in the delete-all confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get clearAllDataAction;

  /// Body text in the delete-all confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Expenses, plan items, budgets and guard payments will be permanently deleted. This cannot be undone.'**
  String get clearAllDataDescription;

  /// Note in the delete-all confirmation dialog clarifying what is preserved
  ///
  /// In en, this message translates to:
  /// **'Saved snapshots and auto-backups are not affected.'**
  String get clearAllDataPreservedNote;

  /// Shown instead of the category dropdown when all categories are already budgeted
  ///
  /// In en, this message translates to:
  /// **'All categories already have a budget for this month. Select a different month to add another.'**
  String get allCategoriesBudgeted;

  /// Dropdown hint text when no category is selected
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategoryHint;

  /// Validation error when no category is selected in the budget form
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get validationSelectCategory;

  /// Text field label for the monthly budget amount
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudgetLabel;

  /// Button label showing the current effective-from month
  ///
  /// In en, this message translates to:
  /// **'Effective from: {validFromLabel}'**
  String effectiveFromLabel(String validFromLabel);

  /// Warning shown when creating a budget for a past month
  ///
  /// In en, this message translates to:
  /// **'You are creating a budget for a past month. It will apply retroactively from {fromLabel}.'**
  String pastMonthBudgetCreateWarning(String fromLabel);

  /// Warning shown when editing a budget starting in a past month
  ///
  /// In en, this message translates to:
  /// **'This will change the {catName} budget back to {fromLabel}. Months {fromLabel}–{prevLabel} will use the new amount.'**
  String pastMonthBudgetEditWarning(
    String catName,
    String fromLabel,
    String prevLabel,
  );

  /// Subtitle on the fixed costs summary tile when no items exist
  ///
  /// In en, this message translates to:
  /// **'No fixed costs planned'**
  String get noFixedCostsPlanned;

  /// Subtitle on the income summary tile when no items exist
  ///
  /// In en, this message translates to:
  /// **'No income planned'**
  String get noIncomePlanned;

  /// Subtitle text on a save slot tile showing the date and counts
  ///
  /// In en, this message translates to:
  /// **'{date} · {expenseCount} expenses · {planItemCount} plan items'**
  String saveSlotSubtitle(String date, int expenseCount, int planItemCount);

  /// Subtitle on a damaged save slot tile
  ///
  /// In en, this message translates to:
  /// **'File is damaged and cannot be loaded'**
  String get saveSlotDamagedSubtitle;

  /// Step header title of the How Groups Work bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get howGroupsTitle;

  /// Per-page subtitle for the first page of the How Groups Work sheet
  ///
  /// In en, this message translates to:
  /// **'What a group is and how it works'**
  String get howGroupsSubtitle0;

  /// Per-page subtitle for the second page of the How Groups Work sheet
  ///
  /// In en, this message translates to:
  /// **'How to take advantage of it'**
  String get howGroupsSubtitle1;

  /// Per-page subtitle for the third page of the How Groups Work sheet
  ///
  /// In en, this message translates to:
  /// **'Where groups surface in the app'**
  String get howGroupsSubtitle2;

  /// Sub-step indicator label for page 1 of the How Groups Work sheet
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get howGroupsLabel0;

  /// Sub-step indicator label for page 2 of the How Groups Work sheet
  ///
  /// In en, this message translates to:
  /// **'Be creative'**
  String get howGroupsLabel1;

  /// Sub-step indicator label for page 3 of the How Groups Work sheet
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get howGroupsLabel2;

  /// Bullet rule on the Tag page of the How Groups Work sheet
  ///
  /// In en, this message translates to:
  /// **'A group is an optional free-text label you attach to any expense.'**
  String get howGroupsRule1;

  /// Bullet rule on the Tag page
  ///
  /// In en, this message translates to:
  /// **'You type any string — there is no fixed list and no validation.'**
  String get howGroupsRule2;

  /// Bullet rule on the Tag page
  ///
  /// In en, this message translates to:
  /// **'Two expenses belong to the same group only when their labels match exactly, character for character.'**
  String get howGroupsRule3;

  /// Bullet rule on the Tag page
  ///
  /// In en, this message translates to:
  /// **'Case is preserved — \"Trip\" and \"trip\" are treated as two different groups.'**
  String get howGroupsRule4;

  /// Bullet rule on the Tag page
  ///
  /// In en, this message translates to:
  /// **'The field is optional. Leave it blank and the expense simply has no group.'**
  String get howGroupsRule5;

  /// Hint box at the bottom of the Tag page
  ///
  /// In en, this message translates to:
  /// **'Set the group when creating or editing any expense.'**
  String get howGroupsHint;

  /// Intro text on the Be Creative page
  ///
  /// In en, this message translates to:
  /// **'Use it whenever you want to track a slice of spending that cuts across categories.'**
  String get howGroupsUseIntro;

  /// Example group label on the Be Creative page (trip example)
  ///
  /// In en, this message translates to:
  /// **'Barcelona {year}'**
  String howGroupsExample1Label(int year);

  /// Description for example 1 on the Be Creative page
  ///
  /// In en, this message translates to:
  /// **'Attach to every expense on a trip — flights, hotels, meals, tickets. See the total cost of the whole trip in one tap.'**
  String get howGroupsExample1Desc;

  /// Example group label on the Be Creative page (restaurant example)
  ///
  /// In en, this message translates to:
  /// **'McDonald\'\'s {year}'**
  String howGroupsExample2Label(int year);

  /// Description for example 2 on the Be Creative page
  ///
  /// In en, this message translates to:
  /// **'Use a consistent name all year. At year-end you know exactly what you spent at that one place.'**
  String get howGroupsExample2Desc;

  /// Example group label on the Be Creative page (renovation example)
  ///
  /// In en, this message translates to:
  /// **'Home renovation Q1'**
  String get howGroupsExample3Label;

  /// Description for example 3 on the Be Creative page
  ///
  /// In en, this message translates to:
  /// **'Span multiple months with the same label. The Groups tab collects everything under that name.'**
  String get howGroupsExample3Desc;

  /// Italic note at the bottom of the Be Creative page
  ///
  /// In en, this message translates to:
  /// **'The more precise your label, the more useful the summary.'**
  String get howGroupsPrecision;

  /// Title of the first record row on the Record page
  ///
  /// In en, this message translates to:
  /// **'Groups tab in Expenses'**
  String get howGroupsRecord0Title;

  /// Body of the first record row on the Record page
  ///
  /// In en, this message translates to:
  /// **'Every group that has at least one expense in the current month appears here as a single row showing the item count and total. Tap a group to drill down and see each individual expense behind it.'**
  String get howGroupsRecord0Body;

  /// Title of the second record row on the Record page
  ///
  /// In en, this message translates to:
  /// **'Monthly Report in Reports'**
  String get howGroupsRecord1Title;

  /// Body of the second record row on the Record page
  ///
  /// In en, this message translates to:
  /// **'When you export a monthly PDF from the Reports screen, groups with expenses in that month get a dedicated \"Expense Groups\" page — each group listed with its expenses, amounts, and a group total.'**
  String get howGroupsRecord1Body;

  /// Note at the bottom of the Record page
  ///
  /// In en, this message translates to:
  /// **'Groups are not included in the yearly report — they are a monthly lens.'**
  String get howGroupsMonthlyNote;

  /// Example group name in the demo card on the Tag page of the How Groups Work sheet
  ///
  /// In en, this message translates to:
  /// **'My group'**
  String get howGroupsExampleGroupName;

  /// Label for the collapsed 'other' segment in pie charts and breakdown lists
  ///
  /// In en, this message translates to:
  /// **'Other categories'**
  String get otherCategories;

  /// Empty state in CategoryExpenseListScreen
  ///
  /// In en, this message translates to:
  /// **'No {category} expenses\nin {period}.'**
  String noCategoryExpenses(String category, String period);

  /// Due date label on the GUARD status card
  ///
  /// In en, this message translates to:
  /// **'Due {monthName} {day}, {year}'**
  String guardDueDate(String monthName, int day, int year);

  /// Label on GUARD card when payment is not yet due
  ///
  /// In en, this message translates to:
  /// **'Not yet due'**
  String get guardNotYetDue;

  /// Next reminder label on GUARD card
  ///
  /// In en, this message translates to:
  /// **'Next: {label}'**
  String guardNextReminder(String label);

  /// Last reminder label on GUARD card
  ///
  /// In en, this message translates to:
  /// **'Last: {label}'**
  String guardLastReminder(String label);

  /// Action button on GUARD card to change the due day
  ///
  /// In en, this message translates to:
  /// **'Change day'**
  String get guardChangeDay;

  /// Action button on GUARD card to remove guard tracking
  ///
  /// In en, this message translates to:
  /// **'Remove GUARD'**
  String get guardRemoveAction;

  /// Dialog title when revoking a payment confirmation
  ///
  /// In en, this message translates to:
  /// **'Mark as unpaid?'**
  String get guardMarkUnpaidTitle;

  /// Dialog body when revoking a payment confirmation
  ///
  /// In en, this message translates to:
  /// **'This will remove the payment confirmation for {monthName} {year}.'**
  String guardMarkUnpaidBody(String monthName, int year);

  /// Confirm button in the mark-as-unpaid dialog
  ///
  /// In en, this message translates to:
  /// **'Mark as Unpaid'**
  String get guardMarkUnpaidAction;

  /// Primary action button on GUARD card
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get guardMarkAsPaid;

  /// Dialog title when removing GUARD from a plan item
  ///
  /// In en, this message translates to:
  /// **'Remove GUARD?'**
  String get guardRemoveTitle;

  /// Dialog body when removing GUARD
  ///
  /// In en, this message translates to:
  /// **'GUARD will be disabled for \"{name}\". Existing payment records are kept but no new reminders will fire.'**
  String guardRemoveBody(String name);

  /// Confirm button in the remove-GUARD dialog
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get guardRemoveConfirm;

  /// Help text for the date picker when editing a paid date
  ///
  /// In en, this message translates to:
  /// **'Select paid date'**
  String get guardSelectPaidDate;

  /// Label on GUARD card showing the confirmed paid date
  ///
  /// In en, this message translates to:
  /// **'Paid {date}'**
  String guardPaidOn(String date);

  /// Step number label above each tab in the How It Works sheet
  ///
  /// In en, this message translates to:
  /// **'STEP {n}'**
  String howItWorksStep(int n);

  /// Subtitle for Plan sub-page 0 (Cashflow)
  ///
  /// In en, this message translates to:
  /// **'Your salary and committed monthly bills'**
  String get planSubtitle0;

  /// Subtitle for Plan sub-page 1 (Classification)
  ///
  /// In en, this message translates to:
  /// **'How your fixed costs are classified'**
  String get planSubtitle1;

  /// Subtitle for Plan sub-page 2 (Allocation)
  ///
  /// In en, this message translates to:
  /// **'How much of your income each type consumes'**
  String get planSubtitle2;

  /// Sub-step label for Plan page 0
  ///
  /// In en, this message translates to:
  /// **'Cashflow'**
  String get planSubStep0;

  /// Sub-step label for Plan page 1
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get planSubStep1;

  /// Sub-step label for Plan page 2
  ///
  /// In en, this message translates to:
  /// **'Allocation'**
  String get planSubStep2;

  /// Body text on the Plan > Cashflow page
  ///
  /// In en, this message translates to:
  /// **'Enter your salary and committed monthly bills — rent, insurance, subscriptions. These are real, known numbers, not estimates or goals.'**
  String get howItWorksPlanIncomeBody;

  /// Description for the Consumption financial type on the Classification page
  ///
  /// In en, this message translates to:
  /// **'Day-to-day spending — groceries, rent, dining, transport'**
  String get howItWorksTypeConsumptionDesc;

  /// Description for the Asset financial type on the Classification page
  ///
  /// In en, this message translates to:
  /// **'Investments and savings that grow your wealth over time'**
  String get howItWorksTypeAssetDesc;

  /// Description for the Insurance financial type on the Classification page
  ///
  /// In en, this message translates to:
  /// **'Protection costs — car, health, and life insurance'**
  String get howItWorksTypeInsuranceDesc;

  /// Body text on the Plan > Classification page
  ///
  /// In en, this message translates to:
  /// **'Each fixed cost is tagged with a financial type. This lets the app show how your income is distributed across spending, savings, and protection.'**
  String get howItWorksFinancialTypesBody;

  /// Card title on the Plan > Allocation page
  ///
  /// In en, this message translates to:
  /// **'Spending vs Income'**
  String get howItWorksSpendingVsIncomeTitle;

  /// Body text on the Plan > Allocation page
  ///
  /// In en, this message translates to:
  /// **'The Plan tab shows how much of your income goes to each financial type — so you can see at a glance whether you spend, save, or protect the right share of what you earn.'**
  String get howItWorksSpendingVsIncomeBody;

  /// Subtitle for Expenses sub-page 0 (Budget)
  ///
  /// In en, this message translates to:
  /// **'Your available budget, calculated from Plan'**
  String get expSubtitle0;

  /// Subtitle for Expenses sub-page 1 (Spending)
  ///
  /// In en, this message translates to:
  /// **'Day-to-day spending you record'**
  String get expSubtitle1;

  /// Subtitle for Expenses sub-page 2 (Result)
  ///
  /// In en, this message translates to:
  /// **'Did you stay within budget?'**
  String get expSubtitle2;

  /// Sub-step label for the Budget page in Expenses
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get subStepBudget;

  /// Sub-step label for the Spending page in Expenses
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get subStepSpending;

  /// Sub-step label for the Result page in Expenses
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get subStepResult;

  /// Body text on the Expenses > Budget page
  ///
  /// In en, this message translates to:
  /// **'The app subtracts your fixed costs from your income and shows the result here. You don\'t set this number — it comes from your Plan.'**
  String get howItWorksBudgetBody;

  /// Body text on the Expenses > Spending page
  ///
  /// In en, this message translates to:
  /// **'Log groceries, meals, shopping and other variable spending. Fixed monthly bills like rent belong in Plan, not here.'**
  String get howItWorksSpendingBody;

  /// Body text on the Expenses > Result page
  ///
  /// In en, this message translates to:
  /// **'At the end of the month the Expenses tab shows which outcome you had.'**
  String get howItWorksResultBody;

  /// Subtitle for Reports sub-page 0 (Breakdown)
  ///
  /// In en, this message translates to:
  /// **'Where did your money go?'**
  String get repSubtitle0;

  /// Subtitle for Reports sub-page 1 (Export)
  ///
  /// In en, this message translates to:
  /// **'Your finances on paper'**
  String get repSubtitle1;

  /// Subtitle for Reports sub-page 2 (Overview)
  ///
  /// In en, this message translates to:
  /// **'The big picture, month by month'**
  String get repSubtitle2;

  /// Sub-step label for the Breakdown page in Reports
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get repSubStep0;

  /// Sub-step label for the Export page in Reports
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get repSubStep1;

  /// Sub-step label for the Overview page in Reports
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get repSubStep2;

  /// Body text on the Reports > Breakdown page
  ///
  /// In en, this message translates to:
  /// **'Breakdown shows your spending by category for any month or year. Tap a slice or category row to drill into the individual expenses and fixed costs behind it.'**
  String get howItWorksBreakdownBody;

  /// Feature bullet in the Monthly PDF card
  ///
  /// In en, this message translates to:
  /// **'Category totals'**
  String get pdfFeatureCategoryTotals;

  /// Feature bullet in the Monthly PDF card
  ///
  /// In en, this message translates to:
  /// **'Budget vs actual'**
  String get pdfFeatureBudgetVsActual;

  /// Feature bullet in the Monthly PDF card
  ///
  /// In en, this message translates to:
  /// **'Financial type split'**
  String get pdfFeatureTypeSplit;

  /// Feature bullet in the Monthly PDF card
  ///
  /// In en, this message translates to:
  /// **'All expenses listed'**
  String get pdfFeatureAllExpenses;

  /// Feature bullet in the Monthly PDF card
  ///
  /// In en, this message translates to:
  /// **'Category budgets'**
  String get pdfFeatureCategoryBudgets;

  /// Feature bullet in the Monthly PDF card
  ///
  /// In en, this message translates to:
  /// **'Group summaries'**
  String get pdfFeatureGroupSummaries;

  /// Feature bullet in the Yearly PDF card
  ///
  /// In en, this message translates to:
  /// **'12-month overview'**
  String get pdfFeature12MonthOverview;

  /// Feature bullet in the Yearly PDF card
  ///
  /// In en, this message translates to:
  /// **'Annual totals'**
  String get pdfFeatureAnnualTotals;

  /// Feature bullet in the Yearly PDF card
  ///
  /// In en, this message translates to:
  /// **'Monthly breakdown'**
  String get pdfFeatureMonthlyBreakdown;

  /// Feature bullet in the Yearly PDF card
  ///
  /// In en, this message translates to:
  /// **'Plan vs actual'**
  String get pdfFeaturePlanVsActual;

  /// Feature bullet in the Yearly PDF card
  ///
  /// In en, this message translates to:
  /// **'Type ratios'**
  String get pdfFeatureTypeRatios;

  /// Feature bullet in the Yearly PDF card
  ///
  /// In en, this message translates to:
  /// **'Active plan items'**
  String get pdfFeatureActivePlanItems;

  /// Body text on the Reports > Export page
  ///
  /// In en, this message translates to:
  /// **'Use the PDF button in Breakdown to export. Reports are shareable via any app on your device.'**
  String get howItWorksExportBody;

  /// Ellipsis row in the Overview mock card
  ///
  /// In en, this message translates to:
  /// **'· · · 9 more months'**
  String get howItWorksMoreMonths;

  /// Body text on the Reports > Overview page
  ///
  /// In en, this message translates to:
  /// **'Overview shows all 12 months side by side — how much you earned, what went into assets, and what was consumed. Tap any month to jump to that period in the Plan.'**
  String get howItWorksOverviewBody;

  /// Result summary label when spending exceeds budget
  ///
  /// In en, this message translates to:
  /// **'Over budget by {amount}'**
  String overBudgetBy(String amount);

  /// Result summary label when spending is under budget
  ///
  /// In en, this message translates to:
  /// **'Saved {amount}'**
  String savedAmount(String amount);

  /// Generic loading placeholder
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingLabel;

  /// Section header for the auto-backup slots
  ///
  /// In en, this message translates to:
  /// **'Auto Backup'**
  String get autoBackupTitle;

  /// Shown when no auto-backup exists
  ///
  /// In en, this message translates to:
  /// **'No backup yet'**
  String get autoBackupNoBackupYet;

  /// Auto-backup subtitle when the section is collapsed
  ///
  /// In en, this message translates to:
  /// **'Updated daily · tap to expand'**
  String get autoBackupSubtitleExpand;

  /// Auto-backup subtitle when the section is expanded
  ///
  /// In en, this message translates to:
  /// **'Updated daily · tap to collapse'**
  String get autoBackupSubtitleCollapse;

  /// All-caps restore action label
  ///
  /// In en, this message translates to:
  /// **'RESTORE'**
  String get actionRestoreAllCaps;

  /// Restore action label
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get actionRestore;

  /// Body text in the restore confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Restoring will replace all current data with the backup.'**
  String get autoBackupRestoreDescription;

  /// Snackbar shown after a successful auto-backup restore
  ///
  /// In en, this message translates to:
  /// **'Backup from {date} restored.'**
  String autoBackupRestored(String date);

  /// Snackbar shown when an auto-backup restore fails
  ///
  /// In en, this message translates to:
  /// **'Failed to restore backup.'**
  String get autoBackupRestoreFailed;

  /// Name label for the most recent auto-backup slot (slot 0)
  ///
  /// In en, this message translates to:
  /// **'Primary backup'**
  String get autoBackupPrimary;

  /// Name label for the previous-day auto-backup slot (slot 1)
  ///
  /// In en, this message translates to:
  /// **'Secondary backup'**
  String get autoBackupSecondary;

  /// Title for the frequency picker bottom sheet for fixed costs
  ///
  /// In en, this message translates to:
  /// **'How often does it recur?'**
  String get frequencyPickerFixed;

  /// Subtitle for the Monthly option in the fixed-cost frequency picker
  ///
  /// In en, this message translates to:
  /// **'Rent, subscriptions, recurring bills'**
  String get frequencyMonthlyFixedSubtitle;

  /// Subtitle for the Yearly option in the fixed-cost frequency picker
  ///
  /// In en, this message translates to:
  /// **'Annual subscriptions, insurance, memberships'**
  String get frequencyYearlyFixedSubtitle;

  /// Title for the frequency picker bottom sheet for income
  ///
  /// In en, this message translates to:
  /// **'How often do you receive it?'**
  String get frequencyPickerIncome;

  /// Subtitle for the Monthly option in the income frequency picker
  ///
  /// In en, this message translates to:
  /// **'Salary, pension, regular transfers'**
  String get frequencyMonthlyIncomeSubtitle;

  /// Subtitle for the Yearly option in the income frequency picker
  ///
  /// In en, this message translates to:
  /// **'Annual bonus, tax refund, dividends'**
  String get frequencyYearlyIncomeSubtitle;

  /// Subtitle for the One-time option in the income frequency picker
  ///
  /// In en, this message translates to:
  /// **'Gift, windfall, one-off payment'**
  String get frequencyOneTimeIncomeSubtitle;

  /// Title for the plan item type picker bottom sheet
  ///
  /// In en, this message translates to:
  /// **'What are you adding?'**
  String get typePickerTitle;

  /// Subtitle for the Income card in the type picker
  ///
  /// In en, this message translates to:
  /// **'Salary, bonus, pension, gifts'**
  String get typeIncomeSubtitle;

  /// Subtitle for the Fixed Cost card in the type picker
  ///
  /// In en, this message translates to:
  /// **'Rent, insurance, subscriptions'**
  String get typeFixedCostSubtitle;

  /// Title for the language picker dialog
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagePickerTitle;

  /// Title for the currency picker sheet
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyPickerTitle;

  /// Label for the custom currency option
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get currencyCustom;

  /// Subtitle for the custom currency option
  ///
  /// In en, this message translates to:
  /// **'Define your own code and symbol'**
  String get currencyCustomSubtitle;

  /// Title of the custom currency input dialog
  ///
  /// In en, this message translates to:
  /// **'Custom Currency'**
  String get currencyCustomTitle;

  /// Label for the currency code input field
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get currencyCodeLabel;

  /// Hint for the currency code input field
  ///
  /// In en, this message translates to:
  /// **'e.g. USD'**
  String get currencyCodeHint;

  /// Label for the currency symbol input field
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get currencySymbolLabel;

  /// Hint for the currency symbol input field
  ///
  /// In en, this message translates to:
  /// **'e.g. \$'**
  String get currencySymbolHint;

  /// Tooltip/action to remove a row from the import preview
  ///
  /// In en, this message translates to:
  /// **'Remove from import'**
  String get removeFromImport;

  /// Title of the export date-range dialog
  ///
  /// In en, this message translates to:
  /// **'Export Expenses'**
  String get exportExpensesTitle;

  /// Instruction text in the export date-range dialog
  ///
  /// In en, this message translates to:
  /// **'Select the date range to export:'**
  String get selectDateRangeHint;

  /// Label for the start date picker in the export dialog
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDateLabel;

  /// Label for the end date picker in the export dialog
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDateLabel;

  /// Placeholder shown when no date has been selected
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelectDate;

  /// Validation error shown in the export dialog
  ///
  /// In en, this message translates to:
  /// **'End date must be on or after start date.'**
  String get endDateAfterStart;

  /// Export action button label
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get actionExport;

  /// Warning shown in the financial-type distribution card when spending exceeds income
  ///
  /// In en, this message translates to:
  /// **'This {period} you spent {amount} more than you earned!'**
  String overspendWarning(String period, String amount);

  /// Word 'month' used in overspendWarning
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get periodMonth;

  /// Word 'year' used in overspendWarning
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get periodYear;

  /// Banner text showing how many GUARD payments are unconfirmed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{GUARD — 1 payment not confirmed} other{GUARD — {count} payments not confirmed}}'**
  String guardBannerCount(int count);

  /// Badge shown on a silenced GUARD item in the banner
  ///
  /// In en, this message translates to:
  /// **'silenced'**
  String get guardSilencedBadge;

  /// Strip shown on the expense list when there are pending GUARD payments
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 guarded payment pending} other{{count} guarded payments pending}}'**
  String guardExpenseStripPending(int count);

  /// Label for an import error row showing the row number and field name
  ///
  /// In en, this message translates to:
  /// **'Row {row} — {field}'**
  String importErrorRowLabel(int row, String field);

  /// Earned amount label in the overview month row
  ///
  /// In en, this message translates to:
  /// **'Earned: {amount}'**
  String earnedLabel(String amount);

  /// Short 'from date' label used in plan item subtitles
  ///
  /// In en, this message translates to:
  /// **'from {label}'**
  String fromDateShort(String label);

  /// Short 'until date' label used in plan item subtitles
  ///
  /// In en, this message translates to:
  /// **'until {label}'**
  String untilDateShort(String label);

  /// Label for the GUARD enable toggle in the setup sheet
  ///
  /// In en, this message translates to:
  /// **'Enable GUARD'**
  String get guardEnableToggle;

  /// Subtitle for the GUARD enable toggle
  ///
  /// In en, this message translates to:
  /// **'Track payment and receive reminders'**
  String get guardEnableToggleSubtitle;

  /// Generic OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// Total row label in the report screen category list
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get labelTotal;

  /// AppBar title for the manage budgets screen (category-budget specific)
  ///
  /// In en, this message translates to:
  /// **'Category Budgets'**
  String get categoryBudgetsTitle;

  /// Empty state primary text on the manage budgets screen
  ///
  /// In en, this message translates to:
  /// **'No category budgets set.'**
  String get noCategoryBudgetsSet;

  /// Title of the delete-budget confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Remove {category} budget'**
  String removeBudgetDialogTitle(String category);

  /// Option title in the delete-budget dialog — end the budget series from the selected month
  ///
  /// In en, this message translates to:
  /// **'End from {from}'**
  String endBudgetFromTitle(String from);

  /// Subtitle for the end-from option in the delete-budget dialog
  ///
  /// In en, this message translates to:
  /// **'Stops the budget from {from} onwards. Earlier months keep their historical budget.'**
  String endBudgetFromDescription(String from);

  /// Option title in the delete-budget dialog — delete all budget records for this series
  ///
  /// In en, this message translates to:
  /// **'Delete entire series'**
  String get deleteBudgetSeriesTitle;

  /// Confirm button label in the delete-budget dialog
  ///
  /// In en, this message translates to:
  /// **'Delete series'**
  String get deleteBudgetSeriesConfirm;

  /// Subtitle for the delete-all option in the delete-budget dialog
  ///
  /// In en, this message translates to:
  /// **'Permanently removes all records ({range}). No budget will appear for any month in this series. This cannot be undone.'**
  String deleteBudgetSeriesDescription(String range);

  /// Date range label used in the delete-budget dialog when the budget has no end date
  ///
  /// In en, this message translates to:
  /// **'{start} – present'**
  String budgetRangePresent(String start);

  /// PDF recurring header title for monthly reports
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get pdfMonthlyReport;

  /// PDF recurring header title for yearly reports
  ///
  /// In en, this message translates to:
  /// **'Yearly Report'**
  String get pdfYearlyReport;

  /// PDF first-page banner title for monthly reports
  ///
  /// In en, this message translates to:
  /// **'MONTHLY REPORT FOR {month} {year}'**
  String pdfMonthlyReportHeader(String month, int year);

  /// PDF first-page banner title for yearly reports
  ///
  /// In en, this message translates to:
  /// **'YEARLY REPORT FOR {year}'**
  String pdfYearlyReportHeader(int year);

  /// PDF subtitle suffix appended to the year when a yearly report covers only part of the year
  ///
  /// In en, this message translates to:
  /// **'(partial year)'**
  String get pdfPartialYear;

  /// PDF section title for the spending-vs-income widget
  ///
  /// In en, this message translates to:
  /// **'SPENDING VS INCOME'**
  String get pdfSectionSpendingVsIncome;

  /// PDF section title for the category summary table
  ///
  /// In en, this message translates to:
  /// **'CATEGORY SUMMARY'**
  String get pdfSectionCategorySummary;

  /// PDF section title for the cash flow summary
  ///
  /// In en, this message translates to:
  /// **'CASH FLOW SUMMARY'**
  String get pdfSectionCashFlowSummary;

  /// PDF section title for the expense groups page
  ///
  /// In en, this message translates to:
  /// **'EXPENSE GROUPS'**
  String get pdfSectionExpenseGroups;

  /// PDF section title for the expense details table
  ///
  /// In en, this message translates to:
  /// **'EXPENSE DETAILS'**
  String get pdfSectionExpenseDetails;

  /// PDF section title for the yearly overview table
  ///
  /// In en, this message translates to:
  /// **'YEARLY OVERVIEW'**
  String get pdfSectionYearlyOverview;

  /// PDF section title for the landscape category-by-month table
  ///
  /// In en, this message translates to:
  /// **'SPENDING BY CATEGORY AND MONTH'**
  String get pdfSectionSpendingByCategory;

  /// PDF income card header label in the cash flow summary
  ///
  /// In en, this message translates to:
  /// **'INCOME'**
  String get pdfIncomeHeader;

  /// PDF fixed costs card header label in the cash flow summary
  ///
  /// In en, this message translates to:
  /// **'FIXED COSTS'**
  String get pdfFixedCostsHeader;

  /// PDF all-caps TOTAL row label in category and expense tables
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get pdfTotal;

  /// PDF column header 'Total' in the landscape category-by-month table
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get pdfColTotal;

  /// PDF label for the income row in the monthly spending-vs-income widget
  ///
  /// In en, this message translates to:
  /// **'Earned this month'**
  String get pdfEarnedThisMonth;

  /// PDF label for the income row in the yearly spending-vs-income widget
  ///
  /// In en, this message translates to:
  /// **'Earned this year'**
  String get pdfEarnedThisYear;

  /// PDF subtotal row label in the expense groups section
  ///
  /// In en, this message translates to:
  /// **'Group total (this month)'**
  String get pdfGroupTotal;

  /// PDF all-time total row label in the expense groups section
  ///
  /// In en, this message translates to:
  /// **'All periods total'**
  String get pdfAllPeriodsTotal;

  /// PDF group header count label showing how many expenses belong to the group in the current month
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item this month} other{{count} items this month}}'**
  String pdfItemsThisMonth(int count);

  /// PDF suffix appended to yearly plan items shown in a monthly cash flow summary
  ///
  /// In en, this message translates to:
  /// **' (normalized)'**
  String get pdfNormalized;

  /// PDF suffix appended to monthly plan items shown in a yearly cash flow summary
  ///
  /// In en, this message translates to:
  /// **' (annualized)'**
  String get pdfAnnualized;

  /// PDF note shown at the top of a partial-year report
  ///
  /// In en, this message translates to:
  /// **'Partial year - months without data show zeros. Year-to-date totals only.'**
  String get pdfPartialYearNote;

  /// PDF footer page number label
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String pdfPage(int page, int total);

  /// PDF placeholder shown when a table or section has no data to display
  ///
  /// In en, this message translates to:
  /// **'No data.'**
  String get pdfNoData;

  /// Example income item name in the How It Works sheet
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get howItWorksExampleSalary;

  /// Example income item name in the How It Works sheet
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get howItWorksExampleBonus;

  /// Example fixed cost name in the How It Works sheet
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get howItWorksExampleRent;

  /// Example fixed cost name in the How It Works sheet
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get howItWorksExampleInsurance;

  /// Example fixed cost name in the How It Works sheet
  ///
  /// In en, this message translates to:
  /// **'ETF fonds'**
  String get howItWorksExampleEtfFonds;

  /// FAB tooltip on the Category Budgets screen
  ///
  /// In en, this message translates to:
  /// **'Add budget'**
  String get addBudgetTooltip;

  /// Title of the category picker bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategoryTitle;

  /// Button in the category picker that expands to show the full category list
  ///
  /// In en, this message translates to:
  /// **'Show all categories'**
  String get showAllCategories;

  /// Button in the category picker that collapses back to the default list
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLessCategories;

  /// Title of the screen showing all available categories
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategoriesTitle;

  /// Subtitle for page 0 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Why it exists'**
  String get howCategoryBudgetsSubtitle0;

  /// Subtitle for page 1 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Creating a budget'**
  String get howCategoryBudgetsSubtitle1;

  /// Subtitle for page 2 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Reading the bar'**
  String get howCategoryBudgetsSubtitle2;

  /// Step indicator label for page 0 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get howCategoryBudgetsLabel0;

  /// Step indicator label for page 1 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get howCategoryBudgetsLabel1;

  /// Step indicator label for page 2 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get howCategoryBudgetsLabel2;

  /// Intro text on page 0 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Set a monthly cap for any category — restaurants, groceries, entertainment. Spend what you planned, nothing more.'**
  String get howCategoryBudgetsWhatIntro;

  /// Bullet rule 1 on page 0 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Pick the categories where you tend to overspend. Set a limit only there.'**
  String get howCategoryBudgetsRule1;

  /// Bullet rule 2 on page 0 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Each budget is a simple monthly cap — for example: Restaurants → 100 € per month.'**
  String get howCategoryBudgetsRule2;

  /// Bullet rule 3 on page 0 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Budgets are optional. Set as many or as few as you like.'**
  String get howCategoryBudgetsRule3;

  /// Bullet rule 4 on page 0 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'You can have one budget per category, across as many categories as you need.'**
  String get howCategoryBudgetsRule4;

  /// Intro text on page 1 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Tap + on the Manage Budgets screen. Pick a category, enter an amount, choose when it starts. Done.'**
  String get howCategoryBudgetsSetupIntro;

  /// Bullet rule 1 on page 1 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Pick a category — for example, Restaurants.'**
  String get howCategoryBudgetsSetupRule1;

  /// Bullet rule 2 on page 1 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Enter your monthly limit — for example, 100 €.'**
  String get howCategoryBudgetsSetupRule2;

  /// Bullet rule 3 on page 1 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Choose the month it starts from. It applies going forward from that point.'**
  String get howCategoryBudgetsSetupRule3;

  /// Bullet rule 4 on page 1 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Once saved, the category is locked — create a new budget to change it later.'**
  String get howCategoryBudgetsSetupRule4;

  /// Hint box text on page 1 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Choosing a past month will apply the budget retroactively. A confirmation appears before you save.'**
  String get howCategoryBudgetsPastMonthHint;

  /// Intro text on page 2 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'The progress bar shows exactly where you stand — at a glance, every time you open Expenses.'**
  String get howCategoryBudgetsProgressIntro;

  /// Bullet rule 1 on page 2 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Green — below 80%: you\'re on track. Keep going.'**
  String get howCategoryBudgetsProgressRule1;

  /// Bullet rule 2 on page 2 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Amber — 80–100%: getting close. Time to slow down.'**
  String get howCategoryBudgetsProgressRule2;

  /// Bullet rule 3 on page 2 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Red — over 100%: limit exceeded. A warning card appears at the top of your Expenses.'**
  String get howCategoryBudgetsProgressRule3;

  /// Section header for the 'where it appears' subsection on page 2 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Where it appears'**
  String get howCategoryBudgetsWhereTitle;

  /// Where it appears bullet 1 on page 2 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Expenses — a progress bar appears below each category row when a budget is active.'**
  String get howCategoryBudgetsWhere1;

  /// Where it appears bullet 2 on page 2 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Category view — each budgeted category shows its fill status inline.'**
  String get howCategoryBudgetsWhere2;

  /// Where it appears bullet 3 on page 2 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Monthly PDF report — budgets are included in your spending summary.'**
  String get howCategoryBudgetsWhere3;

  /// Hint box text on page 2 of the How Category Budgets Work sheet
  ///
  /// In en, this message translates to:
  /// **'Budgets reset each month — unused amounts don\'t carry over.'**
  String get howCategoryBudgetsResetHint;

  /// Subtitle for page 0 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Your payment reminder'**
  String get howGuardSubtitle0;

  /// Subtitle for page 1 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Setting it up'**
  String get howGuardSubtitle1;

  /// Subtitle for page 2 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'How it repeats'**
  String get howGuardSubtitle2;

  /// Step indicator label for page 0 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get howGuardLabel0;

  /// Step indicator label for page 1 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get howGuardLabel1;

  /// Step indicator label for page 2 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get howGuardLabel2;

  /// Intro text on page 0 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'GUARD reminds you when a regular bill is coming due — rent, Netflix, insurance. Nothing slips through.'**
  String get howGuardWhatIntro;

  /// Bullet rule 1 on page 0 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'On the due date, a notification appears on your phone. No action needed in advance.'**
  String get howGuardRule1;

  /// Bullet rule 2 on page 0 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Tap \"Paid\" to confirm. Or silence it if you want to skip this time.'**
  String get howGuardRule2;

  /// Bullet rule 3 on page 0 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Every guarded bill shows its current state at a glance.'**
  String get howGuardRule3;

  /// Status label for the unpaid state in the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Due — waiting for your confirmation'**
  String get howGuardStateUnpaid;

  /// Status label for the paid state in the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Paid — confirmed for this period'**
  String get howGuardStatePaid;

  /// Status label for the silenced state in the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Silenced — reminder dismissed'**
  String get howGuardStateSilenced;

  /// Intro text on page 1 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Open any Fixed Cost, tap Edit, and switch GUARD on. Set when the bill is due — that\'s all.'**
  String get howGuardActivateIntro;

  /// Bullet rule 1 on page 1 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Set the due day — the day of the month you expect to pay. For example: rent on the 1st, Netflix on the 15th.'**
  String get howGuardActivateRule1;

  /// Bullet rule 2 on page 1 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'From that day, a daily reminder repeats until you mark it paid or silence it.'**
  String get howGuardActivateRule2;

  /// Bullet rule 3 on page 1 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'For yearly bills — like insurance — also pick the due month.'**
  String get howGuardActivateRule3;

  /// Bullet rule 4 on page 1 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'You can change the daily reminder time in GUARD settings.'**
  String get howGuardActivateRule4;

  /// Hint box text on page 1 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Only Fixed Cost items can have GUARD enabled.'**
  String get howGuardFixedCostOnlyHint;

  /// Intro text on page 2 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'GUARD resets on its own at the start of each new period. You never need to reset anything manually.'**
  String get howGuardActIntro;

  /// Bullet rule 1 on page 2 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Monthly bills — like rent or subscriptions — get a fresh reminder every month.'**
  String get howGuardActRule1;

  /// Bullet rule 2 on page 2 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Yearly bills — like insurance or annual fees — reset once a year.'**
  String get howGuardActRule2;

  /// Bullet rule 3 on page 2 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Once you mark a bill as paid, it stays confirmed until the next period begins.'**
  String get howGuardActRule3;

  /// Hint box text on page 2 of the How GUARD Works sheet
  ///
  /// In en, this message translates to:
  /// **'Paid or silenced — it only applies to the current period. The next one always starts fresh.'**
  String get howGuardPerPeriodHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'cs',
    'de',
    'en',
    'hu',
    'pl',
    'sk',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'hu':
      return AppLocalizationsHu();
    case 'pl':
      return AppLocalizationsPl();
    case 'sk':
      return AppLocalizationsSk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
