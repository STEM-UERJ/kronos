import '../../domain/entities/history_entities.dart';

sealed class HistoryState {
  const HistoryState();
}

final class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

final class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

final class HistoryLoaded extends HistoryState {
  final List<HistorySession> sessions;

  const HistoryLoaded({required this.sessions});
}

final class HistoryDetailsLoaded extends HistoryState {
  final HistorySessionDetails details;

  const HistoryDetailsLoaded({required this.details});
}

final class HistoryFailure extends HistoryState {
  final String message;

  const HistoryFailure(this.message);
}
