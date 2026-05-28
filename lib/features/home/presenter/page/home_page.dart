import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kronos/core/router/routes.dart';
import 'package:kronos/core/theme/app_colors.dart';
import 'package:kronos/features/home/domain/entities/home_entities.dart';
import 'package:kronos/features/home/presenter/logic/home_bloc.dart';
import 'package:kronos/features/home/presenter/logic/home_event.dart';
import 'package:kronos/features/home/presenter/logic/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  key: Key('home_loading_spinner'),
                  color: AppColors.violetLight,
                ),
              );
            }

            if (state is HomeFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: AppColors.onSurfaceDark),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is HomeLoaded) {
              final dashboard = state.dashboard;
              return RefreshIndicator(
                color: AppColors.violetLight,
                onRefresh: () async {
                  context.read<HomeBloc>().add(const HomeRefreshRequested());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(dashboard: dashboard),
                      const SizedBox(height: 32),
                      _TodaySummaryCard(dashboard: dashboard),
                      const SizedBox(height: 24),
                      _WeeklySummaryCard(points: dashboard.weeklyProgress),
                      const SizedBox(height: 40),
                      _ActionButton(),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final HomeDashboard dashboard;
  const _Header({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final syncColor = switch (dashboard.syncStatus) {
      HomeSyncStatus.synced => AppColors.success,
      HomeSyncStatus.pending => AppColors.warning,
      HomeSyncStatus.error => AppColors.error,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dashboard.greeting,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: syncColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_done_outlined, color: syncColor, size: 16),
              const SizedBox(width: 6),
              Text(
                "Synced",
                style: TextStyle(
                  color: syncColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  final HomeDashboard dashboard;
  const _TodaySummaryCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final int hours = dashboard.todayTotalMinutes ~/ 60;
    final int minutes = dashboard.todayTotalMinutes % 60;

    // Dia completo - 8 horas de sono
    double utilMinutes = 16 * 60;

    // Controle de erros caso passe
    if (dashboard.todayTotalMinutes > utilMinutes) {
      utilMinutes = 24.0 * 60.0;
    }

    double progress = (dashboard.todayTotalMinutes / utilMinutes).clamp(
      0.0,
      1.0,
    );

    // Convenção de valores muito pequenos
    if (dashboard.todayTotalMinutes > 0 && progress < 0.02) {
      progress = 0.02;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: 0.85,
                strokeWidth: 14,
                color: AppColors.violetContainer,
                backgroundColor: Colors.transparent,
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 14,
                strokeCap: StrokeCap.round,
                color: AppColors.info,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Today",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "${hours}h ${minutes}m",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  final List<WeeklyStudyPoint> points;
  const _WeeklySummaryCard({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "This Week",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: points.map((p) => _Bar(point: p)).toList(),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final WeeklyStudyPoint point;
  const _Bar({required this.point});

  @override
  Widget build(BuildContext context) {
    final double height = (point.minutes / 120) * 100;

    final bool isHighlighted = point.dayLabel == 'F' || point.isToday;
    final barColor = isHighlighted
        ? AppColors.success
        : AppColors.violetContainer;

    final int hours = point.minutes ~/ 60;
    final int mins = point.minutes % 60;
    final String timeString = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Column(
      children: [
        Tooltip(
          message: timeString,
          preferBelow: false,
          triggerMode: TooltipTriggerMode.tap,
          decoration: BoxDecoration(
            color: AppColors.violetLight,
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          child: Container(
            width: 28,
            height: height.clamp(10.0, 100.0),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          point.dayLabel,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () => context.go(Routes.timer),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violetLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: const Text("Start a new session"),
      ),
    );
  }
}
