// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appTitle => 'Finance Tracker';

  @override
  String get welcomeTagline => 'Vedd kézbe a pénzügyeid irányítását';

  @override
  String get getStarted => 'Kezdés';

  @override
  String get tabExpenses => 'Kiadások';

  @override
  String get tabPlan => 'Terv';

  @override
  String get tabReports => 'Jelentések';

  @override
  String get actionEdit => 'Szerkesztés';

  @override
  String get actionDelete => 'Törlés';

  @override
  String get actionSave => 'Mentés';

  @override
  String get actionCancel => 'Mégse';

  @override
  String get actionLoad => 'Betöltés';

  @override
  String get actionImport => 'Importálás';

  @override
  String get actionOverwrite => 'Felülírás';

  @override
  String get labelAmount => 'Összeg';

  @override
  String get labelCategory => 'Kategória';

  @override
  String get labelFinancialType => 'Pénzügyi típus';

  @override
  String get labelDate => 'Dátum';

  @override
  String get labelNote => 'Megjegyzés';

  @override
  String get labelNoteOptional => 'Megjegyzés (opcionális)';

  @override
  String get labelGroup => 'Csoport';

  @override
  String get labelGroupOptional => 'Csoport (opcionális)';

  @override
  String get groupHintText => 'pl. Nyaralás, Születésnap';

  @override
  String get labelName => 'Név';

  @override
  String get labelFrequency => 'Gyakoriság';

  @override
  String get labelValidFrom => 'Érvényes ettől';

  @override
  String get labelValidTo => 'Érvényes eddig (opcionális)';

  @override
  String get menuImportExpenses => 'Kiadások importálása';

  @override
  String get menuExportExpenses => 'Kiadások exportálása';

  @override
  String get menuImport => 'Importálás';

  @override
  String get menuSaves => 'Mentések';

  @override
  String get menuDeleteAll => 'Összes adat törlése';

  @override
  String get menuHowItWorks => 'Hogyan működik';

  @override
  String get menuResetWithDummyData => 'Visszaállítás mintaadatokkal';

  @override
  String get menuManageBudgets => 'Keretek kezelése';

  @override
  String get menuGuard => 'GUARD beállításai';

  @override
  String get expenseListTitle => 'Kiadások';

  @override
  String get savesTooltip => 'Mentések';

  @override
  String get howItWorksTooltip => 'Hogyan működik';

  @override
  String get howItWorksQuestion => 'Hogyan működik?';

  @override
  String get viewModeItems => 'Tételek';

  @override
  String get viewModeByCategory => 'Kategória';

  @override
  String get viewModeByGroup => 'Csoportok';

  @override
  String get thisMonthsBudget => 'E havi keret';

  @override
  String get budgetNotSet => 'Nincs beállítva keret';

  @override
  String get setIncomeInPlan => 'Bevétel beállítása';

  @override
  String noExpensesInMonth(String monthName, int year) {
    return 'Nincs kiadás $monthName $year hónapban.';
  }

  @override
  String get tapPlusToAddOne => 'Koppints a + gombra egy hozzáadásához.';

  @override
  String get fixedBillsHint =>
      'A fix számlák, mint a lakbér, a Tervhez tartoznak.';

  @override
  String get noGroupsThisMonth => 'Ebben a hónapban nincsenek csoportok.';

  @override
  String get addGroupHint =>
      'Adj meg egy csoportot kiadás létrehozásakor\nvagy szerkesztésekor.';

  @override
  String get howGroupsWorkQuestion => 'Hogyan működnek a csoportok?';

  @override
  String get howGuardWorkQuestion => 'Hogyan működik a GUARD?';

  @override
  String get howCategoryBudgetsWorkQuestion =>
      'Hogyan működnek a kategória keretek?';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tétel',
      one: '1 tétel',
    );
    return '$_temp0';
  }

  @override
  String get addExpenseTitle => 'Kiadás hozzáadása';

  @override
  String get editExpenseTitle => 'Kiadás szerkesztése';

  @override
  String get validationAmountEmpty => 'Adj meg összeget';

  @override
  String get validationAmountInvalid => 'Adj meg érvényes pozitív számot';

  @override
  String get expenseDetailTitle => 'Kiadás';

  @override
  String noExpensesInNamedGroup(String name) {
    return 'Nincs kiadás itt: \"$name\".';
  }

  @override
  String get planTitle => 'Terv';

  @override
  String get toggleMonthly => 'Havi';

  @override
  String get toggleYearly => 'Éves';

  @override
  String get sectionIncome => 'Bevétel';

  @override
  String get sectionFixedCosts => 'Fix költségek';

  @override
  String get noIncomeItems => 'Nincsenek bevételi tételek.';

  @override
  String get noFixedCostItems => 'Nincsenek fix költség tételek.';

  @override
  String get spendableBudget => 'Elkölthető keret';

  @override
  String get deleteItemDialogTitle => 'Tervtétel törlése';

  @override
  String get deleteItemFromPeriod => 'Ettől az időszaktól';

  @override
  String get deleteItemWholeSeries => 'Teljes sorozat';

  @override
  String get planItemDeleted => 'A tervtétel törölve.';

  @override
  String get addIncomeTitle => 'Bevétel hozzáadása';

  @override
  String get addFixedCostTitle => 'Fix költség hozzáadása';

  @override
  String get editIncomeTitle => 'Bevétel szerkesztése';

  @override
  String get editFixedCostTitle => 'Fix költség szerkesztése';

  @override
  String get frequencyOneTime => 'Egyszeri';

  @override
  String get frequencyMonthly => 'Havi';

  @override
  String get frequencyYearly => 'Éves';

  @override
  String get guardSectionLabel => 'GUARD';

  @override
  String get guardTrackPayment => 'Fizetés követése';

  @override
  String get guardDueDayLabel => 'Esedékesség napja';

  @override
  String get guardOneTimeLabel => 'Egyszeri fizetés';

  @override
  String get planItemSaved => 'A tervtétel mentve.';

  @override
  String get addNewItemSheetTitle => 'Új hozzáadása';

  @override
  String get typeIncome => 'Bevétel';

  @override
  String get typeFixedCost => 'Fix költség';

  @override
  String get ongoing => 'Folyamatban';

  @override
  String get manageBudgetsTitle => 'Keretek kezelése';

  @override
  String get noBudgetsSet => 'Ehhez az időszakhoz nincs beállított keret.';

  @override
  String get addFirstBudget => 'Add hozzá az első keretedet.';

  @override
  String get addBudgetTitle => 'Keret hozzáadása';

  @override
  String get editBudgetTitle => 'Keret szerkesztése';

  @override
  String get budgetAmount => 'Keret összege';

  @override
  String get effectiveFrom => 'Érvényes ettől';

  @override
  String get pastMonthBudgetWarning =>
      'A múltbeli keret beállítása nem befolyásolja a korábbi költést.';

  @override
  String get budgetSaved => 'A keret mentve.';

  @override
  String get budgetDeleted => 'A keret törölve.';

  @override
  String get guardScreenTitle => 'GUARD';

  @override
  String get guardDailyReminderTime => 'Napi emlékeztető ideje';

  @override
  String get guardTimePicker => 'Napi GUARD emlékeztető ideje';

  @override
  String get guardMarkPaid => 'Fizetettnek jelölés';

  @override
  String get guardSilence => 'Némítás';

  @override
  String get guardStatusPaid => 'Fizetve';

  @override
  String get guardStatusScheduled => 'Ütemezve';

  @override
  String get guardStatusUnpaid => 'Nincs fizetve';

  @override
  String get guardStatusSilenced => 'Némítva';

  @override
  String get noGuardedItems => 'Nincsenek figyelt tételek.';

  @override
  String get reportsTitle => 'Jelentések';

  @override
  String get reportModeMonthly => 'Havi';

  @override
  String get reportModeYearly => 'Éves';

  @override
  String get reportModeOverview => 'Áttekintés';

  @override
  String get exportPdf => 'PDF exportálása';

  @override
  String get noExpensesForPeriod =>
      'Ehhez az időszakhoz nincs rögzített kiadás.';

  @override
  String get noIncomeOrSpendingDataForYear =>
      'Ehhez az évhez nincs bevételi vagy költési adat.';

  @override
  String get pieChartOther => 'Egyéb';

  @override
  String get reportSectionFixedCosts => 'FIX KÖLTSÉGEK';

  @override
  String get reportSectionExpenses => 'KIADÁSOK';

  @override
  String get noneInPeriod => 'Nincs ebben az időszakban.';

  @override
  String fixedCostCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fix költség',
      one: '1 fix költség',
    );
    return '$_temp0';
  }

  @override
  String expenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kiadás',
      one: '1 kiadás',
    );
    return '$_temp0';
  }

  @override
  String get noItemsInPeriod => 'Nincs tétel ebben az időszakban';

  @override
  String get importTitle => 'Kiadások importálása';

  @override
  String get importStep1Title => 'Sablon letöltése';

  @override
  String get importStep1Description =>
      'Szerezd be a hivatalos Excel-sablont minden kötelező oszloppal és az érvényes értékek útmutatójával.';

  @override
  String get importStep1Button => 'Sablon letöltése';

  @override
  String get importStep2Title => 'Kitöltés és import';

  @override
  String get importStep2Description =>
      'Töltsd ki a sablont Excelben vagy Google Táblázatokban, majd válaszd ki itt a fájlt a kiadásaid importálásához.';

  @override
  String get importStep2Button => 'Fájl kiválasztása (.xlsx vagy .csv)';

  @override
  String get importInfoText =>
      'Csak kiadások importálhatók. Bevétel és tervtételek nem támogatottak.\n\nElfogadott formátumok: .xlsx (Excel) és .csv.\nA CSV fájloknak ugyanabban az oszlopsorrendben kell lenniük, mint a sablonnak: Date, Amount, Category, Financial Type, Note, Group.\n\nAz alkalmazásból exportált fájlok közvetlenül is importálhatók.';

  @override
  String importReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kiadás készen áll az importra',
      one: '1 kiadás készen áll az importra',
    );
    return '$_temp0';
  }

  @override
  String importErrorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sort nem sikerült beolvasni',
      one: '1 sort nem sikerült beolvasni',
    );
    return '$_temp0';
  }

  @override
  String importErrorCountSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sort nem sikerült beolvasni — át lesz ugorva',
      one: '1 sort nem sikerült beolvasni — át lesz ugorva',
    );
    return '$_temp0';
  }

  @override
  String get importNoDataFound => 'Nem található adat a fájlban.';

  @override
  String get importTapToEdit =>
      'Koppints bármelyik sorra, hogy importálás előtt szerkeszd vagy eltávolítsd.';

  @override
  String get importRowsWithErrors => 'Hibás sorok';

  @override
  String get importNoDataRows => 'Nem találhatók adatsorok.';

  @override
  String importConfirmButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kiadás importálása',
      one: '1 kiadás importálása',
    );
    return '$_temp0';
  }

  @override
  String importSuccessMessage(int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kiadás importálva · $range',
      one: '1 kiadás importálva · $range',
    );
    return '$_temp0';
  }

  @override
  String get importUnsupportedFile =>
      'Nem támogatott fájltípus. Válassz .xlsx vagy .csv fájlt.';

  @override
  String get importCouldNotReadFile => 'A fájl nem olvasható. Próbáld újra.';

  @override
  String importPickerError(Object error) {
    return 'A fájlválasztó nem nyitható meg: $error';
  }

  @override
  String importTemplateError(Object error) {
    return 'A sablon nem generálható: $error';
  }

  @override
  String get tryAnotherFile => 'Másik fájl kipróbálása';

  @override
  String get savesTitle => 'Mentések';

  @override
  String get sectionAutoBackup => 'AUTOMATIKUS BIZTONSÁGI MENTÉS';

  @override
  String get sectionSaves => 'MENTÉSEK';

  @override
  String get sectionDataTransfer => 'ADATÁTADÁS';

  @override
  String get sectionDataDeletion => 'ADATTÖRLÉS';

  @override
  String get exportAllData => 'Összes adat exportálása';

  @override
  String get importAllData => 'Összes adat importálása';

  @override
  String get deleteAllData => 'Összes adat törlése';

  @override
  String get emptySlot => 'Üres hely';

  @override
  String savedConfirmation(String name) {
    return '\'$name\' mentve.';
  }

  @override
  String loadedConfirmation(String name) {
    return '\'$name\' betöltve.';
  }

  @override
  String exportFailed(Object error) {
    return 'Exportálás sikertelen: $error';
  }

  @override
  String importFailedInvalid(Object error) {
    return 'Érvénytelen fájl: $error';
  }

  @override
  String get importDataSuccess => 'Az adatok importálása sikeres.';

  @override
  String get couldNotReadSelectedFile => 'A kiválasztott fájl nem olvasható.';

  @override
  String get importDataDialogTitle => 'Importálod az adatokat?';

  @override
  String get importDataDialogContent =>
      'Ez a fájl tartalmával lecseréli az ÖSSZES jelenlegi kiadást és tervtételt. Ez nem vonható vissza.';

  @override
  String get saveName => 'Mentés neve';

  @override
  String get saveNameCannotBeEmpty => 'A név nem lehet üres';

  @override
  String replacingLabel(String name) {
    return 'Lecserélve: $name';
  }

  @override
  String get loadDialogDescription =>
      'Minden jelenlegi adatot ez a mentett pillanatkép vált fel.';

  @override
  String get deleteDialogDescription =>
      'Ez a mentett pillanatkép végleg törlődik.';

  @override
  String get damagedSaveFile => 'Sérült mentési fájl';

  @override
  String overBudgetAmount(String amount) {
    return '$amount túllépés';
  }

  @override
  String underBudgetAmount(String amount) {
    return '$amount maradt';
  }

  @override
  String spentLabel(String amount) {
    return 'Elköltve: $amount';
  }

  @override
  String budgetLabel(String amount) {
    return 'Keret: $amount';
  }

  @override
  String progressBarLabel(String spent, String budget) {
    return '$spent elköltve  /  $budget keret';
  }

  @override
  String categoryBudgetOverBy(String category, String amount) {
    return '$category keret: $amount túllépés';
  }

  @override
  String get deleteAllDataDialogTitle => 'Törlöd az összes adatot?';

  @override
  String get deleteAllDataDialogContent =>
      'Ez végleg törli az összes kiadást, bevételt és tervtételt. Ez nem vonható vissza.';

  @override
  String get deleteAllDataConfirm => 'Összes törlése';

  @override
  String get monthJanuary => 'Január';

  @override
  String get monthFebruary => 'Február';

  @override
  String get monthMarch => 'Március';

  @override
  String get monthApril => 'Április';

  @override
  String get monthMay => 'Május';

  @override
  String get monthJune => 'Június';

  @override
  String get monthJuly => 'Július';

  @override
  String get monthAugust => 'Augusztus';

  @override
  String get monthSeptember => 'Szeptember';

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
  String get monthAbbrMar => 'Már';

  @override
  String get monthAbbrApr => 'Ápr';

  @override
  String get monthAbbrMay => 'Máj';

  @override
  String get monthAbbrJun => 'Jún';

  @override
  String get monthAbbrJul => 'Júl';

  @override
  String get monthAbbrAug => 'Aug';

  @override
  String get monthAbbrSep => 'Szept';

  @override
  String get monthAbbrOct => 'Okt';

  @override
  String get monthAbbrNov => 'Nov';

  @override
  String get monthAbbrDec => 'Dec';

  @override
  String get categoryHousing => 'Lakhatás';

  @override
  String get categoryGroceries => 'Élelmiszer';

  @override
  String get categoryVacation => 'Nyaralás';

  @override
  String get categoryTransport => 'Közlekedés';

  @override
  String get categoryInsurance => 'Biztosítás';

  @override
  String get categorySubscriptions => 'Előfizetések';

  @override
  String get categoryCommunication => 'Kommunikáció';

  @override
  String get categoryHealth => 'Egészség';

  @override
  String get categoryRestaurants => 'Éttermek';

  @override
  String get categoryEntertainment => 'Szórakozás';

  @override
  String get categoryElectronics => 'Elektronika';

  @override
  String get categoryClothing => 'Ruházat';

  @override
  String get categoryEducation => 'Oktatás';

  @override
  String get categoryInvestment => 'Befektetés';

  @override
  String get categoryGifts => 'Ajándékok';

  @override
  String get categoryTaxes => 'Adók';

  @override
  String get categoryMedications => 'Gyógyszerek';

  @override
  String get categoryUtilities => 'Közüzemi díjak';

  @override
  String get categoryHousehold => 'Háztartási cikkek';

  @override
  String get categoryPersonalCare => 'Személyes gondozás';

  @override
  String get categorySavings => 'Megtakarítások';

  @override
  String get categoryDebt => 'Adósság';

  @override
  String get categoryKids => 'Gyerekek';

  @override
  String get categoryPets => 'Háziállatok';

  @override
  String get categoryFees => 'Díjak';

  @override
  String get categoryFuel => 'Üzemanyag';

  @override
  String get categoryMaintenance => 'Karbantartás';

  @override
  String get categoryDonations => 'Adományok';

  @override
  String get categoryOther => 'Egyéb';

  @override
  String get financialTypeAsset => 'Eszköz';

  @override
  String get financialTypeConsumption => 'Fogyasztás';

  @override
  String get financialTypeInsurance => 'Biztosítás';

  @override
  String get addPlanItemTitle => 'Tervtétel hozzáadása';

  @override
  String get addMonthlyIncomeTitle => 'Havi bevétel hozzáadása';

  @override
  String get addYearlyIncomeTitle => 'Éves bevétel hozzáadása';

  @override
  String get addOneTimeIncomeTitle => 'Egyszeri bevétel hozzáadása';

  @override
  String get addMonthlyFixedCostTitle => 'Havi fix költség hozzáadása';

  @override
  String get addYearlyFixedCostTitle => 'Éves fix költség hozzáadása';

  @override
  String get editMonthlyIncomeTitle => 'Havi bevétel szerkesztése';

  @override
  String get editYearlyIncomeTitle => 'Éves bevétel szerkesztése';

  @override
  String get editOneTimeIncomeTitle => 'Egyszeri bevétel szerkesztése';

  @override
  String get editMonthlyFixedCostTitle => 'Havi fix költség szerkesztése';

  @override
  String get editYearlyFixedCostTitle => 'Éves fix költség szerkesztése';

  @override
  String get labelType => 'Típus';

  @override
  String get labelMonth => 'Hónap';

  @override
  String get labelYear => 'Év';

  @override
  String get labelDayOfMonth => 'Hónap napja';

  @override
  String get nameHintText => 'pl. Fizetés, Lakbér, Biztosítás';

  @override
  String get validationEnterName => 'Adj meg egy nevet';

  @override
  String get selectMonthTitle => 'Hónap kiválasztása';

  @override
  String get lastRenewalYearTitle => 'Utolsó megújítás éve';

  @override
  String lastMonthRenewal(String monthName) {
    return 'Utolsó $monthName megújítás';
  }

  @override
  String lastActiveMonthInfo(String label) {
    return 'Utolsó aktív hónap: $label';
  }

  @override
  String get setEndDate => 'Záródátum beállítása';

  @override
  String untilLabel(String validToLabel) {
    return 'Eddig: $validToLabel';
  }

  @override
  String lastActiveMonthNote(String label) {
    return '$label az utolsó aktív hónap.';
  }

  @override
  String get endMonthAfterStart =>
      'A záró hónapnak a kezdő hónap után kell lennie.';

  @override
  String get fromFieldLabel => 'Ettől';

  @override
  String renewedEachMonth(String monthName) {
    return 'Minden $monthName-ban megújul. A dátumok rögzítettek.';
  }

  @override
  String get untilFieldLabel => 'Eddig';

  @override
  String lastActiveMonthParens(String label) {
    return '$label (utolsó aktív hónap)';
  }

  @override
  String get openEnded => 'Nyitott végű';

  @override
  String fromDateLabel(String validFromLabel) {
    return 'Ettől: $validFromLabel';
  }

  @override
  String get samePeriodInPlace =>
      'Ugyanaz a hónap, mint az eredeti — helyben frissül.';

  @override
  String get differentPeriodNewVersion => 'Másik hónap — új verzió jön létre.';

  @override
  String get applyChangesToTitle => 'Mire alkalmazod a módosításokat...';

  @override
  String get applyToWholeSeries => 'Teljes sorozatra';

  @override
  String applyToWholeSeriesSubtitle(String seriesStartLabel) {
    return 'Minden időszak $seriesStartLabel időponttól kezdve';
  }

  @override
  String applyFromOnwards(String nextLabel) {
    return '$nextLabel időponttól kezdve';
  }

  @override
  String applyFromSubtitle(String capLabel, String nextLabel) {
    return 'Az eredeti sorozat $capLabel időpontban ér véget.\nAz új sorozat $nextLabel időpontban indul.';
  }

  @override
  String get applyFromUnavailable =>
      'Ebben a sorozatban nincs elérhető jövőbeli időszak.';

  @override
  String get yearlyItemsOnlyAtRenewal =>
      'Az éves tételek csak a megújulási hónapjukban módosíthatók.';

  @override
  String get guardRemindMe => 'Emlékeztess, hogy megerősítsem ezt a fizetést';

  @override
  String get guardShorterMonths =>
      'A rövidebb hónapok az utolsó napjukat fogják használni.';

  @override
  String get dueDayMonthly => 'Esedékesség napja (havonta ismétlődik)';

  @override
  String dueDayYearly(String monthName) {
    return 'Esedékesség napja (minden $monthName hónapban ismétlődik)';
  }

  @override
  String dueDayMonthlyLabel(int day) {
    return 'Minden hónap $day. napja';
  }

  @override
  String dueDayYearlyLabel(int day, String monthName) {
    return '$monthName $day. napja minden évben';
  }

  @override
  String get guardDailyReminder => 'Napi emlékeztető';

  @override
  String get guardChangeNotifTime =>
      'Koppints az értesítés idejének módosításához';

  @override
  String get guardNoGuardedItemsHint =>
      'Kapcsold be a GUARD-ot egy fix költségnél a fizetések követéséhez.';

  @override
  String guardedItemsCount(int count) {
    return 'Figyelt tételek · $count';
  }

  @override
  String get planItemTitle => 'Tervtétel';

  @override
  String get activeFrom => 'Aktív ettől';

  @override
  String get activeUntil => 'Aktív eddig';

  @override
  String get perMonth => '/ hó';

  @override
  String get perYear => '/ év';

  @override
  String get oneTimeSuffix => '(egyszeri)';

  @override
  String get noEndDate => 'Nincs záródátum';

  @override
  String get guardNotEnabled => 'Nincs bekapcsolva';

  @override
  String removeIncomeEntirely(String name) {
    return '\"$name\" teljesen el lesz távolítva.';
  }

  @override
  String removeIncomeFromOnwards(String name, String from, String prev) {
    return '\"$name\" $from időponttól megszűnik. $prev és a korábbi időszakok tervezve maradnak.';
  }

  @override
  String get actionRemoveAllCaps => 'ELTÁVOLÍT';

  @override
  String get removeBudgetAllCaps => 'KÖLTSÉGKERET ELTÁVOLÍTÁSA';

  @override
  String removeFromOnwardsTitle(String label) {
    return '$label időponttól kezdve';
  }

  @override
  String removeCycleSubtitle(String start, String end) {
    return 'Ez a ciklus ($start – $end) és minden jövőbeli ciklus eltávolításra kerül.';
  }

  @override
  String removeHistoryKept(String prev) {
    return 'A történet megmarad $prev időpontig.';
  }

  @override
  String get silenceReminderTitle => 'Némítod ezt az emlékeztetőt?';

  @override
  String silenceReminderBody(String periodLabel) {
    return 'A(z) $periodLabel fizetés továbbra is megerősítetlenként fog megjelenni. Bármikor fizetettnek jelölheted.';
  }

  @override
  String get yesSilence => 'Igen, némítás';

  @override
  String get addPlanItemTooltip => 'Tervtétel hozzáadása';

  @override
  String get spendableThisMonth => 'E hónapban elkölthető';

  @override
  String get spendableThisYear => 'Idén elkölthető';

  @override
  String get noPlanItemsYet => 'Még nincsenek tervtételek.';

  @override
  String get tapPlusToAddPlanItems =>
      'Koppints a + gombra bevétel vagy fix költség hozzáadásához.';

  @override
  String get removeWholeSeries => 'Teljes sorozat';

  @override
  String removeWholeSeriesSubtitle(String seriesStartLabel) {
    return '$seriesStartLabel időponttól minden időszak eltávolításra kerül.';
  }

  @override
  String get clearAllDataAction => 'TÖRLÉS';

  @override
  String get clearAllDataDescription =>
      'A kiadások, tervtételek, keretek és guard fizetések végleg törlődnek. Ez nem vonható vissza.';

  @override
  String get clearAllDataPreservedNote =>
      'A mentett pillanatképek és automatikus biztonsági mentések nem érintettek.';

  @override
  String get allCategoriesBudgeted =>
      'Minden kategóriához már van keret ebben a hónapban. Válassz másik hónapot egy új hozzáadásához.';

  @override
  String get selectCategoryHint => 'Válassz kategóriát';

  @override
  String get validationSelectCategory => 'Válassz kategóriát';

  @override
  String get monthlyBudgetLabel => 'Havi keret';

  @override
  String effectiveFromLabel(String validFromLabel) {
    return 'Érvényes ettől: $validFromLabel';
  }

  @override
  String pastMonthBudgetCreateWarning(String fromLabel) {
    return 'Korábbi hónapra hozol létre keretet. Ez visszamenőleg $fromLabel időponttól fog érvényesülni.';
  }

  @override
  String pastMonthBudgetEditWarning(
    String catName,
    String fromLabel,
    String prevLabel,
  ) {
    return 'Ez visszaállítja a(z) $catName keretet $fromLabel időpontig. A(z) $fromLabel–$prevLabel hónapok az új összeget fogják használni.';
  }

  @override
  String get noFixedCostsPlanned => 'Nincs tervezett fix költség';

  @override
  String get noIncomePlanned => 'Nincs tervezett bevétel';

  @override
  String saveSlotSubtitle(String date, int expenseCount, int planItemCount) {
    return '$date · $expenseCount kiadás · $planItemCount tervtétel';
  }

  @override
  String get saveSlotDamagedSubtitle => 'A fájl sérült és nem tölthető be';

  @override
  String get howGroupsWorkTitle => 'Hogyan működik?';

  @override
  String get howGroupsTitle => 'Csoportok';

  @override
  String get howGroupsSubtitle0 => 'Mi a csoport és hogyan működik';

  @override
  String get howGroupsSubtitle1 => 'Hogyan használd ki jól';

  @override
  String get howGroupsSubtitle2 => 'Hol jelennek meg a csoportok az appban';

  @override
  String get howGroupsLabel0 => 'Címke';

  @override
  String get howGroupsLabel1 => 'Légy kreatív';

  @override
  String get howGroupsLabel2 => 'Nyilvántartás';

  @override
  String get howGroupsRule1 =>
      'A csoport egy opcionális szabad szöveges címke, amelyet bármely kiadáshoz hozzárendelhetsz.';

  @override
  String get howGroupsRule2 =>
      'Bármilyen szöveget beírhatsz — nincs fix lista és nincs ellenőrzés.';

  @override
  String get howGroupsRule3 =>
      'Két kiadás csak akkor tartozik ugyanabba a csoportba, ha a címkéik pontosan megegyeznek, karakterről karakterre.';

  @override
  String get howGroupsRule4 =>
      'A kis- és nagybetűk megőrződnek — a „Trip” és a „trip” két külön csoportnak számít.';

  @override
  String get howGroupsRule5 =>
      'A mező opcionális. Hagyd üresen, és a kiadásnak egyszerűen nem lesz csoportja.';

  @override
  String get howGroupsHint =>
      'A csoportot bármely kiadás létrehozásakor vagy szerkesztésekor állítsd be.';

  @override
  String get howGroupsUseIntro =>
      'Használd akkor, amikor a költés egy olyan szeletét akarod követni, amely több kategórián is átnyúlik.';

  @override
  String howGroupsExample1Label(int year) {
    return 'Barcelona $year';
  }

  @override
  String get howGroupsExample1Desc =>
      'Rendeld hozzá az utazás minden kiadásához — repülőjegyekhez, szállodákhoz, étkezésekhez, belépőkhöz. Egy koppintással lásd az egész út teljes költségét.';

  @override
  String howGroupsExample2Label(int year) {
    return 'McDonald\'\'s $year';
  }

  @override
  String get howGroupsExample2Desc =>
      'Használj következetes nevet egész évben. Év végén pontosan tudni fogod, mennyit költöttél arra az egy helyre.';

  @override
  String get howGroupsExample3Label => 'Otthonfelújítás Q1';

  @override
  String get howGroupsExample3Desc =>
      'Terjeszd ki ugyanazt a címkét több hónapra. A Csoportok lap mindent e név alatt gyűjt össze.';

  @override
  String get howGroupsPrecision =>
      'Minél pontosabb a címkéd, annál hasznosabb lesz az összegzés.';

  @override
  String get howGroupsRecord0Title => 'Csoportok lap a Kiadásokban';

  @override
  String get howGroupsRecord0Body =>
      'Minden csoport, amelyhez legalább egy kiadás tartozik az aktuális hónapban, itt egyetlen sorban jelenik meg a tételszámmal és az összeggel. Koppints egy csoportra a részletekért, és nézd meg a mögötte lévő egyes kiadásokat.';

  @override
  String get howGroupsRecord1Title => 'Havi jelentés a Jelentésekben';

  @override
  String get howGroupsRecord1Body =>
      'Amikor havi PDF-et exportálsz a Jelentések képernyőről, az adott hónapban kiadással rendelkező csoportok külön „Kiadási csoportok” oldalt kapnak — minden csoport felsorolva a kiadásaival, összegeivel és a csoport összesen értékével.';

  @override
  String get howGroupsMonthlyNote =>
      'A csoportok nem szerepelnek az éves jelentésben — ezek havi nézőpontot adnak.';

  @override
  String get howGroupsExampleGroupName => 'Saját csoportom';

  @override
  String get otherCategories => 'Egyéb kategóriák';

  @override
  String noCategoryExpenses(String category, String period) {
    return 'Nincs $category kiadás\nitt: $period.';
  }

  @override
  String guardDueDate(String monthName, int day, int year) {
    return 'Esedékes: $monthName $day, $year';
  }

  @override
  String get guardNotYetDue => 'Még nem esedékes';

  @override
  String guardNextReminder(String label) {
    return 'Következő: $label';
  }

  @override
  String guardLastReminder(String label) {
    return 'Utolsó: $label';
  }

  @override
  String get guardChangeDay => 'Nap módosítása';

  @override
  String get guardRemoveAction => 'GUARD eltávolítása';

  @override
  String get guardMarkUnpaidTitle => 'Fizetetlennek jelölöd?';

  @override
  String guardMarkUnpaidBody(String monthName, int year) {
    return 'Ez eltávolítja a fizetési megerősítést ehhez: $monthName $year.';
  }

  @override
  String get guardMarkUnpaidAction => 'Jelölés fizetetlennek';

  @override
  String get guardMarkAsPaid => 'Jelölés fizetettnek';

  @override
  String get guardRemoveTitle => 'Eltávolítod a GUARD-ot?';

  @override
  String guardRemoveBody(String name) {
    return 'A GUARD ki lesz kapcsolva ennél: \"$name\". A meglévő fizetési rekordok megmaradnak, de új emlékeztetők nem fognak elindulni.';
  }

  @override
  String get guardRemoveConfirm => 'Eltávolítás';

  @override
  String get guardSelectPaidDate => 'Fizetési dátum kiválasztása';

  @override
  String guardPaidOn(String date) {
    return 'Fizetve ekkor: $date';
  }

  @override
  String howItWorksStep(int n) {
    return '$n. LÉPÉS';
  }

  @override
  String get planSubtitle0 => 'A fizetésed és a kötelező havi számláid';

  @override
  String get planSubtitle1 => 'Hogyan vannak besorolva a fix költségeid';

  @override
  String get planSubtitle2 =>
      'A bevételed mekkora részét viszi el az egyes típusok';

  @override
  String get planSubStep0 => 'Cashflow';

  @override
  String get planSubStep1 => 'Besorolás';

  @override
  String get planSubStep2 => 'Elosztás';

  @override
  String get howItWorksPlanIncomeBody =>
      'Add meg a fizetésedet és a kötelező havi számláidat — lakbér, biztosítás, előfizetések. Ezek valós, ismert számok, nem becslések vagy célok.';

  @override
  String get howItWorksTypeConsumptionDesc =>
      'Napi szintű költés — élelmiszer, lakbér, étkezés, közlekedés';

  @override
  String get howItWorksTypeAssetDesc =>
      'Befektetések és megtakarítások, amelyek idővel növelik a vagyonodat';

  @override
  String get howItWorksTypeInsuranceDesc =>
      'Védelmi költségek — autó-, egészség- és életbiztosítás';

  @override
  String get howItWorksFinancialTypesBody =>
      'Minden fix költség egy pénzügyi típussal van megjelölve. Ez lehetővé teszi az app számára, hogy megmutassa, hogyan oszlik meg a bevételed a költés, a megtakarítás és a védelem között.';

  @override
  String get howItWorksSpendingVsIncomeTitle => 'Költés vs Bevétel';

  @override
  String get howItWorksSpendingVsIncomeBody =>
      'A Terv lap megmutatja, hogy a bevételedből mennyi jut az egyes pénzügyi típusokra — így egy pillantással láthatod, hogy megfelelő arányban költesz, takarítasz meg vagy védesz abból, amit keresel.';

  @override
  String get expSubtitle0 => 'Az elérhető kereted, a Tervből számolva';

  @override
  String get expSubtitle1 => 'A rögzített napi költéseid';

  @override
  String get expSubtitle2 => 'Benne maradtál a keretben?';

  @override
  String get subStepBudget => 'Keret';

  @override
  String get subStepSpending => 'Költés';

  @override
  String get subStepResult => 'Eredmény';

  @override
  String get howItWorksBudgetBody =>
      'Az app levonja a fix költségeidet a bevételedből, és itt mutatja az eredményt. Ezt a számot nem te állítod be — a Tervből származik.';

  @override
  String get howItWorksSpendingBody =>
      'Rögzítsd az élelmiszert, étkezéseket, vásárlást és más változó költéseket. Az olyan fix havi számlák, mint a lakbér, a Tervhez tartoznak, nem ide.';

  @override
  String get howItWorksResultBody =>
      'A hónap végén a Kiadások lap megmutatja, milyen eredményt értél el.';

  @override
  String get repSubtitle0 => 'Hová ment a pénzed?';

  @override
  String get repSubtitle1 => 'A pénzügyeid papíron';

  @override
  String get repSubtitle2 => 'A teljes kép, hónapról hónapra';

  @override
  String get repSubStep0 => 'Bontás';

  @override
  String get repSubStep1 => 'Export';

  @override
  String get repSubStep2 => 'Áttekintés';

  @override
  String get howItWorksBreakdownBody =>
      'A Bontás megmutatja a költésed kategóriák szerint bármely hónapra vagy évre. Koppints egy szeletre vagy kategóriasorra, hogy a mögötte lévő egyedi kiadásokat és fix költségeket lásd.';

  @override
  String get pdfFeatureCategoryTotals => 'Kategóriaösszesítők';

  @override
  String get pdfFeatureBudgetVsActual => 'Keret vs tény';

  @override
  String get pdfFeatureTypeSplit => 'Pénzügyi típus bontás';

  @override
  String get pdfFeatureAllExpenses => 'Összes kiadás listázva';

  @override
  String get pdfFeatureCategoryBudgets => 'Kategóriakeretek';

  @override
  String get pdfFeatureGroupSummaries => 'Csoportösszegzések';

  @override
  String get pdfFeature12MonthOverview => '12 hónapos áttekintés';

  @override
  String get pdfFeatureAnnualTotals => 'Éves összesítők';

  @override
  String get pdfFeatureMonthlyBreakdown => 'Havi bontás';

  @override
  String get pdfFeaturePlanVsActual => 'Terv vs tény';

  @override
  String get pdfFeatureTypeRatios => 'Típusarányok';

  @override
  String get pdfFeatureActivePlanItems => 'Aktív tervtételek';

  @override
  String get howItWorksExportBody =>
      'Az exportáláshoz használd a PDF gombot a Bontásban. A jelentések bármely eszközödön lévő appon keresztül megoszthatók.';

  @override
  String get howItWorksMoreMonths => '· · · még 9 hónap';

  @override
  String get howItWorksOverviewBody =>
      'Az Áttekintés mind a 12 hónapot egymás mellett mutatja — mennyit kerestél, mennyi ment eszközökbe, és mennyi fogyott el. Koppints bármelyik hónapra, hogy arra az időszakra ugorj a Tervben.';

  @override
  String overBudgetBy(String amount) {
    return '$amount túlköltés';
  }

  @override
  String savedAmount(String amount) {
    return '$amount megtakarítva';
  }

  @override
  String get loadingLabel => 'Betöltés…';

  @override
  String get autoBackupTitle => 'Automatikus biztonsági mentés';

  @override
  String get autoBackupNoBackupYet => 'Még nincs biztonsági mentés';

  @override
  String get autoBackupSubtitleExpand =>
      'Naponta frissül · koppints a kibontáshoz';

  @override
  String get autoBackupSubtitleCollapse =>
      'Naponta frissül · koppints az összecsukáshoz';

  @override
  String get actionRestoreAllCaps => 'VISSZAÁLLÍTÁS';

  @override
  String get actionRestore => 'Visszaállítás';

  @override
  String get autoBackupRestoreDescription =>
      'A visszaállítás lecseréli az összes jelenlegi adatot a biztonsági mentésre.';

  @override
  String autoBackupRestored(String date) {
    return '$date dátumú biztonsági mentés visszaállítva.';
  }

  @override
  String get autoBackupRestoreFailed =>
      'A biztonsági mentés visszaállítása sikertelen.';

  @override
  String get autoBackupPrimary => 'Elsődleges biztonsági mentés';

  @override
  String get autoBackupSecondary => 'Másodlagos biztonsági mentés';

  @override
  String get frequencyPickerFixed => 'Milyen gyakran ismétlődik?';

  @override
  String get frequencyMonthlyFixedSubtitle =>
      'Lakbér, előfizetések, ismétlődő számlák';

  @override
  String get frequencyYearlyFixedSubtitle =>
      'Éves előfizetések, biztosítás, tagságok';

  @override
  String get frequencyPickerIncome => 'Milyen gyakran kapod?';

  @override
  String get frequencyMonthlyIncomeSubtitle =>
      'Fizetés, nyugdíj, rendszeres átutalások';

  @override
  String get frequencyYearlyIncomeSubtitle =>
      'Éves bónusz, adóvisszatérítés, osztalék';

  @override
  String get frequencyOneTimeIncomeSubtitle =>
      'Ajándék, rendkívüli bevétel, egyszeri kifizetés';

  @override
  String get typePickerTitle => 'Mit adsz hozzá?';

  @override
  String get typeIncomeSubtitle => 'Fizetés, bónusz, nyugdíj, ajándékok';

  @override
  String get typeFixedCostSubtitle => 'Lakbér, biztosítás, előfizetések';

  @override
  String get languagePickerTitle => 'Nyelv';

  @override
  String get currencyPickerTitle => 'Pénznem';

  @override
  String get currencyCustom => 'Egyéni';

  @override
  String get currencyCustomSubtitle => 'Saját kód és szimbólum megadása';

  @override
  String get currencyCustomTitle => 'Egyéni pénznem';

  @override
  String get currencyCodeLabel => 'Kód';

  @override
  String get currencyCodeHint => 'pl. USD';

  @override
  String get currencySymbolLabel => 'Szimbólum';

  @override
  String get currencySymbolHint => 'pl. \$';

  @override
  String get removeFromImport => 'Eltávolítás az importból';

  @override
  String get exportExpensesTitle => 'Kiadások exportálása';

  @override
  String get selectDateRangeHint =>
      'Válaszd ki az exportálandó dátumtartományt:';

  @override
  String get startDateLabel => 'Kezdő dátum';

  @override
  String get endDateLabel => 'Záró dátum';

  @override
  String get tapToSelectDate => 'Koppints a kiválasztáshoz';

  @override
  String get endDateAfterStart =>
      'A záródátumnak a kezdődátummal azonosnak vagy későbbinek kell lennie.';

  @override
  String get actionExport => 'Exportálás';

  @override
  String overspendWarning(String period, String amount) {
    return 'Ebben a(z) $period időszakban $amount összeggel többet költöttél, mint amennyit kerestél!';
  }

  @override
  String get periodMonth => 'hónapban';

  @override
  String get periodYear => 'évben';

  @override
  String guardBannerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'GUARD — $count fizetés nincs megerősítve',
      one: 'GUARD — 1 fizetés nincs megerősítve',
    );
    return '$_temp0';
  }

  @override
  String get guardSilencedBadge => 'némítva';

  @override
  String guardExpenseStripPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count figyelt fizetés függőben',
      one: '1 figyelt fizetés függőben',
    );
    return '$_temp0';
  }

  @override
  String importErrorRowLabel(int row, String field) {
    return '$row. sor — $field';
  }

  @override
  String earnedLabel(String amount) {
    return 'Kereset: $amount';
  }

  @override
  String fromDateShort(String label) {
    return '$label időponttól';
  }

  @override
  String untilDateShort(String label) {
    return '$label időpontig';
  }

  @override
  String get guardEnableToggle => 'GUARD engedélyezése';

  @override
  String get guardEnableToggleSubtitle =>
      'Fizetés követése és emlékeztetők fogadása';

  @override
  String get actionOk => 'OK';

  @override
  String get labelTotal => 'Összesen';

  @override
  String get categoryBudgetsTitle => 'Kategóriakeretek';

  @override
  String get noCategoryBudgetsSet => 'Nincsenek beállított kategóriakeretek.';

  @override
  String removeBudgetDialogTitle(String category) {
    return '$category keret eltávolítása';
  }

  @override
  String endBudgetFromTitle(String from) {
    return 'Lezárás ettől: $from';
  }

  @override
  String endBudgetFromDescription(String from) {
    return 'Leállítja a keretet $from időponttól kezdve. A korábbi hónapok megőrzik a történeti keretüket.';
  }

  @override
  String get deleteBudgetSeriesTitle => 'Teljes sorozat törlése';

  @override
  String get deleteBudgetSeriesConfirm => 'Sorozat törlése';

  @override
  String deleteBudgetSeriesDescription(String range) {
    return 'Végleg eltávolít minden rekordot ($range). Ennél a sorozatnál egyetlen hónapban sem fog megjelenni keret. Ez nem vonható vissza.';
  }

  @override
  String budgetRangePresent(String start) {
    return '$start – jelenleg';
  }

  @override
  String get pdfMonthlyReport => 'Havi jelentés';

  @override
  String get pdfYearlyReport => 'Éves jelentés';

  @override
  String pdfMonthlyReportHeader(String month, int year) {
    return 'HAVI JELENTÉS ERRŐL: $month $year';
  }

  @override
  String pdfYearlyReportHeader(int year) {
    return 'ÉVES JELENTÉS ERRŐL: $year';
  }

  @override
  String get pdfPartialYear => '(részleges év)';

  @override
  String get pdfSectionSpendingVsIncome => 'KÖLTÉS VS BEVÉTEL';

  @override
  String get pdfSectionCategorySummary => 'KATEGÓRIA-ÖSSZEFOGLALÓ';

  @override
  String get pdfSectionCashFlowSummary => 'CASH FLOW ÖSSZEFOGLALÓ';

  @override
  String get pdfSectionExpenseGroups => 'KIADÁSI CSOPORTOK';

  @override
  String get pdfSectionExpenseDetails => 'KIADÁS RÉSZLETEK';

  @override
  String get pdfSectionYearlyOverview => 'ÉVES ÁTTEKINTÉS';

  @override
  String get pdfSectionSpendingByCategory =>
      'KÖLTÉS KATEGÓRIA ÉS HÓNAP SZERINT';

  @override
  String get pdfIncomeHeader => 'BEVÉTEL';

  @override
  String get pdfFixedCostsHeader => 'FIX KÖLTSÉGEK';

  @override
  String get pdfTotal => 'ÖSSZESEN';

  @override
  String get pdfColTotal => 'Összesen';

  @override
  String get pdfEarnedThisMonth => 'Ebben a hónapban keresett';

  @override
  String get pdfEarnedThisYear => 'Ebben az évben keresett';

  @override
  String get pdfGroupTotal => 'Csoport összesen (ebben a hónapban)';

  @override
  String get pdfAllPeriodsTotal => 'Minden időszak összesen';

  @override
  String pdfItemsThisMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tétel ebben a hónapban',
      one: '1 tétel ebben a hónapban',
    );
    return '$_temp0';
  }

  @override
  String get pdfNormalized => ' (normalizált)';

  @override
  String get pdfAnnualized => ' (évesítve)';

  @override
  String get pdfPartialYearNote =>
      'Részleges év - a hónapok adatok nélkül nullát mutatnak. Csak év elejétől számított összesítések.';

  @override
  String pdfPage(int page, int total) {
    return '$page. oldal / $total';
  }

  @override
  String get pdfNoData => 'Nincs adat.';

  @override
  String get howItWorksExampleSalary => 'Fizetés';

  @override
  String get howItWorksExampleBonus => 'Bónusz';

  @override
  String get howItWorksExampleRent => 'Lakbér';

  @override
  String get howItWorksExampleInsurance => 'Biztosítás';

  @override
  String get howItWorksExampleEtfFonds => 'ETF alapok';

  @override
  String get addBudgetTooltip => 'Keret hozzáadása';

  @override
  String get selectCategoryTitle => 'Kategória kiválasztása';

  @override
  String get showAllCategories => 'Az összes kategória megjelenítése';

  @override
  String get showLessCategories => 'Kevesebb megjelenítése';

  @override
  String get allCategoriesTitle => 'Összes kategória';

  @override
  String get howCategoryBudgetsTitle => 'Hogyan működnek a kategória keretek';

  @override
  String get howCategoryBudgetsSubtitle0 => 'Miért létezik';

  @override
  String get howCategoryBudgetsSubtitle1 => 'Keret létrehozása';

  @override
  String get howCategoryBudgetsSubtitle2 => 'A sáv értelmezése';

  @override
  String get howCategoryBudgetsLabel0 => 'Limit';

  @override
  String get howCategoryBudgetsLabel1 => 'Beállítás';

  @override
  String get howCategoryBudgetsLabel2 => 'Haladás';

  @override
  String get howCategoryBudgetsWhatIntro =>
      'Állíts be havi limitet bármelyik kategóriára — éttermek, bevásárlás, szórakozás. Csak annyit költs, amennyit terveztél.';

  @override
  String get howCategoryBudgetsRule1 =>
      'Válaszd ki azokat a kategóriákat, ahol hajlamos vagy túlkölteni. Csak ott állíts be limitet.';

  @override
  String get howCategoryBudgetsRule2 =>
      'Minden keret egy egyszerű havi cap — például: Éttermek → 100 € havonta.';

  @override
  String get howCategoryBudgetsRule3 =>
      'A keretek opcionálisak. Annyit állíts be, amennyit szeretnél.';

  @override
  String get howCategoryBudgetsRule4 =>
      'Kategóriánként egy kereted lehet, annyi kategóriában, amennyire szükséged van.';

  @override
  String get howCategoryBudgetsSetupIntro =>
      'Koppints a + gombra a Keretek kezelése képernyőn. Válassz kategóriát, adj meg összeget, válaszd meg a kezdeti dátumot. Kész.';

  @override
  String get howCategoryBudgetsSetupRule1 =>
      'Válassz kategóriát — például Éttermek.';

  @override
  String get howCategoryBudgetsSetupRule2 =>
      'Add meg a havi limitedet — például 100 €.';

  @override
  String get howCategoryBudgetsSetupRule3 =>
      'Válaszd meg azt a hónapot, amelytől érvényes. Attól a ponttól él.';

  @override
  String get howCategoryBudgetsSetupRule4 =>
      'Mentés után a kategória zárolva van — új keretet hozz létre, ha módosítani szeretnéd.';

  @override
  String get howCategoryBudgetsPastMonthHint =>
      'Ha múlt hónapot választasz, a keret visszamenőleg érvényes lesz. Mentés előtt megerősítés jelenik meg.';

  @override
  String get howCategoryBudgetsProgressIntro =>
      'A folyamatjelző sáv pontosan megmutatja, hol állsz — egy pillantásra, minden alkalommal, amikor megnyitod a Kiadásokat.';

  @override
  String get howCategoryBudgetsProgressRule1 =>
      'Zöld — 80% alatt: jó úton jársz. Csak így tovább.';

  @override
  String get howCategoryBudgetsProgressRule2 =>
      'Borostyán — 80–100%: közeledik. Ideje lassítani.';

  @override
  String get howCategoryBudgetsProgressRule3 =>
      'Piros — 100% felett: limit túllépve. Figyelmeztetés jelenik meg a Kiadások tetején.';

  @override
  String get howCategoryBudgetsWhereTitle => 'Hol jelenik meg';

  @override
  String get howCategoryBudgetsWhere1 =>
      'Kiadások — aktív keret esetén minden kategóriasor alatt megjelenik a folyamatjelző sáv.';

  @override
  String get howCategoryBudgetsWhere2 =>
      'Kategória nézet — minden korlátozott kategória inline mutatja a telítettségét.';

  @override
  String get howCategoryBudgetsWhere3 =>
      'Havi PDF-jelentés — a keretek szerepelnek a kiadási összesítőben.';

  @override
  String get howCategoryBudgetsResetHint =>
      'A keretek havonta visszaállnak — a fel nem használt összegek nem vihetők át.';

  @override
  String get howGuardTitle => 'Hogyan működik a GUARD';

  @override
  String get howGuardSubtitle0 => 'Fizetési emlékeztető';

  @override
  String get howGuardSubtitle1 => 'Beállítás';

  @override
  String get howGuardSubtitle2 => 'Hogyan ismétlődik';

  @override
  String get howGuardLabel0 => 'Emlékeztető';

  @override
  String get howGuardLabel1 => 'Beállítások';

  @override
  String get howGuardLabel2 => 'Ismétlődő';

  @override
  String get howGuardWhatIntro =>
      'A GUARD emlékezteti, amikor egy rendszeres számla esedékes — bérleti díj, Netflix, biztosítás. Semmi sem csúszik át.';

  @override
  String get howGuardRule1 =>
      'Az esedékesség napján értesítés jelenik meg a telefonján. Előzetes teendő nincs.';

  @override
  String get howGuardRule2 =>
      'Koppintson a \"Fizetve\" gombra a megerősítéshez. Vagy némítsa el, ha ezúttal ki szeretné hagyni.';

  @override
  String get howGuardRule3 =>
      'Minden őrzött számla megmutatja aktuális állapotát.';

  @override
  String get howGuardStateUnpaid => 'Esedékes — vár a megerősítésére';

  @override
  String get howGuardStatePaid => 'Fizetve — megerősítve erre az időszakra';

  @override
  String get howGuardStateSilenced => 'Elnémítva — emlékeztető elutasítva';

  @override
  String get howGuardActivateIntro =>
      'Nyisson meg bármely fix kiadást, koppintson a Szerkesztés gombra, és kapcsolja be a GUARD-ot. Állítsa be, mikor esedékes a számla — ennyi az egész.';

  @override
  String get howGuardActivateRule1 =>
      'Állítsa be a fizetési napot — a hónap azon napját, amelyen fizetni szokott. Például: bérleti díj 1-jén, Netflix 15-én.';

  @override
  String get howGuardActivateRule2 =>
      'Attól a naptól kezdve a napi emlékeztető addig ismétlődik, amíg meg nem jelöli fizetettként vagy el nem némítja.';

  @override
  String get howGuardActivateRule3 =>
      'Éves számlák esetén — mint a biztosítás — válassza ki az esedékességi hónapot is.';

  @override
  String get howGuardActivateRule4 =>
      'A napi emlékeztető időpontját a GUARD beállításaiban módosíthatja.';

  @override
  String get howGuardFixedCostOnlyHint =>
      'A GUARD csak fix kiadás tételeknél engedélyezhető.';

  @override
  String get howGuardActIntro =>
      'A GUARD minden új időszak elején automatikusan visszaáll. Semmit sem kell manuálisan visszaállítani.';

  @override
  String get howGuardActRule1 =>
      'A havi számlák — mint a bérleti díj vagy az előfizetések — minden hónapban új emlékeztetőt kapnak.';

  @override
  String get howGuardActRule2 =>
      'Az éves számlák — mint a biztosítás vagy éves díjak — évente egyszer állnak vissza.';

  @override
  String get howGuardActRule3 =>
      'Amint megjelöl egy számlát fizetettként, megerősítve marad a következő időszak kezdetéig.';

  @override
  String get howGuardPerPeriodHint =>
      'Fizetve vagy elnémítva — csak az aktuális időszakra vonatkozik. A következő mindig frissen kezdődik.';
}
