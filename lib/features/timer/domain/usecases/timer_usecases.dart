import 'package:kronos/core/contracts/use_case_contract.dart';
import 'package:result_dart/result_dart.dart';

import '../entities/timer_entities.dart';
import '../repositories/timer_repository.dart';
import 'timer_usecase_contracts.dart';

final class StartTimerSessionUseCaseImpl implements StartTimerSessionUseCase {
  final TimerRepository _repository;

  StartTimerSessionUseCaseImpl({required TimerRepository repository})
    : _repository = repository;

  @override
  AsyncResult<TimerSession> call(StartTimerSessionParams params) {
    return _repository.startSession(
      subject: params.subject,
      notes: params.notes,
    );
  }
}

final class PauseTimerSessionUseCaseImpl implements PauseTimerSessionUseCase {
  final TimerRepository _repository;

  PauseTimerSessionUseCaseImpl({required TimerRepository repository})
    : _repository = repository;

  @override
  AsyncResult<TimerSession> call(SessionIdParams params) {
    return _repository.pauseSession(params.sessionId);
  }
}

final class ResumeTimerSessionUseCaseImpl implements ResumeTimerSessionUseCase {
  final TimerRepository _repository;

  ResumeTimerSessionUseCaseImpl({required TimerRepository repository})
    : _repository = repository;

  @override
  AsyncResult<TimerSession> call(SessionIdParams params) {
    return _repository.resumeSession(params.sessionId);
  }
}

final class TickTimerSessionUseCaseImpl implements TickTimerSessionUseCase {
  final TimerRepository _repository;

  TickTimerSessionUseCaseImpl({required TimerRepository repository})
    : _repository = repository;

  @override
  AsyncResult<TimerSession> call(TickTimerSessionParams params) {
    return _repository.tickSession(
      sessionId: params.sessionId,
      elapsedSeconds: params.elapsedSeconds,
    );
  }
}

final class FinishTimerSessionUseCaseImpl implements FinishTimerSessionUseCase {
  final TimerRepository _repository;

  FinishTimerSessionUseCaseImpl({required TimerRepository repository})
    : _repository = repository;

  @override
  AsyncResult<TimerSessionSummary> call(FinishTimerSessionParams params) {
    return _repository.finishSession(
      sessionId: params.sessionId,
      notes: params.notes,
    );
  }
}

final class GetLastTimerSessionUseCaseImpl
    implements GetLastTimerSessionUseCase {
  final TimerRepository _repository;

  GetLastTimerSessionUseCaseImpl({required TimerRepository repository})
    : _repository = repository;

  @override
  AsyncResult<TimerSessionSummary> call(NoParams params) {
    return _repository.getLastSession();
  }
}
