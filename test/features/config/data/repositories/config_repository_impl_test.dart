import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:kronos/features/config/data/repositories/config_repository_impl.dart';
import 'package:kronos/features/config/data/source/config_source.dart';
import 'package:kronos/features/config/domain/entities/config_entities.dart';
import 'package:kronos/features/config/domain/errors/config_domain_error.dart';

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

        expect(result.value, isEmpty);
        expect(result.status, GithubTokenStatus.missing);
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

      expect(
        repository.saveToken(configuredToken),
        throwsA(isA<ConfigTokenSaveError>()),
      );
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

        expect(result.status, TokenValidationStatus.valid);
        expect(result.message, 'Token valido');
        verify(source.validateToken(configuredToken)).called(1);
      },
    );

    test(
      'syncPendingSessions converte erro generico em ConfigSessionSyncError',
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

        expect(result.synchronizedCount, 3);
        expect(result.failedCount, 1);
        expect(result.message, 'Sincronizacao finalizada');
        verify(source.syncPendingSessions()).called(1);
      },
    );
  });
}
