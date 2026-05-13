import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'migrations.dart';

class AppDatabase {
  const AppDatabase._();

  static Database? _instance;
  static Future<Database>? _opening;

  static Future<Database> open() async {
    if (_instance != null) return _instance!;
    _opening ??= _doOpen();
    _instance = await _opening!;
    return _instance!;
  }

  static Future<Database> _doOpen() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'pick_tracker.db');
    return openDatabase(
      path,
      version: Migrations.latestVersion,
      onConfigure: Migrations.onConfigure,
      onCreate: Migrations.onCreate,
      onUpgrade: Migrations.onUpgrade,
    );
  }

  static Future<Database> openForTest() async {
    return openDatabase(
      inMemoryDatabasePath,
      version: Migrations.latestVersion,
      onConfigure: Migrations.onConfigure,
      onCreate: Migrations.onCreate,
      onUpgrade: Migrations.onUpgrade,
      singleInstance: false,
    );
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
    _opening = null;
  }
}
