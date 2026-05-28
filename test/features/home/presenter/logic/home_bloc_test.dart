import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kronos/core/contracts/use_case_contract.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:kronos/features/home/domain/entities/home_entities.dart';
import 'package:kronos/features/home/domain/usecases/home_usecase_contracts.dart';

import 'package:kronos/features/home/presenter/logic/home_bloc.dart';
import 'package:kronos/features/home/presenter/logic/home_event.dart';
import 'package:kronos/features/home/presenter/logic/home_state.dart';

class MockGetHomeDashboardUseCase extends Mock
    implements GetHomeDashboardUseCase {}

class MockRefreshHomeDashboardUseCase extends Mock
    implements RefreshHomeDashboardUseCase {}

void main() {
  late MockGetHomeDashboardUseCase mockGetHomeDashboardUseCase;
  late MockRefreshHomeDashboardUseCase mockRefreshHomeDashboardUseCase;

  const dummyDashboard = HomeDashboard(
    greeting: 'Bom dia',
    todayTotalMinutes: 240,
    todaySessionsCount: 3,
    syncStatus: HomeSyncStatus.synced,
    weeklyProgress: [],
  );

  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockGetHomeDashboardUseCase = MockGetHomeDashboardUseCase();
    mockRefreshHomeDashboardUseCase = MockRefreshHomeDashboardUseCase();
  });

  HomeBloc buildBloc() => HomeBloc(
    getHomeDashboardUseCase: mockGetHomeDashboardUseCase,
    refreshHomeDashboardUseCase: mockRefreshHomeDashboardUseCase,
  );

  group('HomeBloc', () {
    test('O estado inicial e HomeInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, isA<HomeInitial>());
      bloc.close();
    });

    blocTest<HomeBloc, HomeState>(
      'Deve emitir [HomeLoading, HomeLoaded] quando HomeStarted for disparado com sucesso',
      build: () {
        when(
          () => mockGetHomeDashboardUseCase(any()),
        ).thenAnswer((_) async => const Success(dummyDashboard));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const HomeStarted()),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeLoaded>().having(
          (state) => state.dashboard,
          'dashboard',
          dummyDashboard,
        ),
      ],
      verify: (_) {
        verify(() => mockGetHomeDashboardUseCase(any())).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'Deve emitir [HomeLoading, HomeFailure] quando HomeStarted falhar',
      build: () {
        when(
          () => mockGetHomeDashboardUseCase(any()),
        ).thenAnswer((_) async => Failure(Exception('Erro no banco')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const HomeStarted()),
      expect: () => [isA<HomeLoading>(), isA<HomeFailure>()],
      verify: (_) {
        verify(() => mockGetHomeDashboardUseCase(any())).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'Deve emitir [HomeLoading, HomeLoaded] quando HomeRefreshRequested for disparado com sucesso',
      build: () {
        when(
          () => mockRefreshHomeDashboardUseCase(any()),
        ).thenAnswer((_) async => const Success(dummyDashboard));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const HomeRefreshRequested()),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeLoaded>().having(
          (state) => state.dashboard,
          'dashboard',
          dummyDashboard,
        ),
      ],
      verify: (_) {
        verify(() => mockRefreshHomeDashboardUseCase(any())).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'Deve emitir [HomeLoading, HomeFailure] quando HomeRefreshRequested falhar',
      build: () {
        when(
          () => mockRefreshHomeDashboardUseCase(any()),
        ).thenAnswer((_) async => Failure(Exception('Erro de sincronização')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const HomeRefreshRequested()),
      expect: () => [isA<HomeLoading>(), isA<HomeFailure>()],
      verify: (_) {
        verify(() => mockRefreshHomeDashboardUseCase(any())).called(1);
      },
    );
  });
}
