import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/count_up_text.dart';

class EndShiftSummary extends StatelessWidget {
  final int totalCases, target, hours, minutes, orders;
  final double shiftRate, activeRate;
  final int? bestCases;
  final double? bestRate;
  final int? slowestCases;
  final double? slowestRate;
  final int outlierCount, streak;
  final int? allTimeBest;
  final String? allTimeBestDate;

  const EndShiftSummary({
    super.key,
    required this.totalCases,
    required this.target,
    required this.hours,
    required this.minutes,
    required this.orders,
    required this.shiftRate,
    required this.activeRate,
    this.bestCases,
    this.bestRate,
    this.slowestCases,
    this.slowestRate,
    required this.outlierCount,
    required this.streak,
    this.allTimeBest,
    this.allTimeBestDate,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (totalCases / target * 100).round();
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SHIFT DONE', style: AppTypography.statLabel),
            const SizedBox(height: 8),
            CountUpText(value: totalCases, style: AppTypography.hero),
            Text('of $target  ·  $pct%', style: AppTypography.statValue),
            const SizedBox(height: 8),
            Text('${hours}h ${minutes}m · $orders orders',
              style: AppTypography.statValue),
            const Divider(height: 32),
            _row('Shift rate', '${shiftRate.round()}/hr'),
            _row('Active rate', '${activeRate.round()}/hr'),
            const Divider(height: 32),
            if (bestCases != null)
              _row('Best order', '$bestCases @ ${bestRate!.round()}/hr'),
            if (slowestCases != null)
              _row('Slowest', '$slowestCases @ ${slowestRate!.round()}/hr  ⚠'),
            if (outlierCount > 0)
              _row('Outliers', '$outlierCount excluded'),
            const Divider(height: 32),
            _row('Streak', '$streak days at target ▲'),
            if (allTimeBest != null)
              _row('All-time best', '$allTimeBest cases · $allTimeBestDate'),
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: Text('Done'))),
          ]))));
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Expanded(child: Text(label, style: AppTypography.statLabel)),
      Text(value, style: AppTypography.statValue),
    ]));
}
