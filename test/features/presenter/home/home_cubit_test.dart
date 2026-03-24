import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kronos/features/domain/entities/study_session.dart';
import 'package:kronos/features/domain/repositories/study_session_repository.dart';
import 'package:kronos/features/domain/usecases/get_local_study_history_use_case.dart';
import 'package:kronos/features/presenter/home/logic/home_cubit.dart';
import 'package:kronos/features/presenter/home/logic/home_state.dart';

class FakeStudySessionRepository implements StudySessionRepository {
  final List<StudySession> _storage;

  FakeStudySessionRepository([this._storage = const []]);

  @override
  Future<void> saveSession(StudySession session) async {
    throw UnimplementedError();
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
    throw UnimplementedError();
  }
}

class ThrowingStudySessionRepository implements StudySessionRepository {
  @override
  Future<void> saveSession(StudySession session) async {
    throw UnimplementedError();
  }

  @override
  Future<List<StudySession>> getAllSessions() async {
    throw Exception('Falha ao carregar histórico');
  }

  @override
  Future<List<StudySession>> getUnsyncedSessions() async {
    throw Exception('Falha ao carregar histórico');
  }

  @override
  Future<void> markAsSynced(String sessionId) async {
    throw UnimplementedError();
  }
}

void main() {
  group('HomeCubit', () {
    test('initial state is HomeInitial', () {
      final cubit = HomeCubit(
        getLocalHistory: GetLocalStudyHistoryUseCase(
          FakeStudySessionRepository(),
        ),
      );

      expect(cubit.state, isA<HomeInitial>());
      cubit.close();
    });

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeLoaded] when history is loaded',
      build: () {
        final fixedDate = DateTime(2026, 1, 1, 10, 0, 0);
        final sessions = [
          StudySession(
            id: '1',
            subject: 'Flutter',
            startTime: fixedDate.subtract(const Duration(hours: 1)),
            endTime: fixedDate,
            isSynced: true,
            notes: 'Teste',
          ),
          StudySession(
            id: '2',
            subject: 'Dart',
            startTime: fixedDate.subtract(const Duration(hours: 2)),
            endTime: fixedDate.subtract(const Duration(hours: 1, minutes: 30)),
            isSynced: false,
            notes: 'Teste2',
          ),
        ];

        return HomeCubit(
          getLocalHistory: GetLocalStudyHistoryUseCase(
            FakeStudySessionRepository(sessions),
          ),
        );
      },
      act: (cubit) => cubit.loadSummary(),
      expect: () => [isA<HomeLoading>(), isA<HomeLoaded>()],
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<HomeLoaded>());
        final loaded = state as HomeLoaded;
        expect(loaded.totalSessions, 2);
        expect(loaded.totalMinutes, 90);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeError] when history usecase throws',
      build: () => HomeCubit(
        getLocalHistory: GetLocalStudyHistoryUseCase(
          ThrowingStudySessionRepository(),
        ),
      ),
      act: (cubit) => cubit.loadSummary(),
      expect: () => [isA<HomeLoading>(), isA<HomeError>()],
    );
  });
}
