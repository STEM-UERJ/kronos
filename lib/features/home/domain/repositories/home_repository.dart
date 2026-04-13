import 'package:kronos/core/contracts/use_case_contract.dart';

import '../entities/home_entities.dart';

abstract interface class HomeRepository {
  AsyncResult<HomeDashboard> getDashboard();

  AsyncResult<HomeDashboard> refreshDashboard();

  AsyncResult<HomeSyncStatus> getSyncStatus();
}
