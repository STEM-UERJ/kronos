import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kronos/features/domain/entities/study_session.dart';
import 'package:kronos/features/domain/repositories/study_session_repository.dart';
import 'package:kronos/features/domain/usecases/finish_and_save_session_locally_use_case.dart';
import 'package:kronos/features/domain/usecases/start_study_session_use_case.dart';
import 'package:kronos/features/presenter/timer/logic/timer_cubit.dart';
import 'package:kronos/features/presenter/timer/logic/timer_state.dart';

class FakeStudySessionRepository implements StudySessionRepository {
  final List<StudySession> _storage = [];

  @override
  Future<void> saveSession(StudySession session) async {
    _storage.removeWhere((s) => s.id == session.id);
    _storage.add(session);
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
    final idx = _storage.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      _storage[idx] = _storage[idx].copyWith(isSynced: true);
    }
  }
}
void main() {
  late FakeStudySessionRepository fakeRepo;
  late StartStudySessionUseCase startUseCase;
  late FinishAndSaveSessionLocallyUseCase finishUseCase;
  late TimerCubit cubit;

  // O setUp roda antes de CADA teste para garantir um ambiente limpo
  setUp(() {
    fakeRepo = FakeStudySessionRepository();
    startUseCase = const StartStudySessionUseCase();
    finishUseCase = FinishAndSaveSessionLocallyUseCase(fakeRepo);

    cubit = TimerCubit(
      startSessionUseCase: startUseCase,
      finishSessionUseCase: finishUseCase,
    );
  });

  // O tearDown roda após CADA teste para limpar a memória (cancelar o _timer)
  tearDown(() {
    cubit.close();
  });

  group('TimerCubit |', () {
    test('O estado inicial deve ser TimerIdle', () {
      expect(cubit.state, isA<TimerIdle>());
    });

    // Este é o teste exigido na "Definição de Pronto" da sua Sprint
    blocTest<TimerCubit, TimerState>(
      'Fluxo completo: start -> pause -> resume -> finish',
      build: () => cubit,
      act: (cubit) async {
        // ATENÇÃO: Se no seu TimerCubit o método se chama "startTimer",
        // mude o nome aqui, ou renomeie lá no Cubit para "start" (como pede a Sprint)
        await cubit.startTimer('Flutter');

        cubit.togglePause(); // Pausa
        cubit.togglePause(); // Retoma

        // ATENÇÃO: Se no seu TimerCubit o método se chama "finishSession",
        // mude o nome aqui ou renomeie lá no Cubit para "finish"
        await cubit.finishSession(notes: 'Sprint concluída!');
      },
      expect: () => [
        // 1. Estado ao iniciar
        isA<TimerRunning>().having((state) => state.isPaused, 'isPaused', false),

        // 2. Estado ao pausar
        isA<TimerRunning>().having((state) => state.isPaused, 'isPaused', true),

        // 3. Estado ao retomar
        isA<TimerRunning>().having((state) => state.isPaused, 'isPaused', false),

        // 4. Estado ao finalizar
        isA<TimerFinished>(),
      ],
      verify: (_) async {
        // Verifica no seu FakeRepo se a sessão foi realmente salva no final
        final sessoes = await fakeRepo.getAllSessions();
        expect(sessoes.length, 1);
        expect(sessoes.first.subject, 'Flutter');
        expect(sessoes.first.isCompleted, true);
        expect(sessoes.first.notes, 'Sprint concluída!');
      },
    );
  });
}