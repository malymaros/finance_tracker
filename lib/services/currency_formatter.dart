import 'currency_service.dart';

/// Centralised currency formatting for the Finance Tracker app.
///
/// All production rendering code must go through this class instead of
/// building amount strings inline.  This is a static facade that delegates
/// to [CurrencyService], so all call sites remain unchanged when the currency
/// preference changes.
///
/// Fallback rule: any unknown or missing value returns EUR / €.
abstract final class CurrencyFormatter {
  // ── Current currency (delegated to CurrencyService) ────────────────────────

  /// ISO 4217 currency code for the current currency.
  static String get currencyCode => CurrencyService.instance.code;

  /// Display symbol for the current currency.
  static String get currencySymbol => CurrencyService.instance.symbol;

  // ── Formatting ─────────────────────────────────────────────────────────────

  /// Formats [amount] for on-screen display.
  ///
  /// Output example: `1234.56 €`
  ///
  /// The symbol is appended as a suffix.  When locale-aware placement
  /// (prefix vs suffix) is introduced, this is the single place to change.
  static String format(double amount) => CurrencyService.instance.format(amount);

  /// Formats [amount] for PDF output using the ISO code rather than the symbol.
  ///
  /// Output example: `1234.56 EUR`
  static String formatForPdf(double amount) => CurrencyService.instance.formatForPdf(amount);
}
