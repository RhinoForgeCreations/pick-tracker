import 'package:flutter_test/flutter_test.dart';
import 'package:pick_tracker/services/clock_guard.dart';

void main() {
  test('matched wall/monotonic → duration unchanged', () {
    final r = ClockGuard.safeDuration(wallClockMs: 10000, monotonicMs: 10001);
    expect(r.durationMs, 10000); expect(r.suspect, isFalse);
  });
  test('wall jumped back >5s → clamp to 0', () {
    final r = ClockGuard.safeDuration(wallClockMs: 4000, monotonicMs: 10000);
    expect(r.durationMs, 0); expect(r.suspect, isTrue);
  });
  test('wall jumped forward >5s → clamp to 0', () {
    final r = ClockGuard.safeDuration(wallClockMs: 50000, monotonicMs: 10000);
    expect(r.durationMs, 0); expect(r.suspect, isTrue);
  });

  test('boundary: diff exactly 5000ms is NOT suspect (strict >)', () {
    final r = ClockGuard.safeDuration(wallClockMs: 15000, monotonicMs: 10000);
    expect(r.durationMs, 15000);
    expect(r.suspect, isFalse);
  });

  test('boundary: diff of 5001ms IS suspect', () {
    final r = ClockGuard.safeDuration(wallClockMs: 15001, monotonicMs: 10000);
    expect(r.durationMs, 0);
    expect(r.suspect, isTrue);
  });
}
