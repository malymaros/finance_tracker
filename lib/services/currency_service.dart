import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/currency_choice.dart';

/// Manages the user's currency preference.
///
/// Singleton pattern: call [CurrencyService.instance] after initialising with
/// `CurrencyService.instance = CurrencyService()` in [main].
///
/// Listeners are notified whenever the currency changes via [setCurrency].
/// The [load] method intentionally does NOT call [notifyListeners] because it
/// runs before any listeners are registered.
class CurrencyService extends ChangeNotifier {
  static CurrencyService? _instance;

  /// The app-wide singleton.  Auto-initialises to EUR defaults if not
  /// explicitly set via the setter (e.g. in unit tests that don't call main).
  static CurrencyService get instance => _instance ??= CurrencyService();

  static set instance(CurrencyService value) => _instance = value;

  static const _prefsKey = 'currency_choice';

  CurrencyChoice _current = const PresetCurrency(CurrencyPreset.eur);

  // ── Public getters ─────────────────────────────────────────────────────────

  /// Currently selected [CurrencyChoice].
  CurrencyChoice get current => _current;

  /// ISO 4217 code for the current currency (e.g. 'EUR').
  String get code => _current.code;

  /// Display symbol for the current currency (e.g. '€').
  String get symbol => _current.symbol;

  // ── Formatting ─────────────────────────────────────────────────────────────

  /// Formats [amount] for on-screen display.
  ///
  /// Output example: `1234.56 €`
  String format(double amount) => '${_formatNumber(amount)} $symbol';

  /// Formats [amount] for PDF output using the ISO code rather than the symbol.
  ///
  /// Output example: `1234.56 EUR`
  String formatForPdf(double amount) => '${_formatNumber(amount)} $code';

  static String _formatNumber(double amount) => amount.toStringAsFixed(2);

  // ── Persistence ────────────────────────────────────────────────────────────

  /// Reads the persisted currency choice and applies it.
  ///
  /// Must be called before [runApp].  Does NOT call [notifyListeners].
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        _current = CurrencyChoice.fromJson(json);
      }
    } catch (_) {
      // Fall back to EUR default — already set in field initialiser.
    }
  }

  /// Validates [choice], persists it, updates [current], and notifies listeners.
  ///
  /// Throws [ArgumentError] if [choice] is a [CustomCurrency] with invalid
  /// code or symbol.
  Future<void> setCurrency(CurrencyChoice choice) async {
    if (choice is CustomCurrency) {
      _validateCustom(choice.code, choice.symbol);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(choice.toJson()));
    _current = choice;
    notifyListeners();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  static void _validateCustom(String code, String symbol) {
    if (code.isEmpty || code.length > 8) {
      throw ArgumentError('Currency code must be 1–8 characters.');
    }
    final codePattern = RegExp(r'^[A-Za-z0-9]+$');
    if (!codePattern.hasMatch(code)) {
      throw ArgumentError('Currency code may only contain letters and digits.');
    }
    if (symbol.isEmpty || symbol.length > 5) {
      throw ArgumentError('Currency symbol must be 1–5 characters.');
    }
    if (symbol != symbol.trim()) {
      throw ArgumentError('Currency symbol cannot have leading or trailing whitespace.');
    }
    if (symbol.contains(RegExp(r'[\n\r\t]'))) {
      throw ArgumentError('Currency symbol cannot contain control characters.');
    }
  }
}
