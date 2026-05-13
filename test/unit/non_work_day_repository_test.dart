import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pick_tracker/db/database.dart';
import 'package:pick_tracker/models/non_work_day.dart';
import 'package:pick_tracker/repositories/non_work_day_repository.dart';

void main() {
  setUpAll(() { sqfliteFfiInit(); databaseFactory = databaseFactoryFfi; });

  test('upsert + isNonWorkDay', () async {
    final db = await AppDatabase.openForTest();
    final repo = NonWorkDayRepository(db);
    await repo.upsert(const NonWorkDay(
      date: '2026-04-25', reason: 'public_holiday', note: 'ANZAC Day'));
    expect(await repo.isNonWorkDay('2026-04-25'), isTrue);
    expect(await repo.isNonWorkDay('2026-05-13'), isFalse);
  });
}
