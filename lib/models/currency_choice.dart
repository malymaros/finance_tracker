import 'package:flutter/foundation.dart';

/// Domain model for the user's currency preference.
///
/// Two variants exist:
/// - [PresetCurrency] — one of the six built-in presets (EUR, USD, etc.)
/// - [CustomCurrency] — user-defined code and symbol (e.g. CHF / Fr.)
///
/// Both expose [code] and [symbol] so callers need not switch on the type.
sealed class CurrencyChoice {
  const CurrencyChoice();

  String get code;
  String get symbol;

  // ── Serialisation ──────────────────────────────────────────────────────────

  Map<String, dynamic> toJson();

  /// Returns a [CurrencyChoice] from JSON.  Falls back to EUR on any error.
  factory CurrencyChoice.fromJson(Map<String, dynamic> json) {
    try {
      final type = json['type'] as String?;
      if (type == 'preset') {
        final presetCode = json['preset'] as String?;
        final preset = CurrencyPreset.values.firstWhere(
          (p) => p.code == presetCode,
          orElse: () => CurrencyPreset.eur,
        );
        return PresetCurrency(preset);
      } else if (type == 'custom') {
        final code = json['code'] as String?;
        final symbol = json['symbol'] as String?;
        if (code != null && code.isNotEmpty && symbol != null && symbol.isNotEmpty) {
          return CustomCurrency(code: code, symbol: symbol);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ CurrencyChoice.fromJson: failed to parse "$json" — $e. Falling back to EUR.');
      }
    }
    return const PresetCurrency(CurrencyPreset.eur);
  }
}

// ── Preset currencies ──────────────────────────────────────────────────────────

enum CurrencyPreset {
  eur(code: 'EUR', symbol: '€'),
  usd(code: 'USD', symbol: '\$'),
  czk(code: 'CZK', symbol: 'Kč'),
  gbp(code: 'GBP', symbol: '£'),
  pln(code: 'PLN', symbol: 'zł'),
  huf(code: 'HUF', symbol: 'Ft');

  const CurrencyPreset({required this.code, required this.symbol});

  final String code;
  final String symbol;
}

class PresetCurrency extends CurrencyChoice {
  final CurrencyPreset preset;

  const PresetCurrency(this.preset);

  @override
  String get code => preset.code;

  @override
  String get symbol => preset.symbol;

  @override
  Map<String, dynamic> toJson() => {'type': 'preset', 'preset': preset.code};
}

// ── Custom currency ────────────────────────────────────────────────────────────

class CustomCurrency extends CurrencyChoice {
  @override
  final String code;

  @override
  final String symbol;

  const CustomCurrency({required this.code, required this.symbol});

  @override
  Map<String, dynamic> toJson() => {'type': 'custom', 'code': code, 'symbol': symbol};
}
