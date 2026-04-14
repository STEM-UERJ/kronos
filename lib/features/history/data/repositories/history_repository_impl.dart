import 'package:kronos/core/contracts/use_case_contract.dart';

import '../../domain/entities/history_entities.dart';
import '../../domain/repositories/history_repository.dart';
import '../source/history_source.dart';

final class HistoryRepositoryImpl implements HistoryRepository {
  final HistorySource _source;

  HistoryRepositoryImpl({required HistorySource source}) : _source = source;

  Never _notImplemented() {
    final _ = _source;
    throw UnimplementedError();
  }

  @override
  AsyncResult<List<HistorySession>> getSessions(HistoryQuery query) {
    return _notImplemented();
  }

  @override
  AsyncResult<HistorySessionDetails> getSessionDetails(String sessionId) {
    return _notImplemented();
  }

  @override
  AsyncResult<void> updateSessionNotes({
    required String sessionId,
    required String notes,
  }) {
    return _notImplemented();
  }

  @override
  AsyncResult<void> deleteSession(String sessionId) {
    return _notImplemented();
  }
}
