import 'package:flutter/material.dart';

class PickTrackerApp extends StatelessWidget {
  const PickTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pick Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: const Scaffold(body: Center(child: Text('pick_tracker'))),
    );
  }
}
