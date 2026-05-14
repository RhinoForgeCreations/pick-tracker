import 'package:sqflite/sqflite.dart';
import 'schema.dart';

class Migrations {
  const Migrations._();

  static const int latestVersion = 1;

  static Future<void> onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    // WAL must be set outside any transaction and via rawQuery (it returns
    // the new journal mode, which db.execute() rejects on Android sqflite).
    await db.rawQuery('PRAGMA journal_mode=WAL');
  }

  static Future<void> onCreate(Database db, int version) async {
    final batch = db.batch();
    for (final stmt in Schema.v1Statements) {
      batch.execute(stmt);
    }
    batch.rawInsert(Schema.seedMeta, [DateTime.now().toUtc().toIso8601String()]);
    batch.rawInsert(Schema.seedSettings);
    await batch.commit(noResult: true);
  }

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    assert(newVersion <= latestVersion,
      'onUpgrade not implemented for v$newVersion — add migration before bumping latestVersion');
  }
}
