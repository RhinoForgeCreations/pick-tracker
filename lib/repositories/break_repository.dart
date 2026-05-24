import 'package:sqflite/sqflite.dart';
import '../models/break_period.dart';

class BreakRepository {
  final Database db;
  BreakRepository(this.db);

  Future<int> insert(BreakPeriod b) => db.insert('breaks', b.toMap());

  Future<BreakPeriod?> getActiveForShift(int shiftId) async {
    final rows = await db.query('breaks',
      where: 'shift_id = ? AND ended_at IS NULL',
      whereArgs: [shiftId],
      orderBy: 'started_at DESC',
      limit: 1);
    if (rows.isEmpty) return null;
    return BreakPeriod.fromMap(rows.first);
  }

  Future<void> close(int id, DateTime endedAt) async {
    await db.update('breaks',
      {'ended_at': endedAt.toIso8601String()},
      where: 'id = ?', whereArgs: [id]);
  }

  Future<List<BreakPeriod>> findByShift(int shiftId) async {
    final rows = await db.query('breaks',
      where: 'shift_id = ?', whereArgs: [shiftId],
      orderBy: 'started_at ASC');
    return rows.map(BreakPeriod.fromMap).toList();
  }

  /// Total break duration in ms for the shift, treating any still-open
  /// break as ending at [asOf].
  Future<int> totalDurationMs(int shiftId, {required DateTime asOf}) async {
    final all = await findByShift(shiftId);
    var total = 0;
    for (final b in all) {
      total += b.durationMs(asOf);
    }
    return total;
  }

  Future<void> delete(int id) async {
    await db.delete('breaks', where: 'id = ?', whereArgs: [id]);
  }
}
