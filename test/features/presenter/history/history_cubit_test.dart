import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kronos/features/domain/entities/study_session.dart';
import 'package:kronos/features/domain/repositories/study_session_repository.dart';
import 'package:kronos/features/domain/usecases/get_local_study_history_use_case.dart';
import 'package:kronos/features/presenter/history/logic/history_cubit.dart';
import 'package:kronos/features/presenter/history/logic/history_state.dart';
import 'package:mocktail/mocktail.dart';

class MockStudySessionRepository extends Mock implements StudySessionRepository {}

void main() {
  group('HistoryCubit', () {
    late HistoryCubit historyCubit;
    late GetLocalStudyHistoryUseCase getLocalStudyHistoryUseCase;
    late MockStudySessionRepository mockStudySessionRepository;

    setUp(() {
      mockStudySessionRepository = MockStudySessionRepository();
      getLocalStudyHistoryUseCase =
          GetLocalStudyHistoryUseCase(mockStudySessionRepository);
      historyCubit = HistoryCubit(getHistoryUseCase: getLocalStudyHistoryUseCase);
    });

    tearDown(() {
      historyCubit.close();
    });

    test('initial state is HistoryInitial', () {
      expect(historyCubit.state, isA<HistoryInitial>());
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
        when(() => mockStudySessionRepository.getAllSessions())
            .thenAnswer((_) async => stored);
        return historyCubit;
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [isA<HistoryLoading>(), isA<HistoryLoaded>()],
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<HistoryLoaded>());
        final sessions = (state as HistoryLoaded).sessions;
        expect(sessions, hasLength(1));
        expect(sessions.first.subject, 'Flutter');
        verify(() => mockStudySessionRepository.getAllSessions()).called(1);
      },
    );

    blocTest<HistoryCubit, HistoryState>(
      'emits [HistoryLoading, HistoryError] when usecase throws',
      build: () {
        when(() => mockStudySessionRepository.getAllSessions())
            .thenThrow(Exception('Database error'));
        return historyCubit;
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [isA<HistoryLoading>(), isA<HistoryError>()],
      verify: (cubit) {
        verify(() => mockStudySessionRepository.getAllSessions()).called(1);
      },
    );
  });
}
