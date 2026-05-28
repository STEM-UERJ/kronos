import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import 'package:kronos/core/contracts/use_case_contract.dart';
import 'package:kronos/features/home/domain/entities/home_entities.dart';
import 'package:kronos/features/home/domain/repositories/home_repository.dart';
import 'package:kronos/features/home/domain/usecases/home_usecases.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository mockRepository;
  late RefreshHomeDashboardUseCaseImpl usecase;

  const dummyDashboard = HomeDashboard(
    greeting: 'Boa tarde',
    todayTotalMinutes: 45,
    todaySessionsCount: 1,
    syncStatus: HomeSyncStatus.pending,
    weeklyProgress: [],
  );

  setUp(() {
    mockRepository = MockHomeRepository();
    usecase = RefreshHomeDashboardUseCaseImpl(repository: mockRepository);
  });

  group('RefreshHomeDashboardUseCase -', () {
    test(
      'Deve retornar Success com HomeDashboard quando o refresh for bem-sucedido',
      () async {
        when(
          () => mockRepository.refreshDashboard(),
        ).thenAnswer((_) async => const Success(dummyDashboard));

        final result = await usecase(NoParams());

        expect(result.isSuccess(), isTrue);
        expect(result.getOrNull(), dummyDashboard);
        verify(() => mockRepository.refreshDashboard()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'Deve retornar Failure com Exception quando o refresh falhar',
      () async {
        final exception = Exception('Falha ao dar refresh');
        when(
          () => mockRepository.refreshDashboard(),
        ).thenAnswer((_) async => Failure(exception));

        final result = await usecase(NoParams());

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), exception);
        verify(() => mockRepository.refreshDashboard()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}
