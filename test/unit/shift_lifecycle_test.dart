import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pick_tracker/db/database.dart';
import 'package:pick_tracker/repositories/shift_repository.dart';
import 'package:pick_tracker/repositories/order_repository.dart';
import 'package:pick_tracker/repositories/settings_repository.dart';
import 'package:pick_tracker/services/shift_lifecycle.dart';

void main() {
  setUpAll(() { sqfliteFfiInit(); databaseFactory = databaseFactoryFfi; });

  ShiftLifecycle make(db) => ShiftLifecycle(
    shifts: ShiftRepository(db),
    orders: OrderRepository(db),
    settings: SettingsRepository(db));

  test('first NEXT creates shift + order #1', () async {
    final db = await AppDatabase.openForTest();
    final svc = make(db);
    final t0 = DateTime.utc(2026, 5, 13, 19, 0);
    final r = await svc.submitNext(cases: 42, at: t0);
    expect(r.newOrder.seq, 1); expect(r.newOrder.cases, 42);
    expect(r.closedOrder, isNull);
  });

  test('subsequent NEXT closes previous, opens new', () async {
    final db = await AppDatabase.openForTest();
    final svc = make(db);
    final t0 = DateTime.utc(2026, 5, 13, 19, 0);
    await svc.submitNext(cases: 42, at: t0);
    final t1 = t0.add(const Duration(minutes: 18));
    final r2 = await svc.submitNext(cases: 50, at: t1);
    expect(r2.closedOrder!.durationMs, 18 * 60 * 1000);
    expect(r2.newOrder.seq, 2);
  });

  test('auto_close backdates to last activity', () async {
    final db = await AppDatabase.openForTest();
    final svc = make(db);
    final t0 = DateTime.utc(2026, 5, 13, 19, 0);
    await svc.submitNext(cases: 42, at: t0);
    final t1 = t0.add(const Duration(hours: 16));
    final n = await svc.autoCloseStaleShifts(now: t1, gapMinutes: 120);
    expect(n, 1);
    expect(await ShiftRepository(db).getActive(), isNull);
  });
}
