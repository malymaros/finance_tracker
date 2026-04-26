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
  String get menuResetWithDummyData => 'Zresetuj z danymi testowymi';

  @override
  String get menuManageBudgets => 'Zarządzaj budżetami';

  @override
  String get menuGuard => 'Ustawienia GUARD';

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
    return 'W miesiącu $monthName $year nie ma żadnych wydatków.';
  }

  @override
  String get tapPlusToAddOne => 'Stuknij +, aby dodać wydatek.';

  @override
  String get fixedBillsHint =>
      'Stałe płatności, takie jak czynsz, należą do Planu.';

  @override
  String get noGroupsThisMonth => 'W tym miesiącu nie ma żadnych grup.';

  @override
  String get addGroupHint =>
      'Dodaj grupę podczas tworzenia\nlub edycji wydatku.';

  @override
  String get howGroupsWorkQuestion => 'Jak działają grupy?';

  @override
  String get howGuardWorkQuestion => 'Jak działa GUARD?';

  @override
  String get howCategoryBudgetsWorkQuestion =>
      'Jak działają budżety kategorii?';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pozycji',
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
  String get validationAmountInvalid => 'Wprowadź prawidłową dodatnią liczbę';

  @override
  String get expenseDetailTitle => 'Wydatek';

  @override
  String noExpensesInNamedGroup(String name) {
    return 'W grupie „$name” nie ma żadnych wydatków.';
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
  String get sectionFixedCosts => 'Stałe wydatki';

  @override
  String get noIncomeItems => 'Brak pozycji dochodu.';

  @override
  String get noFixedCostItems => 'Brak pozycji stałych wydatków.';

  @override
  String get spendableBudget => 'Budżet do wydania';

  @override
  String get deleteItemDialogTitle => 'Usuń pozycję planu';

  @override
  String get deleteItemFromPeriod => 'Od tego okresu';

  @override
  String get deleteItemWholeSeries => 'Całą serię';

  @override
  String get planItemDeleted => 'Pozycja planu została usunięta.';

  @override
  String get addIncomeTitle => 'Dodaj dochód';

  @override
  String get addFixedCostTitle => 'Dodaj stały wydatek';

  @override
  String get editIncomeTitle => 'Edytuj dochód';

  @override
  String get editFixedCostTitle => 'Edytuj stały wydatek';

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
  String get typeFixedCost => 'Stały wydatek';

  @override
  String get ongoing => 'Bez zakończenia';

  @override
  String get manageBudgetsTitle => 'Zarządzaj budżetami';

  @override
  String get noBudgetsSet => 'Dla tego okresu nie ustawiono żadnych budżetów.';

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
      'Ustawienie budżetu w przeszłości nie wpłynie na minione wydatki.';

  @override
  String get budgetSaved => 'Budżet został zapisany.';

  @override
  String get budgetDeleted => 'Budżet został usunięty.';

  @override
  String get guardScreenTitle => 'GUARD';

  @override
  String get guardDailyReminderTime => 'Godzina codziennego przypomnienia';

  @override
  String get guardTimePicker => 'Godzina codziennego przypomnienia GUARD';

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
  String get noGuardedItems => 'Brak śledzonych pozycji.';

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
  String get noExpensesForPeriod =>
      'Dla tego okresu nie zapisano żadnych wydatków.';

  @override
  String get noIncomeOrSpendingDataForYear =>
      'Dla tego roku nie ma danych o dochodach ani wydatkach.';

  @override
  String get pieChartOther => 'Inne';

  @override
  String get reportSectionFixedCosts => 'STAŁE KOSZTY';

  @override
  String get reportSectionExpenses => 'WYDATKI';

  @override
  String get noneInPeriod => 'W tym okresie nic.';

  @override
  String fixedCostCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stałych wydatków',
      few: '$count stałe wydatki',
      one: '1 stały wydatek',
    );
    return '$_temp0';
  }

  @override
  String expenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wydatków',
      few: '$count wydatki',
      one: '1 wydatek',
    );
    return '$_temp0';
  }

  @override
  String get noItemsInPeriod => 'W tym okresie nie ma żadnych pozycji';

  @override
  String get importTitle => 'Importuj wydatki';

  @override
  String get importStep1Title => 'Pobierz szablon';

  @override
  String get importStep1Description =>
      'Pobierz oficjalny szablon Excel ze wszystkimi wymaganymi kolumnami i instrukcjami dotyczącymi prawidłowych wartości.';

  @override
  String get importStep1Button => 'Pobierz szablon';

  @override
  String get importStep2Title => 'Wypełnij i zaimportuj';

  @override
  String get importStep2Description =>
      'Wypełnij szablon w Excelu lub Google Sheets, a następnie wybierz tutaj plik do importu wydatków.';

  @override
  String get importStep2Button => 'Wybierz plik (.xlsx lub .csv)';

  @override
  String get importInfoText =>
      'Importować można tylko wydatki. Dochody i pozycje planu nie są obsługiwane.\n\nObsługiwane formaty: .xlsx (Excel) i .csv.\nPliki CSV muszą mieć taką samą kolejność kolumn jak szablon: Data, Kwota, Kategoria, Typ finansowy, Notatka, Grupa.\n\nPliki wyeksportowane z tej aplikacji można importować bezpośrednio.';

  @override
  String importReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wydatków gotowych do importu',
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
      other: '$count wierszy nie udało się wczytać',
      few: '$count wierszy nie udało się wczytać',
      one: '1 wiersza nie udało się wczytać',
    );
    return '$_temp0';
  }

  @override
  String importErrorCountSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wierszy nie udało się wczytać — zostaną pominięte',
      few: '$count wiersze nie udało się wczytać — zostaną pominięte',
      one: '1 wiersza nie udało się wczytać — zostanie pominięty',
    );
    return '$_temp0';
  }

  @override
  String get importNoDataFound => 'W pliku nie znaleziono żadnych danych.';

  @override
  String get importTapToEdit =>
      'Stuknij dowolny wiersz, aby go przed importem edytować lub usunąć.';

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
      other: '$count wydatków zaimportowanych · $range',
      few: '$count wydatki zaimportowane · $range',
      one: '1 wydatek zaimportowany · $range',
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
  String get tryAnotherFile => 'Spróbuj inny plik';

  @override
  String get savesTitle => 'Zapisy';

  @override
  String get sectionAutoBackup => 'AUTOMATYCZNA KOPIA ZAPASOWA';

  @override
  String get sectionSaves => 'ZAPISY';

  @override
  String get sectionDataTransfer => 'PRZENOSZENIE DANYCH';

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
    return '„$name” zostało zapisane.';
  }

  @override
  String loadedConfirmation(String name) {
    return '„$name” zostało wczytane.';
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
    return '$amount ponad limit';
  }

  @override
  String underBudgetAmount(String amount) {
    return 'Pozostało $amount';
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
    return '$spent wydane  /  $budget budżet';
  }

  @override
  String categoryBudgetOverBy(String category, String amount) {
    return 'Budżet $category: przekroczony o $amount';
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
  String get categoryElectronics => 'Elektronika';

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
  String get categoryUtilities => 'Media i usługi';

  @override
  String get categoryHousehold => 'Artykuły gospodarstwa domowego';

  @override
  String get categoryPersonalCare => 'Pielęgnacja osobista';

  @override
  String get categorySavings => 'Oszczędności';

  @override
  String get categoryDebt => 'Długi';

  @override
  String get categoryKids => 'Dzieci';

  @override
  String get categoryPets => 'Zwierzęta domowe';

  @override
  String get categoryFees => 'Opłaty';

  @override
  String get categoryFuel => 'Paliwo';

  @override
  String get categoryMaintenance => 'Konserwacja';

  @override
  String get categoryDonations => 'Darowizny';

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
  String get addMonthlyFixedCostTitle => 'Dodaj miesięczny stały wydatek';

  @override
  String get addYearlyFixedCostTitle => 'Dodaj roczny stały wydatek';

  @override
  String get editMonthlyIncomeTitle => 'Edytuj miesięczny dochód';

  @override
  String get editYearlyIncomeTitle => 'Edytuj roczny dochód';

  @override
  String get editOneTimeIncomeTitle => 'Edytuj jednorazowy dochód';

  @override
  String get editMonthlyFixedCostTitle => 'Edytuj miesięczny stały wydatek';

  @override
  String get editYearlyFixedCostTitle => 'Edytuj roczny stały wydatek';

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
    return 'Ostatnie odnowienie w miesiącu $monthName';
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
    return '$label to ostatni aktywny miesiąc.';
  }

  @override
  String get endMonthAfterStart =>
      'Miesiąc końcowy musi być po miesiącu początkowym.';

  @override
  String get fromFieldLabel => 'Od';

  @override
  String renewedEachMonth(String monthName) {
    return 'Odnawia się co $monthName. Daty są stałe.';
  }

  @override
  String get untilFieldLabel => 'Do';

  @override
  String lastActiveMonthParens(String label) {
    return '$label (ostatni aktywny miesiąc)';
  }

  @override
  String get openEnded => 'Bez zakończenia';

  @override
  String fromDateLabel(String validFromLabel) {
    return 'Od: $validFromLabel';
  }

  @override
  String get samePeriodInPlace =>
      'Ten sam miesiąc co oryginalny — aktualizacja w miejscu.';

  @override
  String get differentPeriodNewVersion =>
      'Inny miesiąc — zostanie utworzona nowa wersja.';

  @override
  String get applyChangesToTitle => 'Zastosować zmiany do...';

  @override
  String get applyToWholeSeries => 'Całą serię';

  @override
  String applyToWholeSeriesSubtitle(String seriesStartLabel) {
    return 'Wszystkie okresy od $seriesStartLabel';
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
  String get guardRemindMe => 'Przypomnij mi, abym potwierdził tę płatność';

  @override
  String get guardShorterMonths =>
      'Krótsze miesiące użyją swojego ostatniego dnia.';

  @override
  String get dueDayMonthly => 'Dzień płatności (powtarzaj co miesiąc)';

  @override
  String dueDayYearly(String monthName) {
    return 'Dzień płatności (powtarzaj co $monthName)';
  }

  @override
  String dueDayMonthlyLabel(int day) {
    return '$day. dzień każdego miesiąca';
  }

  @override
  String dueDayYearlyLabel(int day, String monthName) {
    return '$day. dzień miesiąca $monthName każdego roku';
  }

  @override
  String get guardDailyReminder => 'Codzienne przypomnienie';

  @override
  String get guardChangeNotifTime =>
      'Stuknij, aby zmienić godzinę powiadomienia';

  @override
  String get guardNoGuardedItemsHint =>
      'Włącz GUARD przy stałym wydatku, aby śledzić płatności.';

  @override
  String guardedItemsCount(int count) {
    return 'Śledzone pozycje · $count';
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
  String get noEndDate => 'Bez daty końcowej';

  @override
  String get guardNotEnabled => 'Nie włączono';

  @override
  String removeIncomeEntirely(String name) {
    return '„$name” zostanie usunięte całkowicie.';
  }

  @override
  String removeIncomeFromOnwards(String name, String from, String prev) {
    return '„$name” zostanie zatrzymane od $from. $prev i wcześniejsze okresy pozostaną zaplanowane.';
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
    return 'Historia do $prev zostanie zachowana.';
  }

  @override
  String get silenceReminderTitle => 'Wyciszyć to przypomnienie?';

  @override
  String silenceReminderBody(String periodLabel) {
    return 'Płatność za okres $periodLabel nadal będzie wyświetlana jako niepotwierdzona. W każdej chwili możesz oznaczyć ją jako opłaconą.';
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
  String get noPlanItemsYet => 'Nie ma jeszcze żadnych pozycji planu.';

  @override
  String get tapPlusToAddPlanItems =>
      'Stuknij +, aby dodać dochód lub stałe koszty.';

  @override
  String get removeWholeSeries => 'Całą serię';

  @override
  String removeWholeSeriesSubtitle(String seriesStartLabel) {
    return 'Wszystkie okresy od $seriesStartLabel zostaną usunięte.';
  }

  @override
  String get clearAllDataAction => 'WYCZYŚĆ';

  @override
  String get clearAllDataDescription =>
      'Wydatki, pozycje planu, budżety i płatności GUARD zostaną trwale usunięte. Tej operacji nie można cofnąć.';

  @override
  String get clearAllDataPreservedNote =>
      'Zapisane snapshoty i automatyczne kopie zapasowe nie zostaną naruszone.';

  @override
  String get allCategoriesBudgeted =>
      'Wszystkie kategorie mają już ustawiony budżet na ten miesiąc. Wybierz inny miesiąc, jeśli chcesz dodać kolejny.';

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
    return 'Tworzysz budżet dla poprzedniego miesiąca. Będzie obowiązywał wstecz od $fromLabel.';
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
  String get noFixedCostsPlanned => 'Nie zaplanowano stałych kosztów';

  @override
  String get noIncomePlanned => 'Nie zaplanowano dochodu';

  @override
  String saveSlotSubtitle(String date, int expenseCount, int planItemCount) {
    return '$date · $expenseCount wydatków · $planItemCount pozycji planu';
  }

  @override
  String get saveSlotDamagedSubtitle =>
      'Plik jest uszkodzony i nie można go wczytać';

  @override
  String get howGroupsTitle => 'Grupy';

  @override
  String get howGroupsSubtitle0 => 'Czym jest grupa i jak działa';

  @override
  String get howGroupsSubtitle1 => 'Jak wyciągnąć z niej jak najwięcej';

  @override
  String get howGroupsSubtitle2 => 'Gdzie grupy pojawiają się w aplikacji';

  @override
  String get howGroupsLabel0 => 'Etykieta';

  @override
  String get howGroupsLabel1 => 'Bądź kreatywny';

  @override
  String get howGroupsLabel2 => 'Przegląd';

  @override
  String get howGroupsRule1 =>
      'Grupa to opcjonalna etykieta tekstowa, którą możesz przypisać do każdego wydatku.';

  @override
  String get howGroupsRule2 =>
      'Możesz wpisać dowolny tekst — nie istnieje stała lista ani walidacja.';

  @override
  String get howGroupsRule3 =>
      'Dwa wydatki należą do tej samej grupy tylko wtedy, gdy ich nazwy są identyczne, znak po znaku.';

  @override
  String get howGroupsRule4 =>
      'Rozróżniana jest wielkość liter — „Trip” i „trip” to dwie różne grupy.';

  @override
  String get howGroupsRule5 =>
      'Pole jest opcjonalne. Jeśli pozostawisz je puste, wydatek po prostu nie będzie miał grupy.';

  @override
  String get howGroupsHint =>
      'Grupę ustawiasz podczas tworzenia lub edycji dowolnego wydatku.';

  @override
  String get howGroupsUseIntro =>
      'Użyj jej zawsze, gdy chcesz śledzić wycinek wydatków obejmujący różne kategorie.';

  @override
  String howGroupsExample1Label(int year) {
    return 'Barcelona $year';
  }

  @override
  String get howGroupsExample1Desc =>
      'Przypisz ją do wszystkich wydatków z wyjazdu — lotów, hoteli, jedzenia, wejściówek. Całkowity koszt całej podróży zobaczysz po jednym stuknięciu.';

  @override
  String howGroupsExample2Label(int year) {
    return 'McDonald\'s $year';
  }

  @override
  String get howGroupsExample2Desc =>
      'Używaj tej samej nazwy przez cały rok. Na koniec roku dokładnie zobaczysz, ile wydałeś w tym jednym miejscu.';

  @override
  String get howGroupsExample3Label => 'Remont domu Q1';

  @override
  String get howGroupsExample3Desc =>
      'Używaj tej samej nazwy przez kilka miesięcy. Karta Grupy zbierze wszystko pod tą nazwą.';

  @override
  String get howGroupsPrecision =>
      'Im dokładniejszą nazwę wpiszesz, tym bardziej przydatne będzie końcowe podsumowanie.';

  @override
  String get howGroupsRecord0Title => 'Karta Grupy w Wydatkach';

  @override
  String get howGroupsRecord0Body =>
      'Każda grupa, która ma w bieżącym miesiącu przynajmniej jeden wydatek, pojawi się tutaj jako jeden wiersz z liczbą pozycji i łączną kwotą. Stuknij grupę, aby zobaczyć pojedyncze wydatki, które się na nią składają.';

  @override
  String get howGroupsRecord1Title => 'Miesięczny raport w Raportach';

  @override
  String get howGroupsRecord1Body =>
      'Gdy na ekranie Raporty eksportujesz miesięczny PDF, grupy z wydatkami w danym miesiącu otrzymają własną stronę „Grupy wydatków” — każda grupa będzie wymieniona wraz ze swoimi wydatkami, kwotami i łączną sumą grupy.';

  @override
  String get howGroupsMonthlyNote =>
      'Grupy nie są częścią rocznego raportu — to widok miesięczny.';

  @override
  String get howGroupsExampleGroupName => 'Moja grupa';

  @override
  String get otherCategories => 'Inne kategorie';

  @override
  String noCategoryExpenses(String category, String period) {
    return 'Brak wydatków kategorii $category\nw okresie $period.';
  }

  @override
  String guardDueDate(String monthName, int day, int year) {
    return 'Płatne $day $monthName $year';
  }

  @override
  String get guardNotYetDue => 'Jeszcze nie jest płatne';

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
    return 'To usunie potwierdzenie płatności za $monthName $year.';
  }

  @override
  String get guardMarkUnpaidAction => 'Oznacz jako nieopłacone';

  @override
  String get guardMarkAsPaid => 'Oznacz jako opłacone';

  @override
  String get guardRemoveTitle => 'Usunąć GUARD?';

  @override
  String guardRemoveBody(String name) {
    return 'GUARD zostanie wyłączony dla „$name”. Istniejące wpisy płatności zostaną zachowane, ale nowe przypomnienia nie będą już uruchamiane.';
  }

  @override
  String get guardRemoveConfirm => 'Usuń';

  @override
  String get guardSelectPaidDate => 'Wybierz datę zapłaty';

  @override
  String guardPaidOn(String date) {
    return 'Opłacono $date';
  }

  @override
  String howItWorksStep(int n) {
    return 'KROK $n';
  }

  @override
  String get planSubtitle0 =>
      'Twoje wynagrodzenie i regularne miesięczne zobowiązania';

  @override
  String get planSubtitle1 => 'Jak klasyfikowane są twoje stałe koszty';

  @override
  String get planSubtitle2 => 'Ile z twojego dochodu pochłania każdy typ';

  @override
  String get planSubStep0 => 'Cashflow';

  @override
  String get planSubStep1 => 'Klasyfikacja';

  @override
  String get planSubStep2 => 'Podział';

  @override
  String get howItWorksPlanIncomeBody =>
      'Wprowadź swoje wynagrodzenie i regularne miesięczne zobowiązania — czynsz, ubezpieczenie, subskrypcje. To są realne, znane kwoty, a nie szacunki ani cele.';

  @override
  String get howItWorksTypeConsumptionDesc =>
      'Codzienne wydatki — zakupy spożywcze, czynsz, jedzenie, transport';

  @override
  String get howItWorksTypeAssetDesc =>
      'Inwestycje i oszczędności, które z czasem zwiększają twój majątek';

  @override
  String get howItWorksTypeInsuranceDesc =>
      'Koszty ochrony — samochód, zdrowie i ubezpieczenie na życie';

  @override
  String get howItWorksFinancialTypesBody =>
      'Każdy stały wydatek jest oznaczony typem finansowym. Dzięki temu aplikacja pokaże, jak twój dochód rozkłada się między konsumpcję, oszczędności i ochronę.';

  @override
  String get howItWorksSpendingVsIncomeTitle => 'Wydatki vs dochód';

  @override
  String get howItWorksSpendingVsIncomeBody =>
      'Karta Plan pokazuje, ile z twojego dochodu trafia do każdego typu finansowego — dzięki temu od razu widzisz, czy wydajesz, oszczędzasz czy chronisz się we właściwej proporcji.';

  @override
  String get expSubtitle0 => 'Twój dostępny budżet obliczony z Planu';

  @override
  String get expSubtitle1 => 'Codzienne wydatki, które zapisujesz';

  @override
  String get expSubtitle2 => 'Zmieszczono się w budżecie?';

  @override
  String get subStepBudget => 'Budżet';

  @override
  String get subStepSpending => 'Wydawanie';

  @override
  String get subStepResult => 'Wynik';

  @override
  String get howItWorksBudgetBody =>
      'Aplikacja odejmuje stałe koszty od twojego dochodu i pokazuje wynik tutaj. Nie ustawiasz tej liczby ręcznie — wynika z twojego Planu.';

  @override
  String get howItWorksSpendingBody =>
      'Zapisuj zakupy spożywcze, posiłki, zakupy i inne zmienne wydatki. Stałe miesięczne płatności, takie jak czynsz, należą do Planu, nie tutaj.';

  @override
  String get howItWorksResultBody =>
      'Na koniec miesiąca karta Wydatki pokaże, jaki wynik osiągnąłeś.';

  @override
  String get repSubtitle0 => 'Gdzie trafiły twoje pieniądze?';

  @override
  String get repSubtitle1 => 'Twoje finanse na papierze';

  @override
  String get repSubtitle2 => 'Duży obraz, miesiąc po miesiącu';

  @override
  String get repSubStep0 => 'Podział';

  @override
  String get repSubStep1 => 'Eksport';

  @override
  String get repSubStep2 => 'Przegląd';

  @override
  String get howItWorksBreakdownBody =>
      'Podział pokazuje twoje wydatki według kategorii dla dowolnego miesiąca lub roku. Stuknij segment wykresu lub wiersz kategorii, aby zobaczyć pojedyncze wydatki i stałe koszty, które się za nimi kryją.';

  @override
  String get pdfFeatureCategoryTotals => 'Sumy kategorii';

  @override
  String get pdfFeatureBudgetVsActual => 'Budżet vs rzeczywistość';

  @override
  String get pdfFeatureTypeSplit => 'Podział według typów finansowych';

  @override
  String get pdfFeatureAllExpenses => 'Wszystkie wydatki na liście';

  @override
  String get pdfFeatureCategoryBudgets => 'Budżety kategorii';

  @override
  String get pdfFeatureGroupSummaries => 'Podsumowania grup';

  @override
  String get pdfFeature12MonthOverview => 'Przegląd 12 miesięcy';

  @override
  String get pdfFeatureAnnualTotals => 'Sumy roczne';

  @override
  String get pdfFeatureMonthlyBreakdown => 'Miesięczny podział';

  @override
  String get pdfFeaturePlanVsActual => 'Plan vs rzeczywistość';

  @override
  String get pdfFeatureTypeRatios => 'Proporcje typów finansowych';

  @override
  String get pdfFeatureActivePlanItems => 'Aktywne pozycje planu';

  @override
  String get howItWorksExportBody =>
      'Użyj przycisku PDF w Podziale, aby wyeksportować raport. Raportami możesz dzielić się przez dowolną aplikację na swoim urządzeniu.';

  @override
  String get howItWorksMoreMonths => '· · · 9 kolejnych miesięcy';

  @override
  String get howItWorksOverviewBody =>
      'Przegląd pokazuje wszystkie 12 miesięcy obok siebie — ile zarobiłeś, ile trafiło do aktywów i ile zostało skonsumowane. Stuknij dowolny miesiąc, aby przejść do tego okresu w Planie.';

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
      'Aktualizowane codziennie · stuknij, aby rozwinąć';

  @override
  String get autoBackupSubtitleCollapse =>
      'Aktualizowane codziennie · stuknij, aby zwinąć';

  @override
  String get actionRestoreAllCaps => 'PRZYWRÓĆ';

  @override
  String get actionRestore => 'Przywróć';

  @override
  String get autoBackupRestoreDescription =>
      'Przywrócenie zastąpi wszystkie bieżące dane zawartością kopii zapasowej.';

  @override
  String autoBackupRestored(String date) {
    return 'Kopia zapasowa z $date została przywrócona.';
  }

  @override
  String get autoBackupRestoreFailed =>
      'Przywracanie kopii zapasowej nie powiodło się.';

  @override
  String get autoBackupPrimary => 'Główna kopia zapasowa';

  @override
  String get autoBackupSecondary => 'Zapasowa kopia zapasowa';

  @override
  String get frequencyPickerFixed => 'Jak często się powtarza?';

  @override
  String get frequencyMonthlyFixedSubtitle =>
      'Czynsz, subskrypcje, regularne rachunki';

  @override
  String get frequencyYearlyFixedSubtitle =>
      'Roczne subskrypcje, ubezpieczenia, członkostwa';

  @override
  String get frequencyPickerIncome => 'Jak często go otrzymujesz?';

  @override
  String get frequencyMonthlyIncomeSubtitle =>
      'Wynagrodzenie, emerytura, regularne przelewy';

  @override
  String get frequencyYearlyIncomeSubtitle =>
      'Roczna premia, zwrot podatku, dywidendy';

  @override
  String get frequencyOneTimeIncomeSubtitle =>
      'Prezent, nieoczekiwany dochód, jednorazowa płatność';

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
  String get currencyCustom => 'Własna';

  @override
  String get currencyCustomSubtitle => 'Zdefiniuj własny kod i symbol';

  @override
  String get currencyCustomTitle => 'Własna waluta';

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
  String get startDateLabel => 'Data od';

  @override
  String get endDateLabel => 'Data do';

  @override
  String get tapToSelectDate => 'Stuknij, aby wybrać';

  @override
  String get endDateAfterStart =>
      'Data końcowa musi być taka sama lub późniejsza niż data początkowa.';

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
      other: 'GUARD — $count niepotwierdzonych płatności',
      few: 'GUARD — $count niepotwierdzone płatności',
      one: 'GUARD — 1 niepotwierdzona płatność',
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
      other: '$count śledzonych płatności czeka',
      few: '$count śledzone płatności czekają',
      one: '1 śledzona płatność czeka',
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
  String get noCategoryBudgetsSet =>
      'Nie ustawiono żadnych budżetów kategorii.';

  @override
  String removeBudgetDialogTitle(String category) {
    return 'Usunąć budżet kategorii $category';
  }

  @override
  String endBudgetFromTitle(String from) {
    return 'Zakończ od $from';
  }

  @override
  String endBudgetFromDescription(String from) {
    return 'Zakończy budżet od $from dalej. Poprzednie miesiące zachowają historyczny budżet.';
  }

  @override
  String get deleteBudgetSeriesTitle => 'Usuń całą serię';

  @override
  String get deleteBudgetSeriesConfirm => 'Usuń serię';

  @override
  String deleteBudgetSeriesDescription(String range) {
    return 'Trwale usunie wszystkie wpisy ($range). Budżet tej serii nie będzie już wyświetlany w żadnym miesiącu. Tej operacji nie można cofnąć.';
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
  String get pdfSectionCashFlowSummary => 'PODSUMOWANIE CASH FLOW';

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
  String get pdfGroupTotal => 'Suma grupy (ten miesiąc)';

  @override
  String get pdfAllPeriodsTotal => 'Suma za wszystkie okresy';

  @override
  String pdfItemsThisMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pozycji w tym miesiącu',
      few: '$count pozycje w tym miesiącu',
      one: '1 pozycja w tym miesiącu',
    );
    return '$_temp0';
  }

  @override
  String get pdfNormalized => ' (znormalizowane)';

  @override
  String get pdfAnnualized => ' (przeliczone na rok)';

  @override
  String get pdfPartialYearNote =>
      'Niepełny rok - miesiące bez danych pokazują zera. Podane są tylko sumy narastające od początku roku.';

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

  @override
  String get selectCategoryTitle => 'Wybierz kategorię';

  @override
  String get showAllCategories => 'Pokaż wszystkie kategorie';

  @override
  String get showLessCategories => 'Pokaż mniej';

  @override
  String get allCategoriesTitle => 'Wszystkie kategorie';

  @override
  String get howCategoryBudgetsSubtitle0 => 'Ogranicz wydatki według kategorii!';

  @override
  String get howCategoryBudgetsSubtitle1 => 'Tworzenie budżetu';

  @override
  String get howCategoryBudgetsSubtitle2 => 'Odczyt paska';

  @override
  String get howCategoryBudgetsLabel0 => 'Limit';

  @override
  String get howCategoryBudgetsLabel1 => 'Ustawić';

  @override
  String get howCategoryBudgetsLabel2 => 'Postęp';

  @override
  String get howCategoryBudgetsWhatIntro =>
      'Ustaw miesięczny limit dla dowolnej kategorii — restauracje, zakupy spożywcze, rozrywka. Wydaj tyle, ile zaplanowałeś, nic więcej.';

  @override
  String get howCategoryBudgetsRule1 =>
      'Wybierz kategorie, w których masz tendencję do przepłacania. Ustaw limit tylko tam.';

  @override
  String get howCategoryBudgetsRule2 =>
      'Każdy budżet to prosty miesięczny limit — na przykład: Restauracje → 100 € miesięcznie.';

  @override
  String get howCategoryBudgetsRule3 =>
      'Budżety są opcjonalne. Ustaw tyle, ile chcesz.';

  @override
  String get howCategoryBudgetsRule4 =>
      'Możesz mieć jeden budżet na kategorię, dla tylu kategorii, ile potrzebujesz.';

  @override
  String get howCategoryBudgetsSetupIntro =>
      'Stuknij + na ekranie Zarządzaj budżetami. Wybierz kategorię, wpisz kwotę, wybierz datę początkową. Gotowe.';

  @override
  String get howCategoryBudgetsSetupRule1 =>
      'Wybierz kategorię — na przykład Restauracje.';

  @override
  String get howCategoryBudgetsSetupRule2 =>
      'Wpisz miesięczny limit — na przykład 100 €.';

  @override
  String get howCategoryBudgetsSetupRule3 =>
      'Wybierz miesiąc, od którego obowiązuje. Stosuje się od tego momentu.';

  @override
  String get howCategoryBudgetsSetupRule4 =>
      'Po zapisaniu kategoria jest zablokowana — aby ją zmienić, utwórz nowy budżet.';

  @override
  String get howCategoryBudgetsPastMonthHint =>
      'Wybranie poprzedniego miesiąca zastosuje budżet wstecznie. Przed zapisaniem pojawi się potwierdzenie.';

  @override
  String get howCategoryBudgetsProgressIntro =>
      'Pasek postępu pokazuje dokładnie, jak stoisz — jednym spojrzeniem, za każdym razem gdy otwierasz Wydatki.';

  @override
  String get howCategoryBudgetsProgressRule1 =>
      'Zielony — poniżej 80%: jesteś na właściwej drodze. Tak trzymaj.';

  @override
  String get howCategoryBudgetsProgressRule2 =>
      'Bursztynowy — 80–100%: zbliżasz się. Czas zwolnić.';

  @override
  String get howCategoryBudgetsProgressRule3 =>
      'Czerwony — powyżej 100%: limit przekroczony. Na górze Wydatków pojawi się karta ostrzeżenia.';

  @override
  String get howCategoryBudgetsWhereTitle => 'Gdzie się pojawia';

  @override
  String get howCategoryBudgetsWhere1 =>
      'Wydatki — gdy budżet jest aktywny, pod każdą kategorią pojawia się pasek postępu.';

  @override
  String get howCategoryBudgetsWhere2 =>
      'Widok kategorii — każda kategoria z budżetem pokazuje swój stopień wypełnienia inline.';

  @override
  String get howCategoryBudgetsWhere3 =>
      'Miesięczny raport PDF — budżety są uwzględnione w podsumowaniu wydatków.';

  @override
  String get howCategoryBudgetsResetHint =>
      'Budżety resetują się co miesiąc — niewykorzystane kwoty nie przechodzą dalej.';

  @override
  String get howGuardSubtitle0 => 'Przypomnienie o płatności';

  @override
  String get howGuardSubtitle1 => 'Konfiguracja';

  @override
  String get howGuardSubtitle2 => 'Jak się powtarza';

  @override
  String get howGuardLabel0 => 'Przypomnienie';

  @override
  String get howGuardLabel1 => 'Ustawienia';

  @override
  String get howGuardLabel2 => 'Cykliczne';

  @override
  String get howGuardWhatIntro =>
      'GUARD przypomina, gdy zbliża się termin płatności regularnego rachunku — czynsz, Netflix, ubezpieczenie. Nic nie umknie.';

  @override
  String get howGuardRule1 =>
      'W dniu płatności na telefonie pojawi się powiadomienie. Żadne wcześniejsze działanie nie jest potrzebne.';

  @override
  String get howGuardRule2 =>
      'Stuknij \"Opłacone\", aby potwierdzić. Lub wycisz, jeśli chcesz pominąć tym razem.';

  @override
  String get howGuardRule3 =>
      'Każdy strzeżony rachunek pokazuje swój aktualny stan.';

  @override
  String get howGuardStateUnpaid =>
      'Wymagalne — oczekuje na Twoje potwierdzenie';

  @override
  String get howGuardStatePaid => 'Opłacone — potwierdzone w tym okresie';

  @override
  String get howGuardStateSilenced => 'Wyciszone — przypomnienie odrzucone';

  @override
  String get howGuardActivateIntro =>
      'Otwórz dowolny stały wydatek, stuknij Edytuj i włącz GUARD. Ustaw, kiedy rachunek jest wymagalny — to wszystko.';

  @override
  String get howGuardActivateRule1 =>
      'Ustaw dzień płatności — dzień miesiąca, w którym spodziewasz się płacić. Na przykład: czynsz 1., Netflix 15.';

  @override
  String get howGuardActivateRule2 =>
      'Od tego dnia codzienne przypomnienie powtarza się, dopóki nie oznaczysz płatności lub nie wyciszysz.';

  @override
  String get howGuardActivateRule3 =>
      'W przypadku rachunków rocznych — jak ubezpieczenie — wybierz też miesiąc płatności.';

  @override
  String get howGuardActivateRule4 =>
      'Godzinę codziennego przypomnienia możesz zmienić w ustawieniach GUARD.';

  @override
  String get howGuardFixedCostOnlyHint =>
      'GUARD można włączyć tylko dla pozycji stałych wydatków.';

  @override
  String get howGuardActIntro =>
      'GUARD resetuje się samoczynnie na początku każdego nowego okresu. Nie musisz niczego resetować ręcznie.';

  @override
  String get howGuardActRule1 =>
      'Miesięczne rachunki — jak czynsz lub subskrypcje — otrzymują nowe przypomnienie co miesiąc.';

  @override
  String get howGuardActRule2 =>
      'Roczne rachunki — jak ubezpieczenie lub opłaty roczne — resetują się raz w roku.';

  @override
  String get howGuardActRule3 =>
      'Po oznaczeniu rachunku jako opłaconego pozostaje potwierdzony do początku następnego okresu.';

  @override
  String get howGuardPerPeriodHint =>
      'Opłacone lub wyciszone — dotyczy tylko bieżącego okresu. Następny zawsze zaczyna się od nowa.';
}
