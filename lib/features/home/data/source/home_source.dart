import '../../domain/entities/home_entities.dart';

abstract interface class HomeSource {
  Future<HomeDashboard> getDashboard();

  Future<HomeDashboard> refreshDashboard();

  Future<HomeSyncStatus> getSyncStatus();
}
