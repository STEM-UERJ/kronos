import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kronos/features/domain/usecases/get_local_study_history_use_case.dart';
import 'package:kronos/features/presenter/history/logic/history_cubit.dart';
import '../page/history_page.dart';
import '../../../../core/router/routes.dart';

final historyRoute = GoRoute(
  path: Routes.history,
  builder: (context, state) => BlocProvider(
    create: (context) =>
        HistoryCubit(getHistoryUseCase: GetIt.I<GetLocalStudyHistoryUseCase>()),
    child: const HistoryPage(),
  ),
);
