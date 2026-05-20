import 'package:get_it/get_it.dart';

import '../data/repositories/timer_repository_impl.dart';
import '../data/source/timer_source.dart';
import '../domain/repositories/timer_repository.dart';
import '../domain/usecases/timer_usecase_contracts.dart';
import '../domain/usecases/timer_usecases.dart';
import '../presenter/logic/timer_bloc.dart';

void setupTimerFeatureDI(GetIt sl) {
  if (!sl.isRegistered<TimerSource>()) {
    sl.registerLazySingleton<TimerSource>(() => TimerSourceImpl(database: sl()));
  }

  if (!sl.isRegistered<TimerRepository>()) {
    sl.registerLazySingleton<TimerRepository>(
      () => TimerRepositoryImpl(source: sl<TimerSource>()),
    );
  }

  if (!sl.isRegistered<StartTimerSessionUseCase>()) {
    sl.registerLazySingleton<StartTimerSessionUseCase>(
      () => StartTimerSessionUseCaseImpl(repository: sl<TimerRepository>()),
    );
  }

  if (!sl.isRegistered<PauseTimerSessionUseCase>()) {
    sl.registerLazySingleton<PauseTimerSessionUseCase>(
      () => PauseTimerSessionUseCaseImpl(repository: sl<TimerRepository>()),
    );
  }

  if (!sl.isRegistered<ResumeTimerSessionUseCase>()) {
    sl.registerLazySingleton<ResumeTimerSessionUseCase>(
      () => ResumeTimerSessionUseCaseImpl(repository: sl<TimerRepository>()),
    );
  }

  if (!sl.isRegistered<TickTimerSessionUseCase>()) {
    sl.registerLazySingleton<TickTimerSessionUseCase>(
      () => TickTimerSessionUseCaseImpl(repository: sl<TimerRepository>()),
    );
  }

  if (!sl.isRegistered<FinishTimerSessionUseCase>()) {
    sl.registerLazySingleton<FinishTimerSessionUseCase>(
      () => FinishTimerSessionUseCaseImpl(repository: sl<TimerRepository>()),
    );
  }

  if (!sl.isRegistered<GetLastTimerSessionUseCase>()) {
    sl.registerLazySingleton<GetLastTimerSessionUseCase>(
      () => GetLastTimerSessionUseCaseImpl(repository: sl<TimerRepository>()),
    );
  }

  if (!sl.isRegistered<TimerBloc>()) {
    sl.registerFactory<TimerBloc>(
      () => TimerBloc(
        startTimerSessionUseCase: sl<StartTimerSessionUseCase>(),
        pauseTimerSessionUseCase: sl<PauseTimerSessionUseCase>(),
        resumeTimerSessionUseCase: sl<ResumeTimerSessionUseCase>(),
        tickTimerSessionUseCase: sl<TickTimerSessionUseCase>(),
        finishTimerSessionUseCase: sl<FinishTimerSessionUseCase>(),
        getLastTimerSessionUseCase: sl<GetLastTimerSessionUseCase>(),
      ),
    );
  }
}
