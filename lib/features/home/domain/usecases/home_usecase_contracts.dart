import 'package:kronos/core/contracts/use_case_contract.dart';

import '../entities/home_entities.dart';

abstract interface class GetHomeDashboardUseCase
    implements UseCase<HomeDashboard, NoParams> {}

abstract interface class RefreshHomeDashboardUseCase
    implements UseCase<HomeDashboard, NoParams> {}

abstract interface class GetHomeSyncStatusUseCase
    implements UseCase<HomeSyncStatus, NoParams> {}
