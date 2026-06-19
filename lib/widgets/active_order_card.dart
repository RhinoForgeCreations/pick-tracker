import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_motion.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ActiveOrderCard extends StatefulWidget {
  final int? cases;
  final DateTime? startedAt;
  final bool active;
  const ActiveOrderCard({super.key, this.cases, this.startedAt, required this.active});

  @override
  State<ActiveOrderCard> createState() => _ActiveOrderCardState();
}

class _ActiveOrderCardState extends State<ActiveOrderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: AppMotion.pulse)..repeat(reverse: true);

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  String _elapsed() {
    if (widget.startedAt == null) return '—';
    final d = DateTime.now().difference(widget.startedAt!.toLocal());
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return Container(padding: const EdgeInsets.all(16),
        child: Text('No active order — tap a number to start',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary)));
    }
    assert(widget.cases != null && widget.startedAt != null,
      'ActiveOrderCard: active=true requires cases and startedAt');
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.4))),
      child: Row(children: [
        FadeTransition(opacity: _pulse, child: Container(width: 10, height: 10,
          decoration: const BoxDecoration(
            color: AppColors.accent, shape: BoxShape.circle))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Picking ${widget.cases} cases', style: AppTypography.statValue),
            Text('Started ${TimeOfDay.fromDateTime(widget.startedAt!.toLocal()).format(context)} · ${_elapsed()}',
              style: AppTypography.statLabel),
          ])),
      ]),
    ).animate(key: ValueKey(widget.startedAt)).fadeIn(duration: 250.ms).slideX(begin: 0.05, curve: Curves.easeOut);
  }
}
