import 'package:equatable/equatable.dart';
import 'package:kronos/features/domain/entities/study_session.dart';

/// Estados da página do Timer.
///
/// Representa os diferentes estados que o gerenciador de estado (Cubit)
/// pode emitir durante uma sessão de estudo.

/// Estado base para todos os estados do Timer.
sealed class TimerState extends Equatable {
  const TimerState();
}

final class TimerIdle extends TimerState {
  const TimerIdle();

  @override
  List<Object?> get props => [];
}

final class TimerRunning extends TimerState {
  final StudySession session;
  final Duration elapsed;
  final bool isPaused;

  const TimerRunning({
    required this.session,
    required this.elapsed,
    this.isPaused = false,
  });

  TimerRunning copyWith({
    StudySession? session,
    Duration? elapsed,
    bool? isPaused,
  }) => TimerRunning(
    session: session ?? this.session,
    elapsed: elapsed ?? this.elapsed,
    isPaused: isPaused ?? this.isPaused,
  );

  @override
  List<Object?> get props => [session, elapsed, isPaused];
}

final class TimerFinished extends TimerState {
  final StudySession completedSession;
  const TimerFinished(this.completedSession);
  @override
  List<Object?> get props => [completedSession];
}

final class TimerError extends TimerState {
  final String message;
  const TimerError(this.message);
  @override
  List<Object?> get props => [message];
}

//States que eu devo criar: Idle (pause), running, finsihed, error
