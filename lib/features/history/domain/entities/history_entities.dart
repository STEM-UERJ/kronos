enum HistoryFilterType { all, thisWeek, unsynced }

final class HistoryQuery {
  final HistoryFilterType filter;

  const HistoryQuery({required this.filter});
}

final class HistorySession {
  final String id;
  final String subject;
  final DateTime startTime;
  final DateTime endTime;
  final int durationInMinutes;
  final bool isSynced;

  const HistorySession({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.durationInMinutes,
    required this.isSynced,
  });
}

final class HistorySessionDetails {
  final HistorySession session;
  final String? notes;

  const HistorySessionDetails({required this.session, this.notes});
}
