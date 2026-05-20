import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import 'package:kronos/core/contracts/use_case_contract.dart';
import 'package:kronos/features/timer/domain/entities/timer_entities.dart';
import 'package:kronos/features/timer/domain/errors/timer_domain_error.dart';
import 'package:kronos/features/timer/domain/usecases/timer_usecase_contracts.dart';
import 'package:kronos/features/timer/presenter/logic/timer_bloc.dart';
import 'package:kronos/features/timer/presenter/logic/timer_event.dart';
import 'package:kronos/features/timer/presenter/logic/timer_state.dart';

class MockStartTimerSessionUseCase extends Mock
    implements StartTimerSessionUseCase {}

class MockPauseTimerSessionUseCase extends Mock
    implements PauseTimerSessionUseCase {}

class MockResumeTimerSessionUseCase extends Mock
    implements ResumeTimerSessionUseCase {}

class MockTickTimerSessionUseCase extends Mock
    implements TickTimerSessionUseCase {}

class MockFinishTimerSessionUseCase extends Mock
    implements FinishTimerSessionUseCase {}

class MockGetLastTimerSessionUseCase extends Mock
    implements GetLastTimerSessionUseCase {}

void main() {
  late MockStartTimerSessionUseCase startTimerSessionUseCase;
  late MockPauseTimerSessionUseCase pauseTimerSessionUseCase;
  late MockResumeTimerSessionUseCase resumeTimerSessionUseCase;
  late MockTickTimerSessionUseCase tickTimerSessionUseCase;
  late MockFinishTimerSessionUseCase finishTimerSessionUseCase;
  late MockGetLastTimerSessionUseCase getLastTimerSessionUseCase;

  TimerBloc buildBloc() {
    return TimerBloc(
      startTimerSessionUseCase: startTimerSessionUseCase,
      pauseTimerSessionUseCase: pauseTimerSessionUseCase,
      resumeTimerSessionUseCase: resumeTimerSessionUseCase,
      tickTimerSessionUseCase: tickTimerSessionUseCase,
      finishTimerSessionUseCase: finishTimerSessionUseCase,
      getLastTimerSessionUseCase: getLastTimerSessionUseCase,
    );
  }

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const StartTimerSessionParams(subject: 'Test'));
    registerFallbackValue(const SessionIdParams(sessionId: '1'));
    registerFallbackValue(
      const TickTimerSessionParams(sessionId: '1', elapsedSeconds: 1),
    );
    registerFallbackValue(const FinishTimerSessionParams(sessionId: '1'));
  });

  setUp(() {
    startTimerSessionUseCase = MockStartTimerSessionUseCase();
    pauseTimerSessionUseCase = MockPauseTimerSessionUseCase();
    resumeTimerSessionUseCase = MockResumeTimerSessionUseCase();
    tickTimerSessionUseCase = MockTickTimerSessionUseCase();
    finishTimerSessionUseCase = MockFinishTimerSessionUseCase();
    getLastTimerSessionUseCase = MockGetLastTimerSessionUseCase();
  });

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

  group('TimerBloc', () {
    test('estado inicial e TimerInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, isA<TimerInitial>());
      bloc.close();
    });

    blocTest<TimerBloc, TimerState>(
      'TimerStarted emite [TimerInitial, TimerIdle] com summary quando há sessão anterior',
      build: () {
        when(
          () => getLastTimerSessionUseCase(any()),
        ).thenAnswer((_) async => const Success(dummySummary));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TimerStarted()),
      expect: () => <Matcher>[
        isA<TimerInitial>(),
        isA<TimerIdle>().having(
          (s) => s.lastSession,
          'lastSession',
          dummySummary,
        ),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'TimerStarted emite [TimerInitial, TimerIdle] sem summary quando falha/nulo no banco',
      build: () {
        when(
          () => getLastTimerSessionUseCase(any()),
        ).thenAnswer((_) async => Failure(TimerLoadError()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TimerStarted()),
      expect: () => <Matcher>[
        isA<TimerInitial>(),
        isA<TimerIdle>().having((s) => s.lastSession, 'lastSession', isNull),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'TimerPlayRequested emite TimerRunning quando start tem sucesso',
      build: () {
        when(
          () => startTimerSessionUseCase(any()),
        ).thenAnswer((_) async => const Success(dummySession));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TimerPlayRequested(subject: 'Flutter')),
      expect: () => <Matcher>[
        isA<TimerRunning>().having(
          (s) => s.session.subject,
          'subject',
          'Flutter',
        ),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'TimerPlayRequested emite TimerFailure quando falha ao iniciar',
      build: () {
        when(() => startTimerSessionUseCase(any())).thenAnswer(
          (_) async => Failure(TimerStartError(cause: Exception('Erro'))),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TimerPlayRequested(subject: 'Flutter')),
      expect: () => <Matcher>[isA<TimerFailure>()],
    );

    blocTest<TimerBloc, TimerState>(
      'TimerPauseRequested emite TimerPaused se o estado atual for TimerRunning',
      build: () {
        when(
          () => tickTimerSessionUseCase(any()),
        ).thenAnswer((_) async => const Success(dummySession));
        when(
          () => pauseTimerSessionUseCase(any()),
        ).thenAnswer((_) async => const Success(dummySession));
        return buildBloc();
      },
      seed: () => const TimerRunning(session: dummySession),
      act: (bloc) => bloc.add(const TimerPauseRequested(elapsedSeconds: 10)),
      expect: () => <Matcher>[isA<TimerPaused>()],
    );

    blocTest<TimerBloc, TimerState>(
      'TimerResumeRequested emite TimerRunning se o estado atual for TimerPaused',
      build: () {
        when(
          () => resumeTimerSessionUseCase(any()),
        ).thenAnswer((_) async => const Success(dummySession));
        return buildBloc();
      },
      seed: () => const TimerPaused(session: dummySession),
      act: (bloc) => bloc.add(const TimerResumeRequested()),
      expect: () => <Matcher>[isA<TimerRunning>()],
    );

    blocTest<TimerBloc, TimerState>(
      'TimerFinishRequested emite TimerFinished e chama o usecase',
      build: () {
        when(
          () => tickTimerSessionUseCase(any()),
        ).thenAnswer((_) async => const Success(dummySession));
        when(
          () => finishTimerSessionUseCase(any()),
        ).thenAnswer((_) async => const Success(dummySummary));
        return buildBloc();
      },
      seed: () => const TimerRunning(session: dummySession),
      act: (bloc) => bloc.add(const TimerFinishRequested(elapsedSeconds: 10)),
      expect: () => <Matcher>[
        isA<TimerFinished>().having((s) => s.summary, 'summary', dummySummary),
      ],
      verify: (_) {
        verify(
          () => finishTimerSessionUseCase(
            any(that: isA<FinishTimerSessionParams>()),
          ),
        ).called(1);
      },
    );

    blocTest<TimerBloc, TimerState>(
      'TimerPauseRequested emite TimerFailure se falhar ao pausar',
      build: () {
        when(
          () => tickTimerSessionUseCase(any()),
        ).thenAnswer((_) async => const Success(dummySession));
        when(() => pauseTimerSessionUseCase(any())).thenAnswer(
          (_) async => Failure(TimerPauseError(cause: Exception('Erro'))),
        );
        return buildBloc();
      },
      seed: () => const TimerRunning(session: dummySession),
      act: (bloc) => bloc.add(const TimerPauseRequested(elapsedSeconds: 10)),
      expect: () => <Matcher>[isA<TimerFailure>()],
    );

    blocTest<TimerBloc, TimerState>(
      'TimerResumeRequested emite TimerFailure se falhar ao retomar',
      build: () {
        when(() => resumeTimerSessionUseCase(any())).thenAnswer(
          (_) async => Failure(TimerResumeError(cause: Exception('Erro'))),
        );
        return buildBloc();
      },
      seed: () => const TimerPaused(session: dummySession),
      act: (bloc) => bloc.add(const TimerResumeRequested()),
      expect: () => <Matcher>[isA<TimerFailure>()],
    );

    blocTest<TimerBloc, TimerState>(
      'TimerFinishRequested a partir de TimerPaused emite TimerFinished e chama usecase',
      build: () {
        when(
          () => tickTimerSessionUseCase(any()),
        ).thenAnswer((_) async => const Success(dummySession));
        when(
          () => finishTimerSessionUseCase(any()),
        ).thenAnswer((_) async => const Success(dummySummary));
        return buildBloc();
      },
      seed: () => const TimerPaused(session: dummySession),
      act: (bloc) => bloc.add(
        const TimerFinishRequested(elapsedSeconds: 10, notes: 'notas'),
      ),
      expect: () => <Matcher>[
        isA<TimerFinished>().having((s) => s.summary, 'summary', dummySummary),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'TimerFinishRequested emite TimerFailure se falhar ao finalizar',
      build: () {
        when(
          () => tickTimerSessionUseCase(any()),
        ).thenAnswer((_) async => const Success(dummySession));
        when(() => finishTimerSessionUseCase(any())).thenAnswer(
          (_) async => Failure(TimerFinishError(cause: Exception('Erro'))),
        );
        return buildBloc();
      },
      seed: () => const TimerRunning(session: dummySession),
      act: (bloc) => bloc.add(const TimerFinishRequested(elapsedSeconds: 10)),
      expect: () => <Matcher>[isA<TimerFailure>()],
    );
  });
}
