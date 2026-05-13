import 'package:sqflite/sqflite.dart';
import '../models/order.dart';

class OrderRepository {
  final Database db;
  OrderRepository(this.db);

  Future<int> insert(Order o) => db.insert('orders', o.toMap());

  Future<Order?> getActiveForShift(int shiftId) async {
    final rows = await db.query('orders',
      where: 'shift_id = ? AND ended_at IS NULL',
      whereArgs: [shiftId], orderBy: 'started_at DESC', limit: 1);
    if (rows.isEmpty) return null;
    return Order.fromMap(rows.first);
  }

  Future<List<Order>> findByShift(int shiftId) async {
    final rows = await db.query('orders',
      where: 'shift_id = ?', whereArgs: [shiftId], orderBy: 'seq ASC');
    return rows.map(Order.fromMap).toList();
  }

  Future<List<Order>> findAllOpen() async {
    final rows = await db.query('orders',
      where: 'ended_at IS NULL', orderBy: 'started_at DESC');
    return rows.map(Order.fromMap).toList();
  }

  Future<void> close(int id, DateTime endedAt, int durationMs, bool isOutlier) async {
    await db.update('orders', {
      'ended_at': endedAt.toIso8601String(),
      'duration_ms': durationMs,
      'is_outlier': isOutlier ? 1 : 0,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(Order o) async {
    await db.update('orders', o.toMap()..['edited'] = 1,
      where: 'id = ?', whereArgs: [o.id]);
  }

  Future<void> delete(int id) async {
    await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> nextSeqForShift(int shiftId) async {
    final r = await db.rawQuery(
      'SELECT COALESCE(MAX(seq),0)+1 AS next FROM orders WHERE shift_id=?',
      [shiftId]);
    return r.first['next'] as int;
  }
}
