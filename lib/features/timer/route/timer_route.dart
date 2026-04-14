import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/getit.dart';
import '../../../core/router/routes.dart';
import '../presenter/logic/timer_bloc.dart';
import '../presenter/logic/timer_event.dart';
import '../presenter/page/timer_page.dart';

final GoRoute timerRoute = GoRoute(
  path: Routes.timer,
  builder: (context, state) => BlocProvider<TimerBloc>(
    create: (_) => sl<TimerBloc>()..add(const TimerStarted()),
    child: const TimerPage(),
  ),
);
