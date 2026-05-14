import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_tracker/screens/end_shift_summary.dart';

void main() {
  testWidgets('renders totals and rates', (t) async {
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 3.0;
    addTearDown(() {
      t.view.resetPhysicalSize();
      t.view.resetDevicePixelRatio();
    });

    await t.pumpWidget(const MaterialApp(home: EndShiftSummary(
      totalCases: 987, target: 1000, hours: 7, minutes: 42,
      orders: 12, shiftRate: 128, activeRate: 142,
      bestCases: 84, bestRate: 156,
      slowestCases: 12, slowestRate: 24, outlierCount: 1, streak: 4)));
    await t.pumpAndSettle(const Duration(seconds: 1));
    expect(find.textContaining('987'), findsWidgets);
    expect(find.textContaining('128'), findsWidgets);
    expect(find.textContaining('142'), findsWidgets);
    expect(find.text('Done'), findsOneWidget);
  });
}
