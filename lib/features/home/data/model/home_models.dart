final class HomeDashboardModel {
  final String greeting;
  final int todayTotalMinutes;
  final int todaySessionsCount;

  const HomeDashboardModel({
    required this.greeting,
    required this.todayTotalMinutes,
    required this.todaySessionsCount,
  });
}
