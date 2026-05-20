import 'package:kronos/features/timer/domain/errors/timer_domain_error.dart';
import 'package:result_dart/result_dart.dart';

import '../../domain/entities/timer_entities.dart';
import '../../domain/repositories/timer_repository.dart';
import '../source/timer_source.dart';

final class TimerRepositoryImpl implements TimerRepository {
  final TimerSource _source;

  TimerRepositoryImpl({required TimerSource source}) : _source = source;

  @override
  AsyncResult<TimerSession> startSession({
    required String subject,
    String? notes,
  }) async {
    try {
      final result = await _source.startSession(subject: subject, notes: notes);
      return Success(result);
    } catch (error, stackTrace) {
      return Failure(TimerStartError(cause: error, stackTrace: stackTrace));
    }
  }

  @override
  AsyncResult<TimerSession> pauseSession(String sessionId) async {
    try {
      final result = await _source.pauseSession(sessionId);
      return Success(result);
    } catch (error, stackTrace) {
      return Failure(TimerPauseError(cause: error, stackTrace: stackTrace));
    }
  }

  @override
  AsyncResult<TimerSession> resumeSession(String sessionId) async {
    try {
      final result = await _source.resumeSession(sessionId);
      return Success(result);
    } catch (error, stackTrace) {
      return Failure(TimerResumeError(cause: error, stackTrace: stackTrace));
    }
  }

  @override
  AsyncResult<TimerSession> tickSession({
    required String sessionId,
    required int elapsedSeconds,
  }) async {
    try {
      final result = await _source.tickSession(
        sessionId: sessionId,
        elapsedSeconds: elapsedSeconds,
      );
      return Success(result);
    } catch (error, stackTrace) {
      return Failure(TimerTickError(cause: error, stackTrace: stackTrace));
    }
  }

  @override
  AsyncResult<TimerSessionSummary> finishSession({
    required String sessionId,
    String? notes,
  }) async {
    try {
      final result = await _source.finishSession(
        sessionId: sessionId,
        notes: notes,
      );
      return Success(result);
    } catch (error, stackTrace) {
      return Failure(TimerFinishError(cause: error, stackTrace: stackTrace));
    }
  }

  @override
  AsyncResult<TimerSessionSummary> getLastSession() async {
    try {
      final result = await _source.getLastSession();
      if (result != null) {
        return Success(result);
      } else {
        return Failure(
          TimerLoadError(
            cause: Exception('No last session found'),
            stackTrace: StackTrace.current,
          ),
        );
      }
    } catch (error, stackTrace) {
      return Failure(TimerLoadError(cause: error, stackTrace: stackTrace));
    }
  }
}
