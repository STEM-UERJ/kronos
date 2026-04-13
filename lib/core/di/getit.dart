import 'package:get_it/get_it.dart';

import 'package:kronos/core/sql/database.dart';
import 'package:kronos/features/config/di/config_di.dart';
import 'package:kronos/features/history/di/history_di.dart';
import 'package:kronos/features/home/di/home_di.dart';
import 'package:kronos/features/timer/di/timer_di.dart';

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
  if (!sl.isRegistered<DatabaseService>()) {
    sl.registerLazySingleton<DatabaseService>(DatabaseService.new);
  }

  setupConfigFeatureDI(sl);
  setupHomeFeatureDI(sl);
  setupTimerFeatureDI(sl);
  setupHistoryFeatureDI(sl);
}
