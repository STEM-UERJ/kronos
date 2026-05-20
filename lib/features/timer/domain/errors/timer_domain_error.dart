sealed class TimerDomainError implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  TimerDomainError({
    required this.message,
    required this.cause,
    required this.stackTrace,
  });

  @override
  String toString() => message;
}

final class TimerStartError extends TimerDomainError {
  TimerStartError({super.cause, super.stackTrace})
    : super(message: 'Não foi possível iniciar o timer');
}

final class TimerPauseError extends TimerDomainError {
  TimerPauseError({super.cause, super.stackTrace})
    : super(message: 'Não foi possível pausar o timer');
}

final class TimerResumeError extends TimerDomainError {
  TimerResumeError({super.cause, super.stackTrace})
    : super(message: 'Não foi possível retomar o timer');
}

final class TimerFinishError extends TimerDomainError {
  TimerFinishError({super.cause, super.stackTrace})
    : super(message: 'Não foi possível finalizar o timer');
}

final class TimerTickError extends TimerDomainError {
  TimerTickError({super.cause, super.stackTrace})
    : super(message: 'Falha de processamento no timer');
}

final class TimerLoadError extends TimerDomainError {
  TimerLoadError({super.cause, super.stackTrace})
    : super(message: 'Não foi possível carregar o timer');
}
