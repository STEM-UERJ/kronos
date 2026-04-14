import 'package:get_it/get_it.dart';

import '../presenter/logic/history_bloc.dart';

void setupHistoryFeatureDI(GetIt sl) {
  if (!sl.isRegistered<HistoryBloc>()) {
    sl.registerFactory<HistoryBloc>(HistoryBloc.new);
  }
}
