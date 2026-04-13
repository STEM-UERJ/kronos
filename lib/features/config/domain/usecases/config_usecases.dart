import '../../../../core/contracts/use_case_contract.dart';
import '../entities/config_entities.dart';
import '../repositories/config_repository.dart';
import 'config_usecase_contracts.dart';

final class SaveGithubTokenUseCaseImpl implements SaveGithubTokenUseCase {
  final ConfigRepository _repository;

  SaveGithubTokenUseCaseImpl({required ConfigRepository repository})
    : _repository = repository;

  @override
  AsyncResult<bool> call(SaveGithubTokenParams params) {
    final GithubToken token = GithubToken(
      value: params.token,
      status: GithubTokenStatus.configured,
    );

    return _repository.saveToken(token);
  }
}

final class GetSavedGithubTokenUseCaseImpl
    implements GetSavedGithubTokenUseCase {
  final ConfigRepository _repository;

  GetSavedGithubTokenUseCaseImpl({required ConfigRepository repository})
    : _repository = repository;

  @override
  AsyncResult<GithubToken> call(NoParams params) {
    return _repository.getSavedToken();
  }
}

final class ClearGithubTokenUseCaseImpl implements ClearGithubTokenUseCase {
  final ConfigRepository _repository;

  ClearGithubTokenUseCaseImpl({required ConfigRepository repository})
    : _repository = repository;

  @override
  AsyncResult<bool> call(NoParams params) {
    return _repository.clearToken();
  }
}

final class ValidateGithubTokenUseCaseImpl
    implements ValidateGithubTokenUseCase {
  final ConfigRepository _repository;

  ValidateGithubTokenUseCaseImpl({required ConfigRepository repository})
    : _repository = repository;

  @override
  AsyncResult<TokenValidationResult> call(ValidateGithubTokenParams params) {
    final GithubToken token = GithubToken(
      value: params.token,
      status: GithubTokenStatus.configured,
    );

    return _repository.validateToken(token);
  }
}

final class SyncPendingSessionsUseCaseImpl
    implements SyncPendingSessionsUseCase {
  final ConfigRepository _repository;

  SyncPendingSessionsUseCaseImpl({required ConfigRepository repository})
    : _repository = repository;

  @override
  AsyncResult<SyncResult> call(NoParams params) {
    return _repository.syncPendingSessions();
  }
}
