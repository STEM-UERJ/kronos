import 'package:kronos/core/contracts/use_case_contract.dart';

import '../../domain/entities/home_entities.dart';
import '../../domain/repositories/home_repository.dart';
import '../source/home_source.dart';

final class HomeRepositoryImpl implements HomeRepository {
  final HomeSource _source;

  HomeRepositoryImpl({required HomeSource source}) : _source = source;

  Never _notImplemented() {
    final _ = _source;
    throw UnimplementedError();
  }

  @override
  AsyncResult<HomeDashboard> getDashboard() {
    return _notImplemented();
  }

  @override
  AsyncResult<HomeDashboard> refreshDashboard() {
    return _notImplemented();
  }

  @override
  AsyncResult<HomeSyncStatus> getSyncStatus() {
    return _notImplemented();
  }
}
