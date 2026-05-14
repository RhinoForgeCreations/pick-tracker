import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import 'history_day_screen.dart';
import 'history_month_screen.dart';
import 'history_week_screen.dart';

class HistoryHubScreen extends StatelessWidget {
  final AppState state;
  const HistoryHubScreen({super.key, required this.state});

  DateTime _mondayOfThisWeek() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - (now.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView(children: [
        ListTile(
          title: const Text('Today'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => HistoryDayScreen(
              shifts: state.shiftsRepo,
              orders: state.ordersRepo,
              date: today)))),
        ListTile(
          title: const Text('This week'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => HistoryWeekScreen(
              shifts: state.shiftsRepo,
              orders: state.ordersRepo,
              nonWork: state.nonWorkRepo,
              weekStart: _mondayOfThisWeek())))),
        ListTile(
          title: const Text('This month'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => HistoryMonthScreen(
              shifts: state.shiftsRepo,
              orders: state.ordersRepo,
              nonWork: state.nonWorkRepo,
              monthStart: monthStart)))),
      ]));
  }
}
