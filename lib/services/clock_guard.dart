class GuardedDuration {
  final int durationMs;
  final bool suspect;
  GuardedDuration(this.durationMs, this.suspect);
}

class ClockGuard {
  const ClockGuard._();

  static const int toleranceMs = 5000;

  /// Returns wallClockMs as the duration when wall and monotonic clocks agree
  /// within `toleranceMs`. When they diverge by more than the tolerance (clock
  /// jump from NTP or user time change), returns a `suspect=true` result with
  /// `durationMs=0` as a sentinel. The zero sentinel propagates through
  /// `Calculations.orderRate` (which returns 0 for zero duration) and is then
  /// flagged by `OutlierDetector`. Callers persisting durations should check
  /// `suspect` and store the order as an outlier explicitly.
  static GuardedDuration safeDuration({
    required int wallClockMs,
    required int monotonicMs,
  }) {
    final diff = (wallClockMs - monotonicMs).abs();
    if (diff > toleranceMs) return GuardedDuration(0, true);
    return GuardedDuration(wallClockMs, false);
  }
}
