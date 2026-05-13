import '../models/order.dart';

class Calculations {
  const Calculations._();

  static const int _msPerHour = 3600000;

  static double orderRate(Order o) {
    if (o.durationMs == null || o.durationMs == 0) return 0;
    return o.cases / (o.durationMs! / _msPerHour);
  }

  /// Excludes still-open orders entirely (both cases AND time).
  static double activeRate(List<Order> orders) {
    final closed = orders.where((o) => o.durationMs != null && o.durationMs! > 0);
    final totalCases = closed.fold<int>(0, (s, o) => s + o.cases);
    final totalMs = closed.fold<int>(0, (s, o) => s + o.durationMs!);
    if (totalMs == 0) return 0;
    return totalCases / (totalMs / _msPerHour);
  }

  static double shiftRate(int totalCases, DateTime start, DateTime end) {
    final hours = end.difference(start).inMilliseconds / _msPerHour;
    if (hours <= 0) return 0;
    return totalCases / hours;
  }

  static double percentOfTarget(int total, int target) {
    if (target <= 0) return 0;
    return total / target * 100;
  }
}
