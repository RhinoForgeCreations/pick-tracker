import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/non_work_day_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/shift_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'history_day_screen.dart';

class HistoryWeekScreen extends StatefulWidget {
  final ShiftRepository shifts;
  final OrderRepository orders;
  final NonWorkDayRepository nonWork;
  final DateTime weekStart;
  const HistoryWeekScreen({super.key,
    required this.shifts, required this.orders,
    required this.nonWork, required this.weekStart});

  @override
  State<HistoryWeekScreen> createState() => _HistoryWeekScreenState();
}

class _HistoryWeekScreenState extends State<HistoryWeekScreen> {
  late List<DateTime> _days;
  final Map<String, int> _totals = {};
  final Map<String, int> _targets = {};
  Set<String> _nonWork = {};

  @override
  void initState() {
    super.initState();
    _days = List.generate(7, (i) => widget.weekStart.add(Duration(days: i)));
    _load();
  }

  String _ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _load() async {
    final from = _ymd(_days.first);
    final to = _ymd(_days.last);
    final shifts = await widget.shifts.findInRange(from, to);
    _totals.clear();
    _targets.clear();
    for (final s in shifts) {
      final os = await widget.orders.findByShift(s.id!);
      final tot = os.fold<int>(0, (a, o) => a + o.cases);
      _totals[s.date] = (_totals[s.date] ?? 0) + tot;
      _targets[s.date] = s.target;
    }
    final nw = await widget.nonWork.findInRange(from, to);
    _nonWork = nw.map((e) => e.date).toSet();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE');
    final weekTotal = _totals.values.fold<int>(0, (a, b) => a + b);
    final daysHit = _totals.entries
        .where((e) => e.value >= (_targets[e.key] ?? 1000))
        .length;
    return Scaffold(
      appBar: AppBar(title: const Text('Week')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WEEK TOTAL', style: AppTypography.statLabel),
              Text('$weekTotal cases', style: AppTypography.bigCount),
              const SizedBox(height: 4),
              Text('$daysHit days at target', style: AppTypography.statLabel),
            ])),
        Expanded(child: ListView.builder(
          itemCount: 7,
          itemBuilder: (_, i) {
            final d = _days[i];
            final k = _ymd(d);
            final total = _totals[k];
            final target = _targets[k];
            final isNonWork = _nonWork.contains(k);
            final hit = total != null && target != null && total >= target;
            return ListTile(
              title: Text('${fmt.format(d)} ${d.day.toString().padLeft(2, '0')}'),
              subtitle: Text(isNonWork
                ? '— off'
                : total == null
                  ? '—'
                  : '$total / ${target ?? "?"}'),
              trailing: Icon(
                isNonWork
                  ? Icons.beach_access
                  : total == null
                    ? Icons.remove
                    : hit
                      ? Icons.check
                      : Icons.close,
                color: isNonWork
                  ? AppColors.textSecondary
                  : hit
                    ? AppColors.success
                    : total == null
                      ? AppColors.textMuted
                      : AppColors.warning),
              onTap: total == null
                ? null
                : () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => HistoryDayScreen(
                      shifts: widget.shifts,
                      orders: widget.orders,
                      date: k))));
          })),
      ]));
  }
}
