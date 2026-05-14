import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

class Exporter {
  final Database db;
  Exporter(this.db);

  String _safeTimestamp() =>
      DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');

  Future<File> exportJson() async {
    final shifts = await db.query('shifts');
    final orders = await db.query('orders');
    final nonWork = await db.query('non_work_days');
    final settings = await db.query('settings');
    final meta = await db.query('meta');
    final payload = {
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'meta': meta,
      'settings': settings,
      'shifts': shifts,
      'orders': orders,
      'non_work_days': nonWork,
    };
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'pick_tracker_${_safeTimestamp()}.json');
    final file = File(path);
    await file.writeAsString(jsonEncode(payload));
    return file;
  }

  Future<File> exportCsv() async {
    final orders = await db.rawQuery('''
      SELECT o.*, s.date AS shift_date, s.target AS shift_target
      FROM orders o JOIN shifts s ON s.id = o.shift_id
      ORDER BY o.started_at''');
    final sb = StringBuffer();
    sb.writeln('shift_date,shift_id,seq,cases,started_at,ended_at,duration_ms,is_outlier,edited,shift_target');
    for (final o in orders) {
      sb.writeln([
        o['shift_date'], o['shift_id'], o['seq'], o['cases'],
        o['started_at'], o['ended_at'] ?? '', o['duration_ms'] ?? '',
        o['is_outlier'], o['edited'], o['shift_target'],
      ].join(','));
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'pick_tracker_${_safeTimestamp()}.csv');
    final file = File(path);
    await file.writeAsString(sb.toString());
    return file;
  }

  Future<void> shareFile(File f) async {
    await Share.shareXFiles([XFile(f.path)]);
  }
}
