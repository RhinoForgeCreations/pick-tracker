import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pick_tracker/db/database.dart';

void main() {
  setUpAll(() { sqfliteFfiInit(); databaseFactory = databaseFactoryFfi; });

  test('opens DB and initialises meta.schema_version=1', () async {
    final db = await AppDatabase.openForTest();
    final rows = await db.query('meta');
    expect(rows, hasLength(1));
    expect(rows.first['schema_version'], 1);
    await db.close();
  });
}
