import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _log = '';

  @override
  void initState() {
    super.initState();
    _loadLog();
  }

  Future<void> _loadLog() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final f = File('${dir.path}/error_log.txt');
      _log = await f.exists() ? await f.readAsString() : '(no errors logged)';
    } catch (_) {
      _log = '(unable to read log)';
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('About')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Pick Tracker',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      const Text('Version 1.0.0'),
      const SizedBox(height: 24),
      const Text('PRIVACY',
        style: TextStyle(letterSpacing: 1, fontSize: 12)),
      const SizedBox(height: 8),
      const Text('This app makes zero network calls. No telemetry, no analytics, no remote storage. All data is stored locally on this device only.'),
      const SizedBox(height: 24),
      const Text('ERROR LOG',
        style: TextStyle(letterSpacing: 1, fontSize: 12)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        color: Colors.black54,
        child: Text(_log,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
    ]));
}
