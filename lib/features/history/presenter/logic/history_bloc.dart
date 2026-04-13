import 'package:bloc/bloc.dart';

import '../../domain/usecases/history_usecase_contracts.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistorySessionsUseCase? _getHistorySessionsUseCase;
  final GetHistorySessionDetailsUseCase? _getHistorySessionDetailsUseCase;

  HistoryBloc({
    GetHistorySessionsUseCase? getHistorySessionsUseCase,
    GetHistorySessionDetailsUseCase? getHistorySessionDetailsUseCase,
  }) : _getHistorySessionsUseCase = getHistorySessionsUseCase,
       _getHistorySessionDetailsUseCase = getHistorySessionDetailsUseCase,
       super(const HistoryInitial()) {
    on<HistoryStarted>(_onStarted);
    on<HistoryFilterChanged>(_onFilterChanged);
    on<HistorySessionSelected>(_onSessionSelected);
  }

  Never _notImplemented() {
    final bool hasAnyDependency =
        _getHistorySessionsUseCase != null ||
        _getHistorySessionDetailsUseCase != null;
    if (hasAnyDependency) {
      // no-op
    }
    throw UnimplementedError();
  }

  void _onStarted(HistoryStarted event, Emitter<HistoryState> emit) {
    _notImplemented();
  }

  void _onFilterChanged(
    HistoryFilterChanged event,
    Emitter<HistoryState> emit,
  ) {
    _notImplemented();
  }

  void _onSessionSelected(
    HistorySessionSelected event,
    Emitter<HistoryState> emit,
  ) {
    _notImplemented();
  }
}
