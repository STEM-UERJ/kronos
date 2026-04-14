import 'package:kronos/core/contracts/use_case_contract.dart';

import '../entities/config_entities.dart';

final class SaveGithubTokenParams extends UseCaseParams {
  final String token;

  const SaveGithubTokenParams({required this.token});
}

final class ValidateGithubTokenParams extends UseCaseParams {
  final String token;

  const ValidateGithubTokenParams({required this.token});
}

abstract interface class SaveGithubTokenUseCase
    implements UseCase<bool, SaveGithubTokenParams> {}

abstract interface class GetSavedGithubTokenUseCase
    implements UseCase<GithubToken, NoParams> {}

abstract interface class ClearGithubTokenUseCase
    implements UseCase<bool, NoParams> {}

abstract interface class ValidateGithubTokenUseCase
    implements UseCase<TokenValidationResult, ValidateGithubTokenParams> {}

abstract interface class SyncPendingSessionsUseCase
    implements UseCase<SyncResult, NoParams> {}
