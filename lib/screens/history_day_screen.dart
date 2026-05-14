import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/shift.dart';
import '../repositories/order_repository.dart';
import '../repositories/shift_repository.dart';
import '../services/calculations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/sparkline.dart';
import 'edit_order_screen.dart';

class HistoryDayScreen extends StatefulWidget {
  final ShiftRepository shifts;
  final OrderRepository orders;
  final String date;
  const HistoryDayScreen({super.key,
    required this.shifts, required this.orders, required this.date});

  @override
  State<HistoryDayScreen> createState() => _HistoryDayScreenState();
}

class _HistoryDayScreenState extends State<HistoryDayScreen> {
  List<Shift> _shifts = const [];
  final Map<int, List<Order>> _ordersByShift = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await widget.shifts.findByDate(widget.date);
    _ordersByShift.clear();
    for (final sh in s) {
      _ordersByShift[sh.id!] = await widget.orders.findByShift(sh.id!);
    }
    if (mounted) setState(() => _shifts = s);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE d MMM');
    return Scaffold(
      appBar: AppBar(title: Text(fmt.format(DateTime.parse(widget.date)))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _shifts.length,
        itemBuilder: (_, i) {
          final s = _shifts[i];
          final os = _ordersByShift[s.id!] ?? const [];
          final total = os.fold<int>(0, (a, o) => a + o.cases);
          final endedAt = s.endedAt ?? DateTime.now().toUtc();
          final hours = endedAt.difference(s.startedAt).inMinutes / 60;
          final rate = hours == 0 ? 0.0 : total / hours;
          final hit = total >= s.target;
          final rates = os
              .where((o) => o.durationMs != null && o.durationMs! > 0)
              .map(Calculations.orderRate)
              .toList();
          return Card(
            color: AppColors.cardBg,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(
                      '$total cases · ${hours.toStringAsFixed(1)}h · ${rate.round()}/hr',
                      style: AppTypography.statValue)),
                    Text(hit ? '✓ TARGET HIT' : '✗ ${s.target - total} short',
                      style: AppTypography.statLabel.copyWith(
                        color: hit ? AppColors.success : AppColors.warning)),
                  ]),
                  const SizedBox(height: 8),
                  Sparkline(values: rates),
                  const SizedBox(height: 8),
                  ...os.map((o) => ListTile(
                    dense: true,
                    title: Text('Order ${o.seq} · ${o.cases} cases'),
                    subtitle: Text(o.durationMs == null
                      ? 'active'
                      : '${(o.durationMs! / 60000).round()} min · '
                        '${Calculations.orderRate(o).round()}/hr'
                        '${o.isOutlier ? "  ⚠" : ""}'),
                    trailing: const Icon(Icons.edit, size: 16),
                    onTap: () async {
                      final ok = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => EditOrderScreen(
                          order: o, repo: widget.orders)));
                      if (ok == true) _load();
                    })),
                ])));
        }));
  }
}
