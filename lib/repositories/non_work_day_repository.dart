import 'package:sqflite/sqflite.dart';
import '../models/non_work_day.dart';

class NonWorkDayRepository {
  final Database db;
  NonWorkDayRepository(this.db);

  Future<void> upsert(NonWorkDay d) async {
    await db.insert('non_work_days', d.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteDate(String date) async {
    await db.delete('non_work_days', where: 'date = ?', whereArgs: [date]);
  }

  Future<bool> isNonWorkDay(String date) async {
    final r = await db.query('non_work_days',
      where: 'date = ?', whereArgs: [date], limit: 1);
    return r.isNotEmpty;
  }

  Future<List<NonWorkDay>> findInRange(String fromDate, String toDate) async {
    final r = await db.query('non_work_days',
      where: 'date BETWEEN ? AND ?', whereArgs: [fromDate, toDate],
      orderBy: 'date ASC');
    return r.map(NonWorkDay.fromMap).toList();
  }
}
