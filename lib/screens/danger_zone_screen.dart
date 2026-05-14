import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

class DangerZoneScreen extends StatefulWidget {
  final AppState state;
  const DangerZoneScreen({super.key, required this.state});

  @override
  State<DangerZoneScreen> createState() => _DangerZoneScreenState();
}

class _DangerZoneScreenState extends State<DangerZoneScreen> {
  final _ctrl = TextEditingController();
  bool get _ok => _ctrl.text.trim() == 'DELETE';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Danger zone')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('This will permanently erase all shifts, orders, settings, and non-work days. There is no undo.'),
          const SizedBox(height: 24),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(labelText: 'Type DELETE to confirm'),
            onChanged: (_) => setState(() {})),
          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: _ok
              ? () async {
                  await widget.state.wipeAllData();
                  if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
                }
              : null,
            child: const Text('Erase everything')),
        ])));
}
