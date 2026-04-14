import 'package:kronos/core/contracts/use_case_contract.dart';

import '../entities/config_entities.dart';

abstract interface class ConfigRepository {
  AsyncResult<GithubToken> getSavedToken();

  AsyncResult<bool> saveToken(GithubToken token);

  AsyncResult<bool> clearToken();

  AsyncResult<TokenValidationResult> validateToken(GithubToken token);

  AsyncResult<SyncResult> syncPendingSessions();
}
