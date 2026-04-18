// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Finance Tracker';

  @override
  String get welcomeTagline => 'Przejmij kontrolę nad swoimi pieniędzmi';

  @override
  String get getStarted => 'Zacznij';

  @override
  String get tabExpenses => 'Wydatki';

  @override
  String get tabPlan => 'Plan';

  @override
  String get tabReports => 'Raporty';

  @override
  String get actionEdit => 'Edytuj';

  @override
  String get actionDelete => 'Usuń';

  @override
  String get actionSave => 'Zapisz';

  @override
  String get actionCancel => 'Anuluj';

  @override
  String get actionLoad => 'Wczytaj';

  @override
  String get actionImport => 'Importuj';

  @override
  String get actionOverwrite => 'Nadpisz';

  @override
  String get labelAmount => 'Kwota';

  @override
  String get labelCategory => 'Kategoria';

  @override
  String get labelFinancialType => 'Typ finansowy';

  @override
  String get labelDate => 'Data';

  @override
  String get labelNote => 'Notatka';

  @override
  String get labelNoteOptional => 'Notatka (opcjonalnie)';

  @override
  String get labelGroup => 'Grupa';

  @override
  String get labelGroupOptional => 'Grupa (opcjonalnie)';

  @override
  String get groupHintText => 'np. Wakacje, Urodziny';

  @override
  String get labelName => 'Nazwa';

  @override
  String get labelFrequency => 'Częstotliwość';

  @override
  String get labelValidFrom => 'Obowiązuje od';

  @override
  String get labelValidTo => 'Obowiązuje do (opcjonalnie)';

  @override
  String get menuImportExpenses => 'Importuj wydatki';

  @override
  String get menuExportExpenses => 'Eksportuj wydatki';

  @override
  String get menuImport => 'Importuj';

  @override
  String get menuSaves => 'Zapisy';

  @override
  String get menuDeleteAll => 'Usuń wszystkie dane';

  @override
  String get menuHowItWorks => 'Jak to działa';

  @override
  String get menuResetWithDummyData => 'Zresetuj z przykładowymi danymi';

  @override
  String get menuManageBudgets => 'Zarządzaj budżetami';

  @override
  String get menuGuard => 'GUARD';

  @override
  String get expenseListTitle => 'Wydatki';

  @override
  String get savesTooltip => 'Zapisy';

  @override
  String get howItWorksTooltip => 'Jak to działa';

  @override
  String get howItWorksQuestion => 'Jak to działa?';

  @override
  String get viewModeItems => 'Pozycje';

  @override
  String get viewModeByCategory => 'Kategoria';

  @override
  String get viewModeByGroup => 'Grupy';

  @override
  String get thisMonthsBudget => 'Budżet na ten miesiąc';

  @override
  String get budgetNotSet => 'Budżet nie jest ustawiony';

  @override
  String get setIncomeInPlan => 'Ustaw dochód';

  @override
  String noExpensesInMonth(String monthName, int year) {
    return 'Brak wydatków w $monthName $year.';
  }

  @override
  String get tapPlusToAddOne => 'Dotknij +, aby dodać jeden.';

  @override
  String get fixedBillsHint =>
      'Stałe rachunki, takie jak czynsz, należą do Planu.';

  @override
  String get noGroupsThisMonth => 'W tym miesiącu nie ma grup.';

  @override
  String get addGroupHint =>
      'Dodaj grupę podczas tworzenia\nlub edycji wydatku.';

  @override
  String get howGroupsWorkQuestion => 'Jak działają grupy?';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pozycji',
      many: '$count pozycji',
      few: '$count pozycje',
      one: '1 pozycja',
    );
    return '$_temp0';
  }

  @override
  String get addExpenseTitle => 'Dodaj wydatek';

  @override
  String get editExpenseTitle => 'Edytuj wydatek';

  @override
  String get validationAmountEmpty => 'Wprowadź kwotę';

  @override
  String get validationAmountInvalid => 'Wprowadź poprawną dodatnią liczbę';

  @override
  String get expenseDetailTitle => 'Wydatek';

  @override
  String noExpensesInNamedGroup(String name) {
    return 'Brak wydatków w „$name”.';
  }

  @override
  String get planTitle => 'Plan';

  @override
  String get toggleMonthly => 'Miesięcznie';

  @override
  String get toggleYearly => 'Rocznie';

  @override
  String get sectionIncome => 'Dochód';

  @override
  String get sectionFixedCosts => 'Stałe koszty';

  @override
  String get noIncomeItems => 'Brak pozycji dochodu.';

  @override
  String get noFixedCostItems => 'Brak pozycji stałych kosztów.';

  @override
  String get spendableBudget => 'Budżet do wydania';

  @override
  String get deleteItemDialogTitle => 'Usuń pozycję planu';

  @override
  String get deleteItemFromPeriod => 'Od tego okresu';

  @override
  String get deleteItemWholeSeries => 'Cała seria';

  @override
  String get planItemDeleted => 'Pozycja planu została usunięta.';

  @override
  String get addIncomeTitle => 'Dodaj dochód';

  @override
  String get addFixedCostTitle => 'Dodaj stały koszt';

  @override
  String get editIncomeTitle => 'Edytuj dochód';

  @override
  String get editFixedCostTitle => 'Edytuj stały koszt';

  @override
  String get frequencyOneTime => 'Jednorazowo';

  @override
  String get frequencyMonthly => 'Miesięcznie';

  @override
  String get frequencyYearly => 'Rocznie';

  @override
  String get guardSectionLabel => 'GUARD';

  @override
  String get guardTrackPayment => 'Śledź płatność';

  @override
  String get guardDueDayLabel => 'Dzień płatności';

  @override
  String get guardOneTimeLabel => 'Płatność jednorazowa';

  @override
  String get planItemSaved => 'Pozycja planu została zapisana.';

  @override
  String get addNewItemSheetTitle => 'Dodaj nowe';

  @override
  String get typeIncome => 'Dochód';

  @override
  String get typeFixedCost => 'Stały koszt';

  @override
  String get ongoing => 'Bez końca';

  @override
  String get manageBudgetsTitle => 'Zarządzaj budżetami';

  @override
  String get noBudgetsSet => 'Brak ustawionych budżetów dla tego okresu.';

  @override
  String get addFirstBudget => 'Dodaj swój pierwszy budżet.';

  @override
  String get addBudgetTitle => 'Dodaj budżet';

  @override
  String get editBudgetTitle => 'Edytuj budżet';

  @override
  String get budgetAmount => 'Kwota budżetu';

  @override
  String get effectiveFrom => 'Obowiązuje od';

  @override
  String get pastMonthBudgetWarning =>
      'Ustawienie budżetu w przeszłości nie wpłynie na wcześniejsze wydatki.';

  @override
  String get budgetSaved => 'Budżet został zapisany.';

  @override
  String get budgetDeleted => 'Budżet został usunięty.';

  @override
  String get guardScreenTitle => 'GUARD';

  @override
  String get guardDailyReminderTime => 'Czas codziennego przypomnienia';

  @override
  String get guardTimePicker => 'Czas codziennego przypomnienia GUARD';

  @override
  String get guardMarkPaid => 'Oznacz jako opłacone';

  @override
  String get guardSilence => 'Wycisz';

  @override
  String get guardStatusPaid => 'Opłacone';

  @override
  String get guardStatusScheduled => 'Zaplanowane';

  @override
  String get guardStatusUnpaid => 'Nieopłacone';

  @override
  String get guardStatusSilenced => 'Wyciszone';

  @override
  String get noGuardedItems => 'Brak chronionych pozycji.';

  @override
  String get reportsTitle => 'Raporty';

  @override
  String get reportModeMonthly => 'Miesięcznie';

  @override
  String get reportModeYearly => 'Rocznie';

  @override
  String get reportModeOverview => 'Przegląd';

  @override
  String get exportPdf => 'Eksportuj PDF';

  @override
  String get noExpensesForPeriod => 'Brak zapisanych wydatków dla tego okresu.';

  @override
  String get noIncomeOrSpendingDataForYear =>
      'Brak danych o dochodach lub wydatkach dla tego roku.';

  @override
  String get pieChartOther => 'Inne';

  @override
  String get reportSectionFixedCosts => 'STAŁE KOSZTY';

  @override
  String get reportSectionExpenses => 'WYDATKI';

  @override
  String get noneInPeriod => 'Brak w tym okresie.';

  @override
  String fixedCostCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stałych kosztów',
      many: '$count stałych kosztów',
      few: '$count stałe koszty',
      one: '1 stały koszt',
    );
    return '$_temp0';
  }

  @override
  String expenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wydatków',
      many: '$count wydatków',
      few: '$count wydatki',
      one: '1 wydatek',
    );
    return '$_temp0';
  }

  @override
  String get noItemsInPeriod => 'Brak pozycji w tym okresie';

  @override
  String get importTitle => 'Importuj wydatki';

  @override
  String get importStep1Title => 'Pobierz szablon';

  @override
  String get importStep1Description =>
      'Pobierz oficjalny szablon Excel ze wszystkimi wymaganymi kolumnami oraz przewodnikiem po prawidłowych wartościach.';

  @override
  String get importStep1Button => 'Pobierz szablon';

  @override
  String get importStep2Title => 'Wypełnij i importuj';

  @override
  String get importStep2Description =>
      'Wypełnij szablon w Excelu lub Google Sheets, a następnie wybierz tutaj plik, aby zaimportować swoje wydatki.';

  @override
  String get importStep2Button => 'Wybierz plik (.xlsx lub .csv)';

  @override
  String get importInfoText =>
      'Można importować tylko wydatki. Dochody i pozycje planu nie są obsługiwane.\n\nAkceptowane formaty: .xlsx (Excel) i .csv.\nPliki CSV muszą mieć taką samą kolejność kolumn jak szablon: Date, Amount, Category, Financial Type, Note, Group.\n\nPliki wyeksportowane z tej aplikacji również można importować bezpośrednio.';

  @override
  String importReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wydatków gotowych do importu',
      many: '$count wydatków gotowych do importu',
      few: '$count wydatki gotowe do importu',
      one: '1 wydatek gotowy do importu',
    );
    return '$_temp0';
  }

  @override
  String importErrorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wierszy nie udało się odczytać',
      many: '$count wierszy nie udało się odczytać',
      few: '$count wierszy nie udało się odczytać',
      one: '1 wiersza nie udało się odczytać',
    );
    return '$_temp0';
  }

  @override
  String importErrorCountSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wierszy nie udało się odczytać — zostaną pominięte',
      many: '$count wierszy nie udało się odczytać — zostaną pominięte',
      few: '$count wierszy nie udało się odczytać — zostaną pominięte',
      one: '1 wiersza nie udało się odczytać — zostanie pominięty',
    );
    return '$_temp0';
  }

  @override
  String get importNoDataFound => 'Nie znaleziono danych w pliku.';

  @override
  String get importTapToEdit =>
      'Dotknij dowolnego wiersza, aby go edytować lub usunąć przed importem.';

  @override
  String get importRowsWithErrors => 'Wiersze z błędami';

  @override
  String get importNoDataRows => 'Nie znaleziono żadnych wierszy danych.';

  @override
  String importConfirmButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importuj $count wydatków',
      many: 'Importuj $count wydatków',
      few: 'Importuj $count wydatki',
      one: 'Importuj 1 wydatek',
    );
    return '$_temp0';
  }

  @override
  String importSuccessMessage(int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wydatków zaimportowano · $range',
      many: '$count wydatków zaimportowano · $range',
      few: '$count wydatki zaimportowano · $range',
      one: '1 wydatek zaimportowano · $range',
    );
    return '$_temp0';
  }

  @override
  String get importUnsupportedFile =>
      'Nieobsługiwany typ pliku. Wybierz plik .xlsx lub .csv.';

  @override
  String get importCouldNotReadFile =>
      'Nie udało się odczytać pliku. Spróbuj ponownie.';

  @override
  String importPickerError(Object error) {
    return 'Nie udało się otworzyć wyboru pliku: $error';
  }

  @override
  String importTemplateError(Object error) {
    return 'Nie udało się wygenerować szablonu: $error';
  }

  @override
  String get tryAnotherFile => 'Spróbuj innego pliku';

  @override
  String get savesTitle => 'Zapisy';

  @override
  String get sectionAutoBackup => 'AUTOMATYCZNA KOPIA ZAPASOWA';

  @override
  String get sectionSaves => 'ZAPISY';

  @override
  String get sectionDataTransfer => 'TRANSFER DANYCH';

  @override
  String get sectionDataDeletion => 'USUWANIE DANYCH';

  @override
  String get exportAllData => 'Eksportuj wszystkie dane';

  @override
  String get importAllData => 'Importuj wszystkie dane';

  @override
  String get deleteAllData => 'Usuń wszystkie dane';

  @override
  String get emptySlot => 'Pusty slot';

  @override
  String savedConfirmation(String name) {
    return '„$name” zapisano.';
  }

  @override
  String loadedConfirmation(String name) {
    return '„$name” wczytano.';
  }

  @override
  String exportFailed(Object error) {
    return 'Eksport nie powiódł się: $error';
  }

  @override
  String importFailedInvalid(Object error) {
    return 'Nieprawidłowy plik: $error';
  }

  @override
  String get importDataSuccess => 'Dane zostały pomyślnie zaimportowane.';

  @override
  String get couldNotReadSelectedFile =>
      'Nie udało się odczytać wybranego pliku.';

  @override
  String get importDataDialogTitle => 'Importować dane?';

  @override
  String get importDataDialogContent =>
      'To zastąpi WSZYSTKIE bieżące wydatki i pozycje planu zawartością pliku. Tej operacji nie można cofnąć.';

  @override
  String get saveName => 'Nazwa zapisu';

  @override
  String get saveNameCannotBeEmpty => 'Nazwa nie może być pusta';

  @override
  String replacingLabel(String name) {
    return 'Zastępowane: $name';
  }

  @override
  String get loadDialogDescription =>
      'Wszystkie bieżące dane zostaną zastąpione tym zapisanym snapshotem.';

  @override
  String get deleteDialogDescription =>
      'Ten zapisany snapshot zostanie trwale usunięty.';

  @override
  String get damagedSaveFile => 'Uszkodzony plik zapisu';

  @override
  String overBudgetAmount(String amount) {
    return '$amount ponad budżet';
  }

  @override
  String underBudgetAmount(String amount) {
    return '$amount pozostało';
  }

  @override
  String spentLabel(String amount) {
    return 'Wydano: $amount';
  }

  @override
  String budgetLabel(String amount) {
    return 'Budżet: $amount';
  }

  @override
  String progressBarLabel(String spent, String budget) {
    return '$spent wydano  /  $budget budżet';
  }

  @override
  String categoryBudgetOverBy(String category, String amount) {
    return 'Budżet kategorii $category: przekroczony o $amount';
  }

  @override
  String get deleteAllDataDialogTitle => 'Usunąć wszystkie dane?';

  @override
  String get deleteAllDataDialogContent =>
      'To trwale usunie wszystkie wydatki, dochody i pozycje planu. Tej operacji nie można cofnąć.';

  @override
  String get deleteAllDataConfirm => 'Usuń wszystko';

  @override
  String get monthJanuary => 'Styczeń';

  @override
  String get monthFebruary => 'Luty';

  @override
  String get monthMarch => 'Marzec';

  @override
  String get monthApril => 'Kwiecień';

  @override
  String get monthMay => 'Maj';

  @override
  String get monthJune => 'Czerwiec';

  @override
  String get monthJuly => 'Lipiec';

  @override
  String get monthAugust => 'Sierpień';

  @override
  String get monthSeptember => 'Wrzesień';

  @override
  String get monthOctober => 'Październik';

  @override
  String get monthNovember => 'Listopad';

  @override
  String get monthDecember => 'Grudzień';

  @override
  String get monthAbbrJan => 'Sty';

  @override
  String get monthAbbrFeb => 'Lut';

  @override
  String get monthAbbrMar => 'Mar';

  @override
  String get monthAbbrApr => 'Kwi';

  @override
  String get monthAbbrMay => 'Maj';

  @override
  String get monthAbbrJun => 'Cze';

  @override
  String get monthAbbrJul => 'Lip';

  @override
  String get monthAbbrAug => 'Sie';

  @override
  String get monthAbbrSep => 'Wrz';

  @override
  String get monthAbbrOct => 'Paź';

  @override
  String get monthAbbrNov => 'Lis';

  @override
  String get monthAbbrDec => 'Gru';

  @override
  String get categoryHousing => 'Mieszkanie';

  @override
  String get categoryGroceries => 'Zakupy spożywcze';

  @override
  String get categoryVacation => 'Wakacje';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryInsurance => 'Ubezpieczenie';

  @override
  String get categorySubscriptions => 'Subskrypcje';

  @override
  String get categoryCommunication => 'Komunikacja';

  @override
  String get categoryHealth => 'Zdrowie';

  @override
  String get categoryRestaurants => 'Restauracje';

  @override
  String get categoryEntertainment => 'Rozrywka';

  @override
  String get categoryClothing => 'Odzież';

  @override
  String get categoryEducation => 'Edukacja';

  @override
  String get categoryInvestment => 'Inwestycje';

  @override
  String get categoryGifts => 'Prezenty';

  @override
  String get categoryTaxes => 'Podatki';

  @override
  String get categoryMedications => 'Leki';

  @override
  String get categoryOther => 'Inne';

  @override
  String get financialTypeAsset => 'Aktywa';

  @override
  String get financialTypeConsumption => 'Konsumpcja';

  @override
  String get financialTypeInsurance => 'Ubezpieczenie';

  @override
  String get addPlanItemTitle => 'Dodaj pozycję planu';

  @override
  String get addMonthlyIncomeTitle => 'Dodaj miesięczny dochód';

  @override
  String get addYearlyIncomeTitle => 'Dodaj roczny dochód';

  @override
  String get addOneTimeIncomeTitle => 'Dodaj jednorazowy dochód';

  @override
  String get addMonthlyFixedCostTitle => 'Dodaj miesięczny stały koszt';

  @override
  String get addYearlyFixedCostTitle => 'Dodaj roczny stały koszt';

  @override
  String get editMonthlyIncomeTitle => 'Edytuj miesięczny dochód';

  @override
  String get editYearlyIncomeTitle => 'Edytuj roczny dochód';

  @override
  String get editOneTimeIncomeTitle => 'Edytuj jednorazowy dochód';

  @override
  String get editMonthlyFixedCostTitle => 'Edytuj miesięczny stały koszt';

  @override
  String get editYearlyFixedCostTitle => 'Edytuj roczny stały koszt';

  @override
  String get labelType => 'Typ';

  @override
  String get labelMonth => 'Miesiąc';

  @override
  String get labelYear => 'Rok';

  @override
  String get labelDayOfMonth => 'Dzień miesiąca';

  @override
  String get nameHintText => 'np. Wynagrodzenie, Czynsz, Ubezpieczenie';

  @override
  String get validationEnterName => 'Wprowadź nazwę';

  @override
  String get selectMonthTitle => 'Wybierz miesiąc';

  @override
  String get lastRenewalYearTitle => 'Rok ostatniego odnowienia';

  @override
  String lastMonthRenewal(String monthName) {
    return 'Ostatnie odnowienie w $monthName';
  }

  @override
  String lastActiveMonthInfo(String label) {
    return 'Ostatni aktywny miesiąc: $label';
  }

  @override
  String get setEndDate => 'Ustaw datę końcową';

  @override
  String untilLabel(String validToLabel) {
    return 'Do: $validToLabel';
  }

  @override
  String lastActiveMonthNote(String label) {
    return '$label jest ostatnim aktywnym miesiącem.';
  }

  @override
  String get endMonthAfterStart =>
      'Miesiąc końcowy musi być po miesiącu początkowym.';

  @override
  String get fromFieldLabel => 'Od';

  @override
  String renewedEachMonth(String monthName) {
    return 'Odnawiane co $monthName. Daty są stałe.';
  }

  @override
  String get untilFieldLabel => 'Do';

  @override
  String lastActiveMonthParens(String label) {
    return '$label (ostatni aktywny miesiąc)';
  }

  @override
  String get openEnded => 'Bez końca';

  @override
  String fromDateLabel(String validFromLabel) {
    return 'Od: $validFromLabel';
  }

  @override
  String get samePeriodInPlace =>
      'Ten sam miesiąc co oryginał — zostanie zaktualizowany w miejscu.';

  @override
  String get differentPeriodNewVersion =>
      'Inny miesiąc — zostanie utworzona nowa wersja.';

  @override
  String get applyChangesToTitle => 'Zastosuj zmiany do...';

  @override
  String get applyToWholeSeries => 'Całej serii';

  @override
  String applyToWholeSeriesSubtitle(String seriesStartLabel) {
    return 'Wszystkie okresy od $seriesStartLabel dalej';
  }

  @override
  String applyFromOnwards(String nextLabel) {
    return 'Od $nextLabel dalej';
  }

  @override
  String applyFromSubtitle(String capLabel, String nextLabel) {
    return 'Oryginalna seria kończy się $capLabel.\nNowa seria zaczyna się $nextLabel.';
  }

  @override
  String get applyFromUnavailable =>
      'W tej serii nie ma dostępnego żadnego przyszłego okresu.';

  @override
  String get yearlyItemsOnlyAtRenewal =>
      'Pozycje roczne można zmieniać tylko w miesiącu ich odnowienia.';

  @override
  String get guardRemindMe => 'Przypomnij mi o potwierdzeniu tej płatności';

  @override
  String get guardShorterMonths =>
      'Krótsze miesiące użyją swojego ostatniego dnia.';

  @override
  String get dueDayMonthly => 'Dzień płatności (powtarza się co miesiąc)';

  @override
  String dueDayYearly(String monthName) {
    return 'Dzień płatności (powtarza się każdego $monthName)';
  }

  @override
  String dueDayMonthlyLabel(int day) {
    return 'Dzień $day każdego miesiąca';
  }

  @override
  String dueDayYearlyLabel(int day, String monthName) {
    return 'Dzień $day miesiąca $monthName każdego roku';
  }

  @override
  String get guardDailyReminder => 'Codzienne przypomnienie';

  @override
  String get guardChangeNotifTime => 'Dotknij, aby zmienić czas powiadomienia';

  @override
  String get guardNoGuardedItemsHint =>
      'Włącz GUARD przy stałym koszcie, aby śledzić płatności.';

  @override
  String guardedItemsCount(int count) {
    return 'Chronione pozycje · $count';
  }

  @override
  String get planItemTitle => 'Pozycja planu';

  @override
  String get activeFrom => 'Aktywne od';

  @override
  String get activeUntil => 'Aktywne do';

  @override
  String get perMonth => '/ miesiąc';

  @override
  String get perYear => '/ rok';

  @override
  String get oneTimeSuffix => '(jednorazowo)';

  @override
  String get noEndDate => 'Brak daty końcowej';

  @override
  String get guardNotEnabled => 'Nie włączono';

  @override
  String removeIncomeEntirely(String name) {
    return '„$name” zostanie całkowicie usunięte.';
  }

  @override
  String removeIncomeFromOnwards(String name, String from, String prev) {
    return '„$name” zostanie zatrzymane od $from dalej. $prev i wcześniejsze okresy pozostaną zaplanowane.';
  }

  @override
  String get actionRemoveAllCaps => 'USUŃ';

  @override
  String get removeBudgetAllCaps => 'USUŃ BUDŻET';

  @override
  String removeFromOnwardsTitle(String label) {
    return 'Od $label dalej';
  }

  @override
  String removeCycleSubtitle(String start, String end) {
    return 'Ten cykl ($start – $end) i wszystkie przyszłe cykle zostaną usunięte.';
  }

  @override
  String removeHistoryKept(String prev) {
    return 'Historia do $prev zostaje zachowana.';
  }

  @override
  String get silenceReminderTitle => 'Wyciszyć to przypomnienie?';

  @override
  String silenceReminderBody(String periodLabel) {
    return 'Płatność za $periodLabel nadal będzie pokazywana jako niepotwierdzona. Możesz w każdej chwili oznaczyć ją jako opłaconą.';
  }

  @override
  String get yesSilence => 'Tak, wycisz';

  @override
  String get addPlanItemTooltip => 'Dodaj pozycję planu';

  @override
  String get spendableThisMonth => 'Do wydania w tym miesiącu';

  @override
  String get spendableThisYear => 'Do wydania w tym roku';

  @override
  String get noPlanItemsYet => 'Brak jeszcze pozycji planu.';

  @override
  String get tapPlusToAddPlanItems =>
      'Dotknij +, aby dodać dochód lub stałe koszty.';

  @override
  String get removeWholeSeries => 'Cała seria';

  @override
  String removeWholeSeriesSubtitle(String seriesStartLabel) {
    return 'Wszystkie okresy od $seriesStartLabel są usuwane.';
  }

  @override
  String get clearAllDataAction => 'USUŃ';

  @override
  String get clearAllDataDescription =>
      'Wydatki, pozycje planu, budżety i płatności guard zostaną trwale usunięte. Tej operacji nie można cofnąć.';

  @override
  String get clearAllDataPreservedNote =>
      'Zapisane snapshoty i automatyczne kopie zapasowe pozostają bez zmian.';

  @override
  String get allCategoriesBudgeted =>
      'Wszystkie kategorie mają już budżet na ten miesiąc. Wybierz inny miesiąc, aby dodać kolejny.';

  @override
  String get selectCategoryHint => 'Wybierz kategorię';

  @override
  String get validationSelectCategory => 'Wybierz kategorię';

  @override
  String get monthlyBudgetLabel => 'Budżet miesięczny';

  @override
  String effectiveFromLabel(String validFromLabel) {
    return 'Obowiązuje od: $validFromLabel';
  }

  @override
  String pastMonthBudgetCreateWarning(String fromLabel) {
    return 'Tworzysz budżet dla wcześniejszego miesiąca. Będzie obowiązywał wstecz od $fromLabel.';
  }

  @override
  String pastMonthBudgetEditWarning(
    String catName,
    String fromLabel,
    String prevLabel,
  ) {
    return 'To zmieni budżet kategorii $catName wstecz do $fromLabel. Miesiące $fromLabel–$prevLabel użyją nowej kwoty.';
  }

  @override
  String get noFixedCostsPlanned => 'Brak zaplanowanych stałych kosztów';

  @override
  String get noIncomePlanned => 'Brak zaplanowanego dochodu';

  @override
  String saveSlotSubtitle(String date, int expenseCount, int planItemCount) {
    return '$date · $expenseCount wydatków · $planItemCount pozycji planu';
  }

  @override
  String get saveSlotDamagedSubtitle =>
      'Plik jest uszkodzony i nie można go wczytać';

  @override
  String get howGroupsWorkTitle => 'Jak to działa?';

  @override
  String get howGroupsTitle => 'Grupy';

  @override
  String get howGroupsSubtitle0 => 'Czym jest grupa i jak działa';

  @override
  String get howGroupsSubtitle1 => 'Jak najlepiej to wykorzystać';

  @override
  String get howGroupsSubtitle2 => 'Gdzie grupy pojawiają się w aplikacji';

  @override
  String get howGroupsLabel0 => 'Tag';

  @override
  String get howGroupsLabel1 => 'Bądź kreatywny';

  @override
  String get howGroupsLabel2 => 'Rejestr';

  @override
  String get howGroupsRule1 =>
      'Grupa to opcjonalna etykieta dowolnego tekstu, którą przypisujesz do dowolnego wydatku.';

  @override
  String get howGroupsRule2 =>
      'Możesz wpisać dowolny ciąg znaków — nie ma stałej listy ani walidacji.';

  @override
  String get howGroupsRule3 =>
      'Dwa wydatki należą do tej samej grupy tylko wtedy, gdy ich etykiety są dokładnie takie same, znak po znaku.';

  @override
  String get howGroupsRule4 =>
      'Wielkość liter jest zachowana — „Trip” i „trip” są traktowane jako dwie różne grupy.';

  @override
  String get howGroupsRule5 =>
      'To pole jest opcjonalne. Zostaw je puste, a wydatek po prostu nie będzie miał grupy.';

  @override
  String get howGroupsHint =>
      'Ustaw grupę podczas tworzenia lub edycji dowolnego wydatku.';

  @override
  String get howGroupsUseIntro =>
      'Używaj tego zawsze, gdy chcesz śledzić fragment wydatków przecinający się z wieloma kategoriami.';

  @override
  String howGroupsExample1Label(int year) {
    return 'Barcelona $year';
  }

  @override
  String get howGroupsExample1Desc =>
      'Przypisz ją do każdego wydatku podczas podróży — lotów, hoteli, posiłków, biletów. Zobacz całkowity koszt całej podróży jednym dotknięciem.';

  @override
  String howGroupsExample2Label(int year) {
    return 'McDonald\'\'s $year';
  }

  @override
  String get howGroupsExample2Desc =>
      'Używaj spójnej nazwy przez cały rok. Pod koniec roku będziesz dokładnie wiedzieć, ile wydałeś w tym jednym miejscu.';

  @override
  String get howGroupsExample3Label => 'Remont domu Q1';

  @override
  String get howGroupsExample3Desc =>
      'Rozciągnij ten sam tag na wiele miesięcy. Karta Grupy zbierze wszystko pod tą nazwą.';

  @override
  String get howGroupsPrecision =>
      'Im bardziej precyzyjny jest twój tag, tym bardziej użyteczne będzie podsumowanie.';

  @override
  String get howGroupsRecord0Title => 'Karta Grupy w Wydatkach';

  @override
  String get howGroupsRecord0Body =>
      'Każda grupa, która ma co najmniej jeden wydatek w bieżącym miesiącu, pojawia się tutaj jako jeden wiersz pokazujący liczbę pozycji i sumę. Dotknij grupy, aby wejść głębiej i zobaczyć każdy pojedynczy wydatek, który za nią stoi.';

  @override
  String get howGroupsRecord1Title => 'Raport miesięczny w Raportach';

  @override
  String get howGroupsRecord1Body =>
      'Gdy eksportujesz miesięczny PDF z ekranu Raporty, grupy z wydatkami w tym miesiącu otrzymują osobną stronę „Grupy wydatków” — każda grupa jest wymieniona wraz ze swoimi wydatkami, kwotami i sumą grupy.';

  @override
  String get howGroupsMonthlyNote =>
      'Grupy nie są uwzględniane w raporcie rocznym — to miesięczna perspektywa.';

  @override
  String get howGroupsExampleGroupName => 'Moja grupa';

  @override
  String get otherCategories => 'Inne kategorie';

  @override
  String noCategoryExpenses(String category, String period) {
    return 'Brak wydatków kategorii $category\nw $period.';
  }

  @override
  String guardDueDate(String monthName, int day, int year) {
    return 'Termin $monthName $day, $year';
  }

  @override
  String get guardNotYetDue => 'Jeszcze nie jest wymagalne';

  @override
  String guardNextReminder(String label) {
    return 'Następne: $label';
  }

  @override
  String guardLastReminder(String label) {
    return 'Ostatnie: $label';
  }

  @override
  String get guardChangeDay => 'Zmień dzień';

  @override
  String get guardRemoveAction => 'Usuń GUARD';

  @override
  String get guardMarkUnpaidTitle => 'Oznaczyć jako nieopłacone?';

  @override
  String guardMarkUnpaidBody(String monthName, int year) {
    return 'To usunie potwierdzenie płatności dla $monthName $year.';
  }

  @override
  String get guardMarkUnpaidAction => 'Oznacz jako nieopłacone';

  @override
  String get guardMarkAsPaid => 'Oznacz jako opłacone';

  @override
  String get guardRemoveTitle => 'Usunąć GUARD?';

  @override
  String guardRemoveBody(String name) {
    return 'GUARD zostanie wyłączony dla „$name”. Istniejące rekordy płatności zostaną zachowane, ale nowe przypomnienia nie będą już uruchamiane.';
  }

  @override
  String get guardRemoveConfirm => 'Usuń';

  @override
  String get guardSelectPaidDate => 'Wybierz datę opłacenia';

  @override
  String guardPaidOn(String date) {
    return 'Opłacono $date';
  }

  @override
  String howItWorksStep(int n) {
    return 'KROK $n';
  }

  @override
  String get planSubtitle0 => 'Twoje wynagrodzenie i stałe miesięczne rachunki';

  @override
  String get planSubtitle1 => 'Jak klasyfikowane są twoje stałe koszty';

  @override
  String get planSubtitle2 => 'Jaką część twojego dochodu pochłania każdy typ';

  @override
  String get planSubStep0 => 'Przepływ gotówki';

  @override
  String get planSubStep1 => 'Klasyfikacja';

  @override
  String get planSubStep2 => 'Alokacja';

  @override
  String get howItWorksPlanIncomeBody =>
      'Wprowadź swoje wynagrodzenie i stałe miesięczne rachunki — czynsz, ubezpieczenie, subskrypcje. To są prawdziwe, znane liczby, a nie szacunki ani cele.';

  @override
  String get howItWorksTypeConsumptionDesc =>
      'Codzienne wydatki — zakupy spożywcze, czynsz, jedzenie na mieście, transport';

  @override
  String get howItWorksTypeAssetDesc =>
      'Inwestycje i oszczędności, które z czasem powiększają twój majątek';

  @override
  String get howItWorksTypeInsuranceDesc =>
      'Koszty ochrony — ubezpieczenie samochodu, zdrowia i życia';

  @override
  String get howItWorksFinancialTypesBody =>
      'Każdy stały koszt jest oznaczony typem finansowym. Dzięki temu aplikacja może pokazać, jak twój dochód jest rozłożony między wydatki, oszczędności i ochronę.';

  @override
  String get howItWorksSpendingVsIncomeTitle => 'Wydatki vs Dochód';

  @override
  String get howItWorksSpendingVsIncomeBody =>
      'Karta Plan pokazuje, ile twojego dochodu trafia do każdego typu finansowego — dzięki czemu na pierwszy rzut oka widzisz, czy wydajesz, oszczędzasz lub chronisz właściwą część tego, co zarabiasz.';

  @override
  String get expSubtitle0 => 'Twój dostępny budżet, obliczony z Planu';

  @override
  String get expSubtitle1 => 'Codzienne wydatki, które zapisujesz';

  @override
  String get expSubtitle2 => 'Czy zmieściłeś się w budżecie?';

  @override
  String get subStepBudget => 'Budżet';

  @override
  String get subStepSpending => 'Wydawanie';

  @override
  String get subStepResult => 'Wynik';

  @override
  String get howItWorksBudgetBody =>
      'Aplikacja odejmuje twoje stałe koszty od twojego dochodu i pokazuje wynik tutaj. Nie ustawiasz tej liczby — pochodzi z twojego Planu.';

  @override
  String get howItWorksSpendingBody =>
      'Zapisuj zakupy spożywcze, posiłki, zakupy i inne zmienne wydatki. Stałe miesięczne rachunki, takie jak czynsz, należą do Planu, nie tutaj.';

  @override
  String get howItWorksResultBody =>
      'Na koniec miesiąca karta Wydatki pokaże, jaki wynik osiągnąłeś.';

  @override
  String get repSubtitle0 => 'Gdzie poszły twoje pieniądze?';

  @override
  String get repSubtitle1 => 'Twoje finanse na papierze';

  @override
  String get repSubtitle2 => 'Pełny obraz, miesiąc po miesiącu';

  @override
  String get repSubStep0 => 'Podział';

  @override
  String get repSubStep1 => 'Eksport';

  @override
  String get repSubStep2 => 'Przegląd';

  @override
  String get howItWorksBreakdownBody =>
      'Podział pokazuje twoje wydatki według kategorii dla dowolnego miesiąca lub roku. Dotknij wycinka lub wiersza kategorii, aby przejść do pojedynczych wydatków i stałych kosztów, które za nimi stoją.';

  @override
  String get pdfFeatureCategoryTotals => 'Sumy kategorii';

  @override
  String get pdfFeatureBudgetVsActual => 'Budżet vs rzeczywistość';

  @override
  String get pdfFeatureTypeSplit => 'Podział typu finansowego';

  @override
  String get pdfFeatureAllExpenses => 'Wszystkie wydatki wymienione';

  @override
  String get pdfFeatureCategoryBudgets => 'Budżety kategorii';

  @override
  String get pdfFeatureGroupSummaries => 'Podsumowania grup';

  @override
  String get pdfFeature12MonthOverview => 'Przegląd 12 miesięcy';

  @override
  String get pdfFeatureAnnualTotals => 'Roczne sumy';

  @override
  String get pdfFeatureMonthlyBreakdown => 'Podział miesięczny';

  @override
  String get pdfFeaturePlanVsActual => 'Plan vs rzeczywistość';

  @override
  String get pdfFeatureTypeRatios => 'Wskaźniki typów';

  @override
  String get pdfFeatureActivePlanItems => 'Aktywne pozycje planu';

  @override
  String get howItWorksExportBody =>
      'Użyj przycisku PDF w Podziale, aby eksportować. Raporty można udostępniać przez dowolną aplikację na twoim urządzeniu.';

  @override
  String get howItWorksMoreMonths => '· · · jeszcze 9 miesięcy';

  @override
  String get howItWorksOverviewBody =>
      'Przegląd pokazuje wszystkie 12 miesięcy obok siebie — ile zarobiłeś, ile trafiło do aktywów i ile zostało skonsumowane. Dotknij dowolnego miesiąca, aby przejść do tego okresu w Planie.';

  @override
  String overBudgetBy(String amount) {
    return 'Ponad budżet o $amount';
  }

  @override
  String savedAmount(String amount) {
    return 'Zaoszczędzono $amount';
  }

  @override
  String get loadingLabel => 'Ładowanie…';

  @override
  String get autoBackupTitle => 'Automatyczna kopia zapasowa';

  @override
  String get autoBackupNoBackupYet => 'Brak kopii zapasowej';

  @override
  String get autoBackupSubtitleExpand =>
      'Aktualizowane codziennie · dotknij, aby rozwinąć';

  @override
  String get autoBackupSubtitleCollapse =>
      'Aktualizowane codziennie · dotknij, aby zwinąć';

  @override
  String get actionRestoreAllCaps => 'PRZYWRÓĆ';

  @override
  String get actionRestore => 'Przywróć';

  @override
  String get autoBackupRestoreDescription =>
      'Przywrócenie zastąpi wszystkie bieżące dane kopią zapasową.';

  @override
  String autoBackupRestored(String date) {
    return 'Przywrócono kopię zapasową z $date.';
  }

  @override
  String get autoBackupRestoreFailed =>
      'Nie udało się przywrócić kopii zapasowej.';

  @override
  String get autoBackupPrimary => 'Główna kopia zapasowa';

  @override
  String get autoBackupSecondary => 'Pomocnicza kopia zapasowa';

  @override
  String get frequencyPickerFixed => 'Jak często to się powtarza?';

  @override
  String get frequencyMonthlyFixedSubtitle =>
      'Czynsz, subskrypcje, powtarzające się rachunki';

  @override
  String get frequencyYearlyFixedSubtitle =>
      'Roczne subskrypcje, ubezpieczenia, członkostwa';

  @override
  String get frequencyPickerIncome => 'Jak często to otrzymujesz?';

  @override
  String get frequencyMonthlyIncomeSubtitle =>
      'Wynagrodzenie, emerytura, regularne przelewy';

  @override
  String get frequencyYearlyIncomeSubtitle =>
      'Roczna premia, zwrot podatku, dywidendy';

  @override
  String get frequencyOneTimeIncomeSubtitle =>
      'Prezent, niespodziewany dochód, jednorazowa płatność';

  @override
  String get typePickerTitle => 'Co dodajesz?';

  @override
  String get typeIncomeSubtitle => 'Wynagrodzenie, premia, emerytura, prezenty';

  @override
  String get typeFixedCostSubtitle => 'Czynsz, ubezpieczenie, subskrypcje';

  @override
  String get languagePickerTitle => 'Język';

  @override
  String get currencyPickerTitle => 'Waluta';

  @override
  String get currencyCustom => 'Niestandardowa';

  @override
  String get currencyCustomSubtitle => 'Zdefiniuj własny kod i symbol';

  @override
  String get currencyCustomTitle => 'Waluta niestandardowa';

  @override
  String get currencyCodeLabel => 'Kod';

  @override
  String get currencyCodeHint => 'np. USD';

  @override
  String get currencySymbolLabel => 'Symbol';

  @override
  String get currencySymbolHint => 'np. \$';

  @override
  String get removeFromImport => 'Usuń z importu';

  @override
  String get exportExpensesTitle => 'Eksportuj wydatki';

  @override
  String get selectDateRangeHint => 'Wybierz zakres dat do eksportu:';

  @override
  String get startDateLabel => 'Data początkowa';

  @override
  String get endDateLabel => 'Data końcowa';

  @override
  String get tapToSelectDate => 'Dotknij, aby wybrać';

  @override
  String get endDateAfterStart =>
      'Data końcowa musi przypadać w dniu rozpoczęcia lub po nim.';

  @override
  String get actionExport => 'Eksportuj';

  @override
  String overspendWarning(String period, String amount) {
    return 'W tym $period wydałeś o $amount więcej, niż zarobiłeś!';
  }

  @override
  String get periodMonth => 'miesiącu';

  @override
  String get periodYear => 'roku';

  @override
  String guardBannerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'GUARD — $count płatności nie zostało potwierdzonych',
      many: 'GUARD — $count płatności nie zostało potwierdzonych',
      few: 'GUARD — $count płatności nie zostały potwierdzone',
      one: 'GUARD — 1 płatność nie została potwierdzona',
    );
    return '$_temp0';
  }

  @override
  String get guardSilencedBadge => 'wyciszone';

  @override
  String guardExpenseStripPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chronionych płatności oczekuje',
      many: '$count chronionych płatności oczekuje',
      few: '$count chronione płatności oczekują',
      one: '1 chroniona płatność oczekuje',
    );
    return '$_temp0';
  }

  @override
  String importErrorRowLabel(int row, String field) {
    return 'Wiersz $row — $field';
  }

  @override
  String earnedLabel(String amount) {
    return 'Zarobiono: $amount';
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
  String get guardEnableToggle => 'Włącz GUARD';

  @override
  String get guardEnableToggleSubtitle =>
      'Śledź płatność i otrzymuj przypomnienia';

  @override
  String get actionOk => 'OK';

  @override
  String get labelTotal => 'Razem';

  @override
  String get categoryBudgetsTitle => 'Budżety kategorii';

  @override
  String get noCategoryBudgetsSet => 'Brak ustawionych budżetów kategorii.';

  @override
  String removeBudgetDialogTitle(String category) {
    return 'Usuń budżet kategorii $category';
  }

  @override
  String endBudgetFromTitle(String from) {
    return 'Zakończ od $from';
  }

  @override
  String endBudgetFromDescription(String from) {
    return 'Zatrzymuje budżet od $from dalej. Wcześniejsze miesiące zachowają swój historyczny budżet.';
  }

  @override
  String get deleteBudgetSeriesTitle => 'Usuń całą serię';

  @override
  String get deleteBudgetSeriesConfirm => 'Usuń serię';

  @override
  String deleteBudgetSeriesDescription(String range) {
    return 'Trwale usuwa wszystkie rekordy ($range). Budżet nie pojawi się w żadnym miesiącu tej serii. Tej operacji nie można cofnąć.';
  }

  @override
  String budgetRangePresent(String start) {
    return '$start – obecnie';
  }

  @override
  String get pdfMonthlyReport => 'Raport miesięczny';

  @override
  String get pdfYearlyReport => 'Raport roczny';

  @override
  String pdfMonthlyReportHeader(String month, int year) {
    return 'RAPORT MIESIĘCZNY ZA $month $year';
  }

  @override
  String pdfYearlyReportHeader(int year) {
    return 'RAPORT ROCZNY ZA $year';
  }

  @override
  String get pdfPartialYear => '(niepełny rok)';

  @override
  String get pdfSectionSpendingVsIncome => 'WYDATKI VS DOCHÓD';

  @override
  String get pdfSectionCategorySummary => 'PODSUMOWANIE KATEGORII';

  @override
  String get pdfSectionCashFlowSummary => 'PODSUMOWANIE PRZEPŁYWU GOTÓWKI';

  @override
  String get pdfSectionExpenseGroups => 'GRUPY WYDATKÓW';

  @override
  String get pdfSectionExpenseDetails => 'SZCZEGÓŁY WYDATKÓW';

  @override
  String get pdfSectionYearlyOverview => 'PRZEGLĄD ROCZNY';

  @override
  String get pdfSectionSpendingByCategory =>
      'WYDATKI WEDŁUG KATEGORII I MIESIĘCY';

  @override
  String get pdfIncomeHeader => 'DOCHÓD';

  @override
  String get pdfFixedCostsHeader => 'STAŁE KOSZTY';

  @override
  String get pdfTotal => 'RAZEM';

  @override
  String get pdfColTotal => 'Razem';

  @override
  String get pdfEarnedThisMonth => 'Zarobiono w tym miesiącu';

  @override
  String get pdfEarnedThisYear => 'Zarobiono w tym roku';

  @override
  String get pdfGroupTotal => 'Suma grupy (w tym miesiącu)';

  @override
  String get pdfAllPeriodsTotal => 'Suma wszystkich okresów';

  @override
  String pdfItemsThisMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pozycji w tym miesiącu',
      many: '$count pozycji w tym miesiącu',
      few: '$count pozycje w tym miesiącu',
      one: '1 pozycja w tym miesiącu',
    );
    return '$_temp0';
  }

  @override
  String get pdfNormalized => ' (znormalizowane)';

  @override
  String get pdfAnnualized => ' (w ujęciu rocznym)';

  @override
  String get pdfPartialYearNote =>
      'Niepełny rok - miesiące bez danych pokazują zera. Tylko sumy od początku roku do dziś.';

  @override
  String pdfPage(int page, int total) {
    return 'Strona $page z $total';
  }

  @override
  String get pdfNoData => 'Brak danych.';

  @override
  String get howItWorksExampleSalary => 'Wynagrodzenie';

  @override
  String get howItWorksExampleBonus => 'Premia';

  @override
  String get howItWorksExampleRent => 'Czynsz';

  @override
  String get howItWorksExampleInsurance => 'Ubezpieczenie';

  @override
  String get howItWorksExampleEtfFonds => 'Fundusze ETF';

  @override
  String get addBudgetTooltip => 'Dodaj budżet';
}
