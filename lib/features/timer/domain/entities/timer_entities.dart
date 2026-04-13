enum TimerSessionStatus { idle, running, paused, finished }

final class TimerSession {
  final String id;
  final String subject;
  final String? notes;
  final int elapsedSeconds;
  final TimerSessionStatus status;

  const TimerSession({
    required this.id,
    required this.subject,
    required this.elapsedSeconds,
    required this.status,
    this.notes,
  });
}

final class TimerSessionSummary {
  final String id;
  final String subject;
  final int totalSeconds;
  final String? notes;

  const TimerSessionSummary({
    required this.id,
    required this.subject,
    required this.totalSeconds,
    this.notes,
  });
}
