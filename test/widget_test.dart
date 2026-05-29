import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_tracker/app.dart';
import 'package:pick_tracker/screens/splash_screen.dart';

void main() {
  testWidgets('App boots into the splash screen before DB init completes',
      (t) async {
    await t.pumpWidget(const PickTrackerApp());
    // First frame: AppState.init() is in flight, the animated splash is shown
    // until both the DB is ready and the intro animation has played.
    expect(find.byType(SplashScreen), findsOneWidget);

    // Tear down so the splash's repeating tickers stop, then advance the clock
    // to drain its one-shot sequence timers (all guarded by `mounted`).
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 4));
  });
}
