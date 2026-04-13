import 'package:kronos/core/contracts/use_case_contract.dart';

import '../../domain/entities/timer_entities.dart';
import '../../domain/repositories/timer_repository.dart';
import '../source/timer_source.dart';

final class TimerRepositoryImpl implements TimerRepository {
  final TimerSource _source;

  TimerRepositoryImpl({required TimerSource source}) : _source = source;

  Never _notImplemented() {
    final _ = _source;
    throw UnimplementedError();
  }

  @override
  AsyncResult<TimerSession> startSession({
    required String subject,
    String? notes,
  }) {
    return _notImplemented();
  }

  @override
  AsyncResult<TimerSession> pauseSession(String sessionId) {
    return _notImplemented();
  }

  @override
  AsyncResult<TimerSession> resumeSession(String sessionId) {
    return _notImplemented();
  }

  @override
  AsyncResult<TimerSession> tickSession({
    required String sessionId,
    required int elapsedSeconds,
  }) {
    return _notImplemented();
  }

  @override
  AsyncResult<TimerSessionSummary> finishSession({
    required String sessionId,
    String? notes,
  }) {
    return _notImplemented();
  }

  @override
  AsyncResult<TimerSessionSummary?> getLastSession() {
    return _notImplemented();
  }
}
