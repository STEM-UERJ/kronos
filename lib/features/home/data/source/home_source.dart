import 'package:kronos/core/sql/database.dart';
import '../../domain/entities/home_entities.dart';

abstract interface class HomeSource {
  Future<HomeDashboard> getDashboard();

  Future<HomeDashboard> refreshDashboard();

  Future<HomeSyncStatus> getSyncStatus();
}

final class HomeSourceImpl implements HomeSource {
  final DatabaseService _databaseService;

  HomeSourceImpl(this._databaseService);

  @override
  Future<HomeDashboard> getDashboard() async {
    const query = '''
      SELECT COALESCE(SUM(elapsed_seconds), 0) AS total_seconds,
       COUNT(*) AS sessions_count
      FROM study_sessions
      WHERE deleted_at IS NULL
        AND date(start_time, 'localtime') = date('now', 'localtime');
    ''';

    // Execute query
    final db = await _databaseService.database;
    final result = await db.rawQuery(query);

    int totalSeconds = 0;
    int sessionsCount = 0;

    if (result.isNotEmpty) {
      totalSeconds = (result.first['total_seconds'] as num?)?.toInt() ?? 0;
      sessionsCount = (result.first['sessions_count'] as num?)?.toInt() ?? 0;
    }

    final todayTotalMinutes = totalSeconds ~/ 60;

    final hour = DateTime.now().hour;
    String greeting = 'Boa noite';
    if (hour >= 5 && hour < 12) {
      greeting = 'Bom dia';
    } else if (hour >= 12 && hour < 18) {
      greeting = 'Boa Tarde';
    }

    final weeklyProgress = await _getWeeklyStudyPoint();
    final syncStatus = await getSyncStatus();

    return HomeDashboard(
      greeting: greeting,
      todayTotalMinutes: todayTotalMinutes,
      todaySessionsCount: sessionsCount,
      syncStatus: syncStatus,
      weeklyProgress: weeklyProgress,
    );
  }

  @override
  Future<HomeDashboard> refreshDashboard() async {
    return await getDashboard();
  }

  @override
  Future<HomeSyncStatus> getSyncStatus() async {
    try {
      const query = '''
        SELECT COUNT(*) AS pending_count
        FROM study_sessions
        WHERE deleted_at IS NULL
          AND is_synced = 0
          AND status = 'finished';
      ''';

      final db = await _databaseService.database;
      final result = await db.rawQuery(query);

      int pendingCount = (result.isNotEmpty)
          ? (result.first['pending_count'] as num?)?.toInt() ?? 0
          : 0;

      return pendingCount == 0 ? HomeSyncStatus.synced : HomeSyncStatus.pending;
    } catch (e) {
      return HomeSyncStatus.error;
    }
  }

  // --- Private methodas

  Future<List<WeeklyStudyPoint>> _getWeeklyStudyPoint() async {
    const query = '''
      SELECT date(start_time, 'localtime') AS day,
       COALESCE(SUM(elapsed_seconds), 0) AS total_seconds
      FROM study_sessions
      WHERE deleted_at IS NULL
        AND date(start_time, 'localtime') >= date('now', '-6 day', 'localtime')
      GROUP BY date(start_time, 'localtime')
      ORDER BY day ASC;
    ''';

    final db = await _databaseService.database;
    final result = await db.rawQuery(query);

    final now = DateTime.now();
    const weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return result.map((row) {
      final totalSeconds = (row['total_seconds'] as num?)?.toInt() ?? 0;

      final dateStr = row['day'] as String;
      final date = DateTime.parse(dateStr);

      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      final dayLabel = weekdays[date.weekday - 1];

      return WeeklyStudyPoint(
        dayLabel: dayLabel,
        minutes: totalSeconds ~/ 60,
        isToday: isToday,
      );
    }).toList();
  }
}
