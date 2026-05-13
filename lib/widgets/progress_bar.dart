import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

class GradientProgressBar extends StatelessWidget {
  final double value;
  const GradientProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: clamped),
      duration: AppMotion.medium, curve: AppMotion.enter,
      builder: (_, v, __) => Stack(children: [
        Container(height: 8, decoration: BoxDecoration(
          color: AppColors.cardBg, borderRadius: BorderRadius.circular(4))),
        FractionallySizedBox(widthFactor: v,
          child: Container(height: 8, decoration: BoxDecoration(
            gradient: AppColors.progressGradient,
            borderRadius: BorderRadius.circular(4)))),
      ]),
    );
  }
}
