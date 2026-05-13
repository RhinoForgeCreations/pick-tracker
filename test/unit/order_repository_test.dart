import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pick_tracker/db/database.dart';
import 'package:pick_tracker/models/order.dart';
import 'package:pick_tracker/models/shift.dart';
import 'package:pick_tracker/repositories/order_repository.dart';
import 'package:pick_tracker/repositories/shift_repository.dart';

void main() {
  setUpAll(() { sqfliteFfiInit(); databaseFactory = databaseFactoryFfi; });

  test('insert + getActive + close', () async {
    final db = await AppDatabase.openForTest();
    final shifts = ShiftRepository(db);
    final orders = OrderRepository(db);
    final now = DateTime.utc(2026, 5, 13, 19, 0);
    final shiftId = await shifts.insert(Shift(
      startedAt: now, date: '2026-05-13', target: 1000, floor: 900));
    final oid = await orders.insert(Order(
      shiftId: shiftId, seq: 1, cases: 42, startedAt: now,
      isOutlier: false, edited: false));
    expect(await orders.getActiveForShift(shiftId), isNotNull);
    await orders.close(oid, now.add(const Duration(minutes: 18)),
      18*60*1000, false);
    expect(await orders.getActiveForShift(shiftId), isNull);
  });
}
