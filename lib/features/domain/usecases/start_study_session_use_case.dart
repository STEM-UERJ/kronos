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
    // TODO: Implementar inicialização de nova sessão
    // 1. Gerar ID único baseado em timestamp ou usar uuid package
    // 2. Criar StudySession com:
    //    - id: ID gerado
    //    - subject: params.subject
    //    - startTime: DateTime.now()
    //    - endTime: null
    //    - isSynced: false
    //    - notes: params.notes
    // 3. Retornar a sessão criada
    throw UnimplementedError('call() não implementado');
  }
}
