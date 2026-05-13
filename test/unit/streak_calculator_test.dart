import 'package:flutter_test/flutter_test.dart';
import 'package:pick_tracker/services/streak_calculator.dart';

void main() {
  test('streak skips non-work days', () {
    final totals = {
      '2026-05-13': 1020,
      '2026-05-12': 1010, // corrected from plan (970 → 1010) so streak walks 5/13→5/12→(skip 5/11)→5/10
      '2026-05-10': 1100,
      '2026-05-09': 880,
    };
    final targets = {for (final k in totals.keys) k: 1000};
    expect(
      StreakCalculator.compute(
        endingOn: '2026-05-13',
        dailyTotals: totals,
        dailyTargets: targets,
        nonWorkDates: {'2026-05-11'},
      ),
      3,
    );
  });

  test('streak breaks on day below target', () {
    final totals = {
      '2026-05-13': 1020,
      '2026-05-12': 850, // below target → streak breaks here
      '2026-05-11': 1100,
    };
    final targets = {for (final k in totals.keys) k: 1000};
    expect(
      StreakCalculator.compute(
        endingOn: '2026-05-13',
        dailyTotals: totals,
        dailyTargets: targets,
        nonWorkDates: {},
      ),
      1,
    );
  });

  test('empty totals returns 0 immediately', () {
    expect(
      StreakCalculator.compute(
        endingOn: '2026-05-13',
        dailyTotals: const {},
        dailyTargets: const {},
        nonWorkDates: const {},
      ),
      0,
    );
  });

  test('maxLookbackDays cap prevents infinite loop on all-nonwork dataset', () {
    // Empty data + every date non-work → would loop forever without the cap.
    final nonWork = <String>{};
    final cur = DateTime.utc(2026, 5, 13);
    for (var i = 0; i < 500; i++) {
      final d = cur.subtract(Duration(days: i));
      nonWork.add(
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}');
    }
    final stopwatch = Stopwatch()..start();
    final streak = StreakCalculator.compute(
      endingOn: '2026-05-13',
      dailyTotals: const {},
      dailyTargets: const {},
      nonWorkDates: nonWork,
    );
    stopwatch.stop();
    expect(streak, 0);
    expect(stopwatch.elapsedMilliseconds, lessThan(100),
      reason: 'cap must terminate quickly');
  });
}
