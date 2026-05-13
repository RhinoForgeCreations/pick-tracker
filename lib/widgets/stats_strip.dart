import 'package:flutter/material.dart';
import '../theme/app_typography.dart';
import 'progress_bar.dart';

class StatsStrip extends StatelessWidget {
  final int todayTotal;
  final int target;
  final double shiftRate;
  final Duration shiftElapsed;

  const StatsStrip({super.key,
    required this.todayTotal, required this.target,
    required this.shiftRate, required this.shiftElapsed});

  String _hm(Duration d) => '${d.inHours}h ${d.inMinutes % 60}m';

  @override
  Widget build(BuildContext context) {
    final pct = target == 0 ? 0.0 : todayTotal / target;
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('TODAY  ', style: AppTypography.statLabel),
          Text('$todayTotal / $target', style: AppTypography.bigCount),
        ]),
        const SizedBox(height: 8),
        GradientProgressBar(value: pct),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Row(children: [
            Text('Shift rate ', style: AppTypography.statLabel),
            Text('${shiftRate.round()}/hr', style: AppTypography.statValue),
          ])),
          Text('Shift ${_hm(shiftElapsed)}', style: AppTypography.statLabel),
        ]),
      ]));
  }
}
