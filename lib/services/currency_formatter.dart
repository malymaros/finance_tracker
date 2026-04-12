/// Centralised currency formatting for the Finance Tracker app.
///
/// All production rendering code must go through this class instead of
/// building amount strings inline.  When the user-preference system arrives
/// (Phase 3), the hardcoded constants below are replaced by preference reads
/// without touching any call site.
///
/// Fallback rule: any unknown or missing value returns EUR / €.
abstract final class CurrencyFormatter {
  // ── Current defaults (Phase 1 — EUR only) ──────────────────────────────────

  /// ISO 4217 currency code.  Never stored as a symbol — always as a code.
  static const String currencyCode = 'EUR';

  /// Display symbol for [currencyCode].
  static const String currencySymbol = '€';

  // ── Formatting ─────────────────────────────────────────────────────────────

  /// Formats [amount] for on-screen display.
  ///
  /// Output example: `1234.56 €`
  ///
  /// The symbol is appended as a suffix.  When Phase 3 introduces locale-aware
  /// placement (prefix vs suffix), this is the single place to change.
  static String format(double amount) {
    return '${_formatNumber(amount)} $currencySymbol';
  }

  /// Formats [amount] for PDF output using the ISO code rather than the symbol.
  ///
  /// Output example: `1234.56 EUR`
  ///
  /// **This method is a temporary compatibility shim.**  The PDF service
  /// historically used the ISO code as text rather than the currency symbol.
  /// Remove this method and unify with [format] when the PDF presentation
  /// layer is properly reviewed (Phase 5).
  static String formatForPdf(double amount) {
    return '${_formatNumber(amount)} $currencyCode';
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  static String _formatNumber(double amount) => amount.toStringAsFixed(2);
}
