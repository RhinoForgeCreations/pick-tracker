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
}
