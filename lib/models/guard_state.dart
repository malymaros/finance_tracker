enum GuardState {
  /// Item is not guarded, or GUARD is not relevant for this item type.
  none,

  /// Guarded and configured, but the due day has not yet arrived for this
  /// period (future period, or current period before its due day).
  /// Shown as a faint icon to indicate GUARD is active, but not yet alerting.
  scheduled,

  /// Guarded, period is due, no payment confirmed, not silenced.
  unpaidActive,

  /// Guarded, period is due, user silenced notifications but has not paid.
  silenced,

  /// Guarded, payment confirmed by user for this period.
  paid,
}
