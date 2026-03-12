import 'package:kronos/features/domain/entities/study_session.dart';
import 'package:kronos/features/domain/repositories/study_session_repository.dart';
import 'package:kronos/features/data/source/local_study_session_source.dart';

/// Implementação do repositório de sessões de estudo.
///
/// [StudySessionRepositoryImpl] implementa o contrato [StudySessionRepository]
/// e coordena as operações com a camada de dados (local via Sqflite e remota).
class StudySessionRepositoryImpl implements StudySessionRepository {
  /// Fonte de dados local (Sqflite).
  final LocalStudySessionSource localSource;

  // TODO: Adicionar campo para source remoto quando implementar sincronização
  // final RemoteStudySessionSource remoteSource;

  StudySessionRepositoryImpl({
    required this.localSource,
    // required this.remoteSource,
  });

  @override
  Future<void> saveSession(StudySession session) async {
    // TODO: Implementar persistência de sessão
    // 1. Converter StudySession em StudySessionModel usando fromEntity()
    // 2. Chamar localSource.saveSession(model)
    // 3. Tratar exceções apropriadamente
    throw UnimplementedError('saveSession() não implementado');
  }

  @override
  Future<List<StudySession>> getAllSessions() async {
    // TODO: Implementar recuperação de todas as sessões
    // 1. Chamar localSource.getAllSessions()
    // 2. Converter List<StudySessionModel> para List<StudySession>
    // 3. Retornar lista (já que StudySessionModel estende StudySession, pode retornar direto)
    // 4. Tratar exceções
    throw UnimplementedError('getAllSessions() não implementado');
  }

  @override
  Future<List<StudySession>> getUnsyncedSessions() async {
    // TODO: Implementar recuperação de sessões não sincronizadas
    // 1. Chamar getAllSessions()
    // 2. Filtrar apenas sessões onde isSynced == false
    // 3. Retornar lista filtrada
    throw UnimplementedError('getUnsyncedSessions() não implementado');
  }

  @override
  Future<void> markAsSynced(String sessionId) async {
    // TODO: Implementar marcação de sincronização
    // 1. Chamar localSource.updateSync(sessionId, true)
    // 2. Tratar exceções
    throw UnimplementedError('markAsSynced() não implementado');
  }
}
