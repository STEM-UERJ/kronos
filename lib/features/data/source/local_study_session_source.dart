import 'package:sqflite/sqflite.dart';
import 'package:kronos/core/sql/database.dart';
import 'package:kronos/features/data/model/study_session_model.dart';

/// Contrato (interface) para a fonte de dados local de sessões de estudo.
///
/// [LocalStudySessionSource] define as operações disponíveis para
/// persistência local usando Sqflite.
abstract interface class LocalStudySessionSource {
  /// Salva uma nova sessão no banco de dados local.
  Future<void> saveSession(StudySessionModel session);

  /// Recupera todas as sessões armazenadas.
  Future<List<StudySessionModel>> getAllSessions();

  /// Busca uma sessão específica pelo ID.
  Future<StudySessionModel?> getSessionById(String id);

  /// Atualiza o status de sincronização de uma sessão.
  Future<void> updateSync(String sessionId, bool isSynced);

  /// Remove uma sessão do banco de dados.
  Future<void> deleteSession(String id);
}

/// Implementação da fonte de dados local usando Sqflite.
///
/// [LocalStudySessionSourceImpl] gerencia todos os acessos ao banco de dados
/// SQLite local para sessões de estudo.
class LocalStudySessionSourceImpl implements LocalStudySessionSource {
  /// Nome da tabela no banco de dados.
  static const String tableName = 'study_sessions';

  /// Classe de serviço de banco com criação e conexão.
  final DatabaseService databaseService;

  LocalStudySessionSourceImpl({required this.databaseService});

  static Future<void> initDatabase(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
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

  @override
  Future<void> saveSession(StudySessionModel session) async {
    final db = await databaseService.database;
    await db.insert(
      tableName,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<StudySessionModel>> getAllSessions() async {
    final db = await databaseService.database;
    final rows = await db.query(tableName, orderBy: 'start_time DESC');
    return rows.map((row) => StudySessionModel.fromMap(row)).toList();
  }

  @override
  Future<StudySessionModel?> getSessionById(String id) async {
    final db = await databaseService.database;
    final rows = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return StudySessionModel.fromMap(rows.first);
  }

  @override
  Future<void> updateSync(String sessionId, bool isSynced) async {
    final db = await databaseService.database;
    await db.update(
      tableName,
      {'is_synced': isSynced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  @override
  Future<void> deleteSession(String id) async {
    final db = await databaseService.database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
