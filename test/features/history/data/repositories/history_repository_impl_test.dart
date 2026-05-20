import 'package:flutter_test/flutter_test.dart';
import 'package:kronos/core/contracts/use_case_contract.dart';
import 'package:kronos/features/history/data/repositories/history_repository_impl.dart';
import 'package:kronos/features/history/data/source/history_source.dart';
import 'package:kronos/features/history/domain/entities/history_entities.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'history_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<HistorySource>()])
void main() {
  late HistoryRepositoryImpl repository;
  late MockHistorySource mockSource;

  setUp(() {
    mockSource = MockHistorySource();
    repository = HistoryRepositoryImpl(source: mockSource);
  });

  final dummySession = HistorySession(
    id: '1',
    subject: 'Math',
    startTime: DateTime(2023, 1, 1),
    endTime: DateTime(2023, 1, 1, 1),
    durationInMinutes: 60,
    isSynced: false,
  );

  group('getSessions', () {
    test('should return list of sessions on success', () async {
      when(mockSource.getSessions(any)).thenAnswer((_) async => [dummySession]);

      final result = await repository.getSessions(const HistoryQuery(filter: HistoryFilterType.all));

      expect(result, isA<Success<List<HistorySession>>>());
      expect(result.getOrNull(), [dummySession]);
    });

    test('should return failure when source throws', () async {
      when(mockSource.getSessions(any)).thenThrow(Exception('DB Error'));

      final result = await repository.getSessions(const HistoryQuery(filter: HistoryFilterType.all));

      expect(result, isA<Failure<List<HistorySession>>>());
    });
  });

  group('getSessionDetails', () {
    test('should return session details on success', () async {
      final details = HistorySessionDetails(session: dummySession, notes: 'Some notes');
      when(mockSource.getSessionDetails(any)).thenAnswer((_) async => details);

      final result = await repository.getSessionDetails('1');

      expect(result, isA<Success<HistorySessionDetails>>());
      expect(result.getOrNull(), details);
    });

    test('should return failure when source throws', () async {
      when(mockSource.getSessionDetails(any)).thenThrow(Exception('DB Error'));

      final result = await repository.getSessionDetails('1');

      expect(result, isA<Failure<HistorySessionDetails>>());
    });
  });

  group('updateSessionNotes', () {
    test('should return success when updating notes', () async {
      when(mockSource.updateSessionNotes(sessionId: anyNamed('sessionId'), notes: anyNamed('notes')))
          .thenAnswer((_) async {});

      final result = await repository.updateSessionNotes(sessionId: '1', notes: 'notes');

      expect(result, isA<Success<void>>());
      verify(mockSource.updateSessionNotes(sessionId: '1', notes: 'notes')).called(1);
    });

    test('should return failure when source throws', () async {
      when(mockSource.updateSessionNotes(sessionId: anyNamed('sessionId'), notes: anyNamed('notes')))
          .thenThrow(Exception('DB Error'));

      final result = await repository.updateSessionNotes(sessionId: '1', notes: 'notes');

      expect(result, isA<Failure<void>>());
    });
  });

  group('deleteSession', () {
    test('should return success when deleting session', () async {
      when(mockSource.deleteSession(any)).thenAnswer((_) async {});

      final result = await repository.deleteSession('1');

      expect(result, isA<Success<void>>());
      verify(mockSource.deleteSession('1')).called(1);
    });

    test('should return failure when source throws', () async {
      when(mockSource.deleteSession(any)).thenThrow(Exception('DB Error'));

      final result = await repository.deleteSession('1');

      expect(result, isA<Failure<void>>());
    });
  });
}
