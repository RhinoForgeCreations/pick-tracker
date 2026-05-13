import 'package:sqflite/sqflite.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  final Database db;
  SettingsRepository(this.db);

  Future<AppSettings> get() async {
    final rows = await db.query('settings', where: 'id = 1');
    return AppSettings.fromMap(rows.first);
  }

  Future<void> setDefaultTarget(int v) async =>
    db.update('settings', {'default_target': v}, where: 'id = 1');

  Future<void> setDefaultFloor(int v) async =>
    db.update('settings', {'default_floor': v}, where: 'id = 1');

  Future<void> setShiftGapMinutes(int v) async =>
    db.update('settings', {'shift_gap_minutes': v}, where: 'id = 1');

  Future<void> setKeepScreenOn(bool v) async =>
    db.update('settings', {'keep_screen_on': v ? 1 : 0}, where: 'id = 1');

  Future<void> setTimeFormat(String v) async {
    assert(v == '24h' || v == '12h');
    await db.update('settings', {'time_format': v}, where: 'id = 1');
  }

  Future<void> setCaps(int soft, int hard) async =>
    db.update('settings',
      {'soft_cap_per_order': soft, 'hard_cap_per_order': hard},
      where: 'id = 1');

  Future<void> setInputBuffer(String s) async =>
    db.update('settings', {'current_input_buffer': s}, where: 'id = 1');

  Future<void> setLastExportAt(DateTime at) async =>
    db.update('settings', {'last_export_at': at.toIso8601String()}, where: 'id = 1');
}
