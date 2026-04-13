enum HomeSyncStatus { synced, pending, error }

final class WeeklyStudyPoint {
  final String dayLabel;
  final int minutes;
  final bool isToday;

  const WeeklyStudyPoint({
    required this.dayLabel,
    required this.minutes,
    required this.isToday,
  });
}

final class HomeDashboard {
  final String greeting;
  final int todayTotalMinutes;
  final int todaySessionsCount;
  final HomeSyncStatus syncStatus;
  final List<WeeklyStudyPoint> weeklyProgress;

  const HomeDashboard({
    required this.greeting,
    required this.todayTotalMinutes,
    required this.todaySessionsCount,
    required this.syncStatus,
    required this.weeklyProgress,
  });
}
