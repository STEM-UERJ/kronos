import '../../../../core/contracts/use_case_contract.dart';
import '../entities/home_entities.dart';
import '../repositories/home_repository.dart';
import 'home_usecase_contracts.dart';

final class GetHomeDashboardUseCaseImpl implements GetHomeDashboardUseCase {
  final HomeRepository _repository;

  GetHomeDashboardUseCaseImpl({required HomeRepository repository})
    : _repository = repository;

  Never _notImplemented() {
    final _ = _repository;
    throw UnimplementedError();
  }

  @override
  AsyncResult<HomeDashboard> call(NoParams params) {
    return _notImplemented();
  }
}

final class RefreshHomeDashboardUseCaseImpl
    implements RefreshHomeDashboardUseCase {
  final HomeRepository _repository;

  RefreshHomeDashboardUseCaseImpl({required HomeRepository repository})
    : _repository = repository;

  Never _notImplemented() {
    final _ = _repository;
    throw UnimplementedError();
  }

  @override
  AsyncResult<HomeDashboard> call(NoParams params) {
    return _notImplemented();
  }
}

final class GetHomeSyncStatusUseCaseImpl implements GetHomeSyncStatusUseCase {
  final HomeRepository _repository;

  GetHomeSyncStatusUseCaseImpl({required HomeRepository repository})
    : _repository = repository;

  Never _notImplemented() {
    final _ = _repository;
    throw UnimplementedError();
  }

  @override
  AsyncResult<HomeSyncStatus> call(NoParams params) {
    return _notImplemented();
  }
}
