import 'package:get_it/get_it.dart';

import '../presenter/logic/home_bloc.dart';

void setupHomeFeatureDI(GetIt sl) {
  if (!sl.isRegistered<HomeBloc>()) {
    sl.registerFactory<HomeBloc>(HomeBloc.new);
  }
}
