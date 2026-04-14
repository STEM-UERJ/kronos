import '../../domain/entities/timer_entities.dart';

sealed class TimerState {
  const TimerState();
}

final class TimerInitial extends TimerState {
  const TimerInitial();
}

final class TimerIdle extends TimerState {
  const TimerIdle();
}

final class TimerRunning extends TimerState {
  final TimerSession session;

  const TimerRunning({required this.session});
}

final class TimerPaused extends TimerState {
  final TimerSession session;

  const TimerPaused({required this.session});
}

final class TimerFinished extends TimerState {
  final TimerSessionSummary summary;

  const TimerFinished({required this.summary});
}

final class TimerFailure extends TimerState {
  final String message;

  const TimerFailure(this.message);
}
