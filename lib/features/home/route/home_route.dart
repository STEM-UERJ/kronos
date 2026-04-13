import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/getit.dart';
import '../../../core/router/routes.dart';
import '../presenter/logic/home_bloc.dart';
import '../presenter/logic/home_event.dart';
import '../presenter/page/home_page.dart';

final GoRoute homeRoute = GoRoute(
  path: Routes.home,
  builder: (context, state) => BlocProvider<HomeBloc>(
    create: (_) => sl<HomeBloc>()..add(const HomeStarted()),
    child: const HomePage(),
  ),
);
