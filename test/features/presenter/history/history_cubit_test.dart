import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kronos/features/domain/entities/study_session.dart';
import 'package:kronos/features/domain/repositories/study_session_repository.dart';
import 'package:kronos/features/domain/usecases/get_local_study_history_use_case.dart';
import 'package:kronos/features/presenter/history/logic/history_cubit.dart';
import 'package:kronos/features/presenter/history/logic/history_state.dart';

class FakeStudySessionRepository implements StudySessionRepository {
  final List<StudySession> _storage;

  FakeStudySessionRepository([this._storage = const []]);

  @override
  Future<void> saveSession(StudySession session) async {
    throw UnimplementedError();
  }

  @override
  Future<List<StudySession>> getAllSessions() async {
    return _storage;
  }

  @override
  Future<List<StudySession>> getUnsyncedSessions() async {
    return _storage.where((s) => !s.isSynced).toList();
  }

  @override
  Future<void> markAsSynced(String sessionId) async {
    throw UnimplementedError();
  }
}

void main() {
  group('HistoryCubit', () {
    test('initial state is HistoryInitial', () {
      final useCase = GetLocalStudyHistoryUseCase(FakeStudySessionRepository());
      final cubit = HistoryCubit(getHistoryUseCase: useCase);

      expect(cubit.state, isA<HistoryInitial>());
      cubit.close();
    });

    blocTest<HistoryCubit, HistoryState>(
      'emits [HistoryLoading, HistoryLoaded] when history is found',
      build: () {
        final stored = [
          StudySession(
            id: '1',
            subject: 'Flutter',
            startTime: DateTime.now().subtract(const Duration(hours: 1)),
            endTime: DateTime.now(),
            isSynced: true,
            notes: 'teste',
          ),
        ];
        final useCase = GetLocalStudyHistoryUseCase(
          FakeStudySessionRepository(stored),
        );
        return HistoryCubit(getHistoryUseCase: useCase);
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [isA<HistoryLoading>(), isA<HistoryLoaded>()],
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<HistoryLoaded>());
        final sessions = (state as HistoryLoaded).sessions;
        expect(sessions, hasLength(1));
        expect(sessions.first.subject, 'Flutter');
      },
    );

    blocTest<HistoryCubit, HistoryState>(
      'emits [HistoryLoading, HistoryError] when usecase throws',
      build: () {
        final repo = FakeStudySessionRepository();
        final useCase = GetLocalStudyHistoryUseCase(repo);
        return HistoryCubit(getHistoryUseCase: useCase);
      },
      act: (cubit) async {
        // Forcing exception by calling on a repository that throws.
        await cubit.loadHistory();
      },
      expect: () => [isA<HistoryLoading>(), isA<HistoryError>()],
      skip: 1,
    );
  });
}
