import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pick_tracker/db/database.dart';
import 'package:pick_tracker/repositories/settings_repository.dart';

void main() {
  setUpAll(() { sqfliteFfiInit(); databaseFactory = databaseFactoryFfi; });

  test('defaults + update', () async {
    final db = await AppDatabase.openForTest();
    final repo = SettingsRepository(db);
    final s = await repo.get();
    expect(s.defaultTarget, 1000);
    expect(s.currentInputBuffer, '');
    await repo.setDefaultTarget(950);
    await repo.setInputBuffer('47');
    final s2 = await repo.get();
    expect(s2.defaultTarget, 950);
    expect(s2.currentInputBuffer, '47');
  });
}
