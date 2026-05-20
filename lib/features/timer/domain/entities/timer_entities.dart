enum TimerSessionStatus { idle, running, paused, finished }

final class TimerSession {
  final String id;
  final String subject;
  final String? notes;
  final int elapsedSeconds;
  final TimerSessionStatus status;
  final bool isSynced;

  const TimerSession({
    required this.id,
    required this.subject,
    required this.elapsedSeconds,
    required this.status,
    required this.isSynced,
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
