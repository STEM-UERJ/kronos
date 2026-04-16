import 'package:bloc/bloc.dart';
import 'package:result_dart/result_dart.dart';

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

  ConfigState error(Exception e) =>
      ConfigFailure((e as ConfigDomainError).message);

  Future<void> _onStarted(
    ConfigStarted event,
    Emitter<ConfigState> emit,
  ) async {
    emit(const ConfigLoading());
    await _getSavedGithubTokenUseCase(const NoParams()).fold((success) {
      final token = success.status == GithubTokenStatus.missing
          ? null
          : success;
      emit(ConfigLoaded(token: token));
    }, (e) => emit(error(e)));
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

    await _saveGithubTokenUseCase(
      SaveGithubTokenParams(token: event.token),
    ).fold((success) {
      emit(ConfigLoaded(token: token));
    }, (e) => emit(error(e)));
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
    await _validateGithubTokenUseCase(
      ValidateGithubTokenParams(token: event.token),
    ).fold((success) {
      emit(ConfigLoaded(token: token, validation: success));
    }, (e) => emit(error(e)));
  }

  Future<void> _onClearTokenRequested(
    ConfigClearTokenRequested event,
    Emitter<ConfigState> emit,
  ) async {
    emit(const ConfigLoading());
    await _clearGithubTokenUseCase(const NoParams()).fold((success) {
      emit(const ConfigLoaded());
    }, (e) => emit(error(e)));
  }

  Future<void> _onSyncRequested(
    ConfigSyncRequested event,
    Emitter<ConfigState> emit,
  ) async {
    emit(const ConfigLoading());
    await _syncPendingSessionsUseCase(const NoParams()).fold((success) {
      emit(ConfigLoaded(lastSyncResult: success));
    }, (e) => emit(error(e)));
  }
}
