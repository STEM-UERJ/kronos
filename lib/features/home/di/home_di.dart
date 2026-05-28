import 'package:get_it/get_it.dart';
import 'package:kronos/features/home/data/repositories/home_repository_impl.dart';
import 'package:kronos/features/home/data/source/home_source.dart';
import 'package:kronos/features/home/domain/repositories/home_repository.dart';
import 'package:kronos/features/home/domain/usecases/home_usecase_contracts.dart';
import 'package:kronos/features/home/domain/usecases/home_usecases.dart';

import '../presenter/logic/home_bloc.dart';

void setupHomeFeatureDI(GetIt sl) {
  if (!sl.isRegistered<HomeSource>()) {
    sl.registerLazySingleton<HomeSource>(() => HomeSourceImpl(sl()));
  }

  if (!sl.isRegistered<HomeRepository>()) {
    sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(source: sl()),
    );
  }

  if (!sl.isRegistered<GetHomeDashboardUseCase>()) {
    sl.registerLazySingleton<GetHomeDashboardUseCase>(
      () => GetHomeDashboardUseCaseImpl(repository: sl()),
    );
  }

  if (!sl.isRegistered<RefreshHomeDashboardUseCase>()) {
    sl.registerLazySingleton<RefreshHomeDashboardUseCase>(
      () => RefreshHomeDashboardUseCaseImpl(repository: sl()),
    );
  }

  if (!sl.isRegistered<GetHomeSyncStatusUseCase>()) {
    sl.registerLazySingleton<GetHomeSyncStatusUseCase>(
      () => GetHomeSyncStatusUseCaseImpl(repository: sl()),
    );
  }

  if (!sl.isRegistered<HomeBloc>()) {
    sl.registerFactory<HomeBloc>(
      () => HomeBloc(
        getHomeDashboardUseCase: sl(),
        refreshHomeDashboardUseCase: sl(),
      ),
    );
  }
}
