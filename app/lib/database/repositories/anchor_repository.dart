import 'package:w_anchor/database/app_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:w_anchor/models/anchoring_session.dart';

class AnchorRepository {
  final dbProvider = AppDatabase.instance;
  static const String _tableName = 'anchorings';

  Future<Database> get database async {
    return dbProvider.database;
  }

  /// CREATE: Starts a new anchoring session
  Future<int> startNewAnchoring(AnchoringSession session) async {
    final db = await database;
    
    return await db.insert(
      _tableName,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// READ (One): Get a single session by its ID
  Future<AnchoringSession?> getAnchoringById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AnchoringSession.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// READ (Active): Get the currently active session (very useful)
  Future<AnchoringSession?> getActiveAnchoring() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'active = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return AnchoringSession.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// READ (All): Get a list of all past sessions
  Future<List<AnchoringSession>> getAllAnchorings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'start_datetime DESC',
    );

    return List.generate(maps.length, (i) {
      return AnchoringSession.fromMap(maps[i]);
    });
  }

  /// UPDATE: Ends an active session
  Future<void> endAnchoring(int id, int endDatetime) async {
    final db = await database;
    await db.update(
      _tableName,
      {
        'active': 0,
        'end_datetime': endDatetime,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// DELETE: Remove a session from history
  Future<void> deleteAnchoring(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}