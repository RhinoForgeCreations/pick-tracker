class GuardedDuration {
  final int durationMs;
  final bool suspect;
  GuardedDuration(this.durationMs, this.suspect);
}

class ClockGuard {
  const ClockGuard._();

  static const int toleranceMs = 5000;

  static GuardedDuration safeDuration({
    required int wallClockMs,
    required int monotonicMs,
  }) {
    final diff = (wallClockMs - monotonicMs).abs();
    if (diff > toleranceMs) return GuardedDuration(0, true);
    return GuardedDuration(wallClockMs, false);
  }
}
