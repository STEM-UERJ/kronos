import '../entities/study_session.dart';
import 'use_case.dart';

/// Parâmetros necessários para iniciar uma nova sessão de estudo.
final class StartSessionParams {
  /// Assunto / área de estudo (ex: 'Flutter', 'Inglês', 'LLMs').
  final String subject;

  /// Anotação inicial opcional — pode ser complementada ao finalizar.
  final String? notes;

  const StartSessionParams({required this.subject, this.notes});
}

/// Inicia o cronômetro para uma nova sessão de estudo.
///
/// Responsabilidade exclusiva: criar um objeto [StudySession] em memória com
/// [startTime] == DateTime.now() e [endTime] == null.
///
/// Nenhum dado é persistido aqui — a sessão vive no estado do Cubit até
/// ser finalizada por [FinishAndSaveSessionLocallyUseCase].
///
/// Implementação esperada:
/// - Gerar ID único para a sessão (usar DateTime.now().microsecondsSinceEpoch ou uuid package)
/// - Criar nova StudySession com os parâmetros fornecidos
/// - Definir startTime como DateTime.now()
/// - Deixar endTime como null (sessão em andamento)
/// - Definir isSynced como false
/// - Retornar a sessão criada
///
/// ```dart
/// final session = await startStudySession(
///   StartSessionParams(subject: 'Flutter'),
/// );
/// ```
final class StartStudySessionUseCase
    implements UseCase<StudySession, StartSessionParams> {
  const StartStudySessionUseCase();

  @override
  Future<StudySession> call(StartSessionParams params) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final session = StudySession(
      id: id,
      subject: params.subject,
      startTime: DateTime.now(),
      endTime: null,
      isSynced: false,
      notes: params.notes,
    );
    return session;
  }
}
