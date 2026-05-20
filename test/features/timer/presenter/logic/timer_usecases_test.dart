import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:result_dart/result_dart.dart';

import 'package:kronos/core/contracts/use_case_contract.dart';
import 'package:kronos/features/timer/domain/entities/timer_entities.dart';
import 'package:kronos/features/timer/domain/repositories/timer_repository.dart';
import 'package:kronos/features/timer/domain/usecases/timer_usecase_contracts.dart';
import 'package:kronos/features/timer/domain/usecases/timer_usecases.dart';
import 'package:kronos/features/timer/domain/errors/timer_domain_error.dart';

import 'timer_usecases_test.mocks.dart';

@GenerateNiceMocks([MockSpec<TimerRepository>()])
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
    provideDummy<Result<TimerSession>>(const Success(dummySession));
    provideDummy<Result<TimerSessionSummary>>(
      const Success(dummySummary),
    );
  });

  late MockTimerRepository mockRepository;

  setUp(() {
    mockRepository = MockTimerRepository();
  });

  group('TimerUseCases', () {
    test(
      'StartTimerSessionUseCase deve repassar parâmetros ao repositório e retornar a sessão',
      () async {
        final usecase = StartTimerSessionUseCaseImpl(
          repository: mockRepository,
        );
        when(
          mockRepository.startSession(subject: 'Flutter', notes: 'Teste'),
        ).thenAnswer((_) async => const Success(dummySession));

        final result = await usecase(
          const StartTimerSessionParams(subject: 'Flutter', notes: 'Teste'),
        );

        expect(result.isSuccess(), isTrue);
        verify(
          mockRepository.startSession(subject: 'Flutter', notes: 'Teste'),
        ).called(1);
      },
    );

    test('PauseTimerSessionUseCase deve pausar via repositório', () async {
      final usecase = PauseTimerSessionUseCaseImpl(repository: mockRepository);
      when(
        mockRepository.pauseSession('1'),
      ).thenAnswer((_) async => const Success(dummySession));

      final result = await usecase(const SessionIdParams(sessionId: '1'));

      expect(result.isSuccess(), isTrue);
      verify(mockRepository.pauseSession('1')).called(1);
    });

    test('ResumeTimerSessionUseCase deve retomar via repositório', () async {
      final usecase = ResumeTimerSessionUseCaseImpl(repository: mockRepository);
      when(
        mockRepository.resumeSession('1'),
      ).thenAnswer((_) async => const Success(dummySession));

      final result = await usecase(const SessionIdParams(sessionId: '1'));

      expect(result.isSuccess(), isTrue);
      verify(mockRepository.resumeSession('1')).called(1);
    });

    test(
      'TickTimerSessionUseCase deve atualizar tempo via repositório',
      () async {
        final usecase = TickTimerSessionUseCaseImpl(repository: mockRepository);
        when(
          mockRepository.tickSession(sessionId: '1', elapsedSeconds: 10),
        ).thenAnswer((_) async => const Success(dummySession));

        final result = await usecase(
          const TickTimerSessionParams(sessionId: '1', elapsedSeconds: 10),
        );

        expect(result.isSuccess(), isTrue);
        verify(
          mockRepository.tickSession(sessionId: '1', elapsedSeconds: 10),
        ).called(1);
      },
    );

    test(
      'FinishTimerSessionUseCase deve encerrar via repositório e retornar o sumário',
      () async {
        final usecase = FinishTimerSessionUseCaseImpl(
          repository: mockRepository,
        );
        when(
          mockRepository.finishSession(sessionId: '1', notes: null),
        ).thenAnswer((_) async => const Success(dummySummary));

        final result = await usecase(
          const FinishTimerSessionParams(sessionId: '1'),
        );

        expect(result.isSuccess(), isTrue);
        verify(
          mockRepository.finishSession(sessionId: '1', notes: null),
        ).called(1);
      },
    );

    test(
      'GetLastTimerSessionUseCase deve retornar Failure em caso de erro',
      () async {
        final usecase = GetLastTimerSessionUseCaseImpl(
          repository: mockRepository,
        );

        final failure = TimerLoadError(cause: Exception('Not found'));
        when(
          mockRepository.getLastSession(),
        ).thenAnswer((_) async => Failure(failure));

        final result = await usecase(const NoParams());

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<TimerLoadError>());
      },
    );
  });
}
