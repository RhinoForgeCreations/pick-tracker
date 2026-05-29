import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../db/database.dart';
import '../models/app_settings.dart';
import '../models/break_period.dart';
import '../models/order.dart';
import '../models/shift.dart';
import '../repositories/break_repository.dart';
import '../repositories/non_work_day_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/shift_repository.dart';
import '../services/calculations.dart';
import '../services/shift_lifecycle.dart';

class AppState extends ChangeNotifier {
  Database? _db;
  late ShiftRepository _shifts;
  late OrderRepository _orders;
  late SettingsRepository _settingsRepo;
  late NonWorkDayRepository _nonWork;
  late BreakRepository _breaks;
  late ShiftLifecycle _lifecycle;
  bool _injected = false;

  AppSettings? settings;
  Shift? activeShift;
  Order? activeOrder;
  BreakPeriod? activeBreak;
  int closedBreakMs = 0;
  int todayTotal = 0;

  AppState();
  AppState.forTest(Database db) { _db = db; _injected = true; }

  ShiftRepository get shiftsRepo => _shifts;
  OrderRepository get ordersRepo => _orders;
  NonWorkDayRepository get nonWorkRepo => _nonWork;
  BreakRepository get breaksRepo => _breaks;
  Database get rawDb => _db!;

  Future<void> init() async {
    if (!_injected) _db = await AppDatabase.open();
    _shifts = ShiftRepository(_db!);
    _orders = OrderRepository(_db!);
    _settingsRepo = SettingsRepository(_db!);
    _nonWork = NonWorkDayRepository(_db!);
    _breaks = BreakRepository(_db!);
    _lifecycle = ShiftLifecycle(
      shifts: _shifts, orders: _orders, settings: _settingsRepo, breaks: _breaks);
    await _refresh();
  }

  Future<void> _refresh() async {
    // Always reload settings so currentInputBuffer (cleared by lifecycle) stays in sync.
    settings = await _settingsRepo.get();
    activeShift = await _shifts.getActive();
    activeOrder = activeShift == null
      ? null
      : await _orders.getActiveForShift(activeShift!.id!);
    if (activeShift == null) {
      activeBreak = null;
      closedBreakMs = 0;
    } else {
      activeBreak = await _breaks.getActiveForShift(activeShift!.id!);
      final all = await _breaks.findByShift(activeShift!.id!);
      var sum = 0;
      for (final b in all) {
        if (b.endedAt != null) sum += b.endedAt!.difference(b.startedAt).inMilliseconds;
      }
      closedBreakMs = sum;
    }
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal());
    final dayShifts = await _shifts.findByDate(today);
    int total = 0;
    for (final s in dayShifts) {
      final os = await _orders.findByShift(s.id!);
      for (final o in os) {
        if (o.endedAt != null) total += o.cases;
      }
    }
    todayTotal = total;
    notifyListeners();
  }

  /// Total break ms for the active shift right now, including the in-progress
  /// break (if any) measured against [now].
  int currentBreakMs(DateTime now) {
    var ms = closedBreakMs;
    if (activeBreak != null) {
      ms += now.toUtc().difference(activeBreak!.startedAt).inMilliseconds;
    }
    return ms;
  }

  bool get onBreak => activeBreak != null;

  @override
  void dispose() {
    if (!_injected) _db?.close();
    super.dispose();
  }

  int? get activeOrderCases => activeOrder?.cases;
  int get target => activeShift?.target ?? settings?.defaultTarget ?? 1000;
  int get floor => activeShift?.floor ?? settings?.defaultFloor ?? 900;
  double get percentOfTarget => Calculations.percentOfTarget(todayTotal, target);

  Future<void> submitNext(int cases) =>
    submitNextAt(cases, DateTime.now().toUtc());

  Future<void> submitNextAt(int cases, DateTime at) async {
    await _lifecycle.submitNext(cases: cases, at: at);
    await _refresh();
  }

  Future<void> endShift() async {
    await _lifecycle.endShift(at: DateTime.now().toUtc());
    await _refresh();
  }

  Future<void> startBreak() async {
    await _lifecycle.startBreak(at: DateTime.now().toUtc());
    await _refresh();
  }

  Future<void> endBreak() async {
    await _lifecycle.endBreak(at: DateTime.now().toUtc());
    await _refresh();
  }

  Future<void> undoLastOrder() async {
    await _lifecycle.undoLastOrder();
    await _refresh();
  }

  Future<int> autoCloseStaleShifts() async {
    final gap = settings?.shiftGapMinutes ?? 120;
    final n = await _lifecycle.autoCloseStaleShifts(
      now: DateTime.now().toUtc(), gapMinutes: gap);
    if (n > 0) await _refresh();
    return n;
  }

  Future<void> setInputBuffer(String s) => _settingsRepo.setInputBuffer(s);
  Future<String> readInputBuffer() async =>
    (await _settingsRepo.get()).currentInputBuffer;

  Future<void> updateActiveShiftTarget(int target) async {
    if (activeShift?.id != null) {
      await _shifts.updateTarget(activeShift!.id!, target);
      await _refresh();
    }
  }

  Future<void> reopenShift(int id) async {
    await _shifts.reopen(id);
    await _refresh();
  }

  Future<void> setDefaultTarget(int t) async {
    await _settingsRepo.setDefaultTarget(t);
    settings = await _settingsRepo.get();
    notifyListeners();
  }
  Future<void> setDefaultFloor(int v) async {
    await _settingsRepo.setDefaultFloor(v);
    settings = await _settingsRepo.get();
    notifyListeners();
  }
  Future<void> setShiftGapMinutes(int v) async {
    await _settingsRepo.setShiftGapMinutes(v);
    settings = await _settingsRepo.get();
    notifyListeners();
  }
  Future<void> setKeepScreenOn(bool v) async {
    await _settingsRepo.setKeepScreenOn(v);
    settings = await _settingsRepo.get();
    notifyListeners();
  }
  Future<void> setTimeFormat(String v) async {
    await _settingsRepo.setTimeFormat(v);
    settings = await _settingsRepo.get();
    notifyListeners();
  }
  Future<void> setCaps(int soft, int hard) async {
    await _settingsRepo.setCaps(soft, hard);
    settings = await _settingsRepo.get();
    notifyListeners();
  }

  Future<void> wipeAllData() async {
    final db = _db!;
    await db.delete('breaks');
    await db.delete('orders');
    await db.delete('shifts');
    await db.delete('non_work_days');
    await db.delete('settings');
    await db.insert('settings', {'id': 1});
    settings = await _settingsRepo.get();
    await _refresh();
  }
}

class ShiftSummary {
  final int totalCases, target, hours, minutes, orders, outlierCount, streak;
  final double shiftRate, activeRate;
  final int? bestCases, slowestCases, allTimeBest;
  final double? bestRate, slowestRate;
  final String? allTimeBestDate;
  ShiftSummary({
    required this.totalCases,
    required this.target,
    required this.hours,
    required this.minutes,
    required this.orders,
    required this.shiftRate,
    required this.activeRate,
    required this.outlierCount,
    required this.streak,
    this.bestCases,
    this.bestRate,
    this.slowestCases,
    this.slowestRate,
    this.allTimeBest,
    this.allTimeBestDate,
  });
}

extension SummarizeExt on AppState {
  Future<ShiftSummary?> summarizeShift(int shiftId) async {
    final shift = await shiftsRepo.getById(shiftId);
    if (shift == null || shift.endedAt == null) return null;
    final os = await ordersRepo.findByShift(shiftId);
    if (os.isEmpty) return null;
    final total = os.fold<int>(0, (s, o) => s + o.cases);
    final breakMs = await breaksRepo.totalDurationMs(shiftId, asOf: shift.endedAt!);
    final workedMs =
      shift.endedAt!.difference(shift.startedAt).inMilliseconds - breakMs;
    final worked = Duration(milliseconds: workedMs.clamp(0, 1 << 62));
    final rate = Calculations.shiftRate(
      total, shift.startedAt, shift.endedAt!, breakMs: breakMs);
    final closed = os.where((o) => o.endedAt != null).toList();
    final active = closed.where((o) => !o.isOutlier).toList();
    final activeRate = Calculations.activeRate(active);
    Order? best;
    Order? slowest;
    for (final o in closed) {
      if (o.durationMs == null || o.durationMs == 0) continue;
      final r = Calculations.orderRate(o);
      if (best == null || r > Calculations.orderRate(best)) best = o;
      if (slowest == null || r < Calculations.orderRate(slowest)) slowest = o;
    }
    return ShiftSummary(
      totalCases: total,
      target: shift.target,
      hours: worked.inHours,
      minutes: worked.inMinutes % 60,
      orders: os.length,
      shiftRate: rate,
      activeRate: activeRate,
      outlierCount: closed.where((o) => o.isOutlier).length,
      streak: 0,
      bestCases: best?.cases,
      bestRate: best == null ? null : Calculations.orderRate(best),
      slowestCases: slowest?.cases,
      slowestRate: slowest == null ? null : Calculations.orderRate(slowest));
  }
}
