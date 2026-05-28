import 'package:result_dart/result_dart.dart';

import '../entities/home_entities.dart';

abstract interface class HomeRepository {
  AsyncResult<HomeDashboard> getDashboard();

  AsyncResult<HomeDashboard> refreshDashboard();

  AsyncResult<HomeSyncStatus> getSyncStatus();
}
