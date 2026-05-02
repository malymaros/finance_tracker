// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'Finance Tracker';

  @override
  String get welcomeTagline => 'Získejte kontrolu nad svými penězi';

  @override
  String get getStarted => 'Začít';

  @override
  String get tabExpenses => 'Výdaje';

  @override
  String get tabPlan => 'Plán';

  @override
  String get tabReports => 'Přehledy';

  @override
  String get actionEdit => 'Upravit';

  @override
  String get actionDelete => 'Smazat';

  @override
  String get deleteExpenseAllCaps => 'DELETE';

  @override
  String get deleteExpenseDescription => 'Tento výdaj bude trvale odstraněn.';

  @override
  String get actionSave => 'Uložit';

  @override
  String get actionCancel => 'Zrušit';

  @override
  String get actionLoad => 'Načíst';

  @override
  String get actionImport => 'Importovat';

  @override
  String get actionOverwrite => 'Přepsat';

  @override
  String get labelAmount => 'Částka';

  @override
  String get labelCategory => 'Kategorie';

  @override
  String get labelFinancialType => 'Finanční typ';

  @override
  String get labelDate => 'Datum';

  @override
  String get labelNote => 'Poznámka';

  @override
  String get labelNoteOptional => 'Poznámka (volitelné)';

  @override
  String get labelGroup => 'Skupina';

  @override
  String get labelGroupOptional => 'Skupina (volitelné)';

  @override
  String get groupHintText => 'např. Dovolená, Narozeniny';

  @override
  String get labelName => 'Název';

  @override
  String get labelFrequency => 'Frekvence';

  @override
  String get labelValidFrom => 'Platné od';

  @override
  String get labelValidTo => 'Platné do (volitelné)';

  @override
  String get menuImportExpenses => 'Importovat výdaje';

  @override
  String get menuExportExpenses => 'Exportovat výdaje';

  @override
  String get menuImport => 'Importovat';

  @override
  String get menuSaves => 'Uložení';

  @override
  String get menuDeleteAll => 'Smazat všechna data';

  @override
  String get menuHowItWorks => 'Jak to funguje';

  @override
  String get menuResetWithDummyData => 'Obnovit s testovacími daty';

  @override
  String get menuManageBudgets => 'Spravovat rozpočty';

  @override
  String get menuGuard => 'Nastavení GUARD';

  @override
  String get expenseListTitle => 'Výdaje';

  @override
  String get savesTooltip => 'Uložení';

  @override
  String get howItWorksTooltip => 'Jak to funguje';

  @override
  String get howItWorksQuestion => 'Jak to funguje?';

  @override
  String get viewModeItems => 'Položky';

  @override
  String get viewModeByCategory => 'Kategorie';

  @override
  String get viewModeByGroup => 'Skupiny';

  @override
  String get thisMonthsBudget => 'Rozpočet na tento měsíc';

  @override
  String get budgetNotSet => 'Rozpočet není nastaven';

  @override
  String get setIncomeInPlan => 'Nastavte příjem';

  @override
  String noExpensesInMonth(String monthName, int year) {
    return 'Žádné výdaje v $monthName $year.';
  }

  @override
  String get tapPlusToAddOne => 'Klepněte na + pro přidání.';

  @override
  String get fixedBillsHint => 'Pevné účty jako nájem patří do Plánu.';

  @override
  String get noGroupsThisMonth => 'Tento měsíc nejsou žádné skupiny.';

  @override
  String get addGroupHint =>
      'Přidejte skupinu při vytváření\nnebo úpravě výdaje.';

  @override
  String get howGroupsWorkQuestion => 'Jak skupiny fungují?';

  @override
  String get howGuardWorkQuestion => 'Jak funguje GUARD?';

  @override
  String get howCategoryBudgetsWorkQuestion =>
      'Jak fungují rozpočty kategorií?';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count položek',
      few: '$count položky',
      one: '1 položka',
    );
    return '$_temp0';
  }

  @override
  String get addExpenseTitle => 'Přidat výdaj';

  @override
  String get editExpenseTitle => 'Upravit výdaj';

  @override
  String get validationAmountEmpty => 'Zadejte částku';

  @override
  String get validationAmountInvalid => 'Zadejte platné kladné číslo';

  @override
  String get expenseDetailTitle => 'Výdaj';

  @override
  String noExpensesInNamedGroup(String name) {
    return 'Žádné výdaje ve skupině „$name“.';
  }

  @override
  String get planTitle => 'Plán';

  @override
  String get toggleMonthly => 'Měsíčně';

  @override
  String get toggleYearly => 'Ročně';

  @override
  String get sectionIncome => 'Příjem';

  @override
  String get sectionFixedCosts => 'Pevné náklady';

  @override
  String get noIncomeItems => 'Žádné položky příjmu.';

  @override
  String get noFixedCostItems => 'Žádné položky pevných nákladů.';

  @override
  String get spendableBudget => 'Rozpočet k utracení';

  @override
  String get deleteItemDialogTitle => 'Smazat položku plánu';

  @override
  String get deleteItemFromPeriod => 'Od tohoto období';

  @override
  String get deleteItemWholeSeries => 'Celou sérii';

  @override
  String get planItemDeleted => 'Položka plánu byla smazána.';

  @override
  String get addIncomeTitle => 'Přidat příjem';

  @override
  String get addFixedCostTitle => 'Přidat pevný náklad';

  @override
  String get editIncomeTitle => 'Upravit příjem';

  @override
  String get editFixedCostTitle => 'Upravit pevný náklad';

  @override
  String get frequencyOneTime => 'Jednorázově';

  @override
  String get frequencyMonthly => 'Měsíčně';

  @override
  String get frequencyYearly => 'Ročně';

  @override
  String get guardSectionLabel => 'GUARD';

  @override
  String get guardTrackPayment => 'Sledovat platbu';

  @override
  String get guardDueDayLabel => 'Den splatnosti';

  @override
  String get guardOneTimeLabel => 'Jednorázová platba';

  @override
  String get planItemSaved => 'Položka plánu byla uložena.';

  @override
  String get addNewItemSheetTitle => 'Přidat nové';

  @override
  String get typeIncome => 'Příjem';

  @override
  String get typeFixedCost => 'Pevný náklad';

  @override
  String get ongoing => 'Probíhající';

  @override
  String get manageBudgetsTitle => 'Spravovat rozpočty';

  @override
  String get noBudgetsSet => 'Pro toto období nejsou nastaveny žádné rozpočty.';

  @override
  String get addFirstBudget => 'Přidejte svůj první rozpočet.';

  @override
  String get addBudgetTitle => 'Přidat rozpočet';

  @override
  String get editBudgetTitle => 'Upravit rozpočet';

  @override
  String get budgetAmount => 'Částka rozpočtu';

  @override
  String get effectiveFrom => 'Účinné od';

  @override
  String get pastMonthBudgetWarning =>
      'Nastavení rozpočtu v minulosti neovlivní minulé výdaje.';

  @override
  String get budgetSaved => 'Rozpočet byl uložen.';

  @override
  String get budgetDeleted => 'Rozpočet byl smazán.';

  @override
  String get guardScreenTitle => 'GUARD';

  @override
  String get guardDailyReminderTime => 'Čas denní připomínky';

  @override
  String get guardTimePicker => 'Čas denní připomínky GUARD';

  @override
  String get guardMarkPaid => 'Označit jako zaplacené';

  @override
  String get guardSilence => 'Ztišit';

  @override
  String get guardStatusPaid => 'Zaplaceno';

  @override
  String get guardStatusScheduled => 'Naplánováno';

  @override
  String get guardStatusUnpaid => 'Nezaplaceno';

  @override
  String get guardStatusSilenced => 'Ztišeno';

  @override
  String get noGuardedItems => 'Žádné hlídané položky.';

  @override
  String get reportsTitle => 'Přehledy';

  @override
  String get reportModeMonthly => 'Měsíčně';

  @override
  String get reportModeYearly => 'Ročně';

  @override
  String get reportModeOverview => 'Přehled';

  @override
  String get exportPdf => 'Exportovat PDF';

  @override
  String get noExpensesForPeriod =>
      'Pro toto období nejsou zaznamenány žádné výdaje.';

  @override
  String get noIncomeOrSpendingDataForYear =>
      'Pro tento rok nejsou žádná data o příjmech ani výdajích.';

  @override
  String get pieChartOther => 'Ostatní';

  @override
  String get reportSectionFixedCosts => 'PEVNÉ NÁKLADY';

  @override
  String get reportSectionExpenses => 'VÝDAJE';

  @override
  String get noneInPeriod => 'V tomto období žádné.';

  @override
  String fixedCostCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pevných nákladů',
      few: '$count pevné náklady',
      one: '1 pevný náklad',
    );
    return '$_temp0';
  }

  @override
  String expenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výdajů',
      few: '$count výdaje',
      one: '1 výdaj',
    );
    return '$_temp0';
  }

  @override
  String get noItemsInPeriod => 'V tomto období nejsou žádné položky';

  @override
  String get importTitle => 'Importovat výdaje';

  @override
  String get importStep1Title => 'Stáhnout šablonu';

  @override
  String get importStep1Description =>
      'Získejte oficiální šablonu Excel se všemi povinnými sloupci a průvodcem platnými hodnotami.';

  @override
  String get importStep1Button => 'Stáhnout šablonu';

  @override
  String get importStep2Title => 'Vyplnit a importovat';

  @override
  String get importStep2Description =>
      'Vyplňte šablonu v Excelu nebo Google Sheets a pak zde vyberte soubor pro import svých výdajů.';

  @override
  String get importStep2Button => 'Vybrat soubor (.xlsx nebo .csv)';

  @override
  String get importInfoText =>
      'Importovat lze pouze výdaje. Příjmy a položky plánu nejsou podporovány.\n\nPřijímané formáty: .xlsx (Excel) a .csv.\nSoubory CSV musí mít stejné pořadí sloupců jako šablona: Date, Amount, Category, Financial Type, Note, Group.\n\nSoubory exportované z této aplikace lze také importovat přímo.';

  @override
  String importReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výdajů připravených k importu',
      few: '$count výdaje připravené k importu',
      one: '1 výdaj připraven k importu',
    );
    return '$_temp0';
  }

  @override
  String importErrorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count řádků se nepodařilo přečíst',
      few: '$count řádky se nepodařilo přečíst',
      one: '1 řádek se nepodařilo přečíst',
    );
    return '$_temp0';
  }

  @override
  String importErrorCountSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count řádků se nepodařilo přečíst — budou přeskočeny',
      few: '$count řádky se nepodařilo přečíst — budou přeskočeny',
      one: '1 řádek se nepodařilo přečíst — bude přeskočen',
    );
    return '$_temp0';
  }

  @override
  String get importNoDataFound => 'V souboru nebyla nalezena žádná data.';

  @override
  String get importTapToEdit =>
      'Klepněte na libovolný řádek pro jeho úpravu nebo odstranění před importem.';

  @override
  String get importRowsWithErrors => 'Řádky s chybami';

  @override
  String get importNoDataRows => 'Nebyly nalezeny žádné datové řádky.';

  @override
  String importConfirmButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importovat $count výdajů',
      few: 'Importovat $count výdaje',
      one: 'Importovat 1 výdaj',
    );
    return '$_temp0';
  }

  @override
  String importSuccessMessage(int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výdajů importováno · $range',
      few: '$count výdaje importovány · $range',
      one: '1 výdaj importován · $range',
    );
    return '$_temp0';
  }

  @override
  String get importUnsupportedFile =>
      'Nepodporovaný typ souboru. Vyberte prosím soubor .xlsx nebo .csv.';

  @override
  String get importCouldNotReadFile =>
      'Soubor se nepodařilo přečíst. Zkuste to prosím znovu.';

  @override
  String importPickerError(Object error) {
    return 'Nepodařilo se otevřít výběr souboru: $error';
  }

  @override
  String importTemplateError(Object error) {
    return 'Nepodařilo se vygenerovat šablonu: $error';
  }

  @override
  String get tryAnotherFile => 'Zkusit jiný soubor';

  @override
  String get savesTitle => 'Uložení';

  @override
  String get sectionAutoBackup => 'AUTOMATICKÁ ZÁLOHA';

  @override
  String get sectionSaves => 'ULOŽENÍ';

  @override
  String get sectionDataTransfer => 'PŘENOS DAT';

  @override
  String get sectionDataDeletion => 'SMAZÁNÍ DAT';

  @override
  String get exportAllData => 'Exportovat všechna data';

  @override
  String get importAllData => 'Importovat všechna data';

  @override
  String get deleteAllData => 'Smazat všechna data';

  @override
  String get emptySlot => 'Prázdný slot';

  @override
  String savedConfirmation(String name) {
    return '„$name“ uloženo.';
  }

  @override
  String loadedConfirmation(String name) {
    return '„$name“ načteno.';
  }

  @override
  String exportFailed(Object error) {
    return 'Export selhal: $error';
  }

  @override
  String importFailedInvalid(Object error) {
    return 'Neplatný soubor: $error';
  }

  @override
  String get importDataSuccess => 'Data byla úspěšně importována.';

  @override
  String get couldNotReadSelectedFile =>
      'Vybraný soubor se nepodařilo přečíst.';

  @override
  String get importDataDialogTitle => 'Importovat data?';

  @override
  String get importDataDialogContent =>
      'Tímto nahradíte VŠECHNY aktuální výdaje a položky plánu obsahem souboru. Tuto akci nelze vrátit zpět.';

  @override
  String get saveName => 'Název uložení';

  @override
  String get saveNameCannotBeEmpty => 'Název nemůže být prázdný';

  @override
  String replacingLabel(String name) {
    return 'Nahrazuje: $name';
  }

  @override
  String get loadDialogDescription =>
      'Všechna aktuální data budou nahrazena tímto uloženým snapshotem.';

  @override
  String get deleteDialogDescription =>
      'Tento uložený snapshot bude trvale smazán.';

  @override
  String get damagedSaveFile => 'Poškozený soubor uložení';

  @override
  String overBudgetAmount(String amount) {
    return '$amount nad rozpočtem';
  }

  @override
  String underBudgetAmount(String amount) {
    return '$amount zbývá';
  }

  @override
  String spentLabel(String amount) {
    return 'Utraceno: $amount';
  }

  @override
  String budgetLabel(String amount) {
    return 'Rozpočet: $amount';
  }

  @override
  String progressBarLabel(String spent, String budget) {
    return '$spent utraceno  /  $budget rozpočet';
  }

  @override
  String categoryBudgetOverBy(String category, String amount) {
    return 'Rozpočet $category: překročen o $amount';
  }

  @override
  String get deleteAllDataDialogTitle => 'Smazat všechna data?';

  @override
  String get deleteAllDataDialogContent =>
      'Tímto trvale smažete všechny výdaje, příjmy a položky plánu. Tuto akci nelze vrátit zpět.';

  @override
  String get deleteAllDataConfirm => 'Smazat vše';

  @override
  String get monthJanuary => 'Leden';

  @override
  String get monthFebruary => 'Únor';

  @override
  String get monthMarch => 'Březen';

  @override
  String get monthApril => 'Duben';

  @override
  String get monthMay => 'Květen';

  @override
  String get monthJune => 'Červen';

  @override
  String get monthJuly => 'Červenec';

  @override
  String get monthAugust => 'Srpen';

  @override
  String get monthSeptember => 'Září';

  @override
  String get monthOctober => 'Říjen';

  @override
  String get monthNovember => 'Listopad';

  @override
  String get monthDecember => 'Prosinec';

  @override
  String get monthAbbrJan => 'Led';

  @override
  String get monthAbbrFeb => 'Úno';

  @override
  String get monthAbbrMar => 'Bře';

  @override
  String get monthAbbrApr => 'Dub';

  @override
  String get monthAbbrMay => 'Kvě';

  @override
  String get monthAbbrJun => 'Čvn';

  @override
  String get monthAbbrJul => 'Čvc';

  @override
  String get monthAbbrAug => 'Srp';

  @override
  String get monthAbbrSep => 'Zář';

  @override
  String get monthAbbrOct => 'Říj';

  @override
  String get monthAbbrNov => 'Lis';

  @override
  String get monthAbbrDec => 'Pro';

  @override
  String get categoryHousing => 'Bydlení';

  @override
  String get categoryGroceries => 'Potraviny';

  @override
  String get categoryVacation => 'Dovolená';

  @override
  String get categoryTransport => 'Doprava';

  @override
  String get categoryInsurance => 'Pojištění';

  @override
  String get categorySubscriptions => 'Předplatné';

  @override
  String get categoryCommunication => 'Komunikace';

  @override
  String get categoryHealth => 'Zdraví';

  @override
  String get categoryRestaurants => 'Restaurace';

  @override
  String get categoryEntertainment => 'Zábava';

  @override
  String get categoryElectronics => 'Elektronika';

  @override
  String get categoryClothing => 'Oblečení';

  @override
  String get categoryEducation => 'Vzdělávání';

  @override
  String get categoryInvestment => 'Investice';

  @override
  String get categoryGifts => 'Dárky';

  @override
  String get categoryTaxes => 'Daně';

  @override
  String get categoryMedications => 'Léky';

  @override
  String get categoryUtilities => 'Energie a služby';

  @override
  String get categoryHousehold => 'Potřeby domácnosti';

  @override
  String get categoryPersonalCare => 'Osobní péče';

  @override
  String get categorySavings => 'Úspory';

  @override
  String get categoryDebt => 'Dluhy';

  @override
  String get categoryKids => 'Děti';

  @override
  String get categoryPets => 'Domácí zvířata';

  @override
  String get categoryFees => 'Poplatky';

  @override
  String get categoryFuel => 'Pohonné hmoty';

  @override
  String get categoryMaintenance => 'Údržba';

  @override
  String get categoryDonations => 'Dary';

  @override
  String get categoryOther => 'Ostatní';

  @override
  String get financialTypeAsset => 'Aktiva';

  @override
  String get financialTypeConsumption => 'Spotřeba';

  @override
  String get financialTypeInsurance => 'Pojištění';

  @override
  String get addPlanItemTitle => 'Přidat položku plánu';

  @override
  String get addMonthlyIncomeTitle => 'Přidat měsíční příjem';

  @override
  String get addYearlyIncomeTitle => 'Přidat roční příjem';

  @override
  String get addOneTimeIncomeTitle => 'Přidat jednorázový příjem';

  @override
  String get addMonthlyFixedCostTitle => 'Přidat měsíční pevný náklad';

  @override
  String get addYearlyFixedCostTitle => 'Přidat roční pevný náklad';

  @override
  String get editMonthlyIncomeTitle => 'Upravit měsíční příjem';

  @override
  String get editYearlyIncomeTitle => 'Upravit roční příjem';

  @override
  String get editOneTimeIncomeTitle => 'Upravit jednorázový příjem';

  @override
  String get editMonthlyFixedCostTitle => 'Upravit měsíční pevný náklad';

  @override
  String get editYearlyFixedCostTitle => 'Upravit roční pevný náklad';

  @override
  String get labelType => 'Typ';

  @override
  String get labelMonth => 'Měsíc';

  @override
  String get labelYear => 'Rok';

  @override
  String get labelDayOfMonth => 'Den v měsíci';

  @override
  String get nameHintText => 'např. Plat, Nájem, Pojištění';

  @override
  String get validationEnterName => 'Zadejte název';

  @override
  String get selectMonthTitle => 'Vybrat měsíc';

  @override
  String get lastRenewalYearTitle => 'Rok posledního obnovení';

  @override
  String lastMonthRenewal(String monthName) {
    return 'Poslední obnovení v $monthName';
  }

  @override
  String lastActiveMonthInfo(String label) {
    return 'Poslední aktivní měsíc: $label';
  }

  @override
  String get setEndDate => 'Nastavit koncové datum';

  @override
  String untilLabel(String validToLabel) {
    return 'Do: $validToLabel';
  }

  @override
  String lastActiveMonthNote(String label) {
    return '$label je poslední aktivní měsíc.';
  }

  @override
  String get endMonthAfterStart =>
      'Koncový měsíc musí být po počátečním měsíci.';

  @override
  String get fromFieldLabel => 'Od';

  @override
  String renewedEachMonth(String monthName) {
    return 'Obnovováno každý $monthName. Data jsou pevně daná.';
  }

  @override
  String get untilFieldLabel => 'Do';

  @override
  String lastActiveMonthParens(String label) {
    return '$label (poslední aktivní měsíc)';
  }

  @override
  String get openEnded => 'Bez konce';

  @override
  String fromDateLabel(String validFromLabel) {
    return 'Od: $validFromLabel';
  }

  @override
  String get samePeriodInPlace =>
      'Stejný měsíc jako původní — aktualizuje se na místě.';

  @override
  String get differentPeriodNewVersion => 'Jiný měsíc — vytvoří se nová verze.';

  @override
  String get applyChangesToTitle => 'Použít změny na...';

  @override
  String get applyToWholeSeries => 'Celou sérii';

  @override
  String applyToWholeSeriesSubtitle(String seriesStartLabel) {
    return 'Všechna období od $seriesStartLabel dál';
  }

  @override
  String applyFromOnwards(String nextLabel) {
    return 'Od $nextLabel dál';
  }

  @override
  String applyFromSubtitle(String capLabel, String nextLabel) {
    return 'Původní série končí $capLabel.\nNová série začíná $nextLabel.';
  }

  @override
  String get applyFromUnavailable =>
      'V této sérii není k dispozici žádné budoucí období.';

  @override
  String get yearlyItemsOnlyAtRenewal =>
      'Roční položky lze měnit pouze v měsíci jejich obnovení.';

  @override
  String get guardRemindMe => 'Připomeňte mi potvrdit tuto platbu';

  @override
  String get guardShorterMonths => 'Kratší měsíce použijí svůj poslední den.';

  @override
  String get dueDayMonthly => 'Den splatnosti (opakování měsíčně)';

  @override
  String dueDayYearly(String monthName) {
    return 'Den splatnosti (opakování každý $monthName)';
  }

  @override
  String dueDayMonthlyLabel(int day) {
    return 'Den $day v každém měsíci';
  }

  @override
  String dueDayYearlyLabel(int day, String monthName) {
    return 'Den $day v $monthName každý rok';
  }

  @override
  String get guardDailyReminder => 'Denní připomínka';

  @override
  String get guardChangeNotifTime => 'Klepněte pro změnu času upozornění';

  @override
  String get guardNoGuardedItemsHint =>
      'Povolte GUARD u pevného nákladu pro sledování plateb.';

  @override
  String guardedItemsCount(int count) {
    return 'Hlídané položky · $count';
  }

  @override
  String get planItemTitle => 'Položka plánu';

  @override
  String get activeFrom => 'Aktivní od';

  @override
  String get activeUntil => 'Aktivní do';

  @override
  String get perMonth => '/ měsíc';

  @override
  String get perYear => '/ rok';

  @override
  String get oneTimeSuffix => '(jednorázově)';

  @override
  String get noEndDate => 'Bez koncového data';

  @override
  String get guardNotEnabled => 'Není povoleno';

  @override
  String removeIncomeEntirely(String name) {
    return '„$name“ bude odstraněn úplně.';
  }

  @override
  String removeIncomeFromOnwards(String name, String from, String prev) {
    return '„$name“ se zastaví od $from dál. $prev a dříve zůstane naplánováno.';
  }

  @override
  String get actionRemoveAllCaps => 'ODSTRANIT';

  @override
  String get removeBudgetAllCaps => 'ODSTRANIT ROZPOČET';

  @override
  String removeFromOnwardsTitle(String label) {
    return 'Od $label dál';
  }

  @override
  String removeCycleSubtitle(String start, String end) {
    return 'Tento cyklus ($start – $end) a všechny budoucí cykly budou odstraněny.';
  }

  @override
  String removeHistoryKept(String prev) {
    return 'Historie do $prev je zachována.';
  }

  @override
  String get silenceReminderTitle => 'Ztišit tuto připomínku?';

  @override
  String silenceReminderBody(String periodLabel) {
    return 'Platba za $periodLabel bude stále zobrazena jako nepotvrzená. Kdykoli ji můžete označit jako zaplacenou.';
  }

  @override
  String get yesSilence => 'Ano, ztišit';

  @override
  String get addPlanItemTooltip => 'Přidat položku plánu';

  @override
  String get spendableThisMonth => 'K utracení tento měsíc';

  @override
  String get spendableThisYear => 'K utracení tento rok';

  @override
  String get noPlanItemsYet => 'Zatím žádné položky plánu.';

  @override
  String get tapPlusToAddPlanItems =>
      'Klepněte na + pro přidání příjmu nebo pevných nákladů.';

  @override
  String get removeWholeSeries => 'Celou sérii';

  @override
  String removeWholeSeriesSubtitle(String seriesStartLabel) {
    return 'Všechna období od $seriesStartLabel jsou odstraněna.';
  }

  @override
  String get clearAllDataAction => 'SMAZAT';

  @override
  String get clearAllDataDescription =>
      'Výdaje, položky plánu, rozpočty a platby guard budou trvale smazány. Tuto akci nelze vrátit zpět.';

  @override
  String get clearAllDataPreservedNote =>
      'Uložené snapshoty a automatické zálohy nejsou ovlivněny.';

  @override
  String get allCategoriesBudgeted =>
      'Všechny kategorie už mají pro tento měsíc rozpočet. Vyberte jiný měsíc pro přidání dalšího.';

  @override
  String get selectCategoryHint => 'Vyberte kategorii';

  @override
  String get validationSelectCategory => 'Vyberte kategorii';

  @override
  String get monthlyBudgetLabel => 'Měsíční rozpočet';

  @override
  String effectiveFromLabel(String validFromLabel) {
    return 'Účinné od: $validFromLabel';
  }

  @override
  String pastMonthBudgetCreateWarning(String fromLabel) {
    return 'Vytváříte rozpočet pro minulý měsíc. Bude platit zpětně od $fromLabel.';
  }

  @override
  String pastMonthBudgetEditWarning(
    String catName,
    String fromLabel,
    String prevLabel,
  ) {
    return 'Tím se změní rozpočet kategorie $catName zpětně na $fromLabel. Měsíce $fromLabel–$prevLabel použijí novou částku.';
  }

  @override
  String get noFixedCostsPlanned => 'Žádné pevné náklady nejsou naplánovány';

  @override
  String get noIncomePlanned => 'Žádný příjem není naplánován';

  @override
  String saveSlotSubtitle(String date, int expenseCount, int planItemCount) {
    return '$date · $expenseCount výdajů · $planItemCount položek plánu';
  }

  @override
  String get saveSlotDamagedSubtitle => 'Soubor je poškozen a nelze ho načíst';

  @override
  String get howGroupsTitle => 'Skupiny';

  @override
  String get howGroupsSubtitle0 => 'Co je skupina a jak funguje';

  @override
  String get howGroupsSubtitle1 => 'Jak z toho vytěžit maximum';

  @override
  String get howGroupsSubtitle2 => 'Kde se skupiny v aplikaci objevují';

  @override
  String get howGroupsLabel0 => 'Štítek';

  @override
  String get howGroupsLabel1 => 'Buďte kreativní';

  @override
  String get howGroupsLabel2 => 'Záznam';

  @override
  String get howGroupsRule1 =>
      'Skupina je volitelný volný textový štítek, který připojíte k libovolnému výdaji.';

  @override
  String get howGroupsRule2 =>
      'Můžete zadat jakýkoli řetězec — neexistuje žádný pevný seznam ani validace.';

  @override
  String get howGroupsRule3 =>
      'Dva výdaje patří do stejné skupiny pouze tehdy, když se jejich štítky přesně shodují, znak po znaku.';

  @override
  String get howGroupsRule4 =>
      'Velikost písmen je zachována — „Trip“ a „trip“ jsou považovány za dvě různé skupiny.';

  @override
  String get howGroupsRule5 =>
      'Pole je volitelné. Nechte ho prázdné a výdaj jednoduše nebude mít žádnou skupinu.';

  @override
  String get howGroupsHint =>
      'Nastavte skupinu při vytváření nebo úpravě libovolného výdaje.';

  @override
  String get howGroupsUseIntro =>
      'Použijte to kdykoli chcete sledovat část výdajů, která prochází napříč kategoriemi.';

  @override
  String howGroupsExample1Label(int year) {
    return 'Barcelona $year';
  }

  @override
  String get howGroupsExample1Desc =>
      'Připojte ho ke každému výdaji na cestě — lety, hotely, jídla, vstupenky. Celkovou cenu celé cesty uvidíte jedním klepnutím.';

  @override
  String howGroupsExample2Label(int year) {
    return 'McDonald\'s $year';
  }

  @override
  String get howGroupsExample2Desc =>
      'Používejte konzistentní název po celý rok. Na konci roku budete přesně vědět, kolik jste utratili na tom jednom místě.';

  @override
  String get howGroupsExample3Label => 'Rekonstrukce domu Q1';

  @override
  String get howGroupsExample3Desc =>
      'Používejte stejný štítek napříč více měsíci. Karta Skupiny shromáždí vše pod tímto názvem.';

  @override
  String get howGroupsPrecision =>
      'Čím přesnější je váš štítek, tím užitečnější je souhrn.';

  @override
  String get howGroupsRecord0Title => 'Karta Skupiny ve Výdajích';

  @override
  String get howGroupsRecord0Body =>
      'Každá skupina, která má v aktuálním měsíci alespoň jeden výdaj, se zde zobrazí jako jeden řádek s počtem položek a součtem. Klepněte na skupinu pro zobrazení detailu a uvidíte každý jednotlivý výdaj, který za ní stojí.';

  @override
  String get howGroupsRecord1Title => 'Měsíční přehled v Přehledech';

  @override
  String get howGroupsRecord1Body =>
      'Když exportujete měsíční PDF z obrazovky Přehledy, skupiny s výdaji v tomto měsíci dostanou vlastní stránku „Skupiny výdajů“ — každá skupina bude uvedena se svými výdaji, částkami a součtem skupiny.';

  @override
  String get howGroupsMonthlyNote =>
      'Skupiny nejsou zahrnuty v ročním přehledu — jsou to měsíční pohled.';

  @override
  String get howGroupsExampleGroupName => 'Moje skupina';

  @override
  String get otherCategories => 'Ostatní kategorie';

  @override
  String noCategoryExpenses(String category, String period) {
    return 'Žádné výdaje v kategorii $category\nv $period.';
  }

  @override
  String guardDueDate(String monthName, int day, int year) {
    return 'Splatné $monthName $day, $year';
  }

  @override
  String get guardNotYetDue => 'Ještě není splatné';

  @override
  String guardNextReminder(String label) {
    return 'Další: $label';
  }

  @override
  String guardLastReminder(String label) {
    return 'Poslední: $label';
  }

  @override
  String get guardChangeDay => 'Změnit den';

  @override
  String get guardRemoveAction => 'Odebrat GUARD';

  @override
  String get guardMarkUnpaidTitle => 'Označit jako nezaplacené?';

  @override
  String guardMarkUnpaidBody(String monthName, int year) {
    return 'Tímto odstraníte potvrzení platby pro $monthName $year.';
  }

  @override
  String get guardMarkUnpaidAction => 'Označit jako nezaplacené';

  @override
  String get guardMarkAsPaid => 'Označit jako zaplacené';

  @override
  String get guardRemoveTitle => 'Odebrat GUARD?';

  @override
  String guardRemoveBody(String name) {
    return 'GUARD bude vypnut pro „$name“. Existující záznamy o platbách zůstanou zachovány, ale nové připomínky se již nebudou spouštět.';
  }

  @override
  String get guardRemoveConfirm => 'Odebrat';

  @override
  String get guardSelectPaidDate => 'Vyberte datum zaplacení';

  @override
  String guardPaidOn(String date) {
    return 'Zaplaceno $date';
  }

  @override
  String howItWorksStep(int n) {
    return 'KROK $n';
  }

  @override
  String get planSubtitle0 => 'Váš plat a pravidelné měsíční účty';

  @override
  String get planSubtitle1 => 'Jak jsou klasifikovány vaše pevné náklady';

  @override
  String get planSubtitle2 => 'Kolik z vašeho příjmu spotřebuje každý typ';

  @override
  String get planSubStep0 => 'Cashflow';

  @override
  String get planSubStep1 => 'Klasifikace';

  @override
  String get planSubStep2 => 'Alokace';

  @override
  String get howItWorksPlanIncomeBody =>
      'Zadejte svůj plat a pravidelné měsíční účty — nájem, pojištění, předplatné. Jsou to skutečná, známá čísla, ne odhady ani cíle.';

  @override
  String get howItWorksTypeConsumptionDesc =>
      'Každodenní výdaje — potraviny, nájem, stravování, doprava';

  @override
  String get howItWorksTypeAssetDesc =>
      'Investice a úspory, které v průběhu času zvyšují váš majetek';

  @override
  String get howItWorksTypeInsuranceDesc =>
      'Náklady na ochranu — pojištění auta, zdraví a života';

  @override
  String get howItWorksFinancialTypesBody =>
      'Každý pevný náklad je označen finančním typem. Díky tomu může aplikace ukázat, jak je váš příjem rozdělen mezi výdaje, úspory a ochranu.';

  @override
  String get howItWorksSpendingVsIncomeTitle => 'Výdaje vs příjem';

  @override
  String get howItWorksSpendingVsIncomeBody =>
      'Karta Plán ukazuje, kolik z vašeho příjmu jde do každého finančního typu — takže na první pohled vidíte, zda správně utrácíte, spoříte nebo chráníte podíl toho, co vyděláte.';

  @override
  String get expSubtitle0 => 'Váš dostupný rozpočet, vypočítaný z Plánu';

  @override
  String get expSubtitle1 => 'Každodenní výdaje, které zaznamenáváte';

  @override
  String get expSubtitle2 => 'Zůstali jste v rámci rozpočtu?';

  @override
  String get subStepBudget => 'Rozpočet';

  @override
  String get subStepSpending => 'Utrácení';

  @override
  String get subStepResult => 'Výsledek';

  @override
  String get howItWorksBudgetBody =>
      'Aplikace odečte vaše pevné náklady od vašeho příjmu a výsledek zobrazí zde. Toto číslo nenastavujete — pochází z vašeho Plánu.';

  @override
  String get howItWorksSpendingBody =>
      'Zaznamenávejte potraviny, jídla, nákupy a další variabilní výdaje. Pevné měsíční účty jako nájem patří do Plánu, ne sem.';

  @override
  String get howItWorksResultBody =>
      'Na konci měsíce karta Výdaje ukáže, jaký výsledek jste měli.';

  @override
  String get repSubtitle0 => 'Kam šly vaše peníze?';

  @override
  String get repSubtitle1 => 'Vaše finance na papíře';

  @override
  String get repSubtitle2 => 'Celkový obraz, měsíc po měsíci';

  @override
  String get repSubStep0 => 'Rozpis';

  @override
  String get repSubStep1 => 'Export';

  @override
  String get repSubStep2 => 'Přehled';

  @override
  String get howItWorksBreakdownBody =>
      'Rozpis ukazuje vaše výdaje podle kategorií za libovolný měsíc nebo rok. Klepněte na výsek nebo řádek kategorie pro zobrazení jednotlivých výdajů a pevných nákladů, které za ním stojí.';

  @override
  String get pdfFeatureCategoryTotals => 'Součty kategorií';

  @override
  String get pdfFeatureBudgetVsActual => 'Rozpočet vs skutečnost';

  @override
  String get pdfFeatureTypeSplit => 'Rozdělení finančních typů';

  @override
  String get pdfFeatureAllExpenses => 'Všechny výdaje vypsány';

  @override
  String get pdfFeatureCategoryBudgets => 'Rozpočty kategorií';

  @override
  String get pdfFeatureGroupSummaries => 'Souhrny skupin';

  @override
  String get pdfFeature12MonthOverview => 'Přehled 12 měsíců';

  @override
  String get pdfFeatureAnnualTotals => 'Roční součty';

  @override
  String get pdfFeatureMonthlyBreakdown => 'Měsíční rozpis';

  @override
  String get pdfFeaturePlanVsActual => 'Plán vs skutečnost';

  @override
  String get pdfFeatureTypeRatios => 'Poměry typů';

  @override
  String get pdfFeatureActivePlanItems => 'Aktivní položky plánu';

  @override
  String get howItWorksExportBody =>
      'Pro export použijte tlačítko PDF v Rozpisu. Přehledy lze sdílet přes jakoukoli aplikaci ve vašem zařízení.';

  @override
  String get howItWorksMoreMonths => '· · · o 9 měsíců více';

  @override
  String get howItWorksOverviewBody =>
      'Přehled ukazuje všech 12 měsíců vedle sebe — kolik jste vydělali, co šlo do aktiv a co bylo spotřebováno. Klepněte na libovolný měsíc pro přechod na toto období v Plánu.';

  @override
  String overBudgetBy(String amount) {
    return 'Nad rozpočtem o $amount';
  }

  @override
  String savedAmount(String amount) {
    return 'Ušetřeno $amount';
  }

  @override
  String get loadingLabel => 'Načítání…';

  @override
  String get autoBackupTitle => 'Automatická záloha';

  @override
  String get autoBackupNoBackupYet => 'Zatím žádná záloha';

  @override
  String get autoBackupSubtitleExpand =>
      'Aktualizováno denně · klepněte pro rozbalení';

  @override
  String get autoBackupSubtitleCollapse =>
      'Aktualizováno denně · klepněte pro sbalení';

  @override
  String get actionRestoreAllCaps => 'OBNOVIT';

  @override
  String get actionRestore => 'Obnovit';

  @override
  String get autoBackupRestoreDescription =>
      'Obnovením nahradíte všechna aktuální data zálohou.';

  @override
  String autoBackupRestored(String date) {
    return 'Záloha z $date obnovena.';
  }

  @override
  String get autoBackupRestoreFailed => 'Zálohu se nepodařilo obnovit.';

  @override
  String get autoBackupPrimary => 'Primární záloha';

  @override
  String get autoBackupSecondary => 'Sekundární záloha';

  @override
  String get frequencyPickerFixed => 'Jak často se opakuje?';

  @override
  String get frequencyMonthlyFixedSubtitle =>
      'Nájem, předplatné, opakující se účty';

  @override
  String get frequencyYearlyFixedSubtitle =>
      'Roční předplatné, pojištění, členství';

  @override
  String get frequencyPickerIncome => 'Jak často to dostáváte?';

  @override
  String get frequencyMonthlyIncomeSubtitle =>
      'Plat, důchod, pravidelné převody';

  @override
  String get frequencyYearlyIncomeSubtitle =>
      'Roční bonus, daňová vratka, dividendy';

  @override
  String get frequencyOneTimeIncomeSubtitle =>
      'Dar, mimořádný příjem, jednorázová platba';

  @override
  String get typePickerTitle => 'Co přidáváte?';

  @override
  String get typeIncomeSubtitle => 'Plat, bonus, důchod, dárky';

  @override
  String get typeFixedCostSubtitle => 'Nájem, pojištění, předplatné';

  @override
  String get languagePickerTitle => 'Jazyk';

  @override
  String get currencyPickerTitle => 'Měna';

  @override
  String get currencyCustom => 'Vlastní';

  @override
  String get currencyCustomSubtitle => 'Definujte vlastní kód a symbol';

  @override
  String get currencyCustomTitle => 'Vlastní měna';

  @override
  String get currencyCodeLabel => 'Kód';

  @override
  String get currencyCodeHint => 'např. USD';

  @override
  String get currencySymbolLabel => 'Symbol';

  @override
  String get currencySymbolHint => 'např. \$';

  @override
  String get removeFromImport => 'Odebrat z importu';

  @override
  String get exportExpensesTitle => 'Exportovat výdaje';

  @override
  String get selectDateRangeHint => 'Vyberte rozsah dat pro export:';

  @override
  String get startDateLabel => 'Počáteční datum';

  @override
  String get endDateLabel => 'Koncové datum';

  @override
  String get tapToSelectDate => 'Klepněte pro výběr';

  @override
  String get endDateAfterStart =>
      'Koncové datum musí být ve stejný den nebo po počátečním datu.';

  @override
  String get actionExport => 'Exportovat';

  @override
  String overspendWarning(String period, String amount) {
    return 'V tomto $period jste utratili o $amount více, než jste vydělali!';
  }

  @override
  String get periodMonth => 'měsíci';

  @override
  String get periodYear => 'roce';

  @override
  String guardBannerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'GUARD — $count plateb není potvrzeno',
      few: 'GUARD — $count platby nejsou potvrzeny',
      one: 'GUARD — 1 platba není potvrzena',
    );
    return '$_temp0';
  }

  @override
  String get guardSilencedBadge => 'ztišeno';

  @override
  String guardExpenseStripPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hlídaných plateb čeká',
      few: '$count hlídané platby čekají',
      one: '1 hlídaná platba čeká',
    );
    return '$_temp0';
  }

  @override
  String importErrorRowLabel(int row, String field) {
    return 'Řádek $row — $field';
  }

  @override
  String earnedLabel(String amount) {
    return 'Vyděláno: $amount';
  }

  @override
  String fromDateShort(String label) {
    return 'od $label';
  }

  @override
  String untilDateShort(String label) {
    return 'do $label';
  }

  @override
  String get guardEnableToggle => 'Povolit GUARD';

  @override
  String get guardEnableToggleSubtitle =>
      'Sledovat platbu a dostávat připomínky';

  @override
  String get actionOk => 'OK';

  @override
  String get labelTotal => 'Celkem';

  @override
  String get categoryBudgetsTitle => 'Rozpočty kategorií';

  @override
  String get noCategoryBudgetsSet =>
      'Nejsou nastaveny žádné rozpočty kategorií.';

  @override
  String removeBudgetDialogTitle(String category) {
    return 'Odebrat rozpočet kategorie $category';
  }

  @override
  String endBudgetFromTitle(String from) {
    return 'Ukončit od $from';
  }

  @override
  String endBudgetFromDescription(String from) {
    return 'Zastaví rozpočet od $from dál. Dřívější měsíce si ponechají svůj historický rozpočet.';
  }

  @override
  String get deleteBudgetSeriesTitle => 'Smazat celou sérii';

  @override
  String get deleteBudgetSeriesConfirm => 'Smazat sérii';

  @override
  String deleteBudgetSeriesDescription(String range) {
    return 'Trvale odstraní všechny záznamy ($range). V žádném měsíci této série se nezobrazí žádný rozpočet. Tuto akci nelze vrátit zpět.';
  }

  @override
  String budgetRangePresent(String start) {
    return '$start – současnost';
  }

  @override
  String get pdfMonthlyReport => 'Měsíční přehled';

  @override
  String get pdfYearlyReport => 'Roční přehled';

  @override
  String pdfMonthlyReportHeader(String month, int year) {
    return 'MĚSÍČNÍ PŘEHLED ZA $month $year';
  }

  @override
  String pdfYearlyReportHeader(int year) {
    return 'ROČNÍ PŘEHLED ZA $year';
  }

  @override
  String get pdfPartialYear => '(částečný rok)';

  @override
  String get pdfSectionSpendingVsIncome => 'VÝDAJE VS PŘÍJEM';

  @override
  String get pdfSectionCategorySummary => 'SOUHRN KATEGORIÍ';

  @override
  String get pdfSectionCashFlowSummary => 'SOUHRN CASH FLOW';

  @override
  String get pdfSectionExpenseGroups => 'SKUPINY VÝDAJŮ';

  @override
  String get pdfSectionExpenseDetails => 'DETAILY VÝDAJŮ';

  @override
  String get pdfSectionYearlyOverview => 'ROČNÍ PŘEHLED';

  @override
  String get pdfSectionSpendingByCategory => 'VÝDAJE PODLE KATEGORIÍ A MĚSÍCŮ';

  @override
  String get pdfIncomeHeader => 'PŘÍJEM';

  @override
  String get pdfFixedCostsHeader => 'PEVNÉ NÁKLADY';

  @override
  String get pdfTotal => 'CELKEM';

  @override
  String get pdfColTotal => 'Celkem';

  @override
  String get pdfEarnedThisMonth => 'Vyděláno tento měsíc';

  @override
  String get pdfEarnedThisYear => 'Vyděláno tento rok';

  @override
  String get pdfGroupTotal => 'Součet skupiny (tento měsíc)';

  @override
  String get pdfAllPeriodsTotal => 'Součet všech období';

  @override
  String pdfItemsThisMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count položek tento měsíc',
      few: '$count položky tento měsíc',
      one: '1 položka tento měsíc',
    );
    return '$_temp0';
  }

  @override
  String get pdfNormalized => ' (normalizováno)';

  @override
  String get pdfAnnualized => ' (přepočteno na rok)';

  @override
  String get pdfPartialYearNote =>
      'Částečný rok - měsíce bez dat zobrazují nuly. Pouze průběžné součty od začátku roku.';

  @override
  String pdfPage(int page, int total) {
    return 'Strana $page z $total';
  }

  @override
  String get pdfNoData => 'Žádná data.';

  @override
  String get howItWorksExampleSalary => 'Plat';

  @override
  String get howItWorksExampleBonus => 'Bonus';

  @override
  String get howItWorksExampleRent => 'Nájem';

  @override
  String get howItWorksExampleInsurance => 'Pojištění';

  @override
  String get howItWorksExampleEtfFonds => 'ETF fondy';

  @override
  String get addBudgetTooltip => 'Přidat rozpočet';

  @override
  String get selectCategoryTitle => 'Vybrat kategorii';

  @override
  String get showAllCategories => 'Zobrazit všechny kategorie';

  @override
  String get showLessCategories => 'Zobrazit méně';

  @override
  String get allCategoriesTitle => 'Všechny kategorie';

  @override
  String get howCategoryBudgetsSubtitle0 => 'Omezte výdaje podle kategorie!';

  @override
  String get howCategoryBudgetsSubtitle1 => 'Vytvoření rozpočtu';

  @override
  String get howCategoryBudgetsSubtitle2 => 'Čtení ukazatele';

  @override
  String get howCategoryBudgetsLabel0 => 'Limit';

  @override
  String get howCategoryBudgetsLabel1 => 'Nastavit';

  @override
  String get howCategoryBudgetsLabel2 => 'Průběh';

  @override
  String get howCategoryBudgetsWhatIntro =>
      'Nastavte měsíční limit pro libovolnou kategorii — restaurace, potraviny, zábava. Utratte jen to, co jste plánovali.';

  @override
  String get howCategoryBudgetsRule1 =>
      'Vyberte kategorie, ve kterých máte tendenci utrácet více. Limit nastavte jen tam.';

  @override
  String get howCategoryBudgetsRule2 =>
      'Každý rozpočet je jednoduchý měsíční limit — například: Restaurace → 100 € za měsíc.';

  @override
  String get howCategoryBudgetsRule3 =>
      'Rozpočty jsou volitelné. Nastavte jich tolik nebo tak málo, jak chcete.';

  @override
  String get howCategoryBudgetsRule4 =>
      'Na každou kategorii může být jeden rozpočet — pro libovolný počet kategorií.';

  @override
  String get howCategoryBudgetsSetupIntro =>
      'Klepněte na + na obrazovce Správa rozpočtů. Vyberte kategorii, zadejte částku, zvolte datum zahájení. Hotovo.';

  @override
  String get howCategoryBudgetsSetupRule1 =>
      'Vyberte kategorii — například Restaurace.';

  @override
  String get howCategoryBudgetsSetupRule2 =>
      'Zadejte měsíční limit — například 100 €.';

  @override
  String get howCategoryBudgetsSetupRule3 =>
      'Zvolte měsíc, od kterého platí. Vztahuje se na vše od tohoto bodu.';

  @override
  String get howCategoryBudgetsSetupRule4 =>
      'Po uložení je kategorie uzamčena — pro pozdější změnu vytvořte nový rozpočet.';

  @override
  String get howCategoryBudgetsPastMonthHint =>
      'Výběr minulého měsíce použije rozpočet zpětně. Před uložením se zobrazí potvrzení.';

  @override
  String get howCategoryBudgetsProgressIntro =>
      'Ukazatel průběhu přesně ukazuje, kde se nacházíte — na jeden pohled, pokaždé když otevřete Výdaje.';

  @override
  String get howCategoryBudgetsProgressRule1 =>
      'Zelená — pod 80 %: výdaje jsou v pořádku. Pokračujte.';

  @override
  String get howCategoryBudgetsProgressRule2 =>
      'Oranžová — 80–100 %: blíží se limit. Čas zpomalit.';

  @override
  String get howCategoryBudgetsProgressRule3 =>
      'Červená — přes 100 %: limit překročen. V horní části Výdajů se zobrazí varovná karta.';

  @override
  String get howCategoryBudgetsWhereTitle => 'Kde se zobrazuje';

  @override
  String get howCategoryBudgetsWhere1 =>
      'Výdaje — pod každým řádkem kategorie se zobrazí ukazatel průběhu, je-li aktivní rozpočet.';

  @override
  String get howCategoryBudgetsWhere2 =>
      'Zobrazení kategorií — každá kategorie s rozpočtem zobrazuje svůj stav naplnění.';

  @override
  String get howCategoryBudgetsWhere3 =>
      'Měsíční PDF výkaz — rozpočty jsou součástí přehledu výdajů.';

  @override
  String get howCategoryBudgetsResetHint =>
      'Rozpočty se každý měsíc resetují — nevyužité částky se nepřenášejí.';

  @override
  String get howGuardSubtitle0 => 'Připomenutí plateb';

  @override
  String get howGuardSubtitle1 => 'Nastavení';

  @override
  String get howGuardSubtitle2 => 'Jak se opakuje';

  @override
  String get howGuardLabel0 => 'Připomenutí';

  @override
  String get howGuardLabel1 => 'Nastavení';

  @override
  String get howGuardLabel2 => 'Opakování';

  @override
  String get howGuardWhatIntro =>
      'GUARD vás upozorní, když se blíží splatnost pravidelného výdaje — nájem, Netflix, pojištění. Nic vám neunikne.';

  @override
  String get howGuardRule1 =>
      'V den splatnosti se na vašem telefonu zobrazí upozornění. Žádná příprava předem není potřeba.';

  @override
  String get howGuardRule2 =>
      'Klepněte na \"Zaplaceno\" pro potvrzení. Nebo upozornění ztište, pokud chcete tentokrát přeskočit.';

  @override
  String get howGuardRule3 =>
      'Každý hlídaný výdaj zobrazuje svůj aktuální stav.';

  @override
  String get howGuardStateUnpaid => 'Splatné — čeká na vaše potvrzení';

  @override
  String get howGuardStatePaid => 'Zaplaceno — potvrzeno pro toto období';

  @override
  String get howGuardStateSilenced => 'Ztišeno — připomenutí zamítnuto';

  @override
  String get howGuardActivateIntro =>
      'Otevřete libovolný fixní výdaj, klepněte na Upravit a zapněte GUARD. Nastavte, kdy je výdaj splatný — to je vše.';

  @override
  String get howGuardActivateRule1 =>
      'Nastavte den splatnosti — den v měsíci, kdy očekáváte platbu. Například: nájem 1., Netflix 15.';

  @override
  String get howGuardActivateRule2 =>
      'Od toho dne se denní připomenutí opakuje, dokud ho neoznačíte jako zaplacené nebo neztišíte.';

  @override
  String get howGuardActivateRule3 =>
      'U ročních výdajů — jako je pojištění — vyberte také měsíc splatnosti.';

  @override
  String get howGuardActivateRule4 =>
      'Čas denního připomenutí lze změnit v nastavení GUARD.';

  @override
  String get howGuardFixedCostOnlyHint =>
      'GUARD lze zapnout pouze pro položky fixních výdajů.';

  @override
  String get howGuardActIntro =>
      'GUARD se automaticky resetuje na začátku každého nového období. Nemusíte nic resetovat ručně.';

  @override
  String get howGuardActRule1 =>
      'Měsíční výdaje — jako nájem nebo předplatné — dostávají nové připomenutí každý měsíc.';

  @override
  String get howGuardActRule2 =>
      'Roční výdaje — jako pojištění nebo roční poplatky — se resetují jednou ročně.';

  @override
  String get howGuardActRule3 =>
      'Jakmile označíte výdaj jako zaplacený, zůstane potvrzený až do začátku dalšího období.';

  @override
  String get howGuardPerPeriodHint =>
      'Zaplaceno nebo ztišeno — platí pouze pro aktuální období. Příští období vždy začíná znovu.';
}
