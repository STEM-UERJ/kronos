import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const String _databaseName = 'study_monitor.db';
  // Mantido fixo em producao. O schema e garantido em runtime no onOpen.
  static const int _databaseVersion = 1;

  static const String tableSessions = 'study_sessions';

  static const String colId = 'id';
  static const String colSubject = 'subject';
  static const String colStartTime = 'start_time';
  static const String colEndTime = 'end_time';
  static const String colNotes = 'notes';
  static const String colStatus = 'status';
  static const String colElapsedSeconds = 'elapsed_seconds';
  static const String colIsSynced = 'is_synced';
  static const String colSyncAttempts = 'sync_attempts';
  static const String colLastSyncError = 'last_sync_error';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colDeletedAt = 'deleted_at';

  static const String statusRunning = 'running';
  static const String statusPaused = 'paused';
  static const String statusFinished = 'finished';

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
      onOpen: _onOpen,
    );
  }

  Future<void> _onOpen(Database db) async {
    await _ensureProductionSchema(db);
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createSessionsTable(db);
    await _createSessionsIndexes(db);
  }

  Future<void> _createSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableSessions (
        $colId TEXT PRIMARY KEY,
        $colSubject TEXT NOT NULL,
        $colStartTime TEXT NOT NULL,
        $colEndTime TEXT,
        $colNotes TEXT,
        $colStatus TEXT NOT NULL DEFAULT '$statusRunning',
        $colElapsedSeconds INTEGER NOT NULL DEFAULT 0,
        $colIsSynced INTEGER NOT NULL DEFAULT 0,
        $colSyncAttempts INTEGER NOT NULL DEFAULT 0,
        $colLastSyncError TEXT,
        $colCreatedAt INTEGER NOT NULL DEFAULT (CAST(strftime('%s', 'now') AS INTEGER) * 1000),
        $colUpdatedAt INTEGER,
        $colDeletedAt INTEGER
      )
    ''');
  }

  Future<void> _createSessionsIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sessions_status ON $tableSessions($colStatus)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sessions_start_time ON $tableSessions($colStartTime DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sessions_sync ON $tableSessions($colIsSynced, $colStatus)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sessions_deleted_at ON $tableSessions($colDeletedAt)',
    );
  }

  Future<void> _ensureProductionSchema(Database db) async {
    final bool tableExists = await _tableExists(db, tableSessions);
    if (!tableExists) {
      await _createSessionsTable(db);
      await _createSessionsIndexes(db);
      return;
    }

    final Set<String> columns = await _getTableColumns(db, tableSessions);

    await _addColumnIfMissing(
      db,
      columns,
      colNotes,
      'ALTER TABLE $tableSessions ADD COLUMN $colNotes TEXT',
    );
    await _addColumnIfMissing(
      db,
      columns,
      colCreatedAt,
      'ALTER TABLE $tableSessions ADD COLUMN $colCreatedAt INTEGER',
    );
    await _addColumnIfMissing(
      db,
      columns,
      colIsSynced,
      'ALTER TABLE $tableSessions ADD COLUMN $colIsSynced INTEGER NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      db,
      columns,
      colStatus,
      "ALTER TABLE $tableSessions ADD COLUMN $colStatus TEXT NOT NULL DEFAULT '$statusRunning'",
    );
    await _addColumnIfMissing(
      db,
      columns,
      colElapsedSeconds,
      'ALTER TABLE $tableSessions ADD COLUMN $colElapsedSeconds INTEGER NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      db,
      columns,
      colSyncAttempts,
      'ALTER TABLE $tableSessions ADD COLUMN $colSyncAttempts INTEGER NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      db,
      columns,
      colLastSyncError,
      'ALTER TABLE $tableSessions ADD COLUMN $colLastSyncError TEXT',
    );
    await _addColumnIfMissing(
      db,
      columns,
      colUpdatedAt,
      'ALTER TABLE $tableSessions ADD COLUMN $colUpdatedAt INTEGER',
    );
    await _addColumnIfMissing(
      db,
      columns,
      colDeletedAt,
      'ALTER TABLE $tableSessions ADD COLUMN $colDeletedAt INTEGER',
    );

    await _createSessionsIndexes(db);
    await _normalizeLegacyRows(db);
  }

  Future<bool> _tableExists(Database db, String table) async {
    final List<Map<String, Object?>> rows = await db.query(
      'sqlite_master',
      columns: ['name'],
      where: 'type = ? AND name = ?',
      whereArgs: ['table', table],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<Set<String>> _getTableColumns(Database db, String table) async {
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'PRAGMA table_info($table)',
    );

    return rows
        .map((Map<String, Object?> row) => row['name'])
        .whereType<String>()
        .toSet();
  }

  Future<void> _addColumnIfMissing(
    Database db,
    Set<String> columns,
    String columnName,
    String statement,
  ) async {
    if (columns.contains(columnName)) {
      return;
    }
    await db.execute(statement);
    columns.add(columnName);
  }

  Future<void> _normalizeLegacyRows(Database db) async {
    final int now = DateTime.now().millisecondsSinceEpoch;

    await db.rawUpdate(
      'UPDATE $tableSessions SET $colCreatedAt = ? WHERE $colCreatedAt IS NULL',
      [now],
    );

    await db.rawUpdate(
      'UPDATE $tableSessions SET $colUpdatedAt = $colCreatedAt WHERE $colUpdatedAt IS NULL',
    );

    await db.rawUpdate(
      'UPDATE $tableSessions SET $colElapsedSeconds = 0 WHERE $colElapsedSeconds IS NULL',
    );

    await db.rawUpdate(
      'UPDATE $tableSessions SET $colSyncAttempts = 0 WHERE $colSyncAttempts IS NULL',
    );

    await db.rawUpdate(
      'UPDATE $tableSessions SET $colStatus = ? WHERE $colStatus IS NULL',
      [statusRunning],
    );

    await db.rawUpdate(
      'UPDATE $tableSessions SET $colStatus = ? WHERE $colEndTime IS NOT NULL AND $colStatus = ?',
      [statusFinished, statusRunning],
    );
  }

  Map<String, dynamic> _normalizeSessionPayload(Map<String, dynamic> data) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final bool hasEndTime = data[colEndTime] != null;

    return <String, dynamic>{
      ...data,
      colStatus:
          data[colStatus] ?? (hasEndTime ? statusFinished : statusRunning),
      colElapsedSeconds: data[colElapsedSeconds] ?? 0,
      colIsSynced: data[colIsSynced] ?? 0,
      colSyncAttempts: data[colSyncAttempts] ?? 0,
      colCreatedAt: data[colCreatedAt] ?? now,
      colUpdatedAt: now,
    };
  }

  // --- Operacoes de sessao (base para Timer/History/Home) ---

  Future<void> insertSession(Map<String, dynamic> sessionData) async {
    final db = await database;
    await db.insert(
      tableSessions,
      _normalizeSessionPayload(sessionData),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getSessionById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> rows = await db.query(
      tableSessions,
      where: '$colId = ? AND $colDeletedAt IS NULL',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<List<Map<String, dynamic>>> getSessions({
    String? status,
    bool onlyUnsynced = false,
    int? limit,
  }) async {
    final db = await database;

    final List<String> whereParts = <String>['$colDeletedAt IS NULL'];
    final List<Object?> whereArgs = <Object?>[];

    if (status != null) {
      whereParts.add('$colStatus = ?');
      whereArgs.add(status);
    }

    if (onlyUnsynced) {
      whereParts.add('$colIsSynced = 0');
    }

    return db.query(
      tableSessions,
      where: whereParts.join(' AND '),
      whereArgs: whereArgs,
      orderBy: '$colStartTime DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedSessions() async {
    final db = await database;
    return await db.query(
      tableSessions,
      where: '$colIsSynced = ? AND $colDeletedAt IS NULL',
      whereArgs: [0],
      orderBy: '$colCreatedAt ASC',
    );
  }

  Future<void> markAsSynced(String id) async {
    final db = await database;
    final int now = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      tableSessions,
      <String, Object?>{
        colIsSynced: 1,
        colLastSyncError: null,
        colUpdatedAt: now,
      },
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSyncFailure(String id, String errorMessage) async {
    final db = await database;
    final int now = DateTime.now().millisecondsSinceEpoch;

    await db.rawUpdate(
      '''
      UPDATE $tableSessions
      SET
        $colSyncAttempts = COALESCE($colSyncAttempts, 0) + 1,
        $colLastSyncError = ?,
        $colUpdatedAt = ?
      WHERE $colId = ?
      ''',
      [errorMessage, now, id],
    );
  }

  Future<void> updateSessionElapsedTime({
    required String id,
    required int elapsedSeconds,
  }) async {
    final db = await database;
    final int now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      tableSessions,
      <String, Object?>{colElapsedSeconds: elapsedSeconds, colUpdatedAt: now},
      where: '$colId = ? AND $colDeletedAt IS NULL',
      whereArgs: [id],
    );
  }

  Future<void> updateSessionStatus({
    required String id,
    required String status,
    DateTime? endTime,
  }) async {
    final db = await database;
    final int now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      tableSessions,
      <String, Object?>{
        colStatus: status,
        colEndTime: endTime?.toIso8601String(),
        colUpdatedAt: now,
      },
      where: '$colId = ? AND $colDeletedAt IS NULL',
      whereArgs: [id],
    );
  }

  Future<void> updateSessionNotes({
    required String id,
    required String notes,
  }) async {
    final db = await database;
    final int now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      tableSessions,
      <String, Object?>{colNotes: notes, colUpdatedAt: now},
      where: '$colId = ? AND $colDeletedAt IS NULL',
      whereArgs: [id],
    );
  }

  Future<void> softDeleteSession(String id) async {
    final db = await database;
    final int now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      tableSessions,
      <String, Object?>{colDeletedAt: now, colUpdatedAt: now},
      where: '$colId = ? AND $colDeletedAt IS NULL',
      whereArgs: [id],
    );
  }
}
