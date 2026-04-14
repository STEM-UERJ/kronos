import 'package:bloc/bloc.dart';

import '../../../../core/contracts/use_case_contract.dart';
import '../../domain/entities/config_entities.dart';
import '../../domain/errors/config_domain_error.dart';
import '../../domain/usecases/config_usecase_contracts.dart';
import 'config_event.dart';
import 'config_state.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  final GetSavedGithubTokenUseCase _getSavedGithubTokenUseCase;
  final SaveGithubTokenUseCase _saveGithubTokenUseCase;
  final ValidateGithubTokenUseCase _validateGithubTokenUseCase;
  final ClearGithubTokenUseCase _clearGithubTokenUseCase;
  final SyncPendingSessionsUseCase _syncPendingSessionsUseCase;

  ConfigBloc({
    required GetSavedGithubTokenUseCase getSavedGithubTokenUseCase,
    required SaveGithubTokenUseCase saveGithubTokenUseCase,
    required ValidateGithubTokenUseCase validateGithubTokenUseCase,
    required ClearGithubTokenUseCase clearGithubTokenUseCase,
    required SyncPendingSessionsUseCase syncPendingSessionsUseCase,
  }) : _getSavedGithubTokenUseCase = getSavedGithubTokenUseCase,
       _saveGithubTokenUseCase = saveGithubTokenUseCase,
       _validateGithubTokenUseCase = validateGithubTokenUseCase,
       _clearGithubTokenUseCase = clearGithubTokenUseCase,
       _syncPendingSessionsUseCase = syncPendingSessionsUseCase,
       super(const ConfigInitial()) {
    on<ConfigStarted>(_onStarted);
    on<ConfigSaveTokenRequested>(_onSaveTokenRequested);
    on<ConfigValidateTokenRequested>(_onValidateTokenRequested);
    on<ConfigClearTokenRequested>(_onClearTokenRequested);
    on<ConfigSyncRequested>(_onSyncRequested);
  }

  Future<void> _onStarted(
    ConfigStarted event,
    Emitter<ConfigState> emit,
  ) async {
    emit(const ConfigLoading());

    try {
      final GithubToken token = await _getSavedGithubTokenUseCase(
        const NoParams(),
      );
      emit(
        ConfigLoaded(
          token: token.status == GithubTokenStatus.missing ? null : token,
        ),
      );
    } on ConfigDomainError catch (error) {
      emit(ConfigFailure(error.message));
    } catch (_) {
      emit(const ConfigFailure('Failed to load settings.'));
    }
  }

  Future<void> _onSaveTokenRequested(
    ConfigSaveTokenRequested event,
    Emitter<ConfigState> emit,
  ) async {
    emit(const ConfigLoading());

    final GithubToken token = GithubToken(
      value: event.token,
      status: GithubTokenStatus.configured,
    );

    try {
      await _saveGithubTokenUseCase(SaveGithubTokenParams(token: event.token));
      emit(ConfigLoaded(token: token));
    } on ConfigDomainError catch (error) {
      emit(ConfigFailure(error.message));
    } catch (_) {
      emit(const ConfigFailure('Failed to save token.'));
    }
  }

  Future<void> _onValidateTokenRequested(
    ConfigValidateTokenRequested event,
    Emitter<ConfigState> emit,
  ) async {
    emit(const ConfigLoading());

    final GithubToken token = GithubToken(
      value: event.token,
      status: GithubTokenStatus.configured,
    );

    try {
      final TokenValidationResult validation =
          await _validateGithubTokenUseCase(
            ValidateGithubTokenParams(token: event.token),
          );
      emit(ConfigLoaded(token: token, validation: validation));
    } on ConfigDomainError catch (error) {
      emit(ConfigFailure(error.message));
    } catch (_) {
      emit(const ConfigFailure('Failed to validate token.'));
    }
  }

  Future<void> _onClearTokenRequested(
    ConfigClearTokenRequested event,
    Emitter<ConfigState> emit,
  ) async {
    emit(const ConfigLoading());
    try {
      await _clearGithubTokenUseCase(const NoParams());
      emit(const ConfigLoaded());
    } on ConfigDomainError catch (error) {
      emit(ConfigFailure(error.message));
    } catch (_) {
      emit(const ConfigFailure('Failed to clear token.'));
    }
  }

  Future<void> _onSyncRequested(
    ConfigSyncRequested event,
    Emitter<ConfigState> emit,
  ) async {
    emit(const ConfigLoading());
    try {
      final SyncResult syncResult = await _syncPendingSessionsUseCase(
        const NoParams(),
      );
      emit(ConfigLoaded(lastSyncResult: syncResult));
    } on ConfigDomainError catch (error) {
      emit(ConfigFailure(error.message));
    } catch (_) {
      emit(const ConfigFailure('Failed to sync sessions.'));
    }
  }
}
