import 'package:get_it/get_it.dart';

import '../../../core/storage/storage.dart';
import '../data/repositories/config_repository_impl.dart';
import '../data/source/config_source.dart';
import '../domain/repositories/config_repository.dart';
import '../domain/usecases/config_usecase_contracts.dart';
import '../domain/usecases/config_usecases.dart';
import '../presenter/logic/config_bloc.dart';

void setupConfigFeatureDI(GetIt sl) {
  if (!sl.isRegistered<SecureStorageWrapper>()) {
    sl.registerLazySingleton<SecureStorageWrapper>(
      FlutterSecureStorageWrapper.new,
    );
  }

  if (!sl.isRegistered<ConfigSource>()) {
    sl.registerLazySingleton<ConfigSource>(
      () => SecureConfigSource(storage: sl<SecureStorageWrapper>()),
    );
  }

  if (!sl.isRegistered<ConfigRepository>()) {
    sl.registerLazySingleton<ConfigRepository>(
      () => ConfigRepositoryImpl(source: sl<ConfigSource>()),
    );
  }

  if (!sl.isRegistered<GetSavedGithubTokenUseCase>()) {
    sl.registerLazySingleton<GetSavedGithubTokenUseCase>(
      () => GetSavedGithubTokenUseCaseImpl(repository: sl<ConfigRepository>()),
    );
  }

  if (!sl.isRegistered<SaveGithubTokenUseCase>()) {
    sl.registerLazySingleton<SaveGithubTokenUseCase>(
      () => SaveGithubTokenUseCaseImpl(repository: sl<ConfigRepository>()),
    );
  }

  if (!sl.isRegistered<ValidateGithubTokenUseCase>()) {
    sl.registerLazySingleton<ValidateGithubTokenUseCase>(
      () => ValidateGithubTokenUseCaseImpl(repository: sl<ConfigRepository>()),
    );
  }

  if (!sl.isRegistered<ClearGithubTokenUseCase>()) {
    sl.registerLazySingleton<ClearGithubTokenUseCase>(
      () => ClearGithubTokenUseCaseImpl(repository: sl<ConfigRepository>()),
    );
  }

  if (!sl.isRegistered<SyncPendingSessionsUseCase>()) {
    sl.registerLazySingleton<SyncPendingSessionsUseCase>(
      () => SyncPendingSessionsUseCaseImpl(repository: sl<ConfigRepository>()),
    );
  }

  if (!sl.isRegistered<ConfigBloc>()) {
    sl.registerFactory<ConfigBloc>(
      () => ConfigBloc(
        getSavedGithubTokenUseCase: sl<GetSavedGithubTokenUseCase>(),
        saveGithubTokenUseCase: sl<SaveGithubTokenUseCase>(),
        validateGithubTokenUseCase: sl<ValidateGithubTokenUseCase>(),
        clearGithubTokenUseCase: sl<ClearGithubTokenUseCase>(),
        syncPendingSessionsUseCase: sl<SyncPendingSessionsUseCase>(),
      ),
    );
  }
}
