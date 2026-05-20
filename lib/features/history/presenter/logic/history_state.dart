import '../../domain/entities/history_entities.dart';

sealed class HistoryState {
  final HistoryFilterType currentFilter;
  const HistoryState({this.currentFilter = HistoryFilterType.all});
}

final class HistoryInitial extends HistoryState {
  const HistoryInitial() : super();
}

final class HistoryLoading extends HistoryState {
  const HistoryLoading({super.currentFilter});
}

final class HistoryLoaded extends HistoryState {
  final List<HistorySession> sessions;

  const HistoryLoaded({required this.sessions, super.currentFilter});
}

final class HistoryDetailsLoaded extends HistoryState {
  final HistorySessionDetails details;

  const HistoryDetailsLoaded({required this.details, super.currentFilter});
}

final class HistoryFailure extends HistoryState {
  final String message;

  const HistoryFailure(this.message, {super.currentFilter});
}
