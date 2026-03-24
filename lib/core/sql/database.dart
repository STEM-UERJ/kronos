import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static const String _databaseName = 'study_monitor.db';
  static const int _databaseVersion = 1;
  static const String tableSessions = 'study_sessions';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Criação das tabelas
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableSessions (
        id TEXT PRIMARY KEY,
        subject TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        created_at INTEGER DEFAULT (strftime('%s', 'now') * 1000)
      )
    ''');
  }

  // --- Métodos de CRUD (Data Source) ---

  // Inserir uma nova sessão
  Future<void> insertSession(Map<String, dynamic> sessionData) async {
    final db = await database;
    await db.insert(
      tableSessions,
      sessionData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Buscar sessões que ainda não foram sincronizadas com os Gists
  Future<List<Map<String, dynamic>>> getUnsyncedSessions() async {
    final db = await database;
    return await db.query(
      tableSessions,
      where: 'is_synced = ?',
      whereArgs: [0], // 0 representa 'false' no SQLite
    );
  }

  // Marcar sessão como sincronizada após sucesso no POST/PATCH do Dio
  Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update(
      tableSessions,
      {'is_synced': 1}, // 1 representa 'true'
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
