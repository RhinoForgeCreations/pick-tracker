import 'package:flutter_test/flutter_test.dart';
import 'package:pick_tracker/models/order.dart';
import 'package:pick_tracker/services/outlier_detector.dart';

void main() {
  Order make({required int cases, required int durMin}) => Order(
    shiftId: 1, seq: 1, cases: cases,
    startedAt: DateTime.utc(2026, 1, 1),
    endedAt: DateTime.utc(2026, 1, 1).add(Duration(minutes: durMin)),
    durationMs: durMin * 60 * 1000, isOutlier: false, edited: false);

  test('rate <30/hr is outlier', () {
    expect(OutlierDetector.isOutlier(make(cases: 5, durMin: 15)), isTrue);
  });
  test('duration >30min is outlier', () {
    expect(OutlierDetector.isOutlier(make(cases: 200, durMin: 45)), isTrue);
  });
  test('healthy order not outlier', () {
    expect(OutlierDetector.isOutlier(make(cases: 42, durMin: 18)), isFalse);
  });

  test('open order (durationMs null) is not outlier', () {
    final open = Order(shiftId: 1, seq: 1, cases: 42,
      startedAt: DateTime.utc(2026, 1, 1), isOutlier: false, edited: false);
    expect(OutlierDetector.isOutlier(open), isFalse);
  });

  test('boundary: exactly 30/hr is NOT outlier (strict <)', () {
    // 15 cases in 30 min = 30/hr exactly
    expect(OutlierDetector.isOutlier(make(cases: 15, durMin: 30)), isFalse);
  });

  test('boundary: just below 30/hr IS outlier', () {
    // 14 cases in 30 min = 28/hr → outlier
    expect(OutlierDetector.isOutlier(make(cases: 14, durMin: 30)), isTrue);
  });

  test('boundary: exactly 30min duration is NOT outlier (strict >)', () {
    // 100 cases in exactly 30 min = 200/hr, exactly at threshold
    expect(OutlierDetector.isOutlier(make(cases: 100, durMin: 30)), isFalse);
  });

  test('boundary: just over 30min duration IS outlier', () {
    expect(OutlierDetector.isOutlier(make(cases: 100, durMin: 31)), isTrue);
  });

  test('zero-duration closed order IS outlier (sentinel via rate=0)', () {
    // Data anomaly: closed order with 0 duration cascades through rate check.
    final zero = Order(shiftId: 1, seq: 1, cases: 5,
      startedAt: DateTime.utc(2026, 1, 1),
      endedAt: DateTime.utc(2026, 1, 1),
      durationMs: 0, isOutlier: false, edited: false);
    expect(OutlierDetector.isOutlier(zero), isTrue);
  });
}
