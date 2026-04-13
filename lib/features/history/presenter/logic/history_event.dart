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
