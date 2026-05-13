import 'package:flutter/material.dart';
import '../theme/app_motion.dart';

class CountUpText extends StatelessWidget {
  final int value;
  final TextStyle style;
  final Duration duration;
  const CountUpText({super.key, required this.value, required this.style,
    this.duration = AppMotion.reveal});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<int>(
    tween: IntTween(begin: 0, end: value),
    duration: duration, curve: AppMotion.enter,
    builder: (_, v, __) => Text('$v', style: style));
}
