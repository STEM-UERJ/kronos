/// Estados da página do Timer.
///
/// Representa os diferentes estados que o gerenciador de estado (Cubit)
/// pode emitir durante uma sessão de estudo.

/// Estado base para todos os estados do Timer.
abstract class TimerState {}

/// Estado inicial - timer ainda não iniciado.
class TimerInitial extends TimerState {}

/// Estado durante execução do timer.
class TimerRunning extends TimerState {
  /// Número de segundos decorridos desde o início da sessão.
  final int secondsElapsed;

  /// Assunto da sessão em andamento.
  final String subject;

  TimerRunning({required this.secondsElapsed, required this.subject});
}

/// Estado quando o timer está pausado.
class TimerPaused extends TimerState {
  /// Número de segundos decorridos até o momento da pausa.
  final int secondsElapsed;

  /// Assunto da sessão pausada.
  final String subject;

  TimerPaused({required this.secondsElapsed, required this.subject});
}

/// Estado quando a sessão foi finalizada e salva.
class TimerFinished extends TimerState {
  /// Duração total da sessão em segundos.
  final int durationInSeconds;

  /// Assunto da sessão completada.
  final String subject;

  /// Notas opcionais adicionadas pelo usuário.
  final String? notes;

  TimerFinished({
    required this.durationInSeconds,
    required this.subject,
    this.notes,
  });
}

/// Estado de erro durante operações do timer.
class TimerError extends TimerState {
  /// Mensagem descrevendo o erro ocorrido.
  final String message;

  TimerError(this.message);
}
