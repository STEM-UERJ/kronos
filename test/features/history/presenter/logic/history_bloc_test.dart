import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kronos/core/contracts/use_case_contract.dart';
import 'package:kronos/features/history/domain/entities/history_entities.dart';
import 'package:kronos/features/history/domain/usecases/history_usecase_contracts.dart';
import 'package:kronos/features/history/presenter/logic/history_bloc.dart';
import 'package:kronos/features/history/presenter/logic/history_event.dart';
import 'package:kronos/features/history/presenter/logic/history_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetHistorySessionsUseCase extends Mock implements GetHistorySessionsUseCase {}
class MockGetHistorySessionDetailsUseCase extends Mock implements GetHistorySessionDetailsUseCase {}
class MockUpdateHistorySessionNotesUseCase extends Mock implements UpdateHistorySessionNotesUseCase {}
class MockDeleteHistorySessionUseCase extends Mock implements DeleteHistorySessionUseCase {}

class FakeGetHistorySessionsParams extends Fake implements GetHistorySessionsParams {}
class FakeSessionDetailsParams extends Fake implements SessionDetailsParams {}
class FakeUpdateSessionNotesParams extends Fake implements UpdateSessionNotesParams {}
class FakeDeleteSessionParams extends Fake implements DeleteSessionParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGetHistorySessionsParams());
    registerFallbackValue(FakeSessionDetailsParams());
    registerFallbackValue(FakeUpdateSessionNotesParams());
    registerFallbackValue(FakeDeleteSessionParams());
  });

  late MockGetHistorySessionsUseCase mockGetSessions;
  late MockGetHistorySessionDetailsUseCase mockGetDetails;
  late MockUpdateHistorySessionNotesUseCase mockUpdateNotes;
  late MockDeleteHistorySessionUseCase mockDeleteSession;

  setUp(() {
    mockGetSessions = MockGetHistorySessionsUseCase();
    mockGetDetails = MockGetHistorySessionDetailsUseCase();
    mockUpdateNotes = MockUpdateHistorySessionNotesUseCase();
    mockDeleteSession = MockDeleteHistorySessionUseCase();
  });

  HistoryBloc buildBloc() => HistoryBloc(
        getHistorySessionsUseCase: mockGetSessions,
        getHistorySessionDetailsUseCase: mockGetDetails,
        updateHistorySessionNotesUseCase: mockUpdateNotes,
        deleteHistorySessionUseCase: mockDeleteSession,
      );

  final dummySession = HistorySession(
    id: '1',
    subject: 'Math',
    startTime: DateTime(2023, 1, 1),
    endTime: DateTime(2023, 1, 1, 1),
    durationInMinutes: 60,
    isSynced: false,
  );

  group('HistoryBloc', () {
    test('initial state is HistoryInitial', () {
      expect(buildBloc().state, isA<HistoryInitial>());
    });

    blocTest<HistoryBloc, HistoryState>(
      'emits [HistoryLoading, HistoryLoaded] when HistoryStarted is added and succeeds',
      build: () {
        when(() => mockGetSessions(any())).thenAnswer((_) async => Success([dummySession]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const HistoryStarted()),
      expect: () => [
        isA<HistoryLoading>(),
        isA<HistoryLoaded>().having((s) => s.sessions, 'sessions', [dummySession]),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'emits [HistoryLoading, HistoryDetailsLoaded] when HistorySessionSelected is added',
      build: () {
        final details = HistorySessionDetails(session: dummySession, notes: 'n');
        when(() => mockGetDetails(any())).thenAnswer((_) async => Success(details));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const HistorySessionSelected('1')),
      expect: () => [
        isA<HistoryLoading>(),
        isA<HistoryDetailsLoaded>().having((s) => s.details.notes, 'notes', 'n'),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'emits [HistoryLoading, HistoryLoaded] after NotesUpdated',
      build: () {
        when(() => mockUpdateNotes(any())).thenAnswer((_) async => const Success(null));
        when(() => mockGetSessions(any())).thenAnswer((_) async => Success([dummySession]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const HistoryNotesUpdated(sessionId: '1', notes: 'new')),
      expect: () => [
        isA<HistoryLoading>(),
        isA<HistoryLoaded>(),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'emits [HistoryLoading, HistoryLoaded] after SessionDeleted',
      build: () {
        when(() => mockDeleteSession(any())).thenAnswer((_) async => const Success(null));
        when(() => mockGetSessions(any())).thenAnswer((_) async => Success([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const HistorySessionDeleted('1')),
      expect: () => [
        isA<HistoryLoading>(),
        isA<HistoryLoaded>().having((s) => s.sessions, 'sessions', isEmpty),
      ],
    );
  });
}
