import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:kronos/features/history/data/repositories/history_repository_impl.dart';
import 'package:kronos/features/history/data/source/history_source.dart';
import 'package:kronos/features/history/domain/entities/history_entities.dart';

import 'history_repository_contract_test.mocks.dart';

@GenerateNiceMocks([MockSpec<HistorySource>()])
void main() {
  setUpAll(() {
    final session = HistorySession(
      id: 'dummy-id',
      subject: 'dummy-subject',
      startTime: DateTime(2026, 1, 1, 0, 0),
      endTime: DateTime(2026, 1, 1, 0, 30),
      durationInMinutes: 30,
      isSynced: true,
    );

    provideDummy(HistorySessionDetails(session: session, notes: 'dummy'));
  });

  group('HistoryRepositoryImpl', () {
    late MockHistorySource source;
    late HistoryRepositoryImpl repository;

    final query = const HistoryQuery(filter: HistoryFilterType.all);
    final session = HistorySession(
      id: 'h1',
      subject: 'Fisica',
      startTime: DateTime(2026, 4, 1, 10, 0),
      endTime: DateTime(2026, 4, 1, 10, 30),
      durationInMinutes: 30,
      isSynced: true,
    );

    setUp(() {
      source = MockHistorySource();
      repository = HistoryRepositoryImpl(source: source);
    });

    test('getSessions retorna lista no caso de sucesso', () async {
      when(source.getSessions(query)).thenAnswer((_) async => [session]);

      final result = await repository.getSessions(query);

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull()!.length, 1);
      expect(result.getOrNull()!.first.id, 'h1');
      expect(result.getOrNull()!.first.subject, 'Fisica');
      verify(source.getSessions(query)).called(1);
    });

    test('getSessions propaga erro no caso de falha', () async {
      when(source.getSessions(query)).thenAnswer(
        (_) => Future<List<HistorySession>>.error(Exception('sessions-failed')),
      );

      final result = await repository.getSessions(query);

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<Exception>());
      verify(source.getSessions(query)).called(1);
    });

    test('getSessionDetails retorna detalhes no caso de sucesso', () async {
      final details = HistorySessionDetails(
        session: session,
        notes: 'Boa sessao',
      );
      when(source.getSessionDetails('h1')).thenAnswer((_) async => details);

      final result = await repository.getSessionDetails('h1');

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull()!.session.subject, 'Fisica');
      expect(result.getOrNull()!.notes, 'Boa sessao');
      verify(source.getSessionDetails('h1')).called(1);
    });

    test('getSessionDetails propaga erro no caso de falha', () async {
      when(source.getSessionDetails('h1')).thenAnswer(
        (_) => Future<HistorySessionDetails>.error(Exception('details-failed')),
      );

      final result = await repository.getSessionDetails('h1');

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<Exception>());
      verify(source.getSessionDetails('h1')).called(1);
    });

    test('updateSessionNotes executa no caso de sucesso', () async {
      when(
        source.updateSessionNotes(sessionId: 'h1', notes: 'Atualizado'),
      ).thenAnswer((_) async {});

      final result = await repository.updateSessionNotes(sessionId: 'h1', notes: 'Atualizado');

      expect(result.isSuccess(), isTrue);
      verify(
        source.updateSessionNotes(sessionId: 'h1', notes: 'Atualizado'),
      ).called(1);
    });

    test('updateSessionNotes propaga erro no caso de falha', () async {
      when(
        source.updateSessionNotes(sessionId: 'h1', notes: 'Atualizado'),
      ).thenAnswer((_) => Future<void>.error(Exception('update-failed')));

      final result = await repository.updateSessionNotes(sessionId: 'h1', notes: 'Atualizado');

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<Exception>());
      verify(
        source.updateSessionNotes(sessionId: 'h1', notes: 'Atualizado'),
      ).called(1);
    });

    test('deleteSession executa no caso de sucesso', () async {
      when(source.deleteSession('h1')).thenAnswer((_) async {});

      final result = await repository.deleteSession('h1');

      expect(result.isSuccess(), isTrue);
      verify(source.deleteSession('h1')).called(1);
    });

    test('deleteSession propaga erro no caso de falha', () async {
      when(
        source.deleteSession('h1'),
      ).thenAnswer((_) => Future<void>.error(Exception('delete-failed')));

      final result = await repository.deleteSession('h1');

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<Exception>());
      verify(source.deleteSession('h1')).called(1);
    });
  });
}
