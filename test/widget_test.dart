import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_tracker/app.dart';

void main() {
  testWidgets('App boots into loading state before DB init completes', (t) async {
    await t.pumpWidget(const PickTrackerApp());
    // First frame: AppState.init() is in flight, the splash CircularProgressIndicator
    // is the only widget rendered before the home screen takes over.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
