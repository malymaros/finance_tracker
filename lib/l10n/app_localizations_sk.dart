// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appTitle => 'Finance Tracker';

  @override
  String get welcomeTagline => 'Získajte kontrolu nad svojimi peniazmi';

  @override
  String get getStarted => 'Začať';

  @override
  String get tabExpenses => 'Výdavky';

  @override
  String get tabPlan => 'Plán';

  @override
  String get tabReports => 'Prehľady';

  @override
  String get actionEdit => 'Upraviť';

  @override
  String get actionDelete => 'Odstrániť';

  @override
  String get actionSave => 'Uložiť';

  @override
  String get actionCancel => 'Zrušiť';

  @override
  String get actionLoad => 'Načítať';

  @override
  String get actionImport => 'Importovať';

  @override
  String get actionOverwrite => 'Prepísať';

  @override
  String get labelAmount => 'Suma';

  @override
  String get labelCategory => 'Kategória';

  @override
  String get labelFinancialType => 'Finančný typ';

  @override
  String get labelDate => 'Dátum';

  @override
  String get labelNote => 'Poznámka';

  @override
  String get labelNoteOptional => 'Poznámka (voliteľné)';

  @override
  String get labelGroup => 'Skupina';

  @override
  String get labelGroupOptional => 'Skupina (voliteľné)';

  @override
  String get groupHintText => 'napr. Dovolenka, Narodeniny';

  @override
  String get labelName => 'Názov';

  @override
  String get labelFrequency => 'Frekvencia';

  @override
  String get labelValidFrom => 'Platné od';

  @override
  String get labelValidTo => 'Platné do (voliteľné)';

  @override
  String get menuImportExpenses => 'Importovať výdavky';

  @override
  String get menuExportExpenses => 'Exportovať výdavky';

  @override
  String get menuImport => 'Importovať';

  @override
  String get menuSaves => 'Uloženia';

  @override
  String get menuDeleteAll => 'Odstrániť všetky dáta';

  @override
  String get menuHowItWorks => 'Ako to funguje';

  @override
  String get menuResetWithDummyData => 'Resetovať s testovacími dátami';

  @override
  String get menuManageBudgets => 'Spravovať rozpočty';

  @override
  String get menuGuard => 'GUARD';

  @override
  String get expenseListTitle => 'Výdavky';

  @override
  String get savesTooltip => 'Uloženia';

  @override
  String get howItWorksTooltip => 'Ako to funguje';

  @override
  String get howItWorksQuestion => 'Ako to funguje?';

  @override
  String get viewModeItems => 'Položky';

  @override
  String get viewModeByCategory => 'Kategória';

  @override
  String get viewModeByGroup => 'Skupiny';

  @override
  String get thisMonthsBudget => 'Rozpočet na tento mesiac';

  @override
  String get budgetNotSet => 'Rozpočet nie je nastavený';

  @override
  String get setIncomeInPlan => 'Nastaviť príjem';

  @override
  String noExpensesInMonth(String monthName, int year) {
    return 'V mesiaci $monthName $year nie sú žiadne výdavky.';
  }

  @override
  String get tapPlusToAddOne => 'Ťuknite na + a pridajte výdavok.';

  @override
  String get fixedBillsHint => 'Fixné platby ako nájom patria do Plánu.';

  @override
  String get noGroupsThisMonth => 'Tento mesiac nie sú žiadne skupiny.';

  @override
  String get addGroupHint =>
      'Pridajte skupinu pri vytváraní\nalebo úprave výdavku.';

  @override
  String get howGroupsWorkQuestion => 'Ako fungujú skupiny?';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count položiek',
      few: '$count položky',
      one: '1 položka',
    );
    return '$_temp0';
  }

  @override
  String get addExpenseTitle => 'Pridať výdavok';

  @override
  String get editExpenseTitle => 'Upraviť výdavok';

  @override
  String get validationAmountEmpty => 'Zadajte sumu';

  @override
  String get validationAmountInvalid => 'Zadajte platné kladné číslo';

  @override
  String get expenseDetailTitle => 'Výdavok';

  @override
  String noExpensesInNamedGroup(String name) {
    return 'V skupine „$name“ nie sú žiadne výdavky.';
  }

  @override
  String get planTitle => 'Plán';

  @override
  String get toggleMonthly => 'Mesačne';

  @override
  String get toggleYearly => 'Ročne';

  @override
  String get sectionIncome => 'Príjem';

  @override
  String get sectionFixedCosts => 'Fixné náklady';

  @override
  String get noIncomeItems => 'Žiadne položky príjmu.';

  @override
  String get noFixedCostItems => 'Žiadne položky fixných nákladov.';

  @override
  String get spendableBudget => 'Rozpočet na míňanie';

  @override
  String get deleteItemDialogTitle => 'Odstrániť položku plánu';

  @override
  String get deleteItemFromPeriod => 'Od tohto obdobia';

  @override
  String get deleteItemWholeSeries => 'Celú sériu';

  @override
  String get planItemDeleted => 'Položka plánu bola odstránená.';

  @override
  String get addIncomeTitle => 'Pridať príjem';

  @override
  String get addFixedCostTitle => 'Pridať fixný náklad';

  @override
  String get editIncomeTitle => 'Upraviť príjem';

  @override
  String get editFixedCostTitle => 'Upraviť fixný náklad';

  @override
  String get frequencyOneTime => 'Jednorazovo';

  @override
  String get frequencyMonthly => 'Mesačne';

  @override
  String get frequencyYearly => 'Ročne';

  @override
  String get guardSectionLabel => 'GUARD';

  @override
  String get guardTrackPayment => 'Sledovať platbu';

  @override
  String get guardDueDayLabel => 'Deň splatnosti';

  @override
  String get guardOneTimeLabel => 'Jednorazová platba';

  @override
  String get planItemSaved => 'Položka plánu bola uložená.';

  @override
  String get addNewItemSheetTitle => 'Pridať nové';

  @override
  String get typeIncome => 'Príjem';

  @override
  String get typeFixedCost => 'Fixný náklad';

  @override
  String get ongoing => 'Bez ukončenia';

  @override
  String get manageBudgetsTitle => 'Spravovať rozpočty';

  @override
  String get noBudgetsSet =>
      'Pre toto obdobie nie sú nastavené žiadne rozpočty.';

  @override
  String get addFirstBudget => 'Pridajte svoj prvý rozpočet.';

  @override
  String get addBudgetTitle => 'Pridať rozpočet';

  @override
  String get editBudgetTitle => 'Upraviť rozpočet';

  @override
  String get budgetAmount => 'Suma rozpočtu';

  @override
  String get effectiveFrom => 'Platné od';

  @override
  String get pastMonthBudgetWarning =>
      'Nastavenie rozpočtu v minulosti neovplyvní minulé výdavky.';

  @override
  String get budgetSaved => 'Rozpočet bol uložený.';

  @override
  String get budgetDeleted => 'Rozpočet bol odstránený.';

  @override
  String get guardScreenTitle => 'GUARD';

  @override
  String get guardDailyReminderTime => 'Čas dennej pripomienky';

  @override
  String get guardTimePicker => 'Čas dennej pripomienky GUARD';

  @override
  String get guardMarkPaid => 'Označiť ako zaplatené';

  @override
  String get guardSilence => 'Stíšiť';

  @override
  String get guardStatusPaid => 'Zaplatené';

  @override
  String get guardStatusScheduled => 'Naplánované';

  @override
  String get guardStatusUnpaid => 'Nezaplatené';

  @override
  String get guardStatusSilenced => 'Stíšené';

  @override
  String get noGuardedItems => 'Žiadne sledované položky.';

  @override
  String get reportsTitle => 'Prehľady';

  @override
  String get reportModeMonthly => 'Mesačne';

  @override
  String get reportModeYearly => 'Ročne';

  @override
  String get reportModeOverview => 'Prehľad';

  @override
  String get exportPdf => 'Exportovať PDF';

  @override
  String get noExpensesForPeriod =>
      'Pre toto obdobie nie sú zaznamenané žiadne výdavky.';

  @override
  String get noIncomeOrSpendingDataForYear =>
      'Pre tento rok nie sú k dispozícii údaje o príjmoch ani výdavkoch.';

  @override
  String get pieChartOther => 'Ostatné';

  @override
  String get reportSectionFixedCosts => 'FIXNÉ NÁKLADY';

  @override
  String get reportSectionExpenses => 'VÝDAVKY';

  @override
  String get noneInPeriod => 'V tomto období nič.';

  @override
  String fixedCostCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fixných nákladov',
      few: '$count fixné náklady',
      one: '1 fixný náklad',
    );
    return '$_temp0';
  }

  @override
  String expenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výdavkov',
      few: '$count výdavky',
      one: '1 výdavok',
    );
    return '$_temp0';
  }

  @override
  String get noItemsInPeriod => 'V tomto období nie sú žiadne položky';

  @override
  String get importTitle => 'Importovať výdavky';

  @override
  String get importStep1Title => 'Stiahnuť šablónu';

  @override
  String get importStep1Description =>
      'Získajte oficiálnu Excel šablónu so všetkými povinnými stĺpcami a návodom na platné hodnoty.';

  @override
  String get importStep1Button => 'Stiahnuť šablónu';

  @override
  String get importStep2Title => 'Vyplniť a importovať';

  @override
  String get importStep2Description =>
      'Vyplňte šablónu v Exceli alebo Google Sheets a potom tu vyberte súbor na import výdavkov.';

  @override
  String get importStep2Button => 'Vybrať súbor (.xlsx alebo .csv)';

  @override
  String get importInfoText =>
      'Importovať je možné iba výdavky. Príjmy a položky plánu nie sú podporované.\n\nPodporované formáty: .xlsx (Excel) a .csv.\nCSV súbory musia mať rovnaké poradie stĺpcov ako šablóna: Dátum, Suma, Kategória, Finančný typ, Poznámka, Skupina.\n\nSúbory exportované z tejto aplikácie je možné importovať priamo.';

  @override
  String importReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výdavkov pripravených na import',
      few: '$count výdavky pripravené na import',
      one: '1 výdavok pripravený na import',
    );
    return '$_temp0';
  }

  @override
  String importErrorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count riadkov sa nepodarilo načítať',
      few: '$count riadky sa nepodarilo načítať',
      one: '1 riadok sa nepodarilo načítať',
    );
    return '$_temp0';
  }

  @override
  String importErrorCountSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count riadkov sa nepodarilo načítať — budú preskočené',
      few: '$count riadky sa nepodarilo načítať — budú preskočené',
      one: '1 riadok sa nepodarilo načítať — bude preskočený',
    );
    return '$_temp0';
  }

  @override
  String get importNoDataFound => 'V súbore sa nenašli žiadne dáta.';

  @override
  String get importTapToEdit =>
      'Ťuknite na ľubovoľný riadok a pred importom ho upravte alebo odstráňte.';

  @override
  String get importRowsWithErrors => 'Riadky s chybami';

  @override
  String get importNoDataRows => 'Nenašli sa žiadne dátové riadky.';

  @override
  String importConfirmButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importovať $count výdavkov',
      few: 'Importovať $count výdavky',
      one: 'Importovať 1 výdavok',
    );
    return '$_temp0';
  }

  @override
  String importSuccessMessage(int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výdavkov importovaných · $range',
      few: '$count výdavky importované · $range',
      one: '1 výdavok importovaný · $range',
    );
    return '$_temp0';
  }

  @override
  String get importUnsupportedFile =>
      'Nepodporovaný typ súboru. Vyberte prosím súbor .xlsx alebo .csv.';

  @override
  String get importCouldNotReadFile =>
      'Súbor sa nepodarilo načítať. Skúste to znova.';

  @override
  String importPickerError(Object error) {
    return 'Nepodarilo sa otvoriť výber súboru: $error';
  }

  @override
  String importTemplateError(Object error) {
    return 'Nepodarilo sa vygenerovať šablónu: $error';
  }

  @override
  String get tryAnotherFile => 'Skúsiť iný súbor';

  @override
  String get savesTitle => 'Uloženia';

  @override
  String get sectionAutoBackup => 'AUTOMATICKÁ ZÁLOHA';

  @override
  String get sectionSaves => 'ULOŽENIA';

  @override
  String get sectionDataTransfer => 'PRENOS DÁT';

  @override
  String get sectionDataDeletion => 'ODSTRÁNENIE DÁT';

  @override
  String get exportAllData => 'Exportovať všetky dáta';

  @override
  String get importAllData => 'Importovať všetky dáta';

  @override
  String get deleteAllData => 'Odstrániť všetky dáta';

  @override
  String get emptySlot => 'Prázdny slot';

  @override
  String savedConfirmation(String name) {
    return '„$name“ bolo uložené.';
  }

  @override
  String loadedConfirmation(String name) {
    return '„$name“ bolo načítané.';
  }

  @override
  String exportFailed(Object error) {
    return 'Export zlyhal: $error';
  }

  @override
  String importFailedInvalid(Object error) {
    return 'Neplatný súbor: $error';
  }

  @override
  String get importDataSuccess => 'Dáta boli úspešne importované.';

  @override
  String get couldNotReadSelectedFile => 'Vybraný súbor sa nepodarilo načítať.';

  @override
  String get importDataDialogTitle => 'Importovať dáta?';

  @override
  String get importDataDialogContent =>
      'Týmto nahradíte VŠETKY aktuálne výdavky a položky plánu obsahom súboru. Túto akciu nie je možné vrátiť späť.';

  @override
  String get saveName => 'Názov uloženia';

  @override
  String get saveNameCannotBeEmpty => 'Názov nemôže byť prázdny';

  @override
  String replacingLabel(String name) {
    return 'Nahrádza sa: $name';
  }

  @override
  String get loadDialogDescription =>
      'Všetky aktuálne dáta budú nahradené týmto uloženým snapshotom.';

  @override
  String get deleteDialogDescription =>
      'Tento uložený snapshot bude natrvalo odstránený.';

  @override
  String get damagedSaveFile => 'Poškodený súbor uloženia';

  @override
  String overBudgetAmount(String amount) {
    return '$amount nad limit';
  }

  @override
  String underBudgetAmount(String amount) {
    return 'Zostáva $amount';
  }

  @override
  String spentLabel(String amount) {
    return 'Minuté: $amount';
  }

  @override
  String budgetLabel(String amount) {
    return 'Rozpočet: $amount';
  }

  @override
  String progressBarLabel(String spent, String budget) {
    return '$spent minuté  /  $budget rozpočet';
  }

  @override
  String categoryBudgetOverBy(String category, String amount) {
    return 'Rozpočet $category: prekročený o $amount';
  }

  @override
  String get deleteAllDataDialogTitle => 'Odstrániť všetky dáta?';

  @override
  String get deleteAllDataDialogContent =>
      'Týmto natrvalo odstránite všetky výdavky, príjmy a položky plánu. Túto akciu nie je možné vrátiť späť.';

  @override
  String get deleteAllDataConfirm => 'Odstrániť všetko';

  @override
  String get monthJanuary => 'Január';

  @override
  String get monthFebruary => 'Február';

  @override
  String get monthMarch => 'Marec';

  @override
  String get monthApril => 'Apríl';

  @override
  String get monthMay => 'Máj';

  @override
  String get monthJune => 'Jún';

  @override
  String get monthJuly => 'Júl';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'Október';

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
  String get monthAbbrMay => 'Máj';

  @override
  String get monthAbbrJun => 'Jún';

  @override
  String get monthAbbrJul => 'Júl';

  @override
  String get monthAbbrAug => 'Aug';

  @override
  String get monthAbbrSep => 'Sep';

  @override
  String get monthAbbrOct => 'Okt';

  @override
  String get monthAbbrNov => 'Nov';

  @override
  String get monthAbbrDec => 'Dec';

  @override
  String get categoryHousing => 'Bývanie';

  @override
  String get categoryGroceries => 'Potraviny';

  @override
  String get categoryVacation => 'Dovolenka';

  @override
  String get categoryTransport => 'Doprava';

  @override
  String get categoryInsurance => 'Poistenie';

  @override
  String get categorySubscriptions => 'Predplatné';

  @override
  String get categoryCommunication => 'Komunikácia';

  @override
  String get categoryHealth => 'Zdravie';

  @override
  String get categoryRestaurants => 'Reštaurácie';

  @override
  String get categoryEntertainment => 'Zábava';

  @override
  String get categoryElectronics => 'Elektronika';

  @override
  String get categoryClothing => 'Oblečenie';

  @override
  String get categoryEducation => 'Vzdelávanie';

  @override
  String get categoryInvestment => 'Investície';

  @override
  String get categoryGifts => 'Dary';

  @override
  String get categoryTaxes => 'Dane';

  @override
  String get categoryMedications => 'Lieky';

  @override
  String get categoryUtilities => 'Energie a služby';

  @override
  String get categoryHousehold => 'Potreby domácnosti';

  @override
  String get categoryPersonalCare => 'Osobná starostlivosť';

  @override
  String get categorySavings => 'Úspory';

  @override
  String get categoryDebt => 'Dlhy';

  @override
  String get categoryKids => 'Deti';

  @override
  String get categoryPets => 'Domáce zvieratá';

  @override
  String get categoryFees => 'Poplatky';

  @override
  String get categoryFuel => 'Pohonné hmoty';

  @override
  String get categoryMaintenance => 'Údržba';

  @override
  String get categoryDonations => 'Dary';

  @override
  String get categoryOther => 'Ostatné';

  @override
  String get financialTypeAsset => 'Aktíva';

  @override
  String get financialTypeConsumption => 'Spotreba';

  @override
  String get financialTypeInsurance => 'Poistenie';

  @override
  String get addPlanItemTitle => 'Pridať položku plánu';

  @override
  String get addMonthlyIncomeTitle => 'Pridať mesačný príjem';

  @override
  String get addYearlyIncomeTitle => 'Pridať ročný príjem';

  @override
  String get addOneTimeIncomeTitle => 'Pridať jednorazový príjem';

  @override
  String get addMonthlyFixedCostTitle => 'Pridať mesačný fixný náklad';

  @override
  String get addYearlyFixedCostTitle => 'Pridať ročný fixný náklad';

  @override
  String get editMonthlyIncomeTitle => 'Upraviť mesačný príjem';

  @override
  String get editYearlyIncomeTitle => 'Upraviť ročný príjem';

  @override
  String get editOneTimeIncomeTitle => 'Upraviť jednorazový príjem';

  @override
  String get editMonthlyFixedCostTitle => 'Upraviť mesačný fixný náklad';

  @override
  String get editYearlyFixedCostTitle => 'Upraviť ročný fixný náklad';

  @override
  String get labelType => 'Typ';

  @override
  String get labelMonth => 'Mesiac';

  @override
  String get labelYear => 'Rok';

  @override
  String get labelDayOfMonth => 'Deň v mesiaci';

  @override
  String get nameHintText => 'napr. Výplata, Nájom, Poistenie';

  @override
  String get validationEnterName => 'Zadajte názov';

  @override
  String get selectMonthTitle => 'Vybrať mesiac';

  @override
  String get lastRenewalYearTitle => 'Rok posledného obnovenia';

  @override
  String lastMonthRenewal(String monthName) {
    return 'Posledné obnovenie v mesiaci $monthName';
  }

  @override
  String lastActiveMonthInfo(String label) {
    return 'Posledný aktívny mesiac: $label';
  }

  @override
  String get setEndDate => 'Nastaviť koncový dátum';

  @override
  String untilLabel(String validToLabel) {
    return 'Do: $validToLabel';
  }

  @override
  String lastActiveMonthNote(String label) {
    return '$label je posledný aktívny mesiac.';
  }

  @override
  String get endMonthAfterStart =>
      'Koncový mesiac musí byť po začiatočnom mesiaci.';

  @override
  String get fromFieldLabel => 'Od';

  @override
  String renewedEachMonth(String monthName) {
    return 'Obnovuje sa každý $monthName. Dátumy sú pevné.';
  }

  @override
  String get untilFieldLabel => 'Do';

  @override
  String lastActiveMonthParens(String label) {
    return '$label (posledný aktívny mesiac)';
  }

  @override
  String get openEnded => 'Bez ukončenia';

  @override
  String fromDateLabel(String validFromLabel) {
    return 'Od: $validFromLabel';
  }

  @override
  String get samePeriodInPlace =>
      'Rovnaký mesiac ako pôvodný — aktualizuje sa na mieste.';

  @override
  String get differentPeriodNewVersion =>
      'Iný mesiac — vytvorí sa nová verzia.';

  @override
  String get applyChangesToTitle => 'Použiť zmeny na...';

  @override
  String get applyToWholeSeries => 'Celú sériu';

  @override
  String applyToWholeSeriesSubtitle(String seriesStartLabel) {
    return 'Všetky obdobia od $seriesStartLabel';
  }

  @override
  String applyFromOnwards(String nextLabel) {
    return 'Od $nextLabel ďalej';
  }

  @override
  String applyFromSubtitle(String capLabel, String nextLabel) {
    return 'Pôvodná séria končí $capLabel.\nNová séria začína $nextLabel.';
  }

  @override
  String get applyFromUnavailable =>
      'V tejto sérii nie je dostupné žiadne budúce obdobie.';

  @override
  String get yearlyItemsOnlyAtRenewal =>
      'Ročné položky je možné meniť iba v mesiaci ich obnovenia.';

  @override
  String get guardRemindMe => 'Pripomeň mi potvrdiť túto platbu';

  @override
  String get guardShorterMonths => 'Kratšie mesiace použijú svoj posledný deň.';

  @override
  String get dueDayMonthly => 'Deň splatnosti (opakovať každý mesiac)';

  @override
  String dueDayYearly(String monthName) {
    return 'Deň splatnosti (opakovať každý $monthName)';
  }

  @override
  String dueDayMonthlyLabel(int day) {
    return '$day. deň každého mesiaca';
  }

  @override
  String dueDayYearlyLabel(int day, String monthName) {
    return '$day. deň v mesiaci $monthName každý rok';
  }

  @override
  String get guardDailyReminder => 'Denná pripomienka';

  @override
  String get guardChangeNotifTime => 'Ťuknite pre zmenu času notifikácie';

  @override
  String get guardNoGuardedItemsHint =>
      'Zapnite GUARD na fixnom náklade, aby ste mohli sledovať platby.';

  @override
  String guardedItemsCount(int count) {
    return 'Sledované položky · $count';
  }

  @override
  String get planItemTitle => 'Položka plánu';

  @override
  String get activeFrom => 'Aktívne od';

  @override
  String get activeUntil => 'Aktívne do';

  @override
  String get perMonth => '/ mesiac';

  @override
  String get perYear => '/ rok';

  @override
  String get oneTimeSuffix => '(jednorazovo)';

  @override
  String get noEndDate => 'Bez koncového dátumu';

  @override
  String get guardNotEnabled => 'Nie je zapnuté';

  @override
  String removeIncomeEntirely(String name) {
    return '„$name“ bude odstránený úplne.';
  }

  @override
  String removeIncomeFromOnwards(String name, String from, String prev) {
    return '„$name“ sa zastaví od $from. $prev a skoršie obdobia zostanú naplánované.';
  }

  @override
  String get actionRemoveAllCaps => 'ODSTRÁNIŤ';

  @override
  String get removeBudgetAllCaps => 'ODSTRÁNIŤ ROZPOČET';

  @override
  String removeFromOnwardsTitle(String label) {
    return 'Od $label ďalej';
  }

  @override
  String removeCycleSubtitle(String start, String end) {
    return 'Tento cyklus ($start – $end) a všetky budúce cykly budú odstránené.';
  }

  @override
  String removeHistoryKept(String prev) {
    return 'História do $prev zostane zachovaná.';
  }

  @override
  String get silenceReminderTitle => 'Stíšiť túto pripomienku?';

  @override
  String silenceReminderBody(String periodLabel) {
    return 'Platba za obdobie $periodLabel bude stále zobrazená ako nepotvrdená. Kedykoľvek ju môžete označiť ako zaplatenú.';
  }

  @override
  String get yesSilence => 'Áno, stíšiť';

  @override
  String get addPlanItemTooltip => 'Pridať položku plánu';

  @override
  String get spendableThisMonth => 'Na míňanie tento mesiac';

  @override
  String get spendableThisYear => 'Na míňanie tento rok';

  @override
  String get noPlanItemsYet => 'Zatiaľ nie sú žiadne položky plánu.';

  @override
  String get tapPlusToAddPlanItems =>
      'Ťuknite na + a pridajte príjem alebo fixné náklady.';

  @override
  String get removeWholeSeries => 'Celú sériu';

  @override
  String removeWholeSeriesSubtitle(String seriesStartLabel) {
    return 'Všetky obdobia od $seriesStartLabel budú odstránené.';
  }

  @override
  String get clearAllDataAction => 'VYMAZAŤ';

  @override
  String get clearAllDataDescription =>
      'Výdavky, položky plánu, rozpočty a platby GUARD budú natrvalo odstránené. Túto akciu nie je možné vrátiť späť.';

  @override
  String get clearAllDataPreservedNote =>
      'Uložené snapshoty a automatické zálohy nebudú ovplyvnené.';

  @override
  String get allCategoriesBudgeted =>
      'Všetky kategórie už majú na tento mesiac nastavený rozpočet. Vyberte iný mesiac, ak chcete pridať ďalší.';

  @override
  String get selectCategoryHint => 'Vyberte kategóriu';

  @override
  String get validationSelectCategory => 'Vyberte kategóriu';

  @override
  String get monthlyBudgetLabel => 'Mesačný rozpočet';

  @override
  String effectiveFromLabel(String validFromLabel) {
    return 'Platné od: $validFromLabel';
  }

  @override
  String pastMonthBudgetCreateWarning(String fromLabel) {
    return 'Vytvárate rozpočet pre minulý mesiac. Bude platiť spätne od $fromLabel.';
  }

  @override
  String pastMonthBudgetEditWarning(
    String catName,
    String fromLabel,
    String prevLabel,
  ) {
    return 'Týmto zmeníte rozpočet kategórie $catName späť na $fromLabel. Mesiace $fromLabel–$prevLabel použijú novú sumu.';
  }

  @override
  String get noFixedCostsPlanned => 'Nie sú naplánované fixné náklady';

  @override
  String get noIncomePlanned => 'Nie je naplánovaný príjem';

  @override
  String saveSlotSubtitle(String date, int expenseCount, int planItemCount) {
    return '$date · $expenseCount výdavkov · $planItemCount položiek plánu';
  }

  @override
  String get saveSlotDamagedSubtitle => 'Súbor je poškodený a nedá sa načítať';

  @override
  String get howGroupsWorkTitle => 'Ako to funguje?';

  @override
  String get howGroupsTitle => 'Skupiny';

  @override
  String get howGroupsSubtitle0 => 'Čo je skupina a ako funguje';

  @override
  String get howGroupsSubtitle1 => 'Ako z nej vyťažiť čo najviac';

  @override
  String get howGroupsSubtitle2 => 'Kde sa skupiny v aplikácii zobrazujú';

  @override
  String get howGroupsLabel0 => 'Štítok';

  @override
  String get howGroupsLabel1 => 'Buďte kreatívni';

  @override
  String get howGroupsLabel2 => 'Prehľad';

  @override
  String get howGroupsRule1 =>
      'Skupina je voliteľný textový štítok, ktorý môžete priradiť ku každému výdavku.';

  @override
  String get howGroupsRule2 =>
      'Môžete zadať ľubovoľný text — neexistuje pevný zoznam ani validácia.';

  @override
  String get howGroupsRule3 =>
      'Dva výdavky patria do rovnakej skupiny len vtedy, keď sa ich názvy zhodujú presne, znak po znaku.';

  @override
  String get howGroupsRule4 =>
      'Rozlišuje sa veľkosť písmen — „Trip“ a „trip“ sú dve odlišné skupiny.';

  @override
  String get howGroupsRule5 =>
      'Pole je voliteľné. Ak ho necháte prázdne, výdavok jednoducho nebude mať skupinu.';

  @override
  String get howGroupsHint =>
      'Skupinu nastavíte pri vytváraní alebo úprave ľubovoľného výdavku.';

  @override
  String get howGroupsUseIntro =>
      'Použite ju vždy, keď chcete sledovať výsek výdavkov, ktorý sa tiahne naprieč kategóriami.';

  @override
  String howGroupsExample1Label(int year) {
    return 'Barcelona $year';
  }

  @override
  String get howGroupsExample1Desc =>
      'Priraďte ho ku všetkým výdavkom na výlete — letenky, hotely, jedlá, vstupy. Celkovú cenu celého výletu uvidíte na jedno ťuknutie.';

  @override
  String howGroupsExample2Label(int year) {
    return 'McDonald\'\'s $year';
  }

  @override
  String get howGroupsExample2Desc =>
      'Používajte počas celého roka rovnaký názov. Na konci roka presne uvidíte, koľko ste minuli na tomto jednom mieste.';

  @override
  String get howGroupsExample3Label => 'Rekonštrukcia domu Q1';

  @override
  String get howGroupsExample3Desc =>
      'Používajte rovnaký názov naprieč viacerými mesiacmi. Karta Skupiny zhromaždí všetko pod týmto názvom.';

  @override
  String get howGroupsPrecision =>
      'Čím presnejší názov zadáte, tým užitočnejší bude výsledný súhrn.';

  @override
  String get howGroupsRecord0Title => 'Karta Skupiny vo Výdavkoch';

  @override
  String get howGroupsRecord0Body =>
      'Každá skupina, ktorá má v aktuálnom mesiaci aspoň jeden výdavok, sa tu zobrazí ako jeden riadok s počtom položiek a celkovou sumou. Ťuknite na skupinu a zobrazia sa jednotlivé výdavky, ktoré ju tvoria.';

  @override
  String get howGroupsRecord1Title => 'Mesačný prehľad v Prehľadoch';

  @override
  String get howGroupsRecord1Body =>
      'Keď na obrazovke Prehľady exportujete mesačné PDF, skupiny s výdavkami v danom mesiaci dostanú vlastnú stránku „Skupiny výdavkov“ — každá skupina bude uvedená so svojimi výdavkami, sumami a celkovým súčtom skupiny.';

  @override
  String get howGroupsMonthlyNote =>
      'Skupiny nie sú súčasťou ročného prehľadu — ide o mesačný pohľad.';

  @override
  String get howGroupsExampleGroupName => 'Moja skupina';

  @override
  String get otherCategories => 'Ostatné kategórie';

  @override
  String noCategoryExpenses(String category, String period) {
    return 'Žiadne výdavky kategórie $category\nv období $period.';
  }

  @override
  String guardDueDate(String monthName, int day, int year) {
    return 'Splatné $day. $monthName $year';
  }

  @override
  String get guardNotYetDue => 'Ešte nie je splatné';

  @override
  String guardNextReminder(String label) {
    return 'Ďalšia: $label';
  }

  @override
  String guardLastReminder(String label) {
    return 'Posledná: $label';
  }

  @override
  String get guardChangeDay => 'Zmeniť deň';

  @override
  String get guardRemoveAction => 'Odstrániť GUARD';

  @override
  String get guardMarkUnpaidTitle => 'Označiť ako nezaplatené?';

  @override
  String guardMarkUnpaidBody(String monthName, int year) {
    return 'Týmto odstránite potvrdenie platby za $monthName $year.';
  }

  @override
  String get guardMarkUnpaidAction => 'Označiť ako nezaplatené';

  @override
  String get guardMarkAsPaid => 'Označiť ako zaplatené';

  @override
  String get guardRemoveTitle => 'Odstrániť GUARD?';

  @override
  String guardRemoveBody(String name) {
    return 'GUARD bude vypnutý pre „$name“. Existujúce záznamy o platbách zostanú zachované, ale nové pripomienky sa už nebudú spúšťať.';
  }

  @override
  String get guardRemoveConfirm => 'Odstrániť';

  @override
  String get guardSelectPaidDate => 'Vyberte dátum zaplatenia';

  @override
  String guardPaidOn(String date) {
    return 'Zaplatené $date';
  }

  @override
  String howItWorksStep(int n) {
    return 'KROK $n';
  }

  @override
  String get planSubtitle0 => 'Vaša výplata a pravidelné mesačné záväzky';

  @override
  String get planSubtitle1 => 'Ako sú klasifikované vaše fixné náklady';

  @override
  String get planSubtitle2 => 'Koľko z vášho príjmu zaberá každý typ';

  @override
  String get planSubStep0 => 'Cashflow';

  @override
  String get planSubStep1 => 'Klasifikácia';

  @override
  String get planSubStep2 => 'Rozdelenie';

  @override
  String get howItWorksPlanIncomeBody =>
      'Zadajte svoju výplatu a pravidelné mesačné záväzky — nájom, poistenie, predplatné. Sú to reálne, známe sumy, nie odhady ani ciele.';

  @override
  String get howItWorksTypeConsumptionDesc =>
      'Každodenné výdavky — potraviny, nájom, strava, doprava';

  @override
  String get howItWorksTypeAssetDesc =>
      'Investície a úspory, ktoré časom zvyšujú váš majetok';

  @override
  String get howItWorksTypeInsuranceDesc =>
      'Náklady na ochranu — auto, zdravie a životné poistenie';

  @override
  String get howItWorksFinancialTypesBody =>
      'Každý fixný náklad je označený finančným typom. Vďaka tomu aplikácia ukáže, ako je váš príjem rozdelený medzi spotrebu, úspory a ochranu.';

  @override
  String get howItWorksSpendingVsIncomeTitle => 'Výdavky vs príjem';

  @override
  String get howItWorksSpendingVsIncomeBody =>
      'Karta Plán ukazuje, koľko z vášho príjmu smeruje do každého finančného typu — takže na prvý pohľad vidíte, či míňate, šetríte alebo sa chránite v správnom pomere.';

  @override
  String get expSubtitle0 => 'Váš dostupný rozpočet vypočítaný z Plánu';

  @override
  String get expSubtitle1 => 'Každodenné výdavky, ktoré zaznamenávate';

  @override
  String get expSubtitle2 => 'Zostali ste v rozpočte?';

  @override
  String get subStepBudget => 'Rozpočet';

  @override
  String get subStepSpending => 'Míňanie';

  @override
  String get subStepResult => 'Výsledok';

  @override
  String get howItWorksBudgetBody =>
      'Aplikácia odpočíta fixné náklady od vášho príjmu a výsledok zobrazí tu. Toto číslo nenastavujete ručne — vzniká z vášho Plánu.';

  @override
  String get howItWorksSpendingBody =>
      'Zapisujte potraviny, jedlá, nákupy a ďalšie variabilné výdavky. Fixné mesačné platby ako nájom patria do Plánu, nie sem.';

  @override
  String get howItWorksResultBody =>
      'Na konci mesiaca karta Výdavky ukáže, aký výsledok ste dosiahli.';

  @override
  String get repSubtitle0 => 'Kam odišli vaše peniaze?';

  @override
  String get repSubtitle1 => 'Vaše financie na papieri';

  @override
  String get repSubtitle2 => 'Veľký obraz, mesiac po mesiaci';

  @override
  String get repSubStep0 => 'Rozpis';

  @override
  String get repSubStep1 => 'Export';

  @override
  String get repSubStep2 => 'Prehľad';

  @override
  String get howItWorksBreakdownBody =>
      'Rozpis ukazuje vaše výdavky podľa kategórií za ľubovoľný mesiac alebo rok. Ťuknite na výsek grafu alebo riadok kategórie a zobrazia sa jednotlivé výdavky a fixné náklady, ktoré za tým stoja.';

  @override
  String get pdfFeatureCategoryTotals => 'Súčty kategórií';

  @override
  String get pdfFeatureBudgetVsActual => 'Rozpočet vs skutočnosť';

  @override
  String get pdfFeatureTypeSplit => 'Rozdelenie podľa finančných typov';

  @override
  String get pdfFeatureAllExpenses => 'Všetky výdavky v zozname';

  @override
  String get pdfFeatureCategoryBudgets => 'Rozpočty kategórií';

  @override
  String get pdfFeatureGroupSummaries => 'Súhrny skupín';

  @override
  String get pdfFeature12MonthOverview => '12-mesačný prehľad';

  @override
  String get pdfFeatureAnnualTotals => 'Ročné súčty';

  @override
  String get pdfFeatureMonthlyBreakdown => 'Mesačný rozpis';

  @override
  String get pdfFeaturePlanVsActual => 'Plán vs skutočnosť';

  @override
  String get pdfFeatureTypeRatios => 'Pomery finančných typov';

  @override
  String get pdfFeatureActivePlanItems => 'Aktívne položky plánu';

  @override
  String get howItWorksExportBody =>
      'Na export použite tlačidlo PDF v Rozpise. Prehľady môžete zdieľať cez akúkoľvek aplikáciu vo svojom zariadení.';

  @override
  String get howItWorksMoreMonths => '· · · 9 ďalších mesiacov';

  @override
  String get howItWorksOverviewBody =>
      'Prehľad zobrazuje všetkých 12 mesiacov vedľa seba — koľko ste zarobili, koľko išlo do aktív a koľko sa spotrebovalo. Ťuknite na ľubovoľný mesiac a preskočíte do tohto obdobia v Pláne.';

  @override
  String overBudgetBy(String amount) {
    return 'Nad rozpočet o $amount';
  }

  @override
  String savedAmount(String amount) {
    return 'Ušetrené $amount';
  }

  @override
  String get loadingLabel => 'Načítava sa…';

  @override
  String get autoBackupTitle => 'Automatická záloha';

  @override
  String get autoBackupNoBackupYet => 'Zatiaľ žiadna záloha';

  @override
  String get autoBackupSubtitleExpand =>
      'Aktualizované denne · ťuknite pre rozbalenie';

  @override
  String get autoBackupSubtitleCollapse =>
      'Aktualizované denne · ťuknite pre zbalenie';

  @override
  String get actionRestoreAllCaps => 'OBNOVIŤ';

  @override
  String get actionRestore => 'Obnoviť';

  @override
  String get autoBackupRestoreDescription =>
      'Obnovením nahradíte všetky aktuálne dáta obsahom zálohy.';

  @override
  String autoBackupRestored(String date) {
    return 'Záloha z $date bola obnovená.';
  }

  @override
  String get autoBackupRestoreFailed => 'Obnovenie zálohy zlyhalo.';

  @override
  String get autoBackupPrimary => 'Primárna záloha';

  @override
  String get autoBackupSecondary => 'Sekundárna záloha';

  @override
  String get frequencyPickerFixed => 'Ako často sa opakuje?';

  @override
  String get frequencyMonthlyFixedSubtitle =>
      'Nájom, predplatné, pravidelné účty';

  @override
  String get frequencyYearlyFixedSubtitle =>
      'Ročné predplatné, poistenie, členstvá';

  @override
  String get frequencyPickerIncome => 'Ako často ho dostávate?';

  @override
  String get frequencyMonthlyIncomeSubtitle =>
      'Výplata, dôchodok, pravidelné prevody';

  @override
  String get frequencyYearlyIncomeSubtitle =>
      'Ročný bonus, daňový preplatok, dividendy';

  @override
  String get frequencyOneTimeIncomeSubtitle =>
      'Dar, neočakávaný príjem, jednorazová platba';

  @override
  String get typePickerTitle => 'Čo pridávate?';

  @override
  String get typeIncomeSubtitle => 'Výplata, bonus, dôchodok, dary';

  @override
  String get typeFixedCostSubtitle => 'Nájom, poistenie, predplatné';

  @override
  String get languagePickerTitle => 'Jazyk';

  @override
  String get currencyPickerTitle => 'Mena';

  @override
  String get currencyCustom => 'Vlastná';

  @override
  String get currencyCustomSubtitle => 'Definujte vlastný kód a symbol';

  @override
  String get currencyCustomTitle => 'Vlastná mena';

  @override
  String get currencyCodeLabel => 'Kód';

  @override
  String get currencyCodeHint => 'napr. USD';

  @override
  String get currencySymbolLabel => 'Symbol';

  @override
  String get currencySymbolHint => 'napr. \$';

  @override
  String get removeFromImport => 'Odstrániť z importu';

  @override
  String get exportExpensesTitle => 'Exportovať výdavky';

  @override
  String get selectDateRangeHint => 'Vyberte dátumový rozsah na export:';

  @override
  String get startDateLabel => 'Dátum od';

  @override
  String get endDateLabel => 'Dátum do';

  @override
  String get tapToSelectDate => 'Ťuknite pre výber';

  @override
  String get endDateAfterStart =>
      'Koncový dátum musí byť rovnaký alebo neskorší ako začiatočný dátum.';

  @override
  String get actionExport => 'Exportovať';

  @override
  String overspendWarning(String period, String amount) {
    return 'V tomto $period ste minuli o $amount viac, než ste zarobili!';
  }

  @override
  String get periodMonth => 'mesiaci';

  @override
  String get periodYear => 'roku';

  @override
  String guardBannerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'GUARD — $count nepotvrdených platieb',
      few: 'GUARD — $count nepotvrdené platby',
      one: 'GUARD — 1 nepotvrdená platba',
    );
    return '$_temp0';
  }

  @override
  String get guardSilencedBadge => 'stíšené';

  @override
  String guardExpenseStripPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sledovaných platieb čaká',
      few: '$count sledované platby čakajú',
      one: '1 sledovaná platba čaká',
    );
    return '$_temp0';
  }

  @override
  String importErrorRowLabel(int row, String field) {
    return 'Riadok $row — $field';
  }

  @override
  String earnedLabel(String amount) {
    return 'Zarobené: $amount';
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
  String get guardEnableToggle => 'Zapnúť GUARD';

  @override
  String get guardEnableToggleSubtitle =>
      'Sledovať platbu a dostávať pripomienky';

  @override
  String get actionOk => 'OK';

  @override
  String get labelTotal => 'Spolu';

  @override
  String get categoryBudgetsTitle => 'Rozpočty kategórií';

  @override
  String get noCategoryBudgetsSet =>
      'Nie sú nastavené žiadne rozpočty kategórií.';

  @override
  String removeBudgetDialogTitle(String category) {
    return 'Odstrániť rozpočet kategórie $category';
  }

  @override
  String endBudgetFromTitle(String from) {
    return 'Ukončiť od $from';
  }

  @override
  String endBudgetFromDescription(String from) {
    return 'Ukončí rozpočet od $from ďalej. Predchádzajúce mesiace si ponechajú historický rozpočet.';
  }

  @override
  String get deleteBudgetSeriesTitle => 'Odstrániť celú sériu';

  @override
  String get deleteBudgetSeriesConfirm => 'Odstrániť sériu';

  @override
  String deleteBudgetSeriesDescription(String range) {
    return 'Natrvalo odstráni všetky záznamy ($range). V žiadnom mesiaci tejto série sa už rozpočet nezobrazí. Túto akciu nie je možné vrátiť späť.';
  }

  @override
  String budgetRangePresent(String start) {
    return '$start – súčasnosť';
  }

  @override
  String get pdfMonthlyReport => 'Mesačný prehľad';

  @override
  String get pdfYearlyReport => 'Ročný prehľad';

  @override
  String pdfMonthlyReportHeader(String month, int year) {
    return 'MESAČNÝ PREHĽAD ZA $month $year';
  }

  @override
  String pdfYearlyReportHeader(int year) {
    return 'ROČNÝ PREHĽAD ZA $year';
  }

  @override
  String get pdfPartialYear => '(čiastočný rok)';

  @override
  String get pdfSectionSpendingVsIncome => 'VÝDAVKY VS PRÍJEM';

  @override
  String get pdfSectionCategorySummary => 'SÚHRN KATEGÓRIÍ';

  @override
  String get pdfSectionCashFlowSummary => 'SÚHRN CASH FLOW';

  @override
  String get pdfSectionExpenseGroups => 'SKUPINY VÝDAVKOV';

  @override
  String get pdfSectionExpenseDetails => 'DETAILY VÝDAVKOV';

  @override
  String get pdfSectionYearlyOverview => 'ROČNÝ PREHĽAD';

  @override
  String get pdfSectionSpendingByCategory =>
      'VÝDAVKY PODĽA KATEGÓRIÍ A MESIACOV';

  @override
  String get pdfIncomeHeader => 'PRÍJEM';

  @override
  String get pdfFixedCostsHeader => 'FIXNÉ NÁKLADY';

  @override
  String get pdfTotal => 'SPOLU';

  @override
  String get pdfColTotal => 'Spolu';

  @override
  String get pdfEarnedThisMonth => 'Zarobené tento mesiac';

  @override
  String get pdfEarnedThisYear => 'Zarobené tento rok';

  @override
  String get pdfGroupTotal => 'Súčet skupiny (tento mesiac)';

  @override
  String get pdfAllPeriodsTotal => 'Súčet za všetky obdobia';

  @override
  String pdfItemsThisMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count položiek tento mesiac',
      few: '$count položky tento mesiac',
      one: '1 položka tento mesiac',
    );
    return '$_temp0';
  }

  @override
  String get pdfNormalized => ' (normalizované)';

  @override
  String get pdfAnnualized => ' (prepočítané na rok)';

  @override
  String get pdfPartialYearNote =>
      'Čiastočný rok - mesiace bez dát zobrazujú nuly. Sú uvedené len priebežné súčty od začiatku roka.';

  @override
  String pdfPage(int page, int total) {
    return 'Strana $page z $total';
  }

  @override
  String get pdfNoData => 'Žiadne dáta.';

  @override
  String get howItWorksExampleSalary => 'Výplata';

  @override
  String get howItWorksExampleBonus => 'Bonus';

  @override
  String get howItWorksExampleRent => 'Nájom';

  @override
  String get howItWorksExampleInsurance => 'Poistenie';

  @override
  String get howItWorksExampleEtfFonds => 'ETF fondy';

  @override
  String get addBudgetTooltip => 'Pridať rozpočet';

  @override
  String get selectCategoryTitle => 'Vybrať kategóriu';

  @override
  String get showAllCategories => 'Zobraziť všetky kategórie';

  @override
  String get showLessCategories => 'Zobraziť menej';

  @override
  String get allCategoriesTitle => 'Všetky kategórie';
}
