import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
    static final AppDatabase instance = AppDatabase._init();
    static Database? _database;

    AppDatabase._init();

    Future<Database> get database async {
      return _database ??= await init();
    }

    Future<Database> init({bool inMemory = false}) async {
      if (_database != null && !inMemory) {
        return _database!;
      }

      String path;
      if (inMemory) {
        path = inMemoryDatabasePath;
      } else {
        final dbPath = await getDatabasesPath();
        path = join(dbPath, 'app_database.db');
      }

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
      return _database!;
    }

  Future _createDB(Database db, int version) async {
    await db.execute(
      '''
        CREATE TABLE periods (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          start_datetime INTEGER NOT NULL,
          end_datetime INTEGER NULL, 
          latitude REAL NOT NULL,
          longitude REAL NOT NULL, 
          active INTEGER NOT NULL DEFAULT 0,
          alarm_radius REAL NOT NULL DEFAULT 0,
          note TEXT NULL,
          name TEXT NULL
        )
      '''
    );
  }
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}