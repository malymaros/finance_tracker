enum GuardState {
  /// Item is not guarded, or GUARD is not relevant.
  none,

  /// Guarded, period is due, no payment confirmed, not silenced.
  unpaidActive,

  /// Guarded, period is due, user silenced notifications but has not paid.
  silenced,

  /// Guarded, payment confirmed by user for this period.
  paid,
}
