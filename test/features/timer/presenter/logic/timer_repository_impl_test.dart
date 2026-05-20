import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:result_dart/result_dart.dart';

import 'package:kronos/features/timer/data/repositories/timer_repository_impl.dart';
import 'package:kronos/features/timer/data/source/timer_source.dart';
import 'package:kronos/features/timer/domain/entities/timer_entities.dart';
import 'package:kronos/features/timer/domain/errors/timer_domain_error.dart';

import 'timer_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<TimerSource>()])
void main() {
  const dummySession = TimerSession(
    id: '1',
    subject: 'Flutter',
    elapsedSeconds: 0,
    status: TimerSessionStatus.running,
    isSynced: false,
  );

  const dummySummary = TimerSessionSummary(
    id: '1',
    subject: 'Flutter',
    totalSeconds: 60,
  );

  setUpAll(() {
    provideDummy<TimerSession>(dummySession);
    provideDummy<TimerSessionSummary>(dummySummary);
  });

  late MockTimerSource mockSource;
  late TimerRepositoryImpl repository;

  setUp(() {
    mockSource = MockTimerSource();
    repository = TimerRepositoryImpl(source: mockSource);
  });

  group('TimerRepositoryImpl', () {
    test(
      'startSession deve retornar Success(TimerSession) quando o source for bem-sucedido',
      () async {
        when(
          mockSource.startSession(subject: 'Flutter', notes: null),
        ).thenAnswer((_) async => dummySession);

        final result = await repository.startSession(subject: 'Flutter');

        expect(result.isSuccess(), isTrue);
        expect(result.getOrNull(), dummySession);
        verify(
          mockSource.startSession(subject: 'Flutter', notes: null),
        ).called(1);
      },
    );

    test(
      'startSession deve retornar Failure(TimerStartError) quando o source lançar exceção',
      () async {
        when(
          mockSource.startSession(subject: 'Flutter', notes: null),
        ).thenThrow(Exception('DB Error'));

        final result = await repository.startSession(subject: 'Flutter');

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<TimerStartError>());
      },
    );

    test('pauseSession deve retornar Success e chamar o source', () async {
      when(mockSource.pauseSession('1')).thenAnswer((_) async => dummySession);

      final result = await repository.pauseSession('1');

      expect(result.isSuccess(), isTrue);
      verify(mockSource.pauseSession('1')).called(1);
    });

    test(
      'pauseSession deve retornar Failure(TimerPauseError) quando lançar exceção',
      () async {
        when(mockSource.pauseSession('1')).thenThrow(Exception('DB Error'));

        final result = await repository.pauseSession('1');

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<TimerPauseError>());
      },
    );

    test('resumeSession deve retornar Success e chamar o source', () async {
      when(mockSource.resumeSession('1')).thenAnswer((_) async => dummySession);

      final result = await repository.resumeSession('1');

      expect(result.isSuccess(), isTrue);
      verify(mockSource.resumeSession('1')).called(1);
    });

    test(
      'resumeSession deve retornar Failure(TimerResumeError) quando lançar exceção',
      () async {
        when(mockSource.resumeSession('1')).thenThrow(Exception('DB Error'));

        final result = await repository.resumeSession('1');

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<TimerResumeError>());
      },
    );

    test('tickSession deve retornar Success e chamar o source', () async {
      when(
        mockSource.tickSession(sessionId: '1', elapsedSeconds: 10),
      ).thenAnswer((_) async => dummySession);

      final result = await repository.tickSession(
        sessionId: '1',
        elapsedSeconds: 10,
      );

      expect(result.isSuccess(), isTrue);
      verify(
        mockSource.tickSession(sessionId: '1', elapsedSeconds: 10),
      ).called(1);
    });

    test(
      'tickSession deve retornar Failure(TimerTickError) quando lançar exceção',
      () async {
        when(
          mockSource.tickSession(sessionId: '1', elapsedSeconds: 10),
        ).thenThrow(Exception('DB Error'));

        final result = await repository.tickSession(
          sessionId: '1',
          elapsedSeconds: 10,
        );

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<TimerTickError>());
      },
    );

    test('finishSession deve retornar Success(TimerSessionSummary)', () async {
      when(
        mockSource.finishSession(sessionId: '1', notes: 'notas'),
      ).thenAnswer((_) async => dummySummary);

      final result = await repository.finishSession(
        sessionId: '1',
        notes: 'notas',
      );

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull(), dummySummary);
    });

    test(
      'finishSession deve retornar Failure(TimerFinishError) quando lançar exceção',
      () async {
        when(
          mockSource.finishSession(sessionId: '1', notes: null),
        ).thenThrow(Exception('DB Error'));

        final result = await repository.finishSession(sessionId: '1');

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<TimerFinishError>());
      },
    );

    test(
      'getLastSession deve retornar Success(TimerSessionSummary) se a sessão existir',
      () async {
        when(mockSource.getLastSession()).thenAnswer((_) async => dummySummary);

        final result = await repository.getLastSession();

        expect(result.isSuccess(), isTrue);
        expect(result.getOrNull(), dummySummary);
      },
    );

    test(
      'getLastSession deve retornar Failure(TimerLoadError) se o banco retornar null',
      () async {
        when(mockSource.getLastSession()).thenAnswer((_) async => null);

        final result = await repository.getLastSession();

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<TimerLoadError>());
        final error = result.exceptionOrNull() as TimerLoadError?;
        expect(error?.cause.toString(), contains('No last session found'));
      },
    );

    test(
      'getLastSession deve retornar Failure(TimerLoadError) quando houver exceção',
      () async {
        when(mockSource.getLastSession()).thenThrow(Exception('DB Error'));

        final result = await repository.getLastSession();

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<TimerLoadError>());
      },
    );
  });
}
