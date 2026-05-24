import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pick_tracker/db/database.dart';
import 'package:pick_tracker/repositories/break_repository.dart';
import 'package:pick_tracker/repositories/shift_repository.dart';
import 'package:pick_tracker/repositories/order_repository.dart';
import 'package:pick_tracker/repositories/settings_repository.dart';
import 'package:pick_tracker/services/shift_lifecycle.dart';

void main() {
  setUpAll(() { sqfliteFfiInit(); databaseFactory = databaseFactoryFfi; });

  ShiftLifecycle make(db) => ShiftLifecycle(
    shifts: ShiftRepository(db),
    orders: OrderRepository(db),
    settings: SettingsRepository(db),
    breaks: BreakRepository(db));

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

  test('undoLastOrder reopens prior order without marking edited', () async {
    final db = await AppDatabase.openForTest();
    final svc = make(db);
    final orderRepo = OrderRepository(db);
    final t0 = DateTime.utc(2026, 5, 13, 19, 0);
    await svc.submitNext(cases: 42, at: t0);
    await svc.submitNext(cases: 50, at: t0.add(const Duration(minutes: 18)));
    // Both orders now exist; order 2 is active, order 1 is closed.
    await svc.undoLastOrder();
    // Order 2 should be gone, order 1 should be active again.
    final shift = await ShiftRepository(db).getActive();
    final remaining = await orderRepo.findByShift(shift!.id!);
    expect(remaining, hasLength(1));
    expect(remaining.first.cases, 42);
    expect(remaining.first.endedAt, isNull);
    expect(remaining.first.durationMs, isNull);
    expect(remaining.first.edited, isFalse,
      reason: 'system-driven reopen must not mark edited=1');
  });

  test('undoLastOrder collapses single-order shift with auto_recovery', () async {
    final db = await AppDatabase.openForTest();
    final svc = make(db);
    final t0 = DateTime.utc(2026, 5, 13, 19, 0);
    await svc.submitNext(cases: 42, at: t0);
    await svc.undoLastOrder();
    expect(await ShiftRepository(db).getActive(), isNull,
      reason: 'shift should be closed with auto_recovery reason');
  });

  test('startBreak no-op when no active shift', () async {
    final db = await AppDatabase.openForTest();
    final svc = make(db);
    final id = await svc.startBreak(at: DateTime.utc(2026, 5, 20, 5, 0));
    expect(id, isNull);
  });

  test('startBreak auto-ends active order', () async {
    final db = await AppDatabase.openForTest();
    final svc = make(db);
    final orderRepo = OrderRepository(db);
    final breakRepo = BreakRepository(db);
    final t0 = DateTime.utc(2026, 5, 20, 5, 0);
    await svc.submitNext(cases: 42, at: t0);
    final breakStart = t0.add(const Duration(minutes: 10));
    final id = await svc.startBreak(at: breakStart);
    expect(id, isNotNull);

    final shift = await ShiftRepository(db).getActive();
    final os = await orderRepo.findByShift(shift!.id!);
    expect(os, hasLength(1));
    expect(os.first.endedAt, breakStart,
      reason: 'active order should be closed at break start');
    expect(os.first.durationMs, 10 * 60 * 1000);

    final openBreak = await breakRepo.getActiveForShift(shift.id!);
    expect(openBreak, isNotNull);
    expect(openBreak!.startedAt, breakStart);
    expect(openBreak.endedAt, isNull);
  });

  test('startBreak no-op when break already open', () async {
    final db = await AppDatabase.openForTest();
    final svc = make(db);
    final t0 = DateTime.utc(2026, 5, 20, 5, 0);
    await svc.submitNext(cases: 42, at: t0);
    final first = await svc.startBreak(at: t0.add(const Duration(minutes: 10)));
    final second = await svc.startBreak(at: t0.add(const Duration(minutes: 15)));
    expect(first, isNotNull);
    expect(second, isNull);
  });

  test('endBreak closes the open break', () async {
    final db = await AppDatabase.openForTest();
    final svc = make(db);
    final breakRepo = BreakRepository(db);
    final t0 = DateTime.utc(2026, 5, 20, 5, 0);
    await svc.submitNext(cases: 42, at: t0);
    await svc.startBreak(at: t0.add(const Duration(minutes: 10)));
    final breakEnd = t0.add(const Duration(minutes: 40));
    await svc.endBreak(at: breakEnd);
    final shift = await ShiftRepository(db).getActive();
    final open = await breakRepo.getActiveForShift(shift!.id!);
    expect(open, isNull);
    final all = await breakRepo.findByShift(shift.id!);
    expect(all, hasLength(1));
    expect(all.first.endedAt, breakEnd);
  });

  test('submitNext auto-closes an open break', () async {
    final db = await AppDatabase.openForTest();
    final svc = make(db);
    final breakRepo = BreakRepository(db);
    final t0 = DateTime.utc(2026, 5, 20, 5, 0);
    await svc.submitNext(cases: 42, at: t0);
    await svc.startBreak(at: t0.add(const Duration(minutes: 10)));
    final resumeAt = t0.add(const Duration(minutes: 40));
    await svc.submitNext(cases: 30, at: resumeAt);
    final shift = await ShiftRepository(db).getActive();
    expect(await breakRepo.getActiveForShift(shift!.id!), isNull);
    final all = await breakRepo.findByShift(shift.id!);
    expect(all.first.endedAt, resumeAt);
  });

  test('endShift closes an open break at the shift end time', () async {
    final db = await AppDatabase.openForTest();
    final svc = make(db);
    final breakRepo = BreakRepository(db);
    final t0 = DateTime.utc(2026, 5, 20, 5, 0);
    await svc.submitNext(cases: 42, at: t0);
    await svc.startBreak(at: t0.add(const Duration(minutes: 10)));
    final endAt = t0.add(const Duration(minutes: 30));
    await svc.endShift(at: endAt);
    expect(await ShiftRepository(db).getActive(), isNull);
    // Find the (now closed) shift via meta
    final all = await db.query('breaks');
    expect(all, hasLength(1));
    final shiftId = all.first['shift_id'] as int;
    final breaks = await breakRepo.findByShift(shiftId);
    expect(breaks.first.endedAt, endAt);
  });
}
