import 'package:kronos/core/sql/database.dart';

import '../../domain/entities/timer_entities.dart';

abstract interface class TimerSource {
  Future<TimerSession> startSession({required String subject, String? notes});

  Future<TimerSession> pauseSession(String sessionId);

  Future<TimerSession> resumeSession(String sessionId);

  Future<TimerSession> tickSession({
    required String sessionId,
    required int elapsedSeconds,
  });

  Future<TimerSessionSummary> finishSession({
    required String sessionId,
    String? notes,
  });

  Future<TimerSessionSummary?> getLastSession();
}

final class TimerSourceImpl implements TimerSource {
  final DatabaseService _database;

  TimerSourceImpl({required DatabaseService database}) : _database = database;

  // funções para mapear os dados do banco para as entidades
  TimerSessionStatus _mapStatus(String status) {
    switch (status) {
      case DatabaseService.statusRunning:
        return TimerSessionStatus.running;
      case DatabaseService.statusPaused:
        return TimerSessionStatus.paused;
      case DatabaseService.statusFinished:
        return TimerSessionStatus.finished;
      default:
        return TimerSessionStatus.idle;
    }
  }

  TimerSession _mapToSession(Map<String, dynamic> data) {
    return TimerSession(
      id: data[DatabaseService.colId] as String,
      subject: data[DatabaseService.colSubject] as String,
      notes: data[DatabaseService.colNotes] as String?,
      status: _mapStatus(data[DatabaseService.colStatus] as String),
      elapsedSeconds:
          (data[DatabaseService.colElapsedSeconds] as num?)?.toInt() ?? 0,
      isSynced: (data[DatabaseService.colIsSynced] as num?)?.toInt() == 1,
    );
  }

  TimerSessionSummary _mapToSummary(Map<String, dynamic> data) {
    return TimerSessionSummary(
      id: data[DatabaseService.colId] as String,
      subject: data[DatabaseService.colSubject] as String,
      totalSeconds:
          (data[DatabaseService.colElapsedSeconds] as num?)?.toInt() ?? 0,
      notes: data[DatabaseService.colNotes] as String?,
    );
  }

  @override
  Future<TimerSession> startSession({
    required String subject,
    String? notes,
  }) async {
    final String sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    final Map<String, dynamic> newSession = {
      DatabaseService.colId: sessionId,
      DatabaseService.colSubject: subject,
      DatabaseService.colNotes: notes,
      DatabaseService.colStartTime: DateTime.now().toIso8601String(),
      DatabaseService.colStatus: DatabaseService.statusRunning,
      DatabaseService.colElapsedSeconds: 0,
      DatabaseService.colIsSynced: 0,
    };

    await _database.insertSession(newSession);

    final data = await _database.getSessionById(sessionId);

    if (data == null) {
      throw Exception('Falha ao buscar sessão criada.');
    }

    return _mapToSession(data);
  }

  @override
  Future<TimerSession> pauseSession(String sessionId) async {
    await _database.updateSessionStatus(
      id: sessionId,
      status: DatabaseService.statusPaused,
    );

    final data = await _database.getSessionById(sessionId);

    if (data == null) {
      throw Exception('Sessão não encontrada.');
    }

    return _mapToSession(data);
  }

  @override
  Future<TimerSession> resumeSession(String sessionId) async {
    await _database.updateSessionStatus(
      id: sessionId,
      status: DatabaseService.statusRunning,
    );

    final data = await _database.getSessionById(sessionId);
    if (data == null) {
      throw Exception('Sessão não encontrada.');
    }

    return _mapToSession(data);
  }

  @override
  Future<TimerSession> tickSession({
    required String sessionId,
    required int elapsedSeconds,
  }) async {
    await _database.updateSessionElapsedTime(
      id: sessionId,
      elapsedSeconds: elapsedSeconds,
    );

    final data = await _database.getSessionById(sessionId);
    if (data == null) {
      throw Exception('Sessão não encontrada.');
    }

    return _mapToSession(data);
  }

  @override
  Future<TimerSessionSummary> finishSession({
    required String sessionId,
    String? notes,
  }) async {
    await _database.updateSessionStatus(
      id: sessionId,
      status: DatabaseService.statusFinished,
      endTime: DateTime.now(),
    );

    if (notes != null) {
      await _database.updateSessionNotes(id: sessionId, notes: notes);
    }

    final data = await _database.getSessionById(sessionId);
    if (data == null) {
      throw Exception('Sessão não encontrada.');
    }

    return _mapToSummary(data);
  }

  @override
  Future<TimerSessionSummary?> getLastSession() async {
    final sessions = await _database.getSessions(
      status: DatabaseService.statusFinished,
      limit: 1,
    );

    if (sessions.isEmpty) {
      return null;
    }

    return _mapToSummary(sessions.first);
  }
}
