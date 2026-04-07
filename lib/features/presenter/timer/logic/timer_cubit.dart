import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kronos/features/domain/usecases/start_study_session_use_case.dart';
import 'package:kronos/features/domain/usecases/finish_and_save_session_locally_use_case.dart';
import 'package:kronos/features/presenter/timer/logic/timer_state.dart';
import 'dart:async';
//Adicionei o study_session.dart, pois ele não havia sido importado do projeto original
// import 'package:kronos/features/domain/entities/study_session.dart';

/// Cubit responsável por gerenciar a lógica do timer de estudo.
///
/// Coordena:
/// - Inicialização de novas sessões
/// - Controloe do cronômetro em tempo real
/// - Pausa e retomada
/// - Finalização e persistência de sessões
class TimerCubit extends Cubit<TimerState> {
  /// Use case para iniciar uma nova sessão de estudo.
  final StartStudySessionUseCase startSessionUseCase;

  /// Use case para finalizar e salvar uma sessão localmente.
  final FinishAndSaveSessionLocallyUseCase finishSessionUseCase;

  /// Timer interno para controlar o cronômetro.
  Timer? _timer;

  /// Armazena a sessão em andamento.
  // TODO: Adicionar campo para armazenar a sessão atual
  // Tive que tirar o final de StudySession, pois utilize ele mais de uma vez

  TimerCubit({
    required this.startSessionUseCase,
    required this.finishSessionUseCase,
    /*
    // Ao invés de usar:
    TimerCubit({
    required this.startSessionUseCase,
    required this.finishSessionUseCase,
    }) : super(TimerInitial());
    //Eu preferi usar:

    // Pq?
    // Simples, no arquivo de estados do timer (timer_state.dart), não criei uma classe chamada TimerInitial, e além disso, usei um construtor (const) na mesma
    */
  }) : super(const TimerIdle());

  /// Inicia uma nova sessão de estudo para o assunto especificado.
  ///
  /// Implementação esperada:
  /// - Criar nova sessão via [startSessionUseCase]
  /// - Armazenar sessão localmente
  /// - Iniciar cronômetro
  /// - Emitir [TimerRunning] com contador em tempo real
  Future<void> startTimer(String subject, {String? notes}) async {
    final session = await startSessionUseCase(
      StartSessionParams(subject: subject, notes: notes),
    );
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final current = state; //state é uma propriedade do cubit
      if (current is TimerRunning) {
        emit(
          current.copyWith(elapsed: current.elapsed + Duration(seconds: (1))),
        );
      }
    });
    emit(TimerRunning(session: session, elapsed: Duration.zero));
    // TODO: Implementar inicialização de nova sessão
    // 1. Chamar startSessionUseCase com o assunto
    // 2. Armazenar a sessão criada
    // 3. Cancelar timer anterior se existir
    // 4. Iniciar novo timer com interval de 1 segundo
    // 5. Emitir TimerRunning com os dados
  } // [feito]

  /// Pausa a sessão atual mantendo o tempo decorrido.
  ///
  /// Implementação esperada:
  /// - Cancelar timer
  /// - Armazenar tempo decorrido
  /// - Emitir [TimerPaused]
  void pauseTimer() {
    final running = state;
    if (running is! TimerRunning) {
      return;
    }
    _timer?.cancel();
    emit(running.copyWith(isPaused: true));
    // TODO: Implementar pausa do timer
    // 1. Verificar se há timer em execução
    // 2. Cancelar _timer?.cancel()
    // 3. Emitir TimerPaused com tempo decorrido
  }

  /// Retoma uma sessão pausada.
  ///
  /// Implementação esperada:
  /// - Reiniciar cronômetro do ponto de pausa
  /// - Emitir [TimerRunning]
  void resumeTimer() {
    final resume = state;
    if (resume is! TimerRunning) {
      return;
    }
    //Se resume.isPaused for false, signifca que está rodando, logo retorna.
    if (resume.isPaused == false) {
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final current = state; //state é uma propriedade do cubit
      if (current is TimerRunning) {
        emit(
          current.copyWith(elapsed: current.elapsed + Duration(seconds: (1))),
        );
      }
    });

    emit(resume.copyWith(isPaused: false));
    // TODO: Implementar retomada do timer
    // 1. Verificar se o estado atual é TimerPaused
    // 1.5 CANCELAR O TIMER
    // 2. Reiniciar timer do ponto anterior
    // 3. Emitir TimerRunning
  }

  /// Finaliza a sessão atual e a salva localmente.
  ///
  /// Implementação esperada:
  /// - Parar cronômetro
  /// - Completar sessão (definir endTime)
  /// - Chamar finishSessionUseCase
  /// - Salvar no banco local
  /// - Emitir [TimerFinished]
  Future<void> finishSession({String? notes}) async {
    // Passo 1
    _timer?.cancel();

    // Passo 2
    final finish = state;
    if (finish is! TimerRunning) {
      return;
    }

    // Passo 2 e 3 -> UC-02 - "O caso de uso chama activeSession.copyWith(endTime: DateTime.now())", logo, no arquivo finish_and_save (nome grande pra caralho) use_case.dart, estará uma função pra adicionar notas se fornecidas, e colocará endTime = agora

    // Quem define o endTime é o useCase

    // Passo 4 é as 3 primeiras linhas do passo 5

    // Passo 5
    try {
      final saved = await finishSessionUseCase(
        FinishSessionParams(activeSession: finish.session, notes: notes),
      );

      emit(TimerFinished(saved));
    } catch (e) {
      emit(TimerError(e.toString()));
    }

    // TODO: Implementar finalização de sessão
    // 1. Cancelar timer em execução
    // 2. Completar a sessão com endTime = agora
    // 3. Adicionar notas se fornecidas
    // 4. Chamar finishSessionUseCase
    // 5. Emitir TimerFinished ou TimerError se falhar
  }

  /// Libera recursos ao descartar o Cubit.
  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void togglePause() {
    final actualState = state;
    if (actualState is! TimerRunning) return;

    if (actualState.isPaused) {
      resumeTimer();
    } else {
      pauseTimer();
    }
  }

  void reset() => emit(const TimerIdle());
}
