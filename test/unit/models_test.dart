import 'package:flutter_test/flutter_test.dart';
import 'package:pick_tracker/models/app_settings.dart';
import 'package:pick_tracker/models/non_work_day.dart';
import 'package:pick_tracker/models/order.dart';
import 'package:pick_tracker/models/shift.dart';

void main() {
  test('Shift roundtrips', () {
    final s = Shift(
      id: 1, startedAt: DateTime.utc(2026, 5, 13, 19, 0),
      date: '2026-05-13', target: 1000, floor: 900);
    final back = Shift.fromMap(s.toMap()..['id'] = 1);
    expect(back.startedAt, s.startedAt);
    expect(back.target, 1000);
  });

  test('Order roundtrips with bool=false', () {
    final o = Order(id: 2, shiftId: 1, seq: 3, cases: 42,
      startedAt: DateTime.utc(2026, 5, 13, 19, 5),
      isOutlier: false, edited: false);
    final back = Order.fromMap(o.toMap()..['id'] = 2);
    expect(back.cases, 42);
    expect(back.seq, 3);
    expect(back.isOutlier, isFalse);
    expect(back.edited, isFalse);
  });

  test('Order roundtrips with bool=true', () {
    final o = Order(id: 3, shiftId: 1, seq: 4, cases: 12,
      startedAt: DateTime.utc(2026, 5, 13, 19, 30),
      endedAt: DateTime.utc(2026, 5, 13, 20, 5),
      durationMs: 35 * 60 * 1000,
      isOutlier: true, edited: true);
    final m = o.toMap();
    expect(m['is_outlier'], 1);
    expect(m['edited'], 1);
    final back = Order.fromMap(m..['id'] = 3);
    expect(back.isOutlier, isTrue);
    expect(back.edited, isTrue);
    expect(back.durationMs, 35 * 60 * 1000);
  });

  test('NonWorkDay roundtrips', () {
    const n = NonWorkDay(date: '2026-04-25', reason: 'public_holiday', note: 'ANZAC Day');
    final back = NonWorkDay.fromMap(n.toMap());
    expect(back.date, '2026-04-25');
    expect(back.reason, 'public_holiday');
    expect(back.note, 'ANZAC Day');
  });

  test('AppSettings.fromMap parses defaults and nullable export timestamp', () {
    final s = AppSettings.fromMap({
      'default_target': 1000, 'default_floor': 900, 'shift_gap_minutes': 120,
      'keep_screen_on': 1, 'time_format': '24h',
      'soft_cap_per_order': 200, 'hard_cap_per_order': 2000,
      'current_input_buffer': '', 'last_export_at': null,
    });
    expect(s.defaultTarget, 1000);
    expect(s.keepScreenOn, isTrue);
    expect(s.lastExportAt, isNull);

    final s2 = AppSettings.fromMap({
      'default_target': 950, 'default_floor': 800, 'shift_gap_minutes': 90,
      'keep_screen_on': 0, 'time_format': '12h',
      'soft_cap_per_order': 150, 'hard_cap_per_order': 1500,
      'current_input_buffer': '47',
      'last_export_at': '2026-05-13T08:00:00.000Z',
    });
    expect(s2.keepScreenOn, isFalse);
    expect(s2.timeFormat, '12h');
    expect(s2.currentInputBuffer, '47');
    expect(s2.lastExportAt, DateTime.utc(2026, 5, 13, 8));
  });
}
