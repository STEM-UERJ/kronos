import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:kronos/features/timer/data/repositories/timer_repository_impl.dart';
import 'package:kronos/features/timer/data/source/timer_source.dart';
import 'package:kronos/features/timer/domain/entities/timer_entities.dart';

import 'timer_repository_contract_test.mocks.dart';

@GenerateNiceMocks([MockSpec<TimerSource>()])
void main() {
  setUpAll(() {
    provideDummy(
      const TimerSession(
        id: 'dummy-id',
        subject: 'dummy-subject',
        elapsedSeconds: 0,
        status: TimerSessionStatus.idle,
      ),
    );
    provideDummy(
      const TimerSessionSummary(
        id: 'dummy-id',
        subject: 'dummy-subject',
        totalSeconds: 0,
      ),
    );
  });

  group('TimerRepositoryImpl', () {
    late MockTimerSource source;
    late TimerRepositoryImpl repository;

    const runningSession = TimerSession(
      id: 'session-1',
      subject: 'Matematica',
      elapsedSeconds: 120,
      status: TimerSessionStatus.running,
      notes: 'Foco',
    );

    const summary = TimerSessionSummary(
      id: 'session-1',
      subject: 'Matematica',
      totalSeconds: 1800,
      notes: 'Concluida',
    );

    setUp(() {
      source = MockTimerSource();
      repository = TimerRepositoryImpl(source: source);
    });

    test('startSession retorna sessao no caso de sucesso', () async {
      when(
        source.startSession(subject: 'Matematica', notes: 'Foco'),
      ).thenAnswer((_) async => runningSession);

      final result = await repository.startSession(
        subject: 'Matematica',
        notes: 'Foco',
      );

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull()!.id, 'session-1');
      expect(result.getOrNull()!.status, TimerSessionStatus.running);
      verify(
        source.startSession(subject: 'Matematica', notes: 'Foco'),
      ).called(1);
    });

    test('startSession propaga erro no caso de falha', () async {
      when(
        source.startSession(subject: 'Matematica', notes: 'Foco'),
      ).thenAnswer(
        (_) => Future<TimerSession>.error(Exception('start-failed')),
      );

      final result = await repository.startSession(subject: 'Matematica', notes: 'Foco');

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<Exception>());
      verify(
        source.startSession(subject: 'Matematica', notes: 'Foco'),
      ).called(1);
    });

    test('finishSession retorna resumo no caso de sucesso', () async {
      when(
        source.finishSession(sessionId: 'session-1', notes: 'Concluida'),
      ).thenAnswer((_) async => summary);

      final result = await repository.finishSession(
        sessionId: 'session-1',
        notes: 'Concluida',
      );

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull()!.totalSeconds, 1800);
      expect(result.getOrNull()!.subject, 'Matematica');
      verify(
        source.finishSession(sessionId: 'session-1', notes: 'Concluida'),
      ).called(1);
    });

    test('finishSession propaga erro no caso de falha', () async {
      when(
        source.finishSession(sessionId: 'session-1', notes: 'Concluida'),
      ).thenAnswer(
        (_) => Future<TimerSessionSummary>.error(Exception('finish-failed')),
      );

      final result = await repository.finishSession(sessionId: 'session-1', notes: 'Concluida');

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<Exception>());
      verify(
        source.finishSession(sessionId: 'session-1', notes: 'Concluida'),
      ).called(1);
    });

    test('getLastSession retorna resumo no caso de sucesso', () async {
      when(source.getLastSession()).thenAnswer((_) async => summary);

      final result = await repository.getLastSession();

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull()?.id, 'session-1');
      expect(result.getOrNull()?.totalSeconds, 1800);
      verify(source.getLastSession()).called(1);
    });

    test('getLastSession propaga erro no caso de falha', () async {
      when(source.getLastSession()).thenAnswer(
        (_) => Future<TimerSessionSummary?>.error(Exception('last-failed')),
      );

      final result = await repository.getLastSession();

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<Exception>());
      verify(source.getLastSession()).called(1);
    });
  });
}
