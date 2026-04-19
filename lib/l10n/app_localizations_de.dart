// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Finance Tracker';

  @override
  String get welcomeTagline => 'Übernimm die Kontrolle über dein Geld';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get tabExpenses => 'Ausgaben';

  @override
  String get tabPlan => 'Plan';

  @override
  String get tabReports => 'Berichte';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionLoad => 'Laden';

  @override
  String get actionImport => 'Importieren';

  @override
  String get actionOverwrite => 'Überschreiben';

  @override
  String get labelAmount => 'Betrag';

  @override
  String get labelCategory => 'Kategorie';

  @override
  String get labelFinancialType => 'Finanztyp';

  @override
  String get labelDate => 'Datum';

  @override
  String get labelNote => 'Notiz';

  @override
  String get labelNoteOptional => 'Notiz (optional)';

  @override
  String get labelGroup => 'Gruppe';

  @override
  String get labelGroupOptional => 'Gruppe (optional)';

  @override
  String get groupHintText => 'z. B. Urlaub, Geburtstag';

  @override
  String get labelName => 'Name';

  @override
  String get labelFrequency => 'Häufigkeit';

  @override
  String get labelValidFrom => 'Gültig ab';

  @override
  String get labelValidTo => 'Gültig bis (optional)';

  @override
  String get menuImportExpenses => 'Ausgaben importieren';

  @override
  String get menuExportExpenses => 'Ausgaben exportieren';

  @override
  String get menuImport => 'Importieren';

  @override
  String get menuSaves => 'Speicherstände';

  @override
  String get menuDeleteAll => 'Alle Daten löschen';

  @override
  String get menuHowItWorks => 'So funktioniert\'s';

  @override
  String get menuResetWithDummyData => 'Mit Beispieldaten zurücksetzen';

  @override
  String get menuManageBudgets => 'Budgets verwalten';

  @override
  String get menuGuard => 'GUARD Einstellungen';

  @override
  String get expenseListTitle => 'Ausgaben';

  @override
  String get savesTooltip => 'Speicherstände';

  @override
  String get howItWorksTooltip => 'So funktioniert\'s';

  @override
  String get howItWorksQuestion => 'Wie funktioniert\'s?';

  @override
  String get viewModeItems => 'Einträge';

  @override
  String get viewModeByCategory => 'Kategorie';

  @override
  String get viewModeByGroup => 'Gruppen';

  @override
  String get thisMonthsBudget => 'Budget dieses Monats';

  @override
  String get budgetNotSet => 'Budget nicht festgelegt';

  @override
  String get setIncomeInPlan => 'Einnahmen festlegen';

  @override
  String noExpensesInMonth(String monthName, int year) {
    return 'Keine Ausgaben im $monthName $year.';
  }

  @override
  String get tapPlusToAddOne => 'Tippe auf +, um eine hinzuzufügen.';

  @override
  String get fixedBillsHint => 'Feste Kosten wie Miete gehören in den Plan.';

  @override
  String get noGroupsThisMonth => 'Keine Gruppen in diesem Monat.';

  @override
  String get addGroupHint =>
      'Füge beim Erstellen\noder Bearbeiten einer Ausgabe eine Gruppe hinzu.';

  @override
  String get howGroupsWorkQuestion => 'Wie funktionieren Gruppen?';

  @override
  String get howGuardWorkQuestion => 'Wie funktioniert GUARD?';

  @override
  String get howCategoryBudgetsWorkQuestion =>
      'Wie funktionieren Kategoriebudgets?';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
    );
    return '$_temp0';
  }

  @override
  String get addExpenseTitle => 'Ausgabe hinzufügen';

  @override
  String get editExpenseTitle => 'Ausgabe bearbeiten';

  @override
  String get validationAmountEmpty => 'Bitte einen Betrag eingeben';

  @override
  String get validationAmountInvalid =>
      'Bitte eine gültige positive Zahl eingeben';

  @override
  String get expenseDetailTitle => 'Ausgabe';

  @override
  String noExpensesInNamedGroup(String name) {
    return 'Keine Ausgaben in „$name“.';
  }

  @override
  String get planTitle => 'Plan';

  @override
  String get toggleMonthly => 'Monatlich';

  @override
  String get toggleYearly => 'Jährlich';

  @override
  String get sectionIncome => 'Einnahmen';

  @override
  String get sectionFixedCosts => 'Fixkosten';

  @override
  String get noIncomeItems => 'Keine Einnahmen.';

  @override
  String get noFixedCostItems => 'Keine Fixkosten.';

  @override
  String get spendableBudget => 'Verfügbares Budget';

  @override
  String get deleteItemDialogTitle => 'Plan-Eintrag löschen';

  @override
  String get deleteItemFromPeriod => 'Ab diesem Zeitraum';

  @override
  String get deleteItemWholeSeries => 'Gesamte Serie';

  @override
  String get planItemDeleted => 'Plan-Eintrag gelöscht.';

  @override
  String get addIncomeTitle => 'Einnahme hinzufügen';

  @override
  String get addFixedCostTitle => 'Fixkosten hinzufügen';

  @override
  String get editIncomeTitle => 'Einnahme bearbeiten';

  @override
  String get editFixedCostTitle => 'Fixkosten bearbeiten';

  @override
  String get frequencyOneTime => 'Einmalig';

  @override
  String get frequencyMonthly => 'Monatlich';

  @override
  String get frequencyYearly => 'Jährlich';

  @override
  String get guardSectionLabel => 'GUARD';

  @override
  String get guardTrackPayment => 'Zahlung verfolgen';

  @override
  String get guardDueDayLabel => 'Fälligkeitstag';

  @override
  String get guardOneTimeLabel => 'Einmalige Zahlung';

  @override
  String get planItemSaved => 'Plan-Eintrag gespeichert.';

  @override
  String get addNewItemSheetTitle => 'Neu hinzufügen';

  @override
  String get typeIncome => 'Einnahme';

  @override
  String get typeFixedCost => 'Fixkosten';

  @override
  String get ongoing => 'Laufend';

  @override
  String get manageBudgetsTitle => 'Budgets verwalten';

  @override
  String get noBudgetsSet =>
      'Für diesen Zeitraum sind keine Budgets festgelegt.';

  @override
  String get addFirstBudget => 'Füge dein erstes Budget hinzu.';

  @override
  String get addBudgetTitle => 'Budget hinzufügen';

  @override
  String get editBudgetTitle => 'Budget bearbeiten';

  @override
  String get budgetAmount => 'Budgetbetrag';

  @override
  String get effectiveFrom => 'Gültig ab';

  @override
  String get pastMonthBudgetWarning =>
      'Ein Budget in der Vergangenheit hat keine Auswirkungen auf frühere Ausgaben.';

  @override
  String get budgetSaved => 'Budget gespeichert.';

  @override
  String get budgetDeleted => 'Budget gelöscht.';

  @override
  String get guardScreenTitle => 'GUARD';

  @override
  String get guardDailyReminderTime => 'Tägliche Erinnerungszeit';

  @override
  String get guardTimePicker => 'Tägliche GUARD-Erinnerungszeit';

  @override
  String get guardMarkPaid => 'Als bezahlt markieren';

  @override
  String get guardSilence => 'Stummschalten';

  @override
  String get guardStatusPaid => 'Bezahlt';

  @override
  String get guardStatusScheduled => 'Geplant';

  @override
  String get guardStatusUnpaid => 'Unbezahlt';

  @override
  String get guardStatusSilenced => 'Stummgeschaltet';

  @override
  String get noGuardedItems => 'Keine überwachten Einträge.';

  @override
  String get reportsTitle => 'Berichte';

  @override
  String get reportModeMonthly => 'Monatlich';

  @override
  String get reportModeYearly => 'Jährlich';

  @override
  String get reportModeOverview => 'Übersicht';

  @override
  String get exportPdf => 'PDF exportieren';

  @override
  String get noExpensesForPeriod =>
      'Für diesen Zeitraum wurden keine Ausgaben erfasst.';

  @override
  String get noIncomeOrSpendingDataForYear =>
      'Für dieses Jahr liegen keine Einnahmen- oder Ausgabendaten vor.';

  @override
  String get pieChartOther => 'Sonstiges';

  @override
  String get reportSectionFixedCosts => 'FIXKOSTEN';

  @override
  String get reportSectionExpenses => 'AUSGABEN';

  @override
  String get noneInPeriod => 'Keine in diesem Zeitraum.';

  @override
  String fixedCostCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fixkosten-Einträge',
      one: '1 Fixkosten-Eintrag',
    );
    return '$_temp0';
  }

  @override
  String expenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ausgaben',
      one: '1 Ausgabe',
    );
    return '$_temp0';
  }

  @override
  String get noItemsInPeriod => 'Keine Einträge in diesem Zeitraum';

  @override
  String get importTitle => 'Ausgaben importieren';

  @override
  String get importStep1Title => 'Vorlage herunterladen';

  @override
  String get importStep1Description =>
      'Lade die offizielle Excel-Vorlage mit allen erforderlichen Spalten und einer Anleitung zu zulässigen Werten herunter.';

  @override
  String get importStep1Button => 'Vorlage herunterladen';

  @override
  String get importStep2Title => 'Ausfüllen und importieren';

  @override
  String get importStep2Description =>
      'Fülle die Vorlage in Excel oder Google Sheets aus und wähle die Datei dann hier aus, um deine Ausgaben zu importieren.';

  @override
  String get importStep2Button => 'Datei auswählen (.xlsx oder .csv)';

  @override
  String get importInfoText =>
      'Nur Ausgaben können importiert werden. Einnahmen und Plan-Einträge werden nicht unterstützt.\n\nAkzeptierte Formate: .xlsx (Excel) und .csv.\nCSV-Dateien müssen dieselbe Spaltenreihenfolge wie die Vorlage haben: Datum, Betrag, Kategorie, Finanztyp, Notiz, Gruppe.\n\nAus dieser App exportierte Dateien können ebenfalls direkt importiert werden.';

  @override
  String importReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ausgaben zum Import bereit',
      one: '1 Ausgabe zum Import bereit',
    );
    return '$_temp0';
  }

  @override
  String importErrorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeilen konnten nicht gelesen werden',
      one: '1 Zeile konnte nicht gelesen werden',
    );
    return '$_temp0';
  }

  @override
  String importErrorCountSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeilen konnten nicht gelesen werden — werden übersprungen',
      one: '1 Zeile konnte nicht gelesen werden — wird übersprungen',
    );
    return '$_temp0';
  }

  @override
  String get importNoDataFound => 'In der Datei wurden keine Daten gefunden.';

  @override
  String get importTapToEdit =>
      'Tippe auf eine beliebige Zeile, um sie vor dem Import zu bearbeiten oder zu entfernen.';

  @override
  String get importRowsWithErrors => 'Zeilen mit Fehlern';

  @override
  String get importNoDataRows => 'Keine Datenzeilen gefunden.';

  @override
  String importConfirmButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ausgaben importieren',
      one: '1 Ausgabe importieren',
    );
    return '$_temp0';
  }

  @override
  String importSuccessMessage(int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ausgaben importiert · $range',
      one: '1 Ausgabe importiert · $range',
    );
    return '$_temp0';
  }

  @override
  String get importUnsupportedFile =>
      'Nicht unterstützter Dateityp. Bitte wähle eine .xlsx- oder .csv-Datei aus.';

  @override
  String get importCouldNotReadFile =>
      'Die Datei konnte nicht gelesen werden. Bitte versuche es erneut.';

  @override
  String importPickerError(Object error) {
    return 'Dateiauswahl konnte nicht geöffnet werden: $error';
  }

  @override
  String importTemplateError(Object error) {
    return 'Vorlage konnte nicht erstellt werden: $error';
  }

  @override
  String get tryAnotherFile => 'Andere Datei versuchen';

  @override
  String get savesTitle => 'Speicherstände';

  @override
  String get sectionAutoBackup => 'AUTOMATISCHES BACKUP';

  @override
  String get sectionSaves => 'SPEICHERSTÄNDE';

  @override
  String get sectionDataTransfer => 'DATENÜBERTRAGUNG';

  @override
  String get sectionDataDeletion => 'DATENLÖSCHUNG';

  @override
  String get exportAllData => 'Alle Daten exportieren';

  @override
  String get importAllData => 'Alle Daten importieren';

  @override
  String get deleteAllData => 'Alle Daten löschen';

  @override
  String get emptySlot => 'Leerer Speicherplatz';

  @override
  String savedConfirmation(String name) {
    return '\'$name\' gespeichert.';
  }

  @override
  String loadedConfirmation(String name) {
    return '\'$name\' geladen.';
  }

  @override
  String exportFailed(Object error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String importFailedInvalid(Object error) {
    return 'Ungültige Datei: $error';
  }

  @override
  String get importDataSuccess => 'Daten erfolgreich importiert.';

  @override
  String get couldNotReadSelectedFile =>
      'Die ausgewählte Datei konnte nicht gelesen werden.';

  @override
  String get importDataDialogTitle => 'Daten importieren?';

  @override
  String get importDataDialogContent =>
      'Dadurch werden ALLE aktuellen Ausgaben und Plan-Einträge durch den Inhalt der Datei ersetzt. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get saveName => 'Name des Speicherstands';

  @override
  String get saveNameCannotBeEmpty => 'Der Name darf nicht leer sein';

  @override
  String replacingLabel(String name) {
    return 'Wird ersetzt: $name';
  }

  @override
  String get loadDialogDescription =>
      'Alle aktuellen Daten werden durch diesen gespeicherten Stand ersetzt.';

  @override
  String get deleteDialogDescription =>
      'Dieser gespeicherte Stand wird dauerhaft gelöscht.';

  @override
  String get damagedSaveFile => 'Beschädigte Speicherdatei';

  @override
  String overBudgetAmount(String amount) {
    return '$amount über dem Budget';
  }

  @override
  String underBudgetAmount(String amount) {
    return '$amount übrig';
  }

  @override
  String spentLabel(String amount) {
    return 'Ausgegeben: $amount';
  }

  @override
  String budgetLabel(String amount) {
    return 'Budget: $amount';
  }

  @override
  String progressBarLabel(String spent, String budget) {
    return '$spent ausgegeben  /  $budget Budget';
  }

  @override
  String categoryBudgetOverBy(String category, String amount) {
    return '$category-Budget: um $amount überschritten';
  }

  @override
  String get deleteAllDataDialogTitle => 'Alle Daten löschen?';

  @override
  String get deleteAllDataDialogContent =>
      'Dadurch werden alle Ausgaben, Einnahmen und Plan-Einträge dauerhaft gelöscht. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get deleteAllDataConfirm => 'Alles löschen';

  @override
  String get monthJanuary => 'Januar';

  @override
  String get monthFebruary => 'Februar';

  @override
  String get monthMarch => 'März';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJune => 'Juni';

  @override
  String get monthJuly => 'Juli';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'Oktober';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'Dezember';

  @override
  String get monthAbbrJan => 'Jan';

  @override
  String get monthAbbrFeb => 'Feb';

  @override
  String get monthAbbrMar => 'Mär';

  @override
  String get monthAbbrApr => 'Apr';

  @override
  String get monthAbbrMay => 'Mai';

  @override
  String get monthAbbrJun => 'Jun';

  @override
  String get monthAbbrJul => 'Jul';

  @override
  String get monthAbbrAug => 'Aug';

  @override
  String get monthAbbrSep => 'Sep';

  @override
  String get monthAbbrOct => 'Okt';

  @override
  String get monthAbbrNov => 'Nov';

  @override
  String get monthAbbrDec => 'Dez';

  @override
  String get categoryHousing => 'Wohnen';

  @override
  String get categoryGroceries => 'Lebensmittel';

  @override
  String get categoryVacation => 'Urlaub';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryInsurance => 'Versicherung';

  @override
  String get categorySubscriptions => 'Abonnements';

  @override
  String get categoryCommunication => 'Kommunikation';

  @override
  String get categoryHealth => 'Gesundheit';

  @override
  String get categoryRestaurants => 'Restaurants';

  @override
  String get categoryEntertainment => 'Unterhaltung';

  @override
  String get categoryElectronics => 'Elektronik';

  @override
  String get categoryClothing => 'Kleidung';

  @override
  String get categoryEducation => 'Bildung';

  @override
  String get categoryInvestment => 'Investition';

  @override
  String get categoryGifts => 'Geschenke';

  @override
  String get categoryTaxes => 'Steuern';

  @override
  String get categoryMedications => 'Medikamente';

  @override
  String get categoryUtilities => 'Nebenkosten';

  @override
  String get categoryHousehold => 'Haushaltsbedarf';

  @override
  String get categoryPersonalCare => 'Körperpflege';

  @override
  String get categorySavings => 'Ersparnisse';

  @override
  String get categoryDebt => 'Schulden';

  @override
  String get categoryKids => 'Kinder';

  @override
  String get categoryPets => 'Haustiere';

  @override
  String get categoryFees => 'Gebühren';

  @override
  String get categoryFuel => 'Kraftstoff';

  @override
  String get categoryMaintenance => 'Wartung';

  @override
  String get categoryDonations => 'Spenden';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get financialTypeAsset => 'Vermögen';

  @override
  String get financialTypeConsumption => 'Konsum';

  @override
  String get financialTypeInsurance => 'Versicherung';

  @override
  String get addPlanItemTitle => 'Plan-Eintrag hinzufügen';

  @override
  String get addMonthlyIncomeTitle => 'Monatliche Einnahme hinzufügen';

  @override
  String get addYearlyIncomeTitle => 'Jährliche Einnahme hinzufügen';

  @override
  String get addOneTimeIncomeTitle => 'Einmalige Einnahme hinzufügen';

  @override
  String get addMonthlyFixedCostTitle => 'Monatliche Fixkosten hinzufügen';

  @override
  String get addYearlyFixedCostTitle => 'Jährliche Fixkosten hinzufügen';

  @override
  String get editMonthlyIncomeTitle => 'Monatliche Einnahme bearbeiten';

  @override
  String get editYearlyIncomeTitle => 'Jährliche Einnahme bearbeiten';

  @override
  String get editOneTimeIncomeTitle => 'Einmalige Einnahme bearbeiten';

  @override
  String get editMonthlyFixedCostTitle => 'Monatliche Fixkosten bearbeiten';

  @override
  String get editYearlyFixedCostTitle => 'Jährliche Fixkosten bearbeiten';

  @override
  String get labelType => 'Typ';

  @override
  String get labelMonth => 'Monat';

  @override
  String get labelYear => 'Jahr';

  @override
  String get labelDayOfMonth => 'Tag des Monats';

  @override
  String get nameHintText => 'z. B. Gehalt, Miete, Versicherung';

  @override
  String get validationEnterName => 'Bitte einen Namen eingeben';

  @override
  String get selectMonthTitle => 'Monat auswählen';

  @override
  String get lastRenewalYearTitle => 'Letztes Verlängerungsjahr';

  @override
  String lastMonthRenewal(String monthName) {
    return 'Letzte $monthName-Verlängerung';
  }

  @override
  String lastActiveMonthInfo(String label) {
    return 'Letzter aktiver Monat: $label';
  }

  @override
  String get setEndDate => 'Enddatum festlegen';

  @override
  String untilLabel(String validToLabel) {
    return 'Bis: $validToLabel';
  }

  @override
  String lastActiveMonthNote(String label) {
    return '$label ist der letzte aktive Monat.';
  }

  @override
  String get endMonthAfterStart => 'Endmonat muss nach dem Startmonat liegen.';

  @override
  String get fromFieldLabel => 'Von';

  @override
  String renewedEachMonth(String monthName) {
    return 'Wird jährlich im $monthName verlängert. Termine sind fest.';
  }

  @override
  String get untilFieldLabel => 'Bis';

  @override
  String lastActiveMonthParens(String label) {
    return '$label (letzter aktiver Monat)';
  }

  @override
  String get openEnded => 'Unbegrenzt';

  @override
  String fromDateLabel(String validFromLabel) {
    return 'Von: $validFromLabel';
  }

  @override
  String get samePeriodInPlace =>
      'Gleicher Monat wie das Original – wird direkt aktualisiert.';

  @override
  String get differentPeriodNewVersion =>
      'Anderer Monat – erstellt eine neue Version.';

  @override
  String get applyChangesToTitle => 'Änderungen anwenden auf...';

  @override
  String get applyToWholeSeries => 'Gesamte Serie';

  @override
  String applyToWholeSeriesSubtitle(String seriesStartLabel) {
    return 'Alle Zeiträume ab $seriesStartLabel';
  }

  @override
  String applyFromOnwards(String nextLabel) {
    return 'Ab $nextLabel';
  }

  @override
  String applyFromSubtitle(String capLabel, String nextLabel) {
    return 'Ursprüngliche Serie endet $capLabel.\nNeue Serie beginnt $nextLabel.';
  }

  @override
  String get applyFromUnavailable =>
      'Kein zukünftiger Zeitraum in dieser Serie verfügbar.';

  @override
  String get yearlyItemsOnlyAtRenewal =>
      'Jährliche Einträge können nur am Verlängerungsmonat geändert werden.';

  @override
  String get guardRemindMe => 'Erinnere mich, diese Zahlung zu bestätigen';

  @override
  String get guardShorterMonths => 'Kürzere Monate verwenden den letzten Tag.';

  @override
  String get dueDayMonthly => 'Fälligkeitstag (monatlich)';

  @override
  String dueDayYearly(String monthName) {
    return 'Fälligkeitstag (jährlich im $monthName)';
  }

  @override
  String dueDayMonthlyLabel(int day) {
    return 'Tag $day jeden Monats';
  }

  @override
  String dueDayYearlyLabel(int day, String monthName) {
    return 'Tag $day im $monthName jedes Jahr';
  }

  @override
  String get guardDailyReminder => 'Tägliche Erinnerung';

  @override
  String get guardChangeNotifTime =>
      'Tippe, um die Benachrichtigungszeit zu ändern';

  @override
  String get guardNoGuardedItemsHint =>
      'Aktiviere GUARD für Fixkosten, um Zahlungen zu verfolgen.';

  @override
  String guardedItemsCount(int count) {
    return 'Überwachte Einträge · $count';
  }

  @override
  String get planItemTitle => 'Plan-Eintrag';

  @override
  String get activeFrom => 'Aktiv ab';

  @override
  String get activeUntil => 'Aktiv bis';

  @override
  String get perMonth => '/ Monat';

  @override
  String get perYear => '/ Jahr';

  @override
  String get oneTimeSuffix => '(einmalig)';

  @override
  String get noEndDate => 'Kein Enddatum';

  @override
  String get guardNotEnabled => 'Nicht aktiviert';

  @override
  String removeIncomeEntirely(String name) {
    return '\"$name\" wird vollständig entfernt.';
  }

  @override
  String removeIncomeFromOnwards(String name, String from, String prev) {
    return '\"$name\" wird ab $from beendet. $prev und früher bleibt weiterhin geplant.';
  }

  @override
  String get actionRemoveAllCaps => 'ENTFERNEN';

  @override
  String get removeBudgetAllCaps => 'BUDGET ENTFERNEN';

  @override
  String removeFromOnwardsTitle(String label) {
    return 'Ab $label';
  }

  @override
  String removeCycleSubtitle(String start, String end) {
    return 'Dieser Zyklus ($start – $end) und alle zukünftigen Zyklen werden entfernt.';
  }

  @override
  String removeHistoryKept(String prev) {
    return 'Verlauf bis $prev wird beibehalten.';
  }

  @override
  String get silenceReminderTitle => 'Erinnerung stummschalten?';

  @override
  String silenceReminderBody(String periodLabel) {
    return 'Die Zahlung für $periodLabel wird weiterhin als unbestätigt angezeigt. Sie kann jederzeit als bezahlt markiert werden.';
  }

  @override
  String get yesSilence => 'Ja, stummschalten';

  @override
  String get addPlanItemTooltip => 'Plan-Eintrag hinzufügen';

  @override
  String get spendableThisMonth => 'Verfügbar diesen Monat';

  @override
  String get spendableThisYear => 'Verfügbar dieses Jahr';

  @override
  String get noPlanItemsYet => 'Noch keine Plan-Einträge.';

  @override
  String get tapPlusToAddPlanItems =>
      'Tippe auf +, um Einnahmen oder Fixkosten hinzuzufügen.';

  @override
  String get removeWholeSeries => 'Gesamte Serie';

  @override
  String removeWholeSeriesSubtitle(String seriesStartLabel) {
    return 'Alle Zeiträume ab $seriesStartLabel werden entfernt.';
  }

  @override
  String get clearAllDataAction => 'LÖSCHEN';

  @override
  String get clearAllDataDescription =>
      'Ausgaben, Plan-Einträge, Budgets und GUARD-Zahlungen werden dauerhaft gelöscht. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get clearAllDataPreservedNote =>
      'Gespeicherte Stände und automatische Backups sind nicht betroffen.';

  @override
  String get allCategoriesBudgeted =>
      'Alle Kategorien haben bereits ein Budget für diesen Monat. Wähle einen anderen Monat, um ein weiteres hinzuzufügen.';

  @override
  String get selectCategoryHint => 'Kategorie auswählen';

  @override
  String get validationSelectCategory => 'Bitte eine Kategorie auswählen';

  @override
  String get monthlyBudgetLabel => 'Monatliches Budget';

  @override
  String effectiveFromLabel(String validFromLabel) {
    return 'Gültig ab: $validFromLabel';
  }

  @override
  String pastMonthBudgetCreateWarning(String fromLabel) {
    return 'Du erstellst ein Budget für einen vergangenen Monat. Es gilt rückwirkend ab $fromLabel.';
  }

  @override
  String pastMonthBudgetEditWarning(
    String catName,
    String fromLabel,
    String prevLabel,
  ) {
    return 'Dadurch wird das Budget für $catName auf $fromLabel zurückgesetzt. Die Monate $fromLabel–$prevLabel verwenden den neuen Betrag.';
  }

  @override
  String get noFixedCostsPlanned => 'Keine Fixkosten geplant';

  @override
  String get noIncomePlanned => 'Keine Einnahmen geplant';

  @override
  String saveSlotSubtitle(String date, int expenseCount, int planItemCount) {
    return '$date · $expenseCount Ausgaben · $planItemCount Plan-Einträge';
  }

  @override
  String get saveSlotDamagedSubtitle =>
      'Datei ist beschädigt und kann nicht geladen werden';

  @override
  String get howGroupsTitle => 'Gruppen';

  @override
  String get howGroupsSubtitle0 =>
      'Was eine Gruppe ist und wie sie funktioniert';

  @override
  String get howGroupsSubtitle1 => 'Wie man sie nutzt';

  @override
  String get howGroupsSubtitle2 => 'Wo Gruppen in der App erscheinen';

  @override
  String get howGroupsLabel0 => 'Markieren';

  @override
  String get howGroupsLabel1 => 'Kreativ werden';

  @override
  String get howGroupsLabel2 => 'Auswerten';

  @override
  String get howGroupsRule1 =>
      'Eine Gruppe ist ein optionales Freitext-Label, das du jeder Ausgabe anheften kannst.';

  @override
  String get howGroupsRule2 =>
      'Du kannst beliebigen Text eingeben – es gibt keine feste Liste und keine Validierung.';

  @override
  String get howGroupsRule3 =>
      'Zwei Ausgaben gehören nur dann zur selben Gruppe, wenn ihre Labels genau übereinstimmen – Zeichen für Zeichen.';

  @override
  String get howGroupsRule4 =>
      'Groß-/Kleinschreibung wird berücksichtigt – „Reise“ und „reise“ gelten als zwei verschiedene Gruppen.';

  @override
  String get howGroupsRule5 =>
      'Das Feld ist optional. Lasse es leer, und die Ausgabe hat einfach keine Gruppe.';

  @override
  String get howGroupsHint =>
      'Lege die Gruppe beim Erstellen oder Bearbeiten einer Ausgabe fest.';

  @override
  String get howGroupsUseIntro =>
      'Nutze es immer, wenn du einen bestimmten Ausgabenbereich über mehrere Kategorien hinweg verfolgen möchtest.';

  @override
  String howGroupsExample1Label(int year) {
    return 'Barcelona $year';
  }

  @override
  String get howGroupsExample1Desc =>
      'Füge es jeder Ausgabe auf einer Reise hinzu – Flüge, Hotels, Mahlzeiten, Tickets. Sieh die Gesamtkosten der gesamten Reise auf einen Blick.';

  @override
  String howGroupsExample2Label(int year) {
    return 'McDonald\'\'s $year';
  }

  @override
  String get howGroupsExample2Desc =>
      'Verwende einen einheitlichen Namen das ganze Jahr über. Am Jahresende weißt du genau, was du an diesem Ort ausgegeben hast.';

  @override
  String get howGroupsExample3Label => 'Hausrenovierung Q1';

  @override
  String get howGroupsExample3Desc =>
      'Erstrecke dich über mehrere Monate mit demselben Label. Der Gruppen-Tab sammelt alles unter diesem Namen.';

  @override
  String get howGroupsPrecision =>
      'Je genauer dein Label, desto nützlicher ist die Zusammenfassung.';

  @override
  String get howGroupsRecord0Title => 'Gruppen-Tab in Ausgaben';

  @override
  String get howGroupsRecord0Body =>
      'Jede Gruppe mit mindestens einer Ausgabe im aktuellen Monat erscheint hier als einzelne Zeile mit Anzahl und Gesamtbetrag. Tippe auf eine Gruppe, um alle einzelnen Ausgaben dahinter zu sehen.';

  @override
  String get howGroupsRecord1Title => 'Monatsbericht in Berichte';

  @override
  String get howGroupsRecord1Body =>
      'Wenn du einen monatlichen PDF-Bericht exportierst, erhalten Gruppen mit Ausgaben in diesem Monat eine eigene Seite „Ausgabengruppen“ – jede Gruppe mit ihren Ausgaben, Beträgen und einem Gruppengesamt.';

  @override
  String get howGroupsMonthlyNote =>
      'Gruppen sind nicht im Jahresbericht enthalten – sie sind eine monatliche Perspektive.';

  @override
  String get howGroupsExampleGroupName => 'Meine Gruppe';

  @override
  String get otherCategories => 'Andere Kategorien';

  @override
  String noCategoryExpenses(String category, String period) {
    return 'Keine $category-Ausgaben\nim $period.';
  }

  @override
  String guardDueDate(String monthName, int day, int year) {
    return 'Fällig am $day. $monthName $year';
  }

  @override
  String get guardNotYetDue => 'Noch nicht fällig';

  @override
  String guardNextReminder(String label) {
    return 'Nächste: $label';
  }

  @override
  String guardLastReminder(String label) {
    return 'Letzte: $label';
  }

  @override
  String get guardChangeDay => 'Tag ändern';

  @override
  String get guardRemoveAction => 'GUARD entfernen';

  @override
  String get guardMarkUnpaidTitle => 'Als unbezahlt markieren?';

  @override
  String guardMarkUnpaidBody(String monthName, int year) {
    return 'Dadurch wird die Zahlungsbestätigung für $monthName $year entfernt.';
  }

  @override
  String get guardMarkUnpaidAction => 'Als unbezahlt markieren';

  @override
  String get guardMarkAsPaid => 'Als bezahlt markieren';

  @override
  String get guardRemoveTitle => 'GUARD entfernen?';

  @override
  String guardRemoveBody(String name) {
    return 'GUARD wird für \"$name\" deaktiviert. Vorhandene Zahlungsnachweise bleiben erhalten, aber es werden keine neuen Erinnerungen ausgelöst.';
  }

  @override
  String get guardRemoveConfirm => 'Entfernen';

  @override
  String get guardSelectPaidDate => 'Zahlungsdatum auswählen';

  @override
  String guardPaidOn(String date) {
    return 'Bezahlt am $date';
  }

  @override
  String howItWorksStep(int n) {
    return 'SCHRITT $n';
  }

  @override
  String get planSubtitle0 => 'Dein Gehalt und feste monatliche Rechnungen';

  @override
  String get planSubtitle1 => 'Wie deine Fixkosten klassifiziert werden';

  @override
  String get planSubtitle2 => 'Wie viel deines Einkommens jeder Typ verbraucht';

  @override
  String get planSubStep0 => 'Cashflow';

  @override
  String get planSubStep1 => 'Klassifizierung';

  @override
  String get planSubStep2 => 'Verteilung';

  @override
  String get howItWorksPlanIncomeBody =>
      'Trage dein Gehalt und feste monatliche Rechnungen ein – Miete, Versicherung, Abonnements. Das sind echte, bekannte Zahlen, keine Schätzungen oder Ziele.';

  @override
  String get howItWorksTypeConsumptionDesc =>
      'Alltägliche Ausgaben – Lebensmittel, Miete, Essen gehen, Transport';

  @override
  String get howItWorksTypeAssetDesc =>
      'Investitionen und Ersparnisse, die dein Vermögen langfristig vermehren';

  @override
  String get howItWorksTypeInsuranceDesc =>
      'Schutzkosten – Auto-, Kranken- und Lebensversicherung';

  @override
  String get howItWorksFinancialTypesBody =>
      'Jede Fixkostposition wird mit einem Finanztyp gekennzeichnet. So kann die App zeigen, wie dein Einkommen auf Ausgaben, Ersparnisse und Absicherung aufgeteilt ist.';

  @override
  String get howItWorksSpendingVsIncomeTitle => 'Ausgaben vs. Einnahmen';

  @override
  String get howItWorksSpendingVsIncomeBody =>
      'Der Plan-Tab zeigt, wie viel deines Einkommens in jeden Finanztyp fließt – so siehst du auf einen Blick, ob du den richtigen Anteil deines Verdienstes ausgibst, sparst oder absicherst.';

  @override
  String get expSubtitle0 => 'Dein verfügbares Budget, berechnet aus dem Plan';

  @override
  String get expSubtitle1 => 'Tägliche Ausgaben, die du erfasst';

  @override
  String get expSubtitle2 => 'Bist du im Budget geblieben?';

  @override
  String get subStepBudget => 'Budget';

  @override
  String get subStepSpending => 'Ausgaben';

  @override
  String get subStepResult => 'Ergebnis';

  @override
  String get howItWorksBudgetBody =>
      'Die App subtrahiert deine Fixkosten vom Einkommen und zeigt das Ergebnis hier an. Du legst diese Zahl nicht fest – sie kommt aus deinem Plan.';

  @override
  String get howItWorksSpendingBody =>
      'Trage Lebensmittel, Mahlzeiten, Einkäufe und andere variable Ausgaben ein. Feste monatliche Rechnungen wie Miete gehören in den Plan, nicht hierher.';

  @override
  String get howItWorksResultBody =>
      'Am Ende des Monats zeigt der Ausgaben-Tab, welches Ergebnis du erzielt hast.';

  @override
  String get repSubtitle0 => 'Wohin ist dein Geld geflossen?';

  @override
  String get repSubtitle1 => 'Deine Finanzen auf Papier';

  @override
  String get repSubtitle2 => 'Das große Bild, Monat für Monat';

  @override
  String get repSubStep0 => 'Aufschlüsselung';

  @override
  String get repSubStep1 => 'Export';

  @override
  String get repSubStep2 => 'Übersicht';

  @override
  String get howItWorksBreakdownBody =>
      'Die Aufschlüsselung zeigt deine Ausgaben nach Kategorie für einen Monat oder ein Jahr. Tippe auf einen Bereich oder eine Kategoriezeile, um die einzelnen Ausgaben und Fixkosten dahinter zu sehen.';

  @override
  String get pdfFeatureCategoryTotals => 'Kategorie-Summen';

  @override
  String get pdfFeatureBudgetVsActual => 'Budget vs. Ist';

  @override
  String get pdfFeatureTypeSplit => 'Finanztyp-Aufteilung';

  @override
  String get pdfFeatureAllExpenses => 'Alle Ausgaben aufgelistet';

  @override
  String get pdfFeatureCategoryBudgets => 'Kategorie-Budgets';

  @override
  String get pdfFeatureGroupSummaries => 'Gruppen-Zusammenfassungen';

  @override
  String get pdfFeature12MonthOverview => '12-Monats-Übersicht';

  @override
  String get pdfFeatureAnnualTotals => 'Jahressummen';

  @override
  String get pdfFeatureMonthlyBreakdown => 'Monatliche Aufschlüsselung';

  @override
  String get pdfFeaturePlanVsActual => 'Plan vs. Ist';

  @override
  String get pdfFeatureTypeRatios => 'Typverhältnisse';

  @override
  String get pdfFeatureActivePlanItems => 'Aktive Plan-Einträge';

  @override
  String get howItWorksExportBody =>
      'Nutze die PDF-Schaltfläche in der Aufschlüsselung zum Exportieren. Berichte können über jede App auf deinem Gerät geteilt werden.';

  @override
  String get howItWorksMoreMonths => '· · · 9 weitere Monate';

  @override
  String get howItWorksOverviewBody =>
      'Die Übersicht zeigt alle 12 Monate nebeneinander – wie viel du verdient hast, was in Vermögenswerte geflossen ist und was verbraucht wurde. Tippe auf einen Monat, um zu diesem Zeitraum im Plan zu springen.';

  @override
  String overBudgetBy(String amount) {
    return 'Um $amount über dem Budget';
  }

  @override
  String savedAmount(String amount) {
    return '$amount gespart';
  }

  @override
  String get loadingLabel => 'Wird geladen…';

  @override
  String get autoBackupTitle => 'Automatisches Backup';

  @override
  String get autoBackupNoBackupYet => 'Noch kein Backup';

  @override
  String get autoBackupSubtitleExpand =>
      'Täglich aktualisiert · tippen zum Aufklappen';

  @override
  String get autoBackupSubtitleCollapse =>
      'Täglich aktualisiert · tippen zum Einklappen';

  @override
  String get actionRestoreAllCaps => 'WIEDERHERSTELLEN';

  @override
  String get actionRestore => 'Wiederherstellen';

  @override
  String get autoBackupRestoreDescription =>
      'Beim Wiederherstellen werden alle aktuellen Daten durch das Backup ersetzt.';

  @override
  String autoBackupRestored(String date) {
    return 'Backup vom $date wiederhergestellt.';
  }

  @override
  String get autoBackupRestoreFailed =>
      'Backup konnte nicht wiederhergestellt werden.';

  @override
  String get autoBackupPrimary => 'Primäres Backup';

  @override
  String get autoBackupSecondary => 'Sekundäres Backup';

  @override
  String get frequencyPickerFixed => 'Wie oft wiederholt es sich?';

  @override
  String get frequencyMonthlyFixedSubtitle =>
      'Miete, Abonnements, wiederkehrende Rechnungen';

  @override
  String get frequencyYearlyFixedSubtitle =>
      'Jahresabonnements, Versicherungen, Mitgliedschaften';

  @override
  String get frequencyPickerIncome => 'Wie oft erhältst du es?';

  @override
  String get frequencyMonthlyIncomeSubtitle =>
      'Gehalt, Rente, regelmäßige Überweisungen';

  @override
  String get frequencyYearlyIncomeSubtitle =>
      'Jahresbonus, Steuererstattung, Dividenden';

  @override
  String get frequencyOneTimeIncomeSubtitle =>
      'Geschenk, unerwartete Einnahme, Einmalzahlung';

  @override
  String get typePickerTitle => 'Was möchtest du hinzufügen?';

  @override
  String get typeIncomeSubtitle => 'Gehalt, Bonus, Rente, Geschenke';

  @override
  String get typeFixedCostSubtitle => 'Miete, Versicherungen, Abonnements';

  @override
  String get languagePickerTitle => 'Sprache';

  @override
  String get currencyPickerTitle => 'Währung';

  @override
  String get currencyCustom => 'Benutzerdefiniert';

  @override
  String get currencyCustomSubtitle => 'Eigenen Code und Symbol festlegen';

  @override
  String get currencyCustomTitle => 'Benutzerdefinierte Währung';

  @override
  String get currencyCodeLabel => 'Code';

  @override
  String get currencyCodeHint => 'z. B. USD';

  @override
  String get currencySymbolLabel => 'Symbol';

  @override
  String get currencySymbolHint => 'z. B. \$';

  @override
  String get removeFromImport => 'Aus Import entfernen';

  @override
  String get exportExpensesTitle => 'Ausgaben exportieren';

  @override
  String get selectDateRangeHint => 'Datumsbereich für den Export auswählen:';

  @override
  String get startDateLabel => 'Startdatum';

  @override
  String get endDateLabel => 'Enddatum';

  @override
  String get tapToSelectDate => 'Tippen zum Auswählen';

  @override
  String get endDateAfterStart =>
      'Das Enddatum muss gleich oder nach dem Startdatum liegen.';

  @override
  String get actionExport => 'Exportieren';

  @override
  String overspendWarning(String period, String amount) {
    return 'Diesen $period hast du $amount mehr ausgegeben als eingenommen!';
  }

  @override
  String get periodMonth => 'Monat';

  @override
  String get periodYear => 'Jahr';

  @override
  String guardBannerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'GUARD — $count Zahlungen nicht bestätigt',
      one: 'GUARD — 1 Zahlung nicht bestätigt',
    );
    return '$_temp0';
  }

  @override
  String get guardSilencedBadge => 'stummgeschaltet';

  @override
  String guardExpenseStripPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bewachte Zahlungen ausstehend',
      one: '1 bewachte Zahlung ausstehend',
    );
    return '$_temp0';
  }

  @override
  String importErrorRowLabel(int row, String field) {
    return 'Zeile $row — $field';
  }

  @override
  String earnedLabel(String amount) {
    return 'Verdient: $amount';
  }

  @override
  String fromDateShort(String label) {
    return 'ab $label';
  }

  @override
  String untilDateShort(String label) {
    return 'bis $label';
  }

  @override
  String get guardEnableToggle => 'GUARD aktivieren';

  @override
  String get guardEnableToggleSubtitle =>
      'Zahlung verfolgen und Erinnerungen erhalten';

  @override
  String get actionOk => 'OK';

  @override
  String get labelTotal => 'Gesamt';

  @override
  String get categoryBudgetsTitle => 'Kategorie-Budgets';

  @override
  String get noCategoryBudgetsSet => 'Keine Kategorie-Budgets festgelegt.';

  @override
  String removeBudgetDialogTitle(String category) {
    return 'Budget für $category entfernen';
  }

  @override
  String endBudgetFromTitle(String from) {
    return 'Beenden ab $from';
  }

  @override
  String endBudgetFromDescription(String from) {
    return 'Beendet das Budget ab $from. Frühere Monate behalten ihr historisches Budget.';
  }

  @override
  String get deleteBudgetSeriesTitle => 'Gesamte Serie löschen';

  @override
  String get deleteBudgetSeriesConfirm => 'Serie löschen';

  @override
  String deleteBudgetSeriesDescription(String range) {
    return 'Entfernt dauerhaft alle Einträge ($range). Für keinen Monat dieser Serie erscheint ein Budget. Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String budgetRangePresent(String start) {
    return '$start – heute';
  }

  @override
  String get pdfMonthlyReport => 'Monatsbericht';

  @override
  String get pdfYearlyReport => 'Jahresbericht';

  @override
  String pdfMonthlyReportHeader(String month, int year) {
    return 'MONATSBERICHT FÜR $month $year';
  }

  @override
  String pdfYearlyReportHeader(int year) {
    return 'JAHRESBERICHT FÜR $year';
  }

  @override
  String get pdfPartialYear => '(Teiljahr)';

  @override
  String get pdfSectionSpendingVsIncome => 'AUSGABEN VS. EINNAHMEN';

  @override
  String get pdfSectionCategorySummary => 'KATEGORIE-ZUSAMMENFASSUNG';

  @override
  String get pdfSectionCashFlowSummary => 'CASHFLOW-ZUSAMMENFASSUNG';

  @override
  String get pdfSectionExpenseGroups => 'AUSGABENGRUPPEN';

  @override
  String get pdfSectionExpenseDetails => 'AUSGABENDETAILS';

  @override
  String get pdfSectionYearlyOverview => 'JAHRESÜBERSICHT';

  @override
  String get pdfSectionSpendingByCategory =>
      'AUSGABEN NACH KATEGORIE UND MONAT';

  @override
  String get pdfIncomeHeader => 'EINNAHMEN';

  @override
  String get pdfFixedCostsHeader => 'FIXKOSTEN';

  @override
  String get pdfTotal => 'GESAMT';

  @override
  String get pdfColTotal => 'Gesamt';

  @override
  String get pdfEarnedThisMonth => 'Diesen Monat verdient';

  @override
  String get pdfEarnedThisYear => 'Dieses Jahr verdient';

  @override
  String get pdfGroupTotal => 'Gruppengesamt (diesen Monat)';

  @override
  String get pdfAllPeriodsTotal => 'Gesamtbetrag aller Zeiträume';

  @override
  String pdfItemsThisMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge diesen Monat',
      one: '1 Eintrag diesen Monat',
    );
    return '$_temp0';
  }

  @override
  String get pdfNormalized => ' (normalisiert)';

  @override
  String get pdfAnnualized => ' (annualisiert)';

  @override
  String get pdfPartialYearNote =>
      'Teiljahr – Monate ohne Daten werden als null angezeigt. Nur Jahres-bis-dato-Summen.';

  @override
  String pdfPage(int page, int total) {
    return 'Seite $page von $total';
  }

  @override
  String get pdfNoData => 'Keine Daten.';

  @override
  String get howItWorksExampleSalary => 'Gehalt';

  @override
  String get howItWorksExampleBonus => 'Bonus';

  @override
  String get howItWorksExampleRent => 'Miete';

  @override
  String get howItWorksExampleInsurance => 'Versicherung';

  @override
  String get howItWorksExampleEtfFonds => 'ETF-Fonds';

  @override
  String get addBudgetTooltip => 'Budget hinzufügen';

  @override
  String get selectCategoryTitle => 'Kategorie auswählen';

  @override
  String get showAllCategories => 'Alle Kategorien anzeigen';

  @override
  String get showLessCategories => 'Weniger anzeigen';

  @override
  String get allCategoriesTitle => 'Alle Kategorien';

  @override
  String get howCategoryBudgetsSubtitle0 => 'Warum es das gibt';

  @override
  String get howCategoryBudgetsSubtitle1 => 'Budget erstellen';

  @override
  String get howCategoryBudgetsSubtitle2 => 'Balken lesen';

  @override
  String get howCategoryBudgetsLabel0 => 'Limit';

  @override
  String get howCategoryBudgetsLabel1 => 'Einrichten';

  @override
  String get howCategoryBudgetsLabel2 => 'Fortschritt';

  @override
  String get howCategoryBudgetsWhatIntro =>
      'Legen Sie ein monatliches Limit für jede Kategorie fest — Restaurants, Lebensmittel, Unterhaltung. Geben Sie nur das aus, was Sie geplant haben.';

  @override
  String get howCategoryBudgetsRule1 =>
      'Wählen Sie die Kategorien, in denen Sie zum Überschreiten neigen. Setzen Sie das Limit nur dort.';

  @override
  String get howCategoryBudgetsRule2 =>
      'Jedes Budget ist ein einfaches Monatslimit — zum Beispiel: Restaurants → 100 € pro Monat.';

  @override
  String get howCategoryBudgetsRule3 =>
      'Budgets sind optional. Setzen Sie so viele oder so wenige wie Sie möchten.';

  @override
  String get howCategoryBudgetsRule4 =>
      'Pro Kategorie kann ein Budget aktiv sein — für beliebig viele Kategorien.';

  @override
  String get howCategoryBudgetsSetupIntro =>
      'Tippen Sie auf + im Budgets verwalten-Bildschirm. Kategorie wählen, Betrag eingeben, Startmonat festlegen. Fertig.';

  @override
  String get howCategoryBudgetsSetupRule1 =>
      'Wählen Sie eine Kategorie — zum Beispiel Restaurants.';

  @override
  String get howCategoryBudgetsSetupRule2 =>
      'Geben Sie Ihr Monatslimit ein — zum Beispiel 100 €.';

  @override
  String get howCategoryBudgetsSetupRule3 =>
      'Wählen Sie den Startmonat. Das Budget gilt ab diesem Zeitpunkt.';

  @override
  String get howCategoryBudgetsSetupRule4 =>
      'Nach dem Speichern ist die Kategorie gesperrt — erstellen Sie ein neues Budget, um es später zu ändern.';

  @override
  String get howCategoryBudgetsPastMonthHint =>
      'Die Wahl eines vergangenen Monats wendet das Budget rückwirkend an. Eine Bestätigung erscheint vor dem Speichern.';

  @override
  String get howCategoryBudgetsProgressIntro =>
      'Der Fortschrittsbalken zeigt genau, wo Sie stehen — auf einen Blick, jedes Mal wenn Sie Ausgaben öffnen.';

  @override
  String get howCategoryBudgetsProgressRule1 =>
      'Grün — unter 80 %: Ausgaben im Rahmen. Weiter so.';

  @override
  String get howCategoryBudgetsProgressRule2 =>
      'Orange — 80–100 %: fast am Limit. Zeit, langsamer zu werden.';

  @override
  String get howCategoryBudgetsProgressRule3 =>
      'Rot — über 100 %: Limit überschritten. Eine Warnkarte erscheint oben in Ihren Ausgaben.';

  @override
  String get howCategoryBudgetsWhereTitle => 'Wo es erscheint';

  @override
  String get howCategoryBudgetsWhere1 =>
      'Ausgaben — unter jeder Kategoriezeile erscheint ein Fortschrittsbalken, wenn ein Budget aktiv ist.';

  @override
  String get howCategoryBudgetsWhere2 =>
      'Kategorienansicht — jede Kategorie mit Budget zeigt ihren Füllstand.';

  @override
  String get howCategoryBudgetsWhere3 =>
      'Monatlicher PDF-Bericht — Budgets sind in der Ausgabenzusammenfassung enthalten.';

  @override
  String get howCategoryBudgetsResetHint =>
      'Budgets werden jeden Monat zurückgesetzt — nicht verbrauchte Beträge werden nicht übertragen.';

  @override
  String get howGuardSubtitle0 => 'Ihre Zahlungserinnerung';

  @override
  String get howGuardSubtitle1 => 'Einrichtung';

  @override
  String get howGuardSubtitle2 => 'Wie es sich wiederholt';

  @override
  String get howGuardLabel0 => 'Erinnerung';

  @override
  String get howGuardLabel1 => 'Einstellungen';

  @override
  String get howGuardLabel2 => 'Wiederkehrend';

  @override
  String get howGuardWhatIntro =>
      'GUARD erinnert Sie, wenn eine regelmäßige Rechnung fällig wird — Miete, Netflix, Versicherung. Nichts geht durch.';

  @override
  String get howGuardRule1 =>
      'Am Fälligkeitstag erscheint eine Benachrichtigung auf Ihrem Telefon. Keine Vorbereitung im Voraus nötig.';

  @override
  String get howGuardRule2 =>
      'Tippen Sie auf \"Bezahlt\" zur Bestätigung. Oder stummschalten, wenn Sie diesmal überspringen möchten.';

  @override
  String get howGuardRule3 =>
      'Jede überwachte Rechnung zeigt ihren aktuellen Status auf einen Blick.';

  @override
  String get howGuardStateUnpaid => 'Fällig — wartet auf Ihre Bestätigung';

  @override
  String get howGuardStatePaid => 'Bezahlt — für diesen Zeitraum bestätigt';

  @override
  String get howGuardStateSilenced => 'Stummgeschaltet — Erinnerung abgewiesen';

  @override
  String get howGuardActivateIntro =>
      'Öffnen Sie eine beliebige Fixkostenposition, tippen Sie auf Bearbeiten und schalten Sie GUARD ein. Legen Sie fest, wann die Rechnung fällig ist — das war\'s.';

  @override
  String get howGuardActivateRule1 =>
      'Legen Sie den Fälligkeitstag fest — den Tag im Monat, an dem Sie zahlen möchten. Zum Beispiel: Miete am 1., Netflix am 15.';

  @override
  String get howGuardActivateRule2 =>
      'Ab diesem Tag wiederholt sich die tägliche Erinnerung, bis Sie sie als bezahlt markieren oder stummschalten.';

  @override
  String get howGuardActivateRule3 =>
      'Bei jährlichen Rechnungen — wie Versicherungen — wählen Sie auch den Fälligkeitsmonat.';

  @override
  String get howGuardActivateRule4 =>
      'Die tägliche Erinnerungszeit können Sie in den GUARD-Einstellungen ändern.';

  @override
  String get howGuardFixedCostOnlyHint =>
      'GUARD kann nur für Fixkosten-Positionen aktiviert werden.';

  @override
  String get howGuardActIntro =>
      'GUARD setzt sich zu Beginn jedes neuen Zeitraums automatisch zurück. Sie müssen nichts manuell zurücksetzen.';

  @override
  String get howGuardActRule1 =>
      'Monatliche Rechnungen — wie Miete oder Abonnements — erhalten jeden Monat eine neue Erinnerung.';

  @override
  String get howGuardActRule2 =>
      'Jährliche Rechnungen — wie Versicherungen oder Jahresgebühren — setzen sich einmal pro Jahr zurück.';

  @override
  String get howGuardActRule3 =>
      'Sobald Sie eine Rechnung als bezahlt markieren, bleibt sie bis zum Beginn des nächsten Zeitraums bestätigt.';

  @override
  String get howGuardPerPeriodHint =>
      'Bezahlt oder stummgeschaltet — gilt nur für den aktuellen Zeitraum. Der nächste beginnt immer neu.';
}
