import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// Convenience extension so any widget can write `context.l10n.keyName`
/// instead of the verbose `AppLocalizations.of(context).keyName`.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
