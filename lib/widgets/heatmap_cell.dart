import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HeatmapCell extends StatelessWidget {
  final int day;
  final double? intensity;
  final bool isHoliday;
  final VoidCallback? onTap;
  const HeatmapCell({super.key,
    required this.day, this.intensity,
    this.isHoliday = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    Color bg;
    if (intensity == null) {
      bg = AppColors.cardBg;
    } else {
      final i = intensity!.clamp(0.0, 1.2);
      bg = Color.lerp(AppColors.cardBg, AppColors.accent, i / 1.2)!;
    }
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6)),
        child: Stack(children: [
          Center(child: Text('$day',
            style: const TextStyle(color: Colors.white, fontSize: 14))),
          if (isHoliday)
            const Positioned(top: 2, right: 4,
              child: Text('★', style: TextStyle(fontSize: 10))),
        ])));
  }
}
