import 'package:result_dart/result_dart.dart';

import '../../domain/entities/history_entities.dart';
import '../../domain/repositories/history_repository.dart';
import '../source/history_source.dart';

final class HistoryRepositoryImpl implements HistoryRepository {
  final HistorySource _source;

  HistoryRepositoryImpl({required HistorySource source}) : _source = source;

  @override
  AsyncResult<List<HistorySession>> getSessions(HistoryQuery query) async {
    try {
      final result = await _source.getSessions(query);
      return Success(result);
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  @override
  AsyncResult<HistorySessionDetails> getSessionDetails(String sessionId) async {
    try {
      final result = await _source.getSessionDetails(sessionId);
      return Success(result);
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  @override
  AsyncResult<void> updateSessionNotes({
    required String sessionId,
    required String notes,
  }) async {
    try {
      await _source.updateSessionNotes(sessionId: sessionId, notes: notes);
      return unit.toSuccess();
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  @override
  AsyncResult<void> deleteSession(String sessionId) async {
    try {
      await _source.deleteSession(sessionId);
      return unit.toSuccess();
    } on Exception catch (e) {
      return Failure(e);
    }
  }
}
