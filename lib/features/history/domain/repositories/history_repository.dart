import 'package:kronos/core/contracts/use_case_contract.dart';

import '../entities/history_entities.dart';

abstract interface class HistoryRepository {
  AsyncResult<List<HistorySession>> getSessions(HistoryQuery query);

  AsyncResult<HistorySessionDetails> getSessionDetails(String sessionId);

  AsyncResult<void> updateSessionNotes({
    required String sessionId,
    required String notes,
  });

  AsyncResult<void> deleteSession(String sessionId);
}
