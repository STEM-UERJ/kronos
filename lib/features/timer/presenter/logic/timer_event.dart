sealed class TimerEvent {
  const TimerEvent();
}

final class TimerStarted extends TimerEvent {
  const TimerStarted();
}

final class TimerPlayRequested extends TimerEvent {
  final String subject;
  final String? notes;

  const TimerPlayRequested({required this.subject, this.notes});
}

final class TimerPauseRequested extends TimerEvent {
  final int elapsedSeconds;
  const TimerPauseRequested({required this.elapsedSeconds});
}

final class TimerResumeRequested extends TimerEvent {
  const TimerResumeRequested();
}

final class TimerFinishRequested extends TimerEvent {
  final String? notes;
  final int elapsedSeconds;

  const TimerFinishRequested({this.notes, required this.elapsedSeconds});
}
