import 'app_localizations.dart';
import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../models/year_month.dart';

extension AppLocalizationsMonths on AppLocalizations {
  String monthName(int month) => [
        '',
        monthJanuary,
        monthFebruary,
        monthMarch,
        monthApril,
        monthMay,
        monthJune,
        monthJuly,
        monthAugust,
        monthSeptember,
        monthOctober,
        monthNovember,
        monthDecember,
      ][month];

  String monthAbbr(int month) => [
        '',
        monthAbbrJan,
        monthAbbrFeb,
        monthAbbrMar,
        monthAbbrApr,
        monthAbbrMay,
        monthAbbrJun,
        monthAbbrJul,
        monthAbbrAug,
        monthAbbrSep,
        monthAbbrOct,
        monthAbbrNov,
        monthAbbrDec,
      ][month];

  String categoryName(ExpenseCategory cat) => switch (cat) {
        ExpenseCategory.housing => categoryHousing,
        ExpenseCategory.groceries => categoryGroceries,
        ExpenseCategory.vacation => categoryVacation,
        ExpenseCategory.transport => categoryTransport,
        ExpenseCategory.insurance => categoryInsurance,
        ExpenseCategory.subscriptions => categorySubscriptions,
        ExpenseCategory.communication => categoryCommunication,
        ExpenseCategory.health => categoryHealth,
        ExpenseCategory.restaurants => categoryRestaurants,
        ExpenseCategory.entertainment => categoryEntertainment,
        ExpenseCategory.clothing => categoryClothing,
        ExpenseCategory.education => categoryEducation,
        ExpenseCategory.investment => categoryInvestment,
        ExpenseCategory.gifts => categoryGifts,
        ExpenseCategory.taxes => categoryTaxes,
        ExpenseCategory.medications => categoryMedications,
        ExpenseCategory.other => categoryOther,
      };

  String financialTypeName(FinancialType t) => switch (t) {
        FinancialType.asset => financialTypeAsset,
        FinancialType.consumption => financialTypeConsumption,
        FinancialType.insurance => financialTypeInsurance,
      };

  String yearMonthLabel(YearMonth ym) => '${monthName(ym.month)} ${ym.year}';
}
