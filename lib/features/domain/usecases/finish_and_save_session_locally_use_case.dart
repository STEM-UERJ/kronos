import '../entities/study_session.dart';
import '../repositories/study_session_repository.dart';
import 'use_case.dart';

/// Parâmetros para finalizar e salvar uma sessão de estudo.
final class FinishSessionParams {
  /// Sessão em andamento retornada por [StartStudySessionUseCase].
  final StudySession activeSession;

  /// Anotação final — substitui ou complementa as notas iniciais.
  final String? notes;

  const FinishSessionParams({required this.activeSession, this.notes});
}

/// Finaliza a sessão ativa e a persiste no banco local (Sqflite).
///
/// Responsabilidades:
/// 1. Registra [endTime] = DateTime.now() na sessão.
/// 2. Garante que [isSynced] == false (a sincronização com GitHub Gists é feita
///    depois, por outro use case se implementado).
/// 3. Delega a persistência ao [StudySessionRepository].
/// 4. Retorna a sessão concluída para o Cubit atualizar a UI.
///
/// Implementação esperada:
/// - Completar a sessão ativa com endTime = DateTime.now()
/// - Atualizar as notas (usar notas fornecidas ou manter as existentes)
/// - Garantir que isSynced = false
/// - Chamar repository.saveSession() para persistir
/// - Retornar a sessão completada
/// - Lançar exceção em caso de erro
///
/// ```dart
/// final saved = await finishAndSave(
///   FinishSessionParams(
///     activeSession: currentSession,
///     notes: 'Revisei Streams e RxDart',
///   ),
/// );
/// ```
final class FinishAndSaveSessionLocallyUseCase
    implements UseCase<StudySession, FinishSessionParams> {
  // ignore: unused_field
  final StudySessionRepository _repository;

  const FinishAndSaveSessionLocallyUseCase(this._repository);

  @override
  Future<StudySession> call(FinishSessionParams params) async {
    final completed = params.activeSession.copyWith(
      endTime: DateTime.now(),
      isSynced: false,
      notes: params.notes ?? params.activeSession.notes,
    );

    await _repository.saveSession(completed);
    return completed;
  }
}
