import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pick_tracker/db/database.dart';
import 'package:pick_tracker/state/app_state.dart';

void main() {
  setUpAll(() { sqfliteFfiInit(); databaseFactory = databaseFactoryFfi; });

  test('submitNext updates active order', () async {
    final db = await AppDatabase.openForTest();
    final state = AppState.forTest(db);
    await state.init();
    final t0 = DateTime.utc(2026, 5, 13, 19, 0);
    await state.submitNextAt(42, t0);
    expect(state.activeOrderCases, 42);
    expect(state.todayTotal, 0);
    await state.submitNextAt(50, t0.add(const Duration(minutes: 18)));
    expect(state.todayTotal, 42);
    expect(state.activeOrderCases, 50);
  });
}
