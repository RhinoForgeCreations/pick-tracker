import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pick_tracker/db/database.dart';
import 'package:pick_tracker/db/migrations.dart';
import 'package:pick_tracker/db/schema.dart';

void main() {
  setUpAll(() { sqfliteFfiInit(); databaseFactory = databaseFactoryFfi; });

  test('opens DB and initialises meta.schema_version=latest', () async {
    final db = await AppDatabase.openForTest();
    final rows = await db.query('meta');
    expect(rows, hasLength(1));
    expect(rows.first['schema_version'], 2);
    await db.close();
  });

  test('breaks table exists in fresh DB', () async {
    final db = await AppDatabase.openForTest();
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='breaks'");
    expect(rows, hasLength(1));
    await db.close();
  });

  test('v1→v2 upgrade preserves existing shift/order data and adds breaks', () async {
    // Use a tmp file so the DB persists across open/close cycles.
    final tmp = await Directory.systemTemp.createTemp('pick_tracker_mig_');
    final path = '${tmp.path}/pick_tracker.db';

    // 1. Open at v1 (simulates a phone running the original release).
    final v1 = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: Migrations.onConfigure,
        onCreate: (db, version) async {
          final batch = db.batch();
          for (final stmt in Schema.v1Statements) {
            batch.execute(stmt);
          }
          batch.rawInsert(
            "INSERT INTO meta (schema_version, created_at) VALUES (1, ?)",
            [DateTime.now().toUtc().toIso8601String()]);
          batch.rawInsert(Schema.seedSettings);
          await batch.commit(noResult: true);
        }));

    // 2. Seed sample data that should survive the upgrade.
    final shiftId = await v1.insert('shifts', {
      'started_at': '2026-05-15T19:00:00.000Z',
      'date': '2026-05-15',
      'target': 1000,
      'floor': 900,
    });
    await v1.insert('orders', {
      'shift_id': shiftId, 'seq': 1, 'cases': 42,
      'started_at': '2026-05-15T19:00:00.000Z',
      'ended_at': '2026-05-15T19:18:00.000Z',
      'duration_ms': 18 * 60 * 1000,
      'is_outlier': 0, 'edited': 0,
    });
    await v1.close();

    // 3. Reopen at v2 — triggers onUpgrade.
    final upgraded = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: Migrations.latestVersion,
        onConfigure: Migrations.onConfigure,
        onCreate: Migrations.onCreate,
        onUpgrade: Migrations.onUpgrade));

    final shifts = await upgraded.query('shifts');
    expect(shifts, hasLength(1));
    expect(shifts.first['target'], 1000);
    final orders = await upgraded.query('orders');
    expect(orders, hasLength(1));
    expect(orders.first['cases'], 42);
    final breaks = await upgraded.query('breaks');
    expect(breaks, isEmpty);
    final meta = await upgraded.query('meta');
    expect(meta.first['schema_version'], 2);

    await upgraded.close();
    await tmp.delete(recursive: true);
  });
}
