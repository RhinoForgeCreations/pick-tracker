import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'migrations.dart';

class AppDatabase {
  const AppDatabase._();

  static Database? _instance;

  static Future<Database> open() async {
    if (_instance != null) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'pick_tracker.db');
    _instance = await openDatabase(
      path,
      version: Migrations.latestVersion,
      onCreate: Migrations.onCreate,
      onUpgrade: Migrations.onUpgrade,
    );
    return _instance!;
  }

  static Future<Database> openForTest() async {
    return openDatabase(
      inMemoryDatabasePath,
      version: Migrations.latestVersion,
      onCreate: Migrations.onCreate,
      onUpgrade: Migrations.onUpgrade,
    );
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
