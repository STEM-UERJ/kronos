import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kronos/features/domain/usecases/start_study_session_use_case.dart';
import 'package:kronos/features/domain/usecases/finish_and_save_session_locally_use_case.dart';
import 'package:kronos/features/presenter/timer/logic/timer_state.dart';
import 'dart:async';

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
  // final StudySession? _currentSession;

  TimerCubit({
    required this.startSessionUseCase,
    required this.finishSessionUseCase,
  }) : super(TimerInitial());

  /// Inicia uma nova sessão de estudo para o assunto especificado.
  ///
  /// Implementação esperada:
  /// - Criar nova sessão via [startSessionUseCase]
  /// - Armazenar sessão localmente
  /// - Iniciar cronômetro
  /// - Emitir [TimerRunning] com contador em tempo real
  Future<void> startTimer(String subject) async {
    // TODO: Implementar inicialização de nova sessão
    // 1. Chamar startSessionUseCase com o assunto
    // 2. Armazenar a sessão criada
    // 3. Cancelar timer anterior se existir
    // 4. Iniciar novo timer com interval de 1 segundo
    // 5. Emitir TimerRunning com os dados
  }

  /// Pausa a sessão atual mantendo o tempo decorrido.
  ///
  /// Implementação esperada:
  /// - Cancelar timer
  /// - Armazenar tempo decorrido
  /// - Emitir [TimerPaused]
  void pauseTimer() {
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
    // TODO: Implementar retomada do timer
    // 1. Verificar se o estado atual é TimerPaused
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
}
