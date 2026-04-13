import '../../domain/entities/timer_entities.dart';

abstract interface class TimerSource {
  Future<TimerSession> startSession({required String subject, String? notes});

  Future<TimerSession> pauseSession(String sessionId);

  Future<TimerSession> resumeSession(String sessionId);

  Future<TimerSession> tickSession({
    required String sessionId,
    required int elapsedSeconds,
  });

  Future<TimerSessionSummary> finishSession({
    required String sessionId,
    String? notes,
  });

  Future<TimerSessionSummary?> getLastSession();
}
