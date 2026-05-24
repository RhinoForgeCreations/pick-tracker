import 'package:flutter_test/flutter_test.dart';
import 'package:pick_tracker/models/order.dart';
import 'package:pick_tracker/services/calculations.dart';

void main() {
  final base = DateTime.utc(2026, 5, 13, 19, 0);
  Order order(int seq, int cases, int durMin) => Order(
    shiftId: 1, seq: seq, cases: cases,
    startedAt: base.add(Duration(minutes: seq * 30)),
    endedAt: base.add(Duration(minutes: seq * 30 + durMin)),
    durationMs: durMin * 60 * 1000, isOutlier: false, edited: false);

  Order openOrder(int seq, int cases) => Order(
    shiftId: 1, seq: seq, cases: cases,
    startedAt: base.add(Duration(minutes: seq * 30)),
    isOutlier: false, edited: false);

  test('order_rate', () {
    expect(Calculations.orderRate(order(1, 42, 18)).round(), 140);
  });
  test('order_rate returns 0 for null/zero duration', () {
    expect(Calculations.orderRate(openOrder(1, 42)), 0.0);
    final zeroDur = Order(shiftId: 1, seq: 1, cases: 5,
      startedAt: base, endedAt: base, durationMs: 0,
      isOutlier: false, edited: false);
    expect(Calculations.orderRate(zeroDur), 0.0);
  });

  test('active_rate sums closed orders only', () {
    final os = [order(1, 42, 18), order(2, 50, 25)];
    expect(Calculations.activeRate(os).round(), 128);
  });
  test('active_rate excludes open orders entirely', () {
    // Without exclusion, 142 cases over 43 min = 198/hr (inflated).
    // With exclusion, 92 cases over 43 min = 128/hr (correct).
    final os = [order(1, 42, 18), order(2, 50, 25), openOrder(3, 50)];
    expect(Calculations.activeRate(os).round(), 128);
  });
  test('active_rate returns 0 for empty list', () {
    expect(Calculations.activeRate(const []), 0.0);
  });

  test('shift_rate wall-clock', () {
    final start = base.add(const Duration(minutes: 30));
    final end = base.add(const Duration(minutes: 85));
    expect(Calculations.shiftRate(92, start, end).round(), 100);
  });
  test('shift_rate returns 0 when end == start', () {
    expect(Calculations.shiftRate(50, base, base), 0.0);
  });
  test('shift_rate subtracts breakMs from worked time', () {
    final start = base.add(const Duration(minutes: 30));
    final end = base.add(const Duration(minutes: 90)); // 60 min wall
    // 92 cases / 30 min worked = 184/hr
    final r = Calculations.shiftRate(92, start, end,
      breakMs: 30 * 60 * 1000);
    expect(r.round(), 184);
  });
  test('shift_rate returns 0 when break >= total time', () {
    final start = base;
    final end = base.add(const Duration(minutes: 30));
    expect(Calculations.shiftRate(50, start, end,
      breakMs: 30 * 60 * 1000), 0.0);
    expect(Calculations.shiftRate(50, start, end,
      breakMs: 99 * 60 * 1000), 0.0);
  });

  test('percent_of_target', () {
    expect(Calculations.percentOfTarget(500, 1000), 50.0);
    expect(Calculations.percentOfTarget(1200, 1000), 120.0);
  });
  test('percent_of_target returns 0 for non-positive target', () {
    expect(Calculations.percentOfTarget(500, 0), 0.0);
    expect(Calculations.percentOfTarget(500, -1), 0.0);
  });
}
