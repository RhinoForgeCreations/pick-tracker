import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/non_work_day_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/shift_repository.dart';
import '../theme/app_typography.dart';
import '../widgets/heatmap_cell.dart';
import 'history_day_screen.dart';

class HistoryMonthScreen extends StatefulWidget {
  final ShiftRepository shifts;
  final OrderRepository orders;
  final NonWorkDayRepository nonWork;
  final DateTime monthStart;
  const HistoryMonthScreen({super.key,
    required this.shifts, required this.orders,
    required this.nonWork, required this.monthStart});

  @override
  State<HistoryMonthScreen> createState() => _HistoryMonthScreenState();
}

class _HistoryMonthScreenState extends State<HistoryMonthScreen> {
  final Map<String, int> _totals = {};
  final Map<String, int> _targets = {};
  Set<String> _holidays = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = widget.monthStart;
    final lastDay = DateTime(m.year, m.month + 1, 0).day;
    final from = DateFormat('yyyy-MM-dd').format(m);
    final to = DateFormat('yyyy-MM-dd').format(DateTime(m.year, m.month, lastDay));
    final shifts = await widget.shifts.findInRange(from, to);
    _totals.clear();
    _targets.clear();
    for (final s in shifts) {
      final os = await widget.orders.findByShift(s.id!);
      _totals[s.date] = (_totals[s.date] ?? 0) +
          os.fold<int>(0, (a, o) => a + o.cases);
      _targets[s.date] = s.target;
    }
    final nw = await widget.nonWork.findInRange(from, to);
    _holidays = nw
        .where((d) => d.reason == 'public_holiday')
        .map((d) => d.date)
        .toSet();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.monthStart;
    final lastDay = DateTime(m.year, m.month + 1, 0).day;
    final firstWeekday = DateTime(m.year, m.month, 1).weekday;
    final cells = <Widget>[];
    for (int i = 1; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (int d = 1; d <= lastDay; d++) {
      final ymd = DateFormat('yyyy-MM-dd').format(DateTime(m.year, m.month, d));
      final total = _totals[ymd];
      final target = _targets[ymd] ?? 1000;
      cells.add(HeatmapCell(
        day: d,
        intensity: total == null ? null : total / target,
        isHoliday: _holidays.contains(ymd),
        onTap: total == null
          ? null
          : () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => HistoryDayScreen(
                shifts: widget.shifts,
                orders: widget.orders,
                date: ymd)))));
    }
    final monthTotal = _totals.values.fold<int>(0, (a, b) => a + b);
    return Scaffold(
      appBar: AppBar(title: Text(DateFormat('MMMM yyyy').format(m))),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MONTH TOTAL', style: AppTypography.statLabel),
              Text('$monthTotal cases', style: AppTypography.bigCount),
            ])),
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.count(crossAxisCount: 7, children: cells))),
      ]));
  }
}
