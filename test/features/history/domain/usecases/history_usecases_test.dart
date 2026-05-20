import 'package:flutter_test/flutter_test.dart';
import 'package:kronos/core/contracts/use_case_contract.dart';
import 'package:kronos/features/history/domain/entities/history_entities.dart';
import 'package:kronos/features/history/domain/repositories/history_repository.dart';
import 'package:kronos/features/history/domain/usecases/history_usecase_contracts.dart';
import 'package:kronos/features/history/domain/usecases/history_usecases.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'history_usecases_test.mocks.dart';

@GenerateNiceMocks([MockSpec<HistoryRepository>()])
void main() {
  late MockHistoryRepository mockRepository;

  setUp(() {
    mockRepository = MockHistoryRepository();
  });

  final dummySession = HistorySession(
    id: '1',
    subject: 'Math',
    startTime: DateTime(2023, 1, 1),
    endTime: DateTime(2023, 1, 1, 1),
    durationInMinutes: 60,
    isSynced: false,
  );

  group('GetHistorySessionsUseCaseImpl', () {
    late GetHistorySessionsUseCaseImpl usecase;

    setUp(() {
      usecase = GetHistorySessionsUseCaseImpl(repository: mockRepository);
    });

    test('should delegate to repository', () async {
      when(mockRepository.getSessions(any))
          .thenAnswer((_) async => Success([dummySession]));

      final result = await usecase(const GetHistorySessionsParams(query: HistoryQuery(filter: HistoryFilterType.all)));

      expect(result.getOrNull(), [dummySession]);
      verify(mockRepository.getSessions(any)).called(1);
    });
  });

  group('GetHistorySessionDetailsUseCaseImpl', () {
    late GetHistorySessionDetailsUseCaseImpl usecase;

    setUp(() {
      usecase = GetHistorySessionDetailsUseCaseImpl(repository: mockRepository);
    });

    test('should delegate to repository', () async {
      final details = HistorySessionDetails(session: dummySession, notes: 'n');
      when(mockRepository.getSessionDetails(any))
          .thenAnswer((_) async => Success(details));

      final result = await usecase(const SessionDetailsParams(sessionId: '1'));

      expect(result.getOrNull(), details);
      verify(mockRepository.getSessionDetails('1')).called(1);
    });
  });

  group('UpdateHistorySessionNotesUseCaseImpl', () {
    late UpdateHistorySessionNotesUseCaseImpl usecase;

    setUp(() {
      usecase = UpdateHistorySessionNotesUseCaseImpl(repository: mockRepository);
    });

    test('should delegate to repository', () async {
      when(mockRepository.updateSessionNotes(sessionId: anyNamed('sessionId'), notes: anyNamed('notes')))
          .thenAnswer((_) async => const Success(null));

      await usecase(const UpdateSessionNotesParams(sessionId: '1', notes: 'n'));

      verify(mockRepository.updateSessionNotes(sessionId: '1', notes: 'n')).called(1);
    });
  });

  group('DeleteHistorySessionUseCaseImpl', () {
    late DeleteHistorySessionUseCaseImpl usecase;

    setUp(() {
      usecase = DeleteHistorySessionUseCaseImpl(repository: mockRepository);
    });

    test('should delegate to repository', () async {
      when(mockRepository.deleteSession(any))
          .thenAnswer((_) async => const Success(null));

      await usecase(const DeleteSessionParams(sessionId: '1'));

      verify(mockRepository.deleteSession('1')).called(1);
    });
  });
}
