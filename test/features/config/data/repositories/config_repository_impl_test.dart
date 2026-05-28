import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:kronos/features/config/data/repositories/config_repository_impl.dart';
import 'package:kronos/features/config/data/source/config_source.dart';
import 'package:kronos/features/config/domain/entities/config_entities.dart';
import 'package:kronos/features/config/domain/errors/config_domain_error.dart';
import 'package:result_dart/result_dart.dart';

import 'config_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ConfigSource>()])
void main() {
  setUpAll(() {
    provideDummy(
      const TokenValidationResult(
        status: TokenValidationStatus.unknown,
        message: 'dummy',
      ),
    );
    provideDummy(
      const SyncResult(synchronizedCount: 0, failedCount: 0, message: 'dummy'),
    );
  });

  group('ConfigRepositoryImpl', () {
    late MockConfigSource source;
    late ConfigRepositoryImpl repository;

    const configuredToken = GithubToken(
      value: 'ghp_token_123',
      status: GithubTokenStatus.configured,
    );

    const validationResult = TokenValidationResult(
      status: TokenValidationStatus.valid,
      message: 'Token valido',
    );

    const syncResult = SyncResult(
      synchronizedCount: 3,
      failedCount: 1,
      message: 'Sincronizacao finalizada',
    );

    setUp(() {
      source = MockConfigSource();
      repository = ConfigRepositoryImpl(source: source);
    });

    test(
      'getSavedToken retorna token configurado quando source responde token',
      () async {
        when(source.getSavedToken()).thenAnswer((_) async => configuredToken);

        final result = await repository.getSavedToken();

        expect(result, same(configuredToken));
        verify(source.getSavedToken()).called(1);
      },
    );

    test(
      'getSavedToken retorna token missing quando source retorna null',
      () async {
        when(source.getSavedToken()).thenAnswer((_) async => null);

        final result = await repository.getSavedToken();

        expect(result.isSuccess(), false);
        expect(result.isError(), true);
        expect(result, Failure(ConfigTokenReadError()));
        verify(source.getSavedToken()).called(1);
      },
    );

    test(
      'getSavedToken converte erro generico em ConfigTokenReadError',
      () async {
        when(source.getSavedToken()).thenThrow(Exception('read-failed'));

        expect(
          repository.getSavedToken(),
          throwsA(isA<ConfigTokenReadError>()),
        );
      },
    );

    test('saveToken retorna sucesso quando source salva token', () async {
      when(source.saveToken(configuredToken)).thenAnswer((_) async {});

      final result = await repository.saveToken(configuredToken);

      expect(result, isTrue);
      verify(source.saveToken(configuredToken)).called(1);
    });

    test('saveToken converte erro generico em ConfigTokenSaveError', () async {
      when(
        source.saveToken(configuredToken),
      ).thenThrow(Exception('save-failed'));

      final result = await repository.saveToken(configuredToken);

      expect(result.isSuccess(), false);
      expect(result.isError(), true);
      expect(result, Failure(ConfigTokenSaveError()));
    });

    test(
      'clearToken converte erro generico em ConfigTokenClearError',
      () async {
        when(source.clearToken()).thenThrow(Exception('clear-failed'));

        expect(repository.clearToken(), throwsA(isA<ConfigTokenClearError>()));
      },
    );

    test(
      'validateToken retorna resultado de validacao quando source responde com sucesso',
      () async {
        when(
          source.validateToken(configuredToken),
        ).thenAnswer((_) async => validationResult);

        final result = await repository.validateToken(configuredToken);

        expect(result.isSuccess(), true);
        expect(result.isError(), false);
        expect(result, Success(validationResult));
        verify(source.validateToken(configuredToken)).called(1);
      },
    );

    test(
      'validateToken converte erro generico em ConfigTokenValidationError',
      () async {
        when(source.syncPendingSessions()).thenThrow(Exception('sync-failed'));

        expect(
          repository.syncPendingSessions(),
          throwsA(isA<ConfigSessionSyncError>()),
        );
      },
    );

    test(
      'syncPendingSessions retorna resultado quando source responde com sucesso',
      () async {
        when(source.syncPendingSessions()).thenAnswer((_) async => syncResult);

        final result = await repository.syncPendingSessions();

        expect(result.isSuccess(), true);
        expect(result.isError(), false);
        expect(result, Success(syncResult));
        verify(source.syncPendingSessions()).called(1);
      },
    );
  });
}
