import 'package:sqflite/sqflite.dart';
import '../models/shift.dart';

class ShiftRepository {
  final Database db;
  ShiftRepository(this.db);

  Future<int> insert(Shift s) => db.insert('shifts', s.toMap());

  Future<Shift?> getActive() async {
    final rows = await db.query('shifts',
      where: 'ended_at IS NULL', orderBy: 'started_at DESC', limit: 1);
    if (rows.isEmpty) return null;
    return Shift.fromMap(rows.first);
  }

  Future<void> close(int id, DateTime at, String reason) async {
    await db.update('shifts',
      {'ended_at': at.toIso8601String(), 'ended_reason': reason},
      where: 'id = ?', whereArgs: [id]);
  }

  Future<void> reopen(int id) async {
    await db.update('shifts', {'ended_at': null, 'ended_reason': null},
      where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTarget(int id, int target) async {
    await db.update('shifts', {'target': target},
      where: 'id = ?', whereArgs: [id]);
  }

  Future<Shift?> getById(int id) async {
    final rows = await db.query('shifts', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Shift.fromMap(rows.first);
  }

  Future<List<Shift>> findByDate(String date) async {
    final rows = await db.query('shifts',
      where: 'date = ?', whereArgs: [date], orderBy: 'started_at ASC');
    return rows.map(Shift.fromMap).toList();
  }

  Future<List<Shift>> findInRange(String fromDate, String toDate) async {
    final rows = await db.query('shifts',
      where: 'date BETWEEN ? AND ?', whereArgs: [fromDate, toDate],
      orderBy: 'date ASC, started_at ASC');
    return rows.map(Shift.fromMap).toList();
  }
}
