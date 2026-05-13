import 'package:flutter_test/flutter_test.dart';
import 'package:pick_tracker/models/shift.dart';
import 'package:pick_tracker/models/order.dart';

void main() {
  test('Shift roundtrips', () {
    final s = Shift(
      id: 1, startedAt: DateTime.utc(2026, 5, 13, 19, 0),
      date: '2026-05-13', target: 1000, floor: 900);
    final back = Shift.fromMap(s.toMap()..['id'] = 1);
    expect(back.startedAt, s.startedAt);
    expect(back.target, 1000);
  });
  test('Order roundtrips', () {
    final o = Order(id: 2, shiftId: 1, seq: 3, cases: 42,
      startedAt: DateTime.utc(2026, 5, 13, 19, 5),
      isOutlier: false, edited: false);
    final back = Order.fromMap(o.toMap()..['id'] = 2);
    expect(back.cases, 42); expect(back.seq, 3);
  });
}
