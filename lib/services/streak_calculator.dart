class StreakCalculator {
  const StreakCalculator._();

  /// Maximum days to walk backward — prevents runaway loops when
  /// nonWorkDates is unbounded or dailyTotals is sparse.
  static const int maxLookbackDays = 365;

  static int compute({
    required String endingOn,
    required Map<String, int> dailyTotals,
    required Map<String, int> dailyTargets,
    required Set<String> nonWorkDates,
  }) {
    // Use UTC arithmetic to avoid DST surprises (1-hour days in Apr/Oct).
    final start = DateTime.parse(endingOn);
    DateTime cur = DateTime.utc(start.year, start.month, start.day);
    int streak = 0;
    for (var walked = 0; walked < maxLookbackDays; walked++) {
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
