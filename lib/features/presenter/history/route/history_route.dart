import 'package:go_router/go_router.dart';
import '../page/history_page.dart';
import '../../../../core/router/routes.dart';

final historyRoute = GoRoute(
  path: Routes.history,
  builder: (context, state) => const HistoryPage(),
);
