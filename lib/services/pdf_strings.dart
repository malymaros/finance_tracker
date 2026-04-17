import '../l10n/app_localizations.dart';
import '../l10n/l10n_extensions.dart';
import '../models/expense_category.dart';
import '../models/financial_type.dart';

/// Holds all localized strings required by [PdfReportService].
///
/// Instantiate via [PdfStrings.fromL10n] on the UI side where a
/// [BuildContext] is available, then pass to the static PDF methods.
class PdfStrings {
  /// Full month names: index 0 is empty, 1–12 are Jan–Dec.
  final List<String> monthNames;

  /// Abbreviated month names: index 0 is empty, 1–12 are Jan–Dec abbrs.
  final List<String> monthAbbreviations;

  final String Function(ExpenseCategory) categoryName;
  final String Function(FinancialType) financialTypeName;

  // Report titles / headers
  final String monthlyReport;
  final String yearlyReport;
  final String partialYear;
  final String Function(String month, int year) monthlyReportHeader;
  final String Function(int year) yearlyReportHeader;

  // Section titles
  final String sectionSpendingVsIncome;
  final String sectionCategorySummary;
  final String sectionCashFlowSummary;
  final String sectionExpenseGroups;
  final String sectionExpenseDetails;
  final String sectionYearlyOverview;
  final String sectionSpendingByCategory;

  // Card headers
  final String incomeHeader;
  final String fixedCostsHeader;

  // Labels / columns
  final String earnedThisMonth;
  final String earnedThisYear;
  final String total;
  final String colTotal;
  final String dateLabel;
  final String noteLabel;
  final String categoryLabel;
  final String amountLabel;

  // Groups section
  final String groupTotal;
  final String allPeriodsTotal;
  final String Function(int count) itemsThisMonth;

  // Suffixes
  final String normalized;
  final String annualized;

  // Parametric strings
  final String Function(String period, String amount) overspendWarning;
  final String Function(String category, String amount) budgetOverBy;

  // Period words (used inside overspendWarning)
  final String periodMonth;
  final String periodYear;

  // Misc
  final String Function(String amount) earnedLabel;
  final String partialYearNote;
  final String noData;
  final String Function(int page, int total) pageOf;

  const PdfStrings({
    required this.monthNames,
    required this.monthAbbreviations,
    required this.categoryName,
    required this.financialTypeName,
    required this.monthlyReport,
    required this.yearlyReport,
    required this.partialYear,
    required this.monthlyReportHeader,
    required this.yearlyReportHeader,
    required this.sectionSpendingVsIncome,
    required this.sectionCategorySummary,
    required this.sectionCashFlowSummary,
    required this.sectionExpenseGroups,
    required this.sectionExpenseDetails,
    required this.sectionYearlyOverview,
    required this.sectionSpendingByCategory,
    required this.incomeHeader,
    required this.fixedCostsHeader,
    required this.earnedThisMonth,
    required this.earnedThisYear,
    required this.total,
    required this.colTotal,
    required this.dateLabel,
    required this.noteLabel,
    required this.categoryLabel,
    required this.amountLabel,
    required this.groupTotal,
    required this.allPeriodsTotal,
    required this.itemsThisMonth,
    required this.normalized,
    required this.annualized,
    required this.overspendWarning,
    required this.budgetOverBy,
    required this.periodMonth,
    required this.periodYear,
    required this.earnedLabel,
    required this.partialYearNote,
    required this.noData,
    required this.pageOf,
  });

  factory PdfStrings.fromL10n(AppLocalizations l10n) {
    return PdfStrings(
      monthNames: [
        '',
        l10n.monthJanuary, l10n.monthFebruary, l10n.monthMarch,
        l10n.monthApril,   l10n.monthMay,      l10n.monthJune,
        l10n.monthJuly,    l10n.monthAugust,   l10n.monthSeptember,
        l10n.monthOctober, l10n.monthNovember, l10n.monthDecember,
      ],
      monthAbbreviations: [
        '',
        l10n.monthAbbrJan, l10n.monthAbbrFeb, l10n.monthAbbrMar,
        l10n.monthAbbrApr, l10n.monthAbbrMay, l10n.monthAbbrJun,
        l10n.monthAbbrJul, l10n.monthAbbrAug, l10n.monthAbbrSep,
        l10n.monthAbbrOct, l10n.monthAbbrNov, l10n.monthAbbrDec,
      ],
      categoryName:     l10n.categoryName,
      financialTypeName: l10n.financialTypeName,
      monthlyReport:    l10n.pdfMonthlyReport,
      yearlyReport:     l10n.pdfYearlyReport,
      partialYear:      l10n.pdfPartialYear,
      monthlyReportHeader: l10n.pdfMonthlyReportHeader,
      yearlyReportHeader:  l10n.pdfYearlyReportHeader,
      sectionSpendingVsIncome:   l10n.pdfSectionSpendingVsIncome,
      sectionCategorySummary:    l10n.pdfSectionCategorySummary,
      sectionCashFlowSummary:    l10n.pdfSectionCashFlowSummary,
      sectionExpenseGroups:      l10n.pdfSectionExpenseGroups,
      sectionExpenseDetails:     l10n.pdfSectionExpenseDetails,
      sectionYearlyOverview:     l10n.pdfSectionYearlyOverview,
      sectionSpendingByCategory: l10n.pdfSectionSpendingByCategory,
      incomeHeader:    l10n.pdfIncomeHeader,
      fixedCostsHeader: l10n.pdfFixedCostsHeader,
      earnedThisMonth: l10n.pdfEarnedThisMonth,
      earnedThisYear:  l10n.pdfEarnedThisYear,
      total:           l10n.pdfTotal,
      colTotal:        l10n.pdfColTotal,
      dateLabel:       l10n.labelDate,
      noteLabel:       l10n.labelNote,
      categoryLabel:   l10n.labelCategory,
      amountLabel:     l10n.labelAmount,
      groupTotal:      l10n.pdfGroupTotal,
      allPeriodsTotal: l10n.pdfAllPeriodsTotal,
      itemsThisMonth:  l10n.pdfItemsThisMonth,
      normalized:      l10n.pdfNormalized,
      annualized:      l10n.pdfAnnualized,
      overspendWarning: l10n.overspendWarning,
      budgetOverBy:     l10n.categoryBudgetOverBy,
      periodMonth:     l10n.periodMonth,
      periodYear:      l10n.periodYear,
      earnedLabel:     l10n.earnedLabel,
      partialYearNote: l10n.pdfPartialYearNote,
      noData:          l10n.pdfNoData,
      pageOf:          l10n.pdfPage,
    );
  }
}
