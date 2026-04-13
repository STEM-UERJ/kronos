import 'package:kronos/core/contracts/use_case_contract.dart';

import '../entities/timer_entities.dart';

abstract interface class TimerRepository {
  AsyncResult<TimerSession> startSession({
    required String subject,
    String? notes,
  });

  AsyncResult<TimerSession> pauseSession(String sessionId);

  AsyncResult<TimerSession> resumeSession(String sessionId);

  AsyncResult<TimerSession> tickSession({
    required String sessionId,
    required int elapsedSeconds,
  });

  AsyncResult<TimerSessionSummary> finishSession({
    required String sessionId,
    String? notes,
  });

  AsyncResult<TimerSessionSummary?> getLastSession();
}
