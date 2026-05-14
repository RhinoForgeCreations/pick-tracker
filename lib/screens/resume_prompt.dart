import 'package:flutter/material.dart';

class ResumePrompt extends StatelessWidget {
  final DateTime lastActivity;
  final VoidCallback onContinue;
  final VoidCallback onEnd;
  const ResumePrompt({
    super.key,
    required this.lastActivity,
    required this.onContinue,
    required this.onEnd,
  });

  String _delta() {
    final d = DateTime.now().difference(lastActivity);
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Active shift'),
    content: Text('Last order ${_delta()} ago.'),
    actions: [
      TextButton(onPressed: onEnd, child: const Text('End shift')),
      FilledButton(onPressed: onContinue, child: const Text('Continue picking')),
    ],
  );
}
