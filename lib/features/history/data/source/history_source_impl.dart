import 'package:kronos/core/sql/database.dart';
import 'package:kronos/features/history/data/source/history_source.dart';
import 'package:kronos/features/history/domain/entities/history_entities.dart';

final class HistorySourceImpl implements HistorySource {
  final DatabaseService _databaseService;

  HistorySourceImpl({required DatabaseService databaseService})
    : _databaseService = databaseService;

  @override
  Future<List<HistorySession>> getSessions(HistoryQuery query) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final isUnsyncedOnly = query.filter == HistoryFilterType.unsynced;
    
    final rawSessions = await _databaseService.getSessions(onlyUnsynced: isUnsyncedOnly);
    
    final sessions = <HistorySession>[];
    
    for (final raw in rawSessions) {
      final startTimeStr = raw[DatabaseService.colStartTime] as String;
      final startTime = DateTime.parse(startTimeStr);
      
      // se o filtro for thisWeek, filtramos manualmente (o getSessions pode nao suportar direto, ou a gente faz)
      if (query.filter == HistoryFilterType.thisWeek && startTime.isBefore(weekAgo)) {
        continue;
      }
      
      final endTimeStr = raw[DatabaseService.colEndTime] as String?;
      final endTime = endTimeStr != null ? DateTime.parse(endTimeStr) : startTime;
      
      final elapsedSeconds = (raw[DatabaseService.colElapsedSeconds] as int?) ?? 0;
      final durationInMinutes = elapsedSeconds ~/ 60;
      final isSyncedInt = (raw[DatabaseService.colIsSynced] as int?) ?? 0;
      
      sessions.add(
        HistorySession(
          id: raw[DatabaseService.colId] as String,
          subject: raw[DatabaseService.colSubject] as String,
          startTime: startTime,
          endTime: endTime,
          durationInMinutes: durationInMinutes,
          isSynced: isSyncedInt == 1,
        ),
      );
    }
    
    return sessions;
  }

  @override
  Future<HistorySessionDetails> getSessionDetails(String sessionId) async {
    final raw = await _databaseService.getSessionById(sessionId);
    if (raw == null) {
      throw Exception('Session not found');
    }
    
    final startTimeStr = raw[DatabaseService.colStartTime] as String;
    final startTime = DateTime.parse(startTimeStr);
    
    final endTimeStr = raw[DatabaseService.colEndTime] as String?;
    final endTime = endTimeStr != null ? DateTime.parse(endTimeStr) : startTime;
    
    final elapsedSeconds = (raw[DatabaseService.colElapsedSeconds] as int?) ?? 0;
    final durationInMinutes = elapsedSeconds ~/ 60;
    final isSyncedInt = (raw[DatabaseService.colIsSynced] as int?) ?? 0;
    
    final session = HistorySession(
      id: raw[DatabaseService.colId] as String,
      subject: raw[DatabaseService.colSubject] as String,
      startTime: startTime,
      endTime: endTime,
      durationInMinutes: durationInMinutes,
      isSynced: isSyncedInt == 1,
    );
    
    final notes = raw[DatabaseService.colNotes] as String?;
    
    return HistorySessionDetails(session: session, notes: notes);
  }

  @override
  Future<void> updateSessionNotes({
    required String sessionId,
    required String notes,
  }) async {
    await _databaseService.updateSessionNotes(id: sessionId, notes: notes);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _databaseService.softDeleteSession(sessionId);
  }
}
