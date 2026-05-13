class StreakCalculator {
  const StreakCalculator._();

  static int compute({
    required String endingOn,
    required Map<String, int> dailyTotals,
    required Map<String, int> dailyTargets,
    required Set<String> nonWorkDates,
  }) {
    DateTime cur = DateTime.parse(endingOn);
    int streak = 0;
    while (true) {
      final k = _ymd(cur);
      if (nonWorkDates.contains(k)) {
        cur = cur.subtract(const Duration(days: 1));
        continue;
      }
      final total = dailyTotals[k];
      final target = dailyTargets[k];
      if (total == null || target == null) break;
      if (total < target) break;
      streak++;
      cur = cur.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
