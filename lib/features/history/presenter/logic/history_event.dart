import '../../domain/entities/history_entities.dart';

sealed class HistoryEvent {
  const HistoryEvent();
}

final class HistoryStarted extends HistoryEvent {
  const HistoryStarted();
}

final class HistoryFilterChanged extends HistoryEvent {
  final HistoryFilterType filter;

  const HistoryFilterChanged(this.filter);
}

final class HistorySessionSelected extends HistoryEvent {
  final String sessionId;

  const HistorySessionSelected(this.sessionId);
}

final class HistoryNotesUpdated extends HistoryEvent {
  final String sessionId;
  final String notes;

  const HistoryNotesUpdated({required this.sessionId, required this.notes});
}

final class HistorySessionDeleted extends HistoryEvent {
  final String sessionId;

  const HistorySessionDeleted(this.sessionId);
}
