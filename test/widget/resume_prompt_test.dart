import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_tracker/screens/resume_prompt.dart';

void main() {
  testWidgets('shows last activity and triggers end callback', (t) async {
    bool ended = false;
    await t.pumpWidget(MaterialApp(home: Scaffold(body: ResumePrompt(
      lastActivity: DateTime.now().subtract(const Duration(hours: 1, minutes: 23)),
      onContinue: () {},
      onEnd: () { ended = true; },
    ))));
    expect(find.textContaining('1h 23m'), findsOneWidget);
    await t.tap(find.text('End shift'));
    await t.pumpAndSettle();
    expect(ended, isTrue);
  });
}
