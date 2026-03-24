import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kronos/features/domain/entities/study_session.dart';
import 'package:kronos/features/domain/repositories/study_session_repository.dart';
import 'package:kronos/features/domain/usecases/finish_and_save_session_locally_use_case.dart';
import 'package:kronos/features/domain/usecases/start_study_session_use_case.dart';
import 'package:kronos/features/presenter/timer/logic/timer_cubit.dart';
import 'package:kronos/features/presenter/timer/logic/timer_state.dart';

class FakeStudySessionRepository implements StudySessionRepository {
  final List<StudySession> _storage = [];

  @override
  Future<void> saveSession(StudySession session) async {
    _storage.removeWhere((s) => s.id == session.id);
    _storage.add(session);
  }

  @override
  Future<List<StudySession>> getAllSessions() async {
    return List.unmodifiable(_storage);
  }

  @override
  Future<List<StudySession>> getUnsyncedSessions() async {
    return _storage.where((s) => !s.isSynced).toList();
  }

  @override
  Future<void> markAsSynced(String sessionId) async {
    final idx = _storage.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      _storage[idx] = _storage[idx].copyWith(isSynced: true);
    }
  }
}

void main() {
  group('TimerCubit', () {
    late StartStudySessionUseCase startUseCase;
    late FinishAndSaveSessionLocallyUseCase finishUseCase;
    late FakeStudySessionRepository repo;

    setUp(() {
      repo = FakeStudySessionRepository();
      startUseCase = const StartStudySessionUseCase();
      finishUseCase = FinishAndSaveSessionLocallyUseCase(repo);
    });

    test('initial state is TimerInitial', () {
      final cubit = TimerCubit(
        startSessionUseCase: startUseCase,
        finishSessionUseCase: finishUseCase,
      );

      expect(cubit.state, isA<TimerInitial>());
      cubit.close();
    });

    blocTest<TimerCubit, TimerState>(
      'should emit [TimerRunning] when startTimer is called',
      build: () => TimerCubit(
        startSessionUseCase: startUseCase,
        finishSessionUseCase: finishUseCase,
      ),
      act: (cubit) => cubit.startTimer('Flutter'),
      wait: const Duration(milliseconds: 5),
      expect: () => [isA<TimerRunning>()],
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<TimerRunning>());
        if (state is TimerRunning) {
          expect(state.subject, 'Flutter');
          expect(state.secondsElapsed, greaterThanOrEqualTo(0));
        }
      },
    );

    // future test cases for TimerCubit actions (pause/resume/finish) should be added here
    // after collaborators implement the full behavior in TimerCubit.
  });
}
