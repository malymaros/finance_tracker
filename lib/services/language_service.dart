import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the user's language preference.
///
/// Singleton pattern — initialised in [main] before [runApp].
/// [load] does NOT call [notifyListeners]; it runs before listeners exist.
/// [setLocale] persists the choice and notifies listeners.
class LanguageService extends ChangeNotifier {
  static LanguageService? _instance;

  /// App-wide singleton.  Auto-initialises to device default if not set
  /// explicitly (e.g. in unit tests that don't call main).
  static LanguageService get instance => _instance ??= LanguageService();
  static set instance(LanguageService value) => _instance = value;

  static const _prefsKey = 'app_locale';

  /// Supported locales in display order.
  static const supportedLocales = [
    Locale('en'),
    Locale('de'),
    Locale('sk'),
    Locale('cs'),
    Locale('pl'),
    Locale('hu'),
  ];

  Locale _current = const Locale('en');

  /// Currently selected locale.
  Locale get current => _current;

  // ── Persistence ────────────────────────────────────────────────────────────

  /// Reads the persisted locale and applies it.
  /// Must be called before [runApp].  Does NOT call [notifyListeners].
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefsKey);
      if (code != null) {
        final match = supportedLocales.firstWhere(
          (l) => l.languageCode == code,
          orElse: () => const Locale('en'),
        );
        _current = match;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ LanguageService.load: failed — $e. Falling back to EN.');
      }
    }
  }

  /// Persists [locale], updates [current], and notifies listeners.
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
    _current = locale;
    notifyListeners();
  }
}
