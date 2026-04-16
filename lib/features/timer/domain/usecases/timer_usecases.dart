import 'package:kronos/core/contracts/use_case_contract.dart';
import 'package:result_dart/result_dart.dart';

import '../entities/timer_entities.dart';
import '../repositories/timer_repository.dart';
import 'timer_usecase_contracts.dart';

final class StartTimerSessionUseCaseImpl implements StartTimerSessionUseCase {
  final TimerRepository _repository;

  StartTimerSessionUseCaseImpl({required TimerRepository repository})
    : _repository = repository;

  Never _notImplemented() {
    final _ = _repository;
    throw UnimplementedError();
  }

  @override
  AsyncResult<TimerSession> call(StartTimerSessionParams params) {
    return _notImplemented();
  }
}

final class PauseTimerSessionUseCaseImpl implements PauseTimerSessionUseCase {
  final TimerRepository _repository;

  PauseTimerSessionUseCaseImpl({required TimerRepository repository})
    : _repository = repository;

  Never _notImplemented() {
    final _ = _repository;
    throw UnimplementedError();
  }

  @override
  AsyncResult<TimerSession> call(SessionIdParams params) {
    return _notImplemented();
  }
}

final class ResumeTimerSessionUseCaseImpl implements ResumeTimerSessionUseCase {
  final TimerRepository _repository;

  ResumeTimerSessionUseCaseImpl({required TimerRepository repository})
    : _repository = repository;

  Never _notImplemented() {
    final _ = _repository;
    throw UnimplementedError();
  }

  @override
  AsyncResult<TimerSession> call(SessionIdParams params) {
    return _notImplemented();
  }
}

final class TickTimerSessionUseCaseImpl implements TickTimerSessionUseCase {
  final TimerRepository _repository;

  TickTimerSessionUseCaseImpl({required TimerRepository repository})
    : _repository = repository;

  Never _notImplemented() {
    final _ = _repository;
    throw UnimplementedError();
  }

  @override
  AsyncResult<TimerSession> call(TickTimerSessionParams params) {
    return _notImplemented();
  }
}

final class FinishTimerSessionUseCaseImpl implements FinishTimerSessionUseCase {
  final TimerRepository _repository;

  FinishTimerSessionUseCaseImpl({required TimerRepository repository})
    : _repository = repository;

  Never _notImplemented() {
    final _ = _repository;
    throw UnimplementedError();
  }

  @override
  AsyncResult<TimerSessionSummary> call(FinishTimerSessionParams params) {
    return _notImplemented();
  }
}

final class GetLastTimerSessionUseCaseImpl
    implements GetLastTimerSessionUseCase {
  final TimerRepository _repository;

  GetLastTimerSessionUseCaseImpl({required TimerRepository repository})
    : _repository = repository;

  Never _notImplemented() {
    final _ = _repository;
    throw UnimplementedError();
  }

  @override
  AsyncResult<TimerSessionSummary> call(NoParams params) {
    return _notImplemented();
  }
}
