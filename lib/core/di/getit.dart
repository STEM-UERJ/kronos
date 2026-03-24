import 'package:get_it/get_it.dart';

import '../sql/database.dart';
// TODO: uncomment after implementing data sources and repositories
// import '../../features/domain/usecases/finish_and_save_session_locally_use_case.dart';
// import '../../features/domain/usecases/get_local_study_history_use_case.dart';
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

  //s1.getIt<StudySessionLocalSource>()
  // ── Data Sources ──────────────────────────────────────────────────────────
  // TODO: uncomment after implementing StudySessionLocalSourceImpl
  // sl.registerLazySingleton<StudySessionLocalSource>(
  //     () => StudySessionLocalSourceImpl(s1.getIt<DtabaseService>()));

  // ── Repositories ──────────────────────────────────────────────────────────
  // TODO: uncomment after implementing StudySessionRepositoryImpl
  // sl.registerLazySingleton<StudySessionRepository>(
  //     () => StudySessionRepositoryImpl(s1.getIt<StudySessionLocalSource>()));

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerFactory<StartStudySessionUseCase>(
    () => const StartStudySessionUseCase(),
  );

  // TODO: uncomment after registering StudySessionRepository above
  // sl.registerFactory<FinishAndSaveSessionLocallyUseCase>(
  //     () => FinishAndSaveSessionLocallyUseCase(sl()));
  // sl.registerFactory<GetLocalStudyHistoryUseCase>(
  //     () => GetLocalStudyHistoryUseCase(sl()));
}
