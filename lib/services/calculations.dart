import '../models/order.dart';

class Calculations {
  const Calculations._();

  static double orderRate(Order o) {
    if (o.durationMs == null || o.durationMs == 0) return 0;
    return o.cases / (o.durationMs! / 3600000);
  }

  static double activeRate(List<Order> orders) {
    final totalCases = orders.fold<int>(0, (s, o) => s + o.cases);
    final totalMs = orders.fold<int>(0, (s, o) => s + (o.durationMs ?? 0));
    if (totalMs == 0) return 0;
    return totalCases / (totalMs / 3600000);
  }

  static double shiftRate(int totalCases, DateTime start, DateTime end) {
    final hours = end.difference(start).inMilliseconds / 3600000;
    if (hours <= 0) return 0;
    return totalCases / hours;
  }

  static double percentOfTarget(int total, int target) {
    if (target <= 0) return 0;
    return total / target * 100;
  }
}
