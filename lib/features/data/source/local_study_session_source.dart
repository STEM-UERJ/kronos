import 'package:sqflite/sqflite.dart';
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

  /// Instância do banco de dados Sqflite.
  final Database database;

  LocalStudySessionSourceImpl({required this.database});

  /// Initializa a tabela no banco de dados na primeira execução.
  ///
  /// Implementação esperada:
  /// - Criar tabela com schema:
  ///   - id (TEXT PRIMARY KEY)
  ///   - subject (TEXT NOT NULL)
  ///   - startTime (INTEGER NOT NULL) - timestamp em ms
  ///   - endTime (INTEGER) - null enquanto sessão estiver ativa
  ///   - isSynced (INTEGER DEFAULT 0)
  ///   - notes (TEXT)
  ///   - createdAt (INTEGER DEFAULT current timestamp)
  static Future<void> initDatabase(Database db) async {
    // TODO: Implementar criação da tabela
    // CREATE TABLE IF NOT EXISTS $tableName (
    //   id TEXT PRIMARY KEY,
    //   subject TEXT NOT NULL,
    //   startTime INTEGER NOT NULL,
    //   endTime INTEGER,
    //   isSynced INTEGER DEFAULT 0,
    //   notes TEXT,
    //   createdAt INTEGER DEFAULT (strftime('%s', 'now') * 1000)
    // )
  }

  @override
  Future<void> saveSession(StudySessionModel session) async {
    // TODO: Implementar persistência de sessão
    // 1. Converter session para mapa usando session.toMap()
    // 2. Executar INSERT OR REPLACE na tabela
    // 3. Usar db.insert() ou db.rawInsert()
  }

  @override
  Future<List<StudySessionModel>> getAllSessions() async {
    // TODO: Implementar recuperação de todas as sessões
    // 1. Executar query: SELECT * FROM $tableName ORDER BY startTime DESC
    // 2. Converter cada mapa resultado em StudySessionModel usando fromMap()
    // 3. Retornar lista de modelos
    throw UnimplementedError('getAllSessions() não implementado');
  }

  @override
  Future<StudySessionModel?> getSessionById(String id) async {
    // TODO: Implementar busca de sessão por ID
    // 1. Executar query: SELECT * FROM $tableName WHERE id = ?
    // 2. Se encontrado, converter mapa em StudySessionModel
    // 3. Se não encontrado, retornar null
    throw UnimplementedError('getSessionById() não implementado');
  }

  @override
  Future<void> updateSync(String sessionId, bool isSynced) async {
    // TODO: Implementar atualização de status de sincronização
    // 1. Converter bool isSynced para int (1 ou 0)
    // 2. Executar UPDATE $tableName SET isSynced = ? WHERE id = ?
    // 3. Usar db.update()
  }

  @override
  Future<void> deleteSession(String id) async {
    // TODO: Implementar remoção de sessão
    // 1. Executar DELETE FROM $tableName WHERE id = ?
    // 2. Usar db.delete()
  }
}
