import 'package:bloc/bloc.dart';

import '../../domain/usecases/timer_usecase_contracts.dart';
import 'timer_event.dart';
import 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final StartTimerSessionUseCase? _startTimerSessionUseCase;
  final PauseTimerSessionUseCase? _pauseTimerSessionUseCase;
  final ResumeTimerSessionUseCase? _resumeTimerSessionUseCase;
  final FinishTimerSessionUseCase? _finishTimerSessionUseCase;
  final GetLastTimerSessionUseCase? _getLastTimerSessionUseCase;

  TimerBloc({
    StartTimerSessionUseCase? startTimerSessionUseCase,
    PauseTimerSessionUseCase? pauseTimerSessionUseCase,
    ResumeTimerSessionUseCase? resumeTimerSessionUseCase,
    FinishTimerSessionUseCase? finishTimerSessionUseCase,
    GetLastTimerSessionUseCase? getLastTimerSessionUseCase,
  }) : _startTimerSessionUseCase = startTimerSessionUseCase,
       _pauseTimerSessionUseCase = pauseTimerSessionUseCase,
       _resumeTimerSessionUseCase = resumeTimerSessionUseCase,
       _finishTimerSessionUseCase = finishTimerSessionUseCase,
       _getLastTimerSessionUseCase = getLastTimerSessionUseCase,
       super(const TimerInitial()) {
    on<TimerStarted>(_onStarted);
    on<TimerPlayRequested>(_onPlayRequested);
    on<TimerPauseRequested>(_onPauseRequested);
    on<TimerResumeRequested>(_onResumeRequested);
    on<TimerFinishRequested>(_onFinishRequested);
  }

  Never _notImplemented() {
    final bool hasAnyDependency =
        _startTimerSessionUseCase != null ||
        _pauseTimerSessionUseCase != null ||
        _resumeTimerSessionUseCase != null ||
        _finishTimerSessionUseCase != null ||
        _getLastTimerSessionUseCase != null;
    if (hasAnyDependency) {
      // no-op
    }
    throw UnimplementedError();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    _notImplemented();
  }

  void _onPlayRequested(TimerPlayRequested event, Emitter<TimerState> emit) {
    _notImplemented();
  }

  void _onPauseRequested(TimerPauseRequested event, Emitter<TimerState> emit) {
    _notImplemented();
  }

  void _onResumeRequested(
    TimerResumeRequested event,
    Emitter<TimerState> emit,
  ) {
    _notImplemented();
  }

  void _onFinishRequested(
    TimerFinishRequested event,
    Emitter<TimerState> emit,
  ) {
    _notImplemented();
  }
}
