import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import 'package:kronos/core/contracts/use_case_contract.dart';
import 'package:kronos/features/home/domain/entities/home_entities.dart';
import 'package:kronos/features/home/domain/repositories/home_repository.dart';
import 'package:kronos/features/home/domain/usecases/home_usecases.dart';

// Mock do Repositório
class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository mockRepository;
  late GetHomeDashboardUseCaseImpl usecase;

  const dummyDashboard = HomeDashboard(
    greeting: 'Bom dia',
    todayTotalMinutes: 120,
    todaySessionsCount: 3,
    syncStatus: HomeSyncStatus.synced,
    weeklyProgress: [],
  );

  setUp(() {
    mockRepository = MockHomeRepository();
    usecase = GetHomeDashboardUseCaseImpl(repository: mockRepository);
  });

  group('GetHomeDashboardUseCase -', () {
    test(
      'Deve retornar Success com HomeDashboard quando o repositório for bem-sucedido',
      () async {
        when(
          () => mockRepository.getDashboard(),
        ).thenAnswer((_) async => const Success(dummyDashboard));

        final result = await usecase(NoParams());

        expect(result.isSuccess(), isTrue);
        expect(result.getOrNull(), dummyDashboard);
        verify(() => mockRepository.getDashboard()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'Deve retornar Failure com Exception quando o repositório falhar',
      () async {
        final exception = Exception('Falha ao carregar dashboard');
        when(
          () => mockRepository.getDashboard(),
        ).thenAnswer((_) async => Failure(exception));

        final result = await usecase(NoParams());

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), exception);
        verify(() => mockRepository.getDashboard()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}
