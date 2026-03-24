import 'package:kronos/features/data/model/study_session_model.dart';
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
    final sessionToSave = session.copyWith(isSynced: false);
    final model = StudySessionModel.fromEntity(sessionToSave);
    await localSource.saveSession(model);
  }

  @override
  Future<List<StudySession>> getAllSessions() async {
    final sessions = await localSource.getAllSessions();
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  @override
  Future<List<StudySession>> getUnsyncedSessions() async {
    final sessions = await localSource.getAllSessions();
    return sessions.where((session) => !session.isSynced).toList();
  }

  @override
  Future<void> markAsSynced(String sessionId) async {
    await localSource.updateSync(sessionId, true);
  }
}
