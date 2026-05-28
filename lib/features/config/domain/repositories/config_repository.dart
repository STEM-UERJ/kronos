import 'package:result_dart/result_dart.dart';

import '../entities/config_entities.dart';

abstract interface class ConfigRepository {
  AsyncResult<GithubToken> getSavedToken();

  AsyncResult<bool> saveToken(GithubToken token);

  AsyncResult<bool> clearToken();

  AsyncResult<TokenValidationResult> validateToken(GithubToken token);

  AsyncResult<SyncResult> syncPendingSessions();
}
