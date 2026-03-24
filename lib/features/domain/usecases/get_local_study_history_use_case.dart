import '../entities/study_session.dart';
import '../repositories/study_session_repository.dart';
import 'use_case.dart';

/// Recupera o histórico completo de sessões de estudo armazenado localmente.
///
/// Funciona 100% offline — não depende de conectividade com a API do GitHub.
/// As sessões são retornadas em ordem decrescente de [startTime] (mais recentes
/// primeiro), conforme implementado por [StudySessionRepository.getAllSessions].
///
/// ```dart
/// final history = await getLocalStudyHistory(const NoParams());
/// ```
final class GetLocalStudyHistoryUseCase
    implements UseCase<List<StudySession>, NoParams> {
  final StudySessionRepository _repository;

  const GetLocalStudyHistoryUseCase(this._repository);

  @override
  Future<List<StudySession>> call(NoParams params) async =>
      await _repository.getAllSessions();
}
