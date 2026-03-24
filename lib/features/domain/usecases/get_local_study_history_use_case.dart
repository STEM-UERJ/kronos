import '../entities/study_session.dart';
import '../repositories/study_session_repository.dart';
import 'use_case.dart';

/// Recupera o histórico completo de sessões de estudo armazenado localmente.
///
/// Funciona 100% offline — não depende de conectividade com a API do GitHub.
/// As sessões são retornadas em ordem decrescente de [startTime] (mais recentes
/// primeiro), conforme implementado por [StudySessionRepository.getAllSessions].
///
/// Implementação esperada:
/// - Chamar _repository.getAllSessions()
/// - Retornar a lista de sessões recebida
/// - Lançar exceção em caso de erro
///
/// ```dart
/// final history = await getLocalStudyHistory(const NoParams());
/// ```
final class GetLocalStudyHistoryUseCase
    implements UseCase<List<StudySession>, NoParams> {
  // ignore: unused_field
  final StudySessionRepository _repository;

  const GetLocalStudyHistoryUseCase(this._repository);

  @override
  Future<List<StudySession>> call(NoParams params) async {
    return await _repository.getAllSessions();
  }
}
