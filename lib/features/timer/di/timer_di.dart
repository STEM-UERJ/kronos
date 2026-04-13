import 'package:get_it/get_it.dart';

import '../presenter/logic/timer_bloc.dart';

void setupTimerFeatureDI(GetIt sl) {
  if (!sl.isRegistered<TimerBloc>()) {
    sl.registerFactory<TimerBloc>(TimerBloc.new);
  }
}
