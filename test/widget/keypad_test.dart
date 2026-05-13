import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_tracker/widgets/keypad.dart';

void main() {
  testWidgets('digits accumulate, NEXT submits as int', (t) async {
    String value = '';
    int submitted = -1;
    await t.pumpWidget(MaterialApp(home: Scaffold(body: StatefulBuilder(
      builder: (ctx, setState) => Keypad(
        value: value,
        onChange: (v) => setState(() => value = v),
        onSubmit: (v) => submitted = v,
        softCap: 200, hardCap: 2000,
      )))));
    await t.tap(find.text('4')); await t.pumpAndSettle();
    await t.tap(find.text('2')); await t.pumpAndSettle();
    expect(value, '42');
    await t.tap(find.text('NEXT')); await t.pumpAndSettle();
    expect(submitted, 42);
  });
}
