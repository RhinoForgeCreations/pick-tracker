import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/non_work_day.dart';
import '../repositories/non_work_day_repository.dart';
import '../services/holiday_seeder.dart';

class NonWorkDaysScreen extends StatefulWidget {
  final NonWorkDayRepository repo;
  const NonWorkDaysScreen({super.key, required this.repo});

  @override
  State<NonWorkDaysScreen> createState() => _NonWorkDaysScreenState();
}

class _NonWorkDaysScreenState extends State<NonWorkDaysScreen> {
  List<NonWorkDay> _days = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _days = await widget.repo.findInRange('2026-01-01', '2030-12-31');
    if (mounted) setState(() {});
  }

  Future<void> _add() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100));
    if (d == null || !mounted) return;
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(children: [
        SimpleDialogOption(
          child: const Text('Leave'),
          onPressed: () => Navigator.pop(context, 'leave')),
        SimpleDialogOption(
          child: const Text('Sick'),
          onPressed: () => Navigator.pop(context, 'sick')),
        SimpleDialogOption(
          child: const Text('Public holiday'),
          onPressed: () => Navigator.pop(context, 'public_holiday')),
        SimpleDialogOption(
          child: const Text('Other'),
          onPressed: () => Navigator.pop(context, 'other')),
      ]));
    if (reason == null) return;
    await widget.repo.upsert(NonWorkDay(
      date: DateFormat('yyyy-MM-dd').format(d),
      reason: reason));
    await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Non-work days'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Re-seed VIC holidays',
          onPressed: () async {
            await HolidaySeeder(widget.repo).seedVic2026();
            await _load();
          }),
      ]),
    floatingActionButton: FloatingActionButton(
      onPressed: _add,
      child: const Icon(Icons.add)),
    body: ListView(children: _days.map((d) => ListTile(
      title: Text(d.date),
      subtitle: Text(d.note ?? d.reason),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          await widget.repo.deleteDate(d.date);
          await _load();
        }),
    )).toList()));
}
