import 'package:flutter/material.dart';
import '../services/exporter.dart';
import '../state/app_state.dart';
import 'about_screen.dart';
import 'danger_zone_screen.dart';
import 'non_work_days_screen.dart';

class SettingsScreen extends StatefulWidget {
  final AppState state;
  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<int?> _askInt(String label, int current) async {
    final ctrl = TextEditingController(text: '$current');
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text)),
            child: const Text('OK')),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state.settings!;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        ListTile(
          title: const Text('Default target'),
          subtitle: Text('${s.defaultTarget}'),
          onTap: () async {
            final v = await _askInt('Default target', s.defaultTarget);
            if (v != null) {
              await widget.state.setDefaultTarget(v);
              if (mounted) setState(() {});
            }
          }),
        ListTile(
          title: const Text('Default floor'),
          subtitle: Text('${s.defaultFloor}'),
          onTap: () async {
            final v = await _askInt('Default floor', s.defaultFloor);
            if (v != null) {
              await widget.state.setDefaultFloor(v);
              if (mounted) setState(() {});
            }
          }),
        ListTile(
          title: const Text('Shift gap (minutes)'),
          subtitle: Text('${s.shiftGapMinutes}'),
          onTap: () async {
            final v = await _askInt('Shift gap min', s.shiftGapMinutes);
            if (v != null) {
              await widget.state.setShiftGapMinutes(v);
              if (mounted) setState(() {});
            }
          }),
        SwitchListTile(
          value: s.keepScreenOn,
          title: const Text('Keep screen on during active shift'),
          onChanged: (v) async {
            await widget.state.setKeepScreenOn(v);
            if (mounted) setState(() {});
          }),
        ListTile(
          title: const Text('Time format'),
          subtitle: Text(s.timeFormat),
          onTap: () async {
            final v = await showDialog<String>(
              context: context,
              builder: (_) => SimpleDialog(children: [
                SimpleDialogOption(
                  child: const Text('24h'),
                  onPressed: () => Navigator.pop(context, '24h')),
                SimpleDialogOption(
                  child: const Text('12h'),
                  onPressed: () => Navigator.pop(context, '12h')),
              ]));
            if (v != null) {
              await widget.state.setTimeFormat(v);
              if (mounted) setState(() {});
            }
          }),
        ListTile(
          title: const Text('Soft cap / hard cap'),
          subtitle: Text('${s.softCapPerOrder} / ${s.hardCapPerOrder}'),
          onTap: () async {
            final soft = await _askInt('Soft cap', s.softCapPerOrder);
            if (soft == null) return;
            if (!mounted) return;
            final hard = await _askInt('Hard cap', s.hardCapPerOrder);
            if (hard == null) return;
            await widget.state.setCaps(soft, hard);
            if (mounted) setState(() {});
          }),
        const Divider(),
        ListTile(
          title: const Text('Export JSON'),
          trailing: const Icon(Icons.upload_file),
          onTap: () async {
            final ex = Exporter(widget.state.rawDb);
            final f = await ex.exportJson();
            await ex.shareFile(f);
          }),
        ListTile(
          title: const Text('Export CSV'),
          trailing: const Icon(Icons.table_chart),
          onTap: () async {
            final ex = Exporter(widget.state.rawDb);
            final f = await ex.exportCsv();
            await ex.shareFile(f);
          }),
        ListTile(
          title: const Text('Non-work days'),
          trailing: const Icon(Icons.event_busy),
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => NonWorkDaysScreen(repo: widget.state.nonWorkRepo)))),
        ListTile(
          title: const Text('About'),
          trailing: const Icon(Icons.info_outline),
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => const AboutScreen()))),
        const Divider(),
        ListTile(
          title: const Text('Delete all data',
            style: TextStyle(color: Colors.redAccent)),
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => DangerZoneScreen(state: widget.state)))),
      ]));
  }
}
