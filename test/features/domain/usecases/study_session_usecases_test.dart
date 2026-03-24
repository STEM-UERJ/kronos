import 'package:flutter_test/flutter_test.dart';
import 'package:kronos/features/domain/entities/study_session.dart';
import 'package:kronos/features/domain/repositories/study_session_repository.dart';
import 'package:kronos/features/domain/usecases/finish_and_save_session_locally_use_case.dart';
import 'package:kronos/features/domain/usecases/get_local_study_history_use_case.dart';
import 'package:kronos/features/domain/usecases/start_study_session_use_case.dart';
import 'package:kronos/features/domain/usecases/use_case.dart';

class FakeStudySessionRepository implements StudySessionRepository {
  final List<StudySession> _sessions = [];

  @override
  Future<void> saveSession(StudySession session) async {
    _sessions.removeWhere((s) => s.id == session.id);
    _sessions.add(session);
  }

  @override
  Future<List<StudySession>> getAllSessions() async {
    return List.unmodifiable(_sessions);
  }

  @override
  Future<List<StudySession>> getUnsyncedSessions() async {
    return _sessions.where((s) => !s.isSynced).toList();
  }

  @override
  Future<void> markAsSynced(String sessionId) async {
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      _sessions[idx] = _sessions[idx].copyWith(isSynced: true);
    }
  }
}

void main() {
  test(
    'StartStudySessionUseCase creates in-progress session with given subject',
    () async {
      final useCase = const StartStudySessionUseCase();
      final session = await useCase.call(
        StartSessionParams(subject: 'Flutter', notes: 'Teste'),
      );

      expect(session.id, isNotEmpty);
      expect(session.subject, 'Flutter');
      expect(session.notes, 'Teste');
      expect(session.endTime, isNull);
      expect(session.isSynced, isFalse);
      expect(session.duration, isNull);
      expect(session.isCompleted, isFalse);
    },
  );

  test(
    'FinishAndSaveSessionLocallyUseCase completes and persists session',
    () async {
      final repo = FakeStudySessionRepository();
      final useCase = FinishAndSaveSessionLocallyUseCase(repo);
      final active = StudySession(
        id: 'test1',
        subject: 'SQL',
        startTime: DateTime.now().subtract(const Duration(minutes: 25)),
        endTime: null,
        isSynced: false,
        notes: 'in progress',
      );

      final completed = await useCase.call(
        FinishSessionParams(activeSession: active, notes: 'finalizado'),
      );

      expect(completed.isCompleted, isTrue);
      expect(completed.endTime, isNotNull);
      expect(completed.isSynced, isFalse);
      expect(completed.notes, 'finalizado');

      final stored = await repo.getAllSessions();
      expect(stored, contains(completed));
    },
  );

  test(
    'GetLocalStudyHistoryUseCase returns ordered sessions from repository',
    () async {
      final repo = FakeStudySessionRepository();
      final useCase = GetLocalStudyHistoryUseCase(repo);

      final s1 = StudySession(
        id: 'a',
        subject: 'A',
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isSynced: true,
      );

      final s2 = StudySession(
        id: 'b',
        subject: 'B',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now().subtract(const Duration(minutes: 30)),
        isSynced: true,
      );

      await repo.saveSession(s1);
      await repo.saveSession(s2);

      final history = await useCase.call(const NoParams());

      expect(history.length, 2);
      expect(history.first.id, 'a');
      expect(history.last.id, 'b');
    },
  );
}
