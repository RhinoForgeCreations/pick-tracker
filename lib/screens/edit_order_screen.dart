import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';
import '../services/outlier_detector.dart';

class EditOrderScreen extends StatefulWidget {
  final Order order;
  final OrderRepository repo;
  const EditOrderScreen({super.key, required this.order, required this.repo});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  late final TextEditingController _cases;
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    _cases = TextEditingController(text: '${widget.order.cases}');
    _start = widget.order.startedAt.toLocal();
    _end = (widget.order.endedAt ?? widget.order.startedAt).toLocal();
  }

  @override
  void dispose() {
    _cases.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: initial);
    if (d == null || !mounted) return null;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial));
    if (t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  Future<void> _save() async {
    final n = int.tryParse(_cases.text) ?? 0;
    if (n <= 0) return;
    final dur = _end.difference(_start).inMilliseconds;
    final probe = Order(
      id: widget.order.id,
      shiftId: widget.order.shiftId,
      seq: widget.order.seq,
      cases: n,
      startedAt: _start.toUtc(),
      endedAt: _end.toUtc(),
      durationMs: dur,
      isOutlier: false,
      edited: true);
    final outlier = OutlierDetector.isOutlier(probe);
    final updated = Order(
      id: widget.order.id,
      shiftId: widget.order.shiftId,
      seq: widget.order.seq,
      cases: n,
      startedAt: _start.toUtc(),
      endedAt: _end.toUtc(),
      durationMs: dur,
      isOutlier: outlier,
      edited: true);
    await widget.repo.update(updated);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Edit order')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _cases,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cases')),
          ListTile(
            title: const Text('Started'),
            subtitle: Text(fmt.format(_start)),
            onTap: () async {
              final v = await _pickDateTime(_start);
              if (v != null && mounted) setState(() => _start = v);
            }),
          ListTile(
            title: const Text('Ended'),
            subtitle: Text(fmt.format(_end)),
            onTap: () async {
              final v = await _pickDateTime(_end);
              if (v != null && mounted) setState(() => _end = v);
            }),
          const Spacer(),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ])));
  }
}
