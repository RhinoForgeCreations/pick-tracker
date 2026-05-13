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

  test('order_rate', () {
    expect(Calculations.orderRate(order(1, 42, 18)).round(), 140);
  });
  test('active_rate sums orders only', () {
    final os = [order(1, 42, 18), order(2, 50, 25)];
    expect(Calculations.activeRate(os).round(), 128);
  });
  test('shift_rate wall-clock', () {
    final start = base.add(const Duration(minutes: 30));
    final end = base.add(const Duration(minutes: 85));
    expect(Calculations.shiftRate(92, start, end).round(), 100);
  });
}
