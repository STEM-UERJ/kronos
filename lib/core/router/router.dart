import 'package:go_router/go_router.dart';

import '../../features/config/route/config_route.dart';
import '../../features/history/route/history_route.dart';
import '../../features/home/route/home_route.dart';
import '../../features/timer/route/timer_route.dart';
import 'app_shell.dart';
import 'routes.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [homeRoute]),
          StatefulShellBranch(routes: [timerRoute]),
          StatefulShellBranch(routes: [historyRoute]),
          StatefulShellBranch(routes: [configRoute]),
        ],
      ),
    ],
  );
}
