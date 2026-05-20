import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:kronos/core/contracts/use_case_contract.dart';
import 'package:result_dart/result_dart.dart';

import '../../domain/usecases/timer_usecase_contracts.dart';
import 'timer_event.dart';
import 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final StartTimerSessionUseCase _startTimerSessionUseCase;
  final PauseTimerSessionUseCase _pauseTimerSessionUseCase;
  final ResumeTimerSessionUseCase _resumeTimerSessionUseCase;
  final TickTimerSessionUseCase _tickTimerSessionUseCase;
  final FinishTimerSessionUseCase _finishTimerSessionUseCase;
  final GetLastTimerSessionUseCase _getLastTimerSessionUseCase;

  TimerBloc({
    required StartTimerSessionUseCase startTimerSessionUseCase,
    required PauseTimerSessionUseCase pauseTimerSessionUseCase,
    required ResumeTimerSessionUseCase resumeTimerSessionUseCase,
    required TickTimerSessionUseCase tickTimerSessionUseCase,
    required FinishTimerSessionUseCase finishTimerSessionUseCase,
    required GetLastTimerSessionUseCase getLastTimerSessionUseCase,
  }) : _startTimerSessionUseCase = startTimerSessionUseCase,
       _pauseTimerSessionUseCase = pauseTimerSessionUseCase,
       _resumeTimerSessionUseCase = resumeTimerSessionUseCase,
       _tickTimerSessionUseCase = tickTimerSessionUseCase,
       _finishTimerSessionUseCase = finishTimerSessionUseCase,
       _getLastTimerSessionUseCase = getLastTimerSessionUseCase,
       super(const TimerInitial()) {
    on<TimerStarted>(_onStarted);
    on<TimerPlayRequested>(_onPlayRequested);
    on<TimerPauseRequested>(_onPauseRequested);
    on<TimerResumeRequested>(_onResumeRequested);
    on<TimerFinishRequested>(_onFinishRequested);
  }

  @override
  Future<void> close() {
    return super.close();
  }

  Future<void> _onStarted(TimerStarted event, Emitter<TimerState> emit) async {
    emit(const TimerInitial());

    final result = await _getLastTimerSessionUseCase(const NoParams());

    result.fold(
      (summary) => emit(TimerIdle(lastSession: summary)),
      (error) => emit(const TimerIdle()),
    );
  }

  Future<void> _onPlayRequested(
    TimerPlayRequested event,
    Emitter<TimerState> emit,
  ) async {
    final result = await _startTimerSessionUseCase(
      StartTimerSessionParams(subject: event.subject, notes: event.notes),
    );

    result.fold((session) {
      emit(TimerRunning(session: session));
    }, (error) => emit(TimerFailure(error.toString())));
  }

  Future<void> _onPauseRequested(
    TimerPauseRequested event,
    Emitter<TimerState> emit,
  ) async {
    final currentState = state;
    if (currentState is TimerRunning) {
      // Sincroniza o tempo decorrido com o banco antes de pausar
      await _tickTimerSessionUseCase(
        TickTimerSessionParams(
          sessionId: currentState.session.id,
          elapsedSeconds: event.elapsedSeconds,
        ),
      );

      final result = await _pauseTimerSessionUseCase(
        SessionIdParams(sessionId: currentState.session.id),
      );

      result.fold(
        (session) => emit(TimerPaused(session: session)),
        (error) => emit(TimerFailure(error.toString())),
      );
    }
  }

  Future<void> _onResumeRequested(
    TimerResumeRequested event,
    Emitter<TimerState> emit,
  ) async {
    final currentState = state;
    if (currentState is TimerPaused) {
      final result = await _resumeTimerSessionUseCase(
        SessionIdParams(sessionId: currentState.session.id),
      );

      result.fold((session) {
        emit(TimerRunning(session: session));
      }, (error) => emit(TimerFailure(error.toString())));
    }
  }

  Future<void> _onFinishRequested(
    TimerFinishRequested event,
    Emitter<TimerState> emit,
  ) async {
    final currentState = state;
    String? sessionId;

    if (currentState is TimerRunning) sessionId = currentState.session.id;
    if (currentState is TimerPaused) sessionId = currentState.session.id;

    // Sincronizar o tempo decorrido
    if (sessionId != null) {
      await _tickTimerSessionUseCase(
        TickTimerSessionParams(
          sessionId: sessionId,
          elapsedSeconds: event.elapsedSeconds,
        ),
      );

      final result = await _finishTimerSessionUseCase(
        FinishTimerSessionParams(sessionId: sessionId, notes: event.notes),
      );

      result.fold(
        (summary) => emit(TimerFinished(summary: summary)),
        (error) => emit(TimerFailure(error.toString())),
      );
    }
  }
}
