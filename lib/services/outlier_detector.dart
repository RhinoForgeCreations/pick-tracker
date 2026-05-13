import '../models/order.dart';
import 'calculations.dart';

class OutlierDetector {
  const OutlierDetector._();

  static const double rateThresholdPerHour = 30;
  static const int durationThresholdMs = 30 * 60 * 1000;

  static bool isOutlier(Order o) {
    if (o.durationMs == null) return false;
    if (o.durationMs! > durationThresholdMs) return true;
    return Calculations.orderRate(o) < rateThresholdPerHour;
  }
}
