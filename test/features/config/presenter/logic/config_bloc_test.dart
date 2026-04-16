import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kronos/features/config/domain/errors/config_domain_error.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kronos/core/contracts/use_case_contract.dart';
import 'package:kronos/features/config/domain/entities/config_entities.dart';
import 'package:kronos/features/config/domain/usecases/config_usecase_contracts.dart';
import 'package:kronos/features/config/presenter/logic/config_bloc.dart';
import 'package:kronos/features/config/presenter/logic/config_event.dart';
import 'package:kronos/features/config/presenter/logic/config_state.dart';
import 'package:result_dart/result_dart.dart';

class MockGetSavedGithubTokenUseCase extends Mock
    implements GetSavedGithubTokenUseCase {}

class MockSaveGithubTokenUseCase extends Mock
    implements SaveGithubTokenUseCase {}

class MockValidateGithubTokenUseCase extends Mock
    implements ValidateGithubTokenUseCase {}

class MockClearGithubTokenUseCase extends Mock
    implements ClearGithubTokenUseCase {}

class MockSyncPendingSessionsUseCase extends Mock
    implements SyncPendingSessionsUseCase {}

void main() {
  late MockGetSavedGithubTokenUseCase getSavedGithubTokenUseCase;
  late MockSaveGithubTokenUseCase saveGithubTokenUseCase;
  late MockValidateGithubTokenUseCase validateGithubTokenUseCase;
  late MockClearGithubTokenUseCase clearGithubTokenUseCase;
  late MockSyncPendingSessionsUseCase syncPendingSessionsUseCase;

  ConfigBloc buildBloc() {
    return ConfigBloc(
      getSavedGithubTokenUseCase: getSavedGithubTokenUseCase,
      saveGithubTokenUseCase: saveGithubTokenUseCase,
      validateGithubTokenUseCase: validateGithubTokenUseCase,
      clearGithubTokenUseCase: clearGithubTokenUseCase,
      syncPendingSessionsUseCase: syncPendingSessionsUseCase,
    );
  }

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const SaveGithubTokenParams(token: 'fallback'));
    registerFallbackValue(const ValidateGithubTokenParams(token: 'fallback'));
  });

  setUp(() {
    getSavedGithubTokenUseCase = MockGetSavedGithubTokenUseCase();
    saveGithubTokenUseCase = MockSaveGithubTokenUseCase();
    validateGithubTokenUseCase = MockValidateGithubTokenUseCase();
    clearGithubTokenUseCase = MockClearGithubTokenUseCase();
    syncPendingSessionsUseCase = MockSyncPendingSessionsUseCase();
  });

  group('ConfigBloc', () {
    blocTest<ConfigBloc, ConfigState>(
      'emite loading e loaded quando ConfigStarted tem sucesso',
      build: () {
        when(() => getSavedGithubTokenUseCase(any<NoParams>())).thenAnswer(
          (_) async => Success(
            const GithubToken(
              value: 'ghp_ok',
              status: GithubTokenStatus.configured,
            ),
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ConfigStarted()),
      expect: () => <Matcher>[
        isA<ConfigLoading>(),
        isA<ConfigLoaded>().having(
          (state) => state.token?.value,
          'token.value',
          'ghp_ok',
        ),
      ],
      verify: (_) {
        verify(() => getSavedGithubTokenUseCase(any<NoParams>())).called(1);
      },
    );

    blocTest<ConfigBloc, ConfigState>(
      'emite loading e failure quando ConfigStarted retorna erro',
      build: () {
        when(() => getSavedGithubTokenUseCase(any<NoParams>())).thenAnswer(
          (_) => Future<Result<GithubToken>>.value(
            Failure(ConfigTokenReadError()),
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ConfigStarted()),
      expect: () => <Matcher>[
        isA<ConfigLoading>(),
        isA<ConfigFailure>().having(
          (state) => state.message,
          'message',
          'Nao foi possivel ler o token salvo.',
        ),
      ],
    );

    blocTest<ConfigBloc, ConfigState>(
      'emite loading e loaded quando ConfigSaveTokenRequested tem sucesso',
      build: () {
        when(
          () => saveGithubTokenUseCase(any<SaveGithubTokenParams>()),
        ).thenAnswer((_) async => Success(true));

        return buildBloc();
      },
      act: (bloc) => bloc.add(const ConfigSaveTokenRequested('ghp_save')),
      expect: () => <Matcher>[
        isA<ConfigLoading>(),
        isA<ConfigLoaded>().having(
          (state) => state.token?.value,
          'token.value',
          'ghp_save',
        ),
      ],
      verify: (_) {
        verify(
          () => saveGithubTokenUseCase(
            any<SaveGithubTokenParams>(
              that: isA<SaveGithubTokenParams>().having(
                (params) => params.token,
                'token',
                'ghp_save',
              ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<ConfigBloc, ConfigState>(
      'emite loading e failure quando ConfigSaveTokenRequested retorna erro',
      build: () {
        when(
          () => saveGithubTokenUseCase(any<SaveGithubTokenParams>()),
        ).thenAnswer(
          (_) => Future<Result<bool>>.value(Failure(ConfigTokenSaveError())),
        );

        return buildBloc();
      },
      act: (bloc) => bloc.add(const ConfigSaveTokenRequested('ghp_save')),
      expect: () => <Matcher>[
        isA<ConfigLoading>(),
        isA<ConfigFailure>().having(
          (state) => state.message,
          'message',
          'Nao foi possivel salvar o token.',
        ),
      ],
    );
  });
}
