import 'package:bloc/bloc.dart';

import '../../domain/entities/history_entities.dart';
import '../../domain/usecases/history_usecase_contracts.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistorySessionsUseCase _getHistorySessionsUseCase;
  final GetHistorySessionDetailsUseCase _getHistorySessionDetailsUseCase;
  final UpdateHistorySessionNotesUseCase _updateHistorySessionNotesUseCase;
  final DeleteHistorySessionUseCase _deleteHistorySessionUseCase;

  HistoryBloc({
    required GetHistorySessionsUseCase getHistorySessionsUseCase,
    required GetHistorySessionDetailsUseCase getHistorySessionDetailsUseCase,
    required UpdateHistorySessionNotesUseCase updateHistorySessionNotesUseCase,
    required DeleteHistorySessionUseCase deleteHistorySessionUseCase,
  }) : _getHistorySessionsUseCase = getHistorySessionsUseCase,
       _getHistorySessionDetailsUseCase = getHistorySessionDetailsUseCase,
       _updateHistorySessionNotesUseCase = updateHistorySessionNotesUseCase,
       _deleteHistorySessionUseCase = deleteHistorySessionUseCase,
       super(const HistoryInitial()) {
    on<HistoryStarted>(_onStarted);
    on<HistoryFilterChanged>(_onFilterChanged);
    on<HistorySessionSelected>(_onSessionSelected);
    on<HistoryNotesUpdated>(_onNotesUpdated);
    on<HistorySessionDeleted>(_onSessionDeleted);
  }

  Future<void> _onStarted(HistoryStarted event, Emitter<HistoryState> emit) async {
    await _fetchSessions(state.currentFilter, emit);
  }

  Future<void> _onFilterChanged(
    HistoryFilterChanged event,
    Emitter<HistoryState> emit,
  ) async {
    await _fetchSessions(event.filter, emit);
  }

  Future<void> _onSessionSelected(
    HistorySessionSelected event,
    Emitter<HistoryState> emit,
  ) async {
    final currentFilter = state.currentFilter;
    emit(HistoryLoading(currentFilter: currentFilter));

    try {
      final details = await _getHistorySessionDetailsUseCase(
        SessionDetailsParams(sessionId: event.sessionId),
      );
      emit(HistoryDetailsLoaded(details: details, currentFilter: currentFilter));
    } catch (error) {
      emit(HistoryFailure(error.toString(), currentFilter: currentFilter));
    }
  }

  Future<void> _onNotesUpdated(
    HistoryNotesUpdated event,
    Emitter<HistoryState> emit,
  ) async {
    final currentFilter = state.currentFilter;
    try {
      await _updateHistorySessionNotesUseCase(
        UpdateSessionNotesParams(sessionId: event.sessionId, notes: event.notes),
      );
      // After successful update, fetch sessions again to refresh the list
      await _fetchSessions(currentFilter, emit);
    } catch (error) {
      emit(HistoryFailure(error.toString(), currentFilter: currentFilter));
    }
  }

  Future<void> _onSessionDeleted(
    HistorySessionDeleted event,
    Emitter<HistoryState> emit,
  ) async {
    final currentFilter = state.currentFilter;
    try {
      await _deleteHistorySessionUseCase(
        DeleteSessionParams(sessionId: event.sessionId),
      );
      // After successful deletion, fetch sessions again to refresh the list
      await _fetchSessions(currentFilter, emit);
    } catch (error) {
      emit(HistoryFailure(error.toString(), currentFilter: currentFilter));
    }
  }

  Future<void> _fetchSessions(HistoryFilterType filter, Emitter<HistoryState> emit) async {
    emit(HistoryLoading(currentFilter: filter));

    try {
      final sessions = await _getHistorySessionsUseCase(
        GetHistorySessionsParams(query: HistoryQuery(filter: filter)),
      );
      emit(HistoryLoaded(sessions: sessions, currentFilter: filter));
    } catch (error) {
      emit(HistoryFailure(error.toString(), currentFilter: filter));
    }
  }
}
