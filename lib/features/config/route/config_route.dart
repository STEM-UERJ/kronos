import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/getit.dart';
import '../../../core/router/routes.dart';
import '../presenter/logic/config_bloc.dart';
import '../presenter/logic/config_event.dart';
import '../presenter/page/config_page.dart';

final GoRoute configRoute = GoRoute(
  path: Routes.settings,
  builder: (context, state) => BlocProvider<ConfigBloc>(
    create: (_) => sl<ConfigBloc>()..add(const ConfigStarted()),
    child: const ConfigPage(),
  ),
);
