import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pick_tracker/db/database.dart';
import 'package:pick_tracker/models/shift.dart';
import 'package:pick_tracker/repositories/shift_repository.dart';

void main() {
  setUpAll(() { sqfliteFfiInit(); databaseFactory = databaseFactoryFfi; });

  test('insert + getActive + close', () async {
    final db = await AppDatabase.openForTest();
    final repo = ShiftRepository(db);
    final now = DateTime.utc(2026, 5, 13, 19, 0);
    final id = await repo.insert(Shift(
      startedAt: now, date: '2026-05-13', target: 1000, floor: 900));
    expect(id, isPositive);
    final active = await repo.getActive();
    expect(active!.id, id);
    await repo.close(id, now.add(const Duration(hours: 7)), 'user');
    expect(await repo.getActive(), isNull);
  });
}
