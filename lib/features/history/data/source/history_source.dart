import '../../domain/entities/history_entities.dart';

abstract interface class HistorySource {
  Future<List<HistorySession>> getSessions(HistoryQuery query);

  Future<HistorySessionDetails> getSessionDetails(String sessionId);

  Future<void> updateSessionNotes({
    required String sessionId,
    required String notes,
  });

  Future<void> deleteSession(String sessionId);
}
