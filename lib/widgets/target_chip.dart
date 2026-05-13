import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TargetChip extends StatelessWidget {
  final int target;
  final VoidCallback onTap;
  const TargetChip({super.key, required this.target, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(24),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBg, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withOpacity(0.4))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎯 ', style: TextStyle(fontSize: 14)),
        Text('$target', style: AppTypography.statValue.copyWith(
          color: AppColors.accent)),
      ])),
  );
}
