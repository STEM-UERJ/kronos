import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:kronos/features/home/data/repositories/home_repository_impl.dart';
import 'package:kronos/features/home/data/source/home_source.dart';
import 'package:kronos/features/home/domain/entities/home_entities.dart';

import 'home_repository_contract_test.mocks.dart';

@GenerateNiceMocks([MockSpec<HomeSource>()])
void main() {
  setUpAll(() {
    provideDummy(
      const HomeDashboard(
        greeting: 'dummy',
        todayTotalMinutes: 0,
        todaySessionsCount: 0,
        syncStatus: HomeSyncStatus.synced,
        weeklyProgress: [],
      ),
    );
  });

  group('HomeRepositoryImpl', () {
    late MockHomeSource source;
    late HomeRepositoryImpl repository;

    const dashboard = HomeDashboard(
      greeting: 'Bom dia',
      todayTotalMinutes: 90,
      todaySessionsCount: 2,
      syncStatus: HomeSyncStatus.synced,
      weeklyProgress: [
        WeeklyStudyPoint(dayLabel: 'Seg', minutes: 30, isToday: true),
      ],
    );

    setUp(() {
      source = MockHomeSource();
      repository = HomeRepositoryImpl(source: source);
    });

    test('getDashboard retorna dashboard no caso de sucesso', () async {
      when(source.getDashboard()).thenAnswer((_) async => dashboard);

      final result = await repository.getDashboard();

      expect(result.greeting, 'Bom dia');
      expect(result.todayTotalMinutes, 90);
      expect(result.syncStatus, HomeSyncStatus.synced);
      verify(source.getDashboard()).called(1);
    });

    test('getDashboard propaga erro no caso de falha', () async {
      when(source.getDashboard()).thenAnswer(
        (_) => Future<HomeDashboard>.error(Exception('dashboard-failed')),
      );

      expect(repository.getDashboard(), throwsA(isA<Exception>()));
      verify(source.getDashboard()).called(1);
    });

    test('refreshDashboard retorna dashboard no caso de sucesso', () async {
      when(source.refreshDashboard()).thenAnswer((_) async => dashboard);

      final result = await repository.refreshDashboard();

      expect(result.greeting, 'Bom dia');
      expect(result.todaySessionsCount, 2);
      verify(source.refreshDashboard()).called(1);
    });

    test('refreshDashboard propaga erro no caso de falha', () async {
      when(source.refreshDashboard()).thenAnswer(
        (_) => Future<HomeDashboard>.error(Exception('refresh-failed')),
      );

      expect(repository.refreshDashboard(), throwsA(isA<Exception>()));
      verify(source.refreshDashboard()).called(1);
    });

    test('getSyncStatus retorna status no caso de sucesso', () async {
      when(
        source.getSyncStatus(),
      ).thenAnswer((_) async => HomeSyncStatus.pending);

      final result = await repository.getSyncStatus();

      expect(result, HomeSyncStatus.pending);
      verify(source.getSyncStatus()).called(1);
    });

    test('getSyncStatus propaga erro no caso de falha', () async {
      when(source.getSyncStatus()).thenAnswer(
        (_) => Future<HomeSyncStatus>.error(Exception('status-failed')),
      );

      expect(repository.getSyncStatus(), throwsA(isA<Exception>()));
      verify(source.getSyncStatus()).called(1);
    });
  });
}
