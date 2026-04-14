import 'package:kronos/core/contracts/use_case_contract.dart';

import '../entities/timer_entities.dart';

final class StartTimerSessionParams extends UseCaseParams {
  final String subject;
  final String? notes;

  const StartTimerSessionParams({required this.subject, this.notes});
}

final class SessionIdParams extends UseCaseParams {
  final String sessionId;

  const SessionIdParams({required this.sessionId});
}

final class TickTimerSessionParams extends UseCaseParams {
  final String sessionId;
  final int elapsedSeconds;

  const TickTimerSessionParams({
    required this.sessionId,
    required this.elapsedSeconds,
  });
}

final class FinishTimerSessionParams extends UseCaseParams {
  final String sessionId;
  final String? notes;

  const FinishTimerSessionParams({required this.sessionId, this.notes});
}

abstract interface class StartTimerSessionUseCase
    implements UseCase<TimerSession, StartTimerSessionParams> {}

abstract interface class PauseTimerSessionUseCase
    implements UseCase<TimerSession, SessionIdParams> {}

abstract interface class ResumeTimerSessionUseCase
    implements UseCase<TimerSession, SessionIdParams> {}

abstract interface class TickTimerSessionUseCase
    implements UseCase<TimerSession, TickTimerSessionParams> {}

abstract interface class FinishTimerSessionUseCase
    implements UseCase<TimerSessionSummary, FinishTimerSessionParams> {}

abstract interface class GetLastTimerSessionUseCase
    implements UseCase<TimerSessionSummary?, NoParams> {}
