import 'package:get_it/get_it.dart';

import '../sql/database.dart';
import '../../features/data/source/local_study_session_source.dart';
import '../../features/data/repositories/study_session_repository_impl.dart';
import '../../features/domain/repositories/study_session_repository.dart';
import '../../features/domain/usecases/finish_and_save_session_locally_use_case.dart';
import '../../features/domain/usecases/get_local_study_history_use_case.dart';
import '../../features/domain/usecases/start_study_session_use_case.dart';

/// Global service locator instance.
///
/// Usage: `sl<MyDependency>()`
final sl = GetIt.instance;

/// Registers all app dependencies.
///
/// Call in [main] before [runApp]:
/// ```dart
/// await setupLocator();
/// runApp(const KronosApp());
/// ```
Future<void> setupLocator() async {
  // ── Core ──────────────────────────────────────────────────────────────────
  sl.registerSingleton<DatabaseService>(DatabaseService());

  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<LocalStudySessionSource>(
    () => LocalStudySessionSourceImpl(databaseService: sl<DatabaseService>()),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<StudySessionRepository>(
    () =>
        StudySessionRepositoryImpl(localSource: sl<LocalStudySessionSource>()),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerFactory<StartStudySessionUseCase>(
    () => const StartStudySessionUseCase(),
  );

  sl.registerFactory<FinishAndSaveSessionLocallyUseCase>(
    () => FinishAndSaveSessionLocallyUseCase(sl<StudySessionRepository>()),
  );

  sl.registerFactory<GetLocalStudyHistoryUseCase>(
    () => GetLocalStudyHistoryUseCase(sl<StudySessionRepository>()),
  );
}
