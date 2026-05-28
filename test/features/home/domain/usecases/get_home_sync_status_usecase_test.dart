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
  late GetHomeSyncStatusUseCaseImpl usecase;

  setUp(() {
    mockRepository = MockHomeRepository();
    usecase = GetHomeSyncStatusUseCaseImpl(repository: mockRepository);
  });

  group('GetHomeSyncStatusUseCase -', () {
    test(
      'Deve retornar Success com HomeSyncStatus quando o repositório for bem-sucedido',
      () async {
        when(
          () => mockRepository.getSyncStatus(),
        ).thenAnswer((_) async => const Success(HomeSyncStatus.pending));

        final result = await usecase(NoParams());

        expect(result.isSuccess(), isTrue);
        expect(result.getOrNull(), HomeSyncStatus.pending);
        verify(() => mockRepository.getSyncStatus()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'Deve retornar Failure com Exception quando o repositório falhar',
      () async {
        final exception = Exception('Falha ao buscar status de sincronização');
        when(
          () => mockRepository.getSyncStatus(),
        ).thenAnswer((_) async => Failure(exception));

        final result = await usecase(NoParams());

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), exception);
        verify(() => mockRepository.getSyncStatus()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}
