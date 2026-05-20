import 'package:get_it/get_it.dart';
import 'package:kronos/core/sql/database.dart';

import '../data/repositories/history_repository_impl.dart';
import '../data/source/history_source.dart';
import '../data/source/history_source_impl.dart';
import '../domain/repositories/history_repository.dart';
import '../domain/usecases/history_usecase_contracts.dart';
import '../domain/usecases/history_usecases.dart';
import '../presenter/logic/history_bloc.dart';

void setupHistoryFeatureDI(GetIt sl) {
  // Source
  if (!sl.isRegistered<HistorySource>()) {
    sl.registerLazySingleton<HistorySource>(
      () => HistorySourceImpl(databaseService: sl<DatabaseService>()),
    );
  }

  // Repository
  if (!sl.isRegistered<HistoryRepository>()) {
    sl.registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(source: sl<HistorySource>()),
    );
  }

  // Use Cases
  if (!sl.isRegistered<GetHistorySessionsUseCase>()) {
    sl.registerLazySingleton<GetHistorySessionsUseCase>(
      () => GetHistorySessionsUseCaseImpl(repository: sl<HistoryRepository>()),
    );
  }
  if (!sl.isRegistered<GetHistorySessionDetailsUseCase>()) {
    sl.registerLazySingleton<GetHistorySessionDetailsUseCase>(
      () => GetHistorySessionDetailsUseCaseImpl(repository: sl<HistoryRepository>()),
    );
  }
  if (!sl.isRegistered<UpdateHistorySessionNotesUseCase>()) {
    sl.registerLazySingleton<UpdateHistorySessionNotesUseCase>(
      () => UpdateHistorySessionNotesUseCaseImpl(repository: sl<HistoryRepository>()),
    );
  }
  if (!sl.isRegistered<DeleteHistorySessionUseCase>()) {
    sl.registerLazySingleton<DeleteHistorySessionUseCase>(
      () => DeleteHistorySessionUseCaseImpl(repository: sl<HistoryRepository>()),
    );
  }

  // BLoC
  if (!sl.isRegistered<HistoryBloc>()) {
    sl.registerFactory<HistoryBloc>(
      () => HistoryBloc(
        getHistorySessionsUseCase: sl<GetHistorySessionsUseCase>(),
        getHistorySessionDetailsUseCase: sl<GetHistorySessionDetailsUseCase>(),
        updateHistorySessionNotesUseCase: sl<UpdateHistorySessionNotesUseCase>(),
        deleteHistorySessionUseCase: sl<DeleteHistorySessionUseCase>(),
      ),
    );
  }
}
