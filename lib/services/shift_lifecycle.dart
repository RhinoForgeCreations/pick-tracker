import 'package:intl/intl.dart';
import '../models/break_period.dart';
import '../models/order.dart';
import '../models/shift.dart';
import '../repositories/break_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/shift_repository.dart';
import 'outlier_detector.dart';

class NextResult {
  final Order newOrder;
  final Order? closedOrder;
  final Shift shift;
  NextResult({required this.newOrder, required this.shift, this.closedOrder});
}

class ShiftLifecycle {
  final ShiftRepository shifts;
  final OrderRepository orders;
  final SettingsRepository settings;
  final BreakRepository breaks;
  ShiftLifecycle({
    required this.shifts,
    required this.orders,
    required this.settings,
    required this.breaks,
  });

  static String _ymd(DateTime d) =>
    DateFormat('yyyy-MM-dd').format(d.toLocal());

  Future<NextResult> submitNext({required int cases, required DateTime at}) async {
    assert(cases > 0);
    var shift = await shifts.getActive();
    Order? closed;

    if (shift == null) {
      final s = await settings.get();
      final id = await shifts.insert(Shift(
        startedAt: at, date: _ymd(at), target: s.defaultTarget, floor: s.defaultFloor));
      shift = await shifts.getById(id);
    } else {
      // Auto-end a break if one is open — entering the next order
      // implicitly resumes work.
      final openBreak = await breaks.getActiveForShift(shift.id!);
      if (openBreak != null) {
        await breaks.close(openBreak.id!, at);
      }
      final active = await orders.getActiveForShift(shift.id!);
      if (active != null) {
        final dur = at.difference(active.startedAt).inMilliseconds;
        final probe = Order(
          id: active.id, shiftId: active.shiftId, seq: active.seq,
          cases: active.cases, startedAt: active.startedAt, endedAt: at,
          durationMs: dur, isOutlier: false, edited: false);
        final outlier = OutlierDetector.isOutlier(probe);
        await orders.close(active.id!, at, dur, outlier);
        closed = Order(
          id: active.id, shiftId: active.shiftId, seq: active.seq,
          cases: active.cases, startedAt: active.startedAt, endedAt: at,
          durationMs: dur, isOutlier: outlier, edited: false);
      }
    }

    final seq = await orders.nextSeqForShift(shift!.id!);
    final newId = await orders.insert(Order(
      shiftId: shift.id!, seq: seq, cases: cases, startedAt: at,
      isOutlier: false, edited: false));
    final newOrder = Order(
      id: newId, shiftId: shift.id!, seq: seq, cases: cases,
      startedAt: at, isOutlier: false, edited: false);
    await settings.setInputBuffer('');
    return NextResult(newOrder: newOrder, shift: shift, closedOrder: closed);
  }

  Future<void> endShift({required DateTime at, String reason = 'user'}) async {
    final shift = await shifts.getActive();
    if (shift == null) return;
    final openBreak = await breaks.getActiveForShift(shift.id!);
    if (openBreak != null) {
      await breaks.close(openBreak.id!, at);
    }
    final active = await orders.getActiveForShift(shift.id!);
    if (active != null) {
      final dur = at.difference(active.startedAt).inMilliseconds;
      final probe = Order(
        id: active.id, shiftId: active.shiftId, seq: active.seq,
        cases: active.cases, startedAt: active.startedAt, endedAt: at,
        durationMs: dur, isOutlier: false, edited: false);
      await orders.close(active.id!, at, dur, OutlierDetector.isOutlier(probe));
    }
    await shifts.close(shift.id!, at, reason);
  }

  Future<int> autoCloseStaleShifts({required DateTime now, required int gapMinutes}) async {
    final shift = await shifts.getActive();
    if (shift == null) return 0;
    final active = await orders.getActiveForShift(shift.id!);
    final lastActivity = active?.startedAt ?? shift.startedAt;
    if (now.difference(lastActivity).inSeconds > gapMinutes * 60) {
      await endShift(at: lastActivity, reason: 'auto_inactivity');
      return 1;
    }
    return 0;
  }

  /// Starts a break for the active shift. Auto-closes any active order at
  /// [at]. No-op if no active shift or a break is already open.
  /// Returns the new break id, or null if no-op.
  Future<int?> startBreak({required DateTime at}) async {
    final shift = await shifts.getActive();
    if (shift == null) return null;
    final existing = await breaks.getActiveForShift(shift.id!);
    if (existing != null) return null;
    final active = await orders.getActiveForShift(shift.id!);
    if (active != null) {
      final dur = at.difference(active.startedAt).inMilliseconds;
      final probe = Order(
        id: active.id, shiftId: active.shiftId, seq: active.seq,
        cases: active.cases, startedAt: active.startedAt, endedAt: at,
        durationMs: dur, isOutlier: false, edited: false);
      await orders.close(active.id!, at, dur, OutlierDetector.isOutlier(probe));
    }
    return breaks.insert(BreakPeriod(shiftId: shift.id!, startedAt: at));
  }

  /// Ends the currently open break for the active shift. No-op if none.
  Future<void> endBreak({required DateTime at}) async {
    final shift = await shifts.getActive();
    if (shift == null) return;
    final open = await breaks.getActiveForShift(shift.id!);
    if (open == null) return;
    await breaks.close(open.id!, at);
  }

  Future<void> undoLastOrder() async {
    final shift = await shifts.getActive();
    if (shift == null) return;
    final all = await orders.findByShift(shift.id!);
    if (all.isEmpty) return;
    final last = all.last;
    await orders.delete(last.id!);
    if (all.length >= 2) {
      // System-driven reopen — does NOT mark the prior order as edited.
      final prev = all[all.length - 2];
      await orders.reopen(prev.id!);
    } else {
      await shifts.close(shift.id!, shift.startedAt, 'auto_recovery');
    }
  }
}
