import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/getit.dart';
import '../../../core/router/routes.dart';
import '../presenter/logic/history_bloc.dart';
import '../presenter/logic/history_event.dart';
import '../presenter/page/history_page.dart';

final GoRoute historyRoute = GoRoute(
  path: Routes.history,
  builder: (context, state) => BlocProvider<HistoryBloc>(
    create: (_) => sl<HistoryBloc>()..add(const HistoryStarted()),
    child: const HistoryPage(),
  ),
);
