import 'package:kronos/core/contracts/use_case_contract.dart';

import '../../domain/entities/config_entities.dart';
import '../../domain/errors/config_domain_error.dart';
import '../../domain/repositories/config_repository.dart';
import '../source/config_source.dart';

final class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigSource _source;

  ConfigRepositoryImpl({required ConfigSource source}) : _source = source;

  @override
  AsyncResult<GithubToken> getSavedToken() async {
    try {
      final GithubToken? token = await _source.getSavedToken();
      return token ??
          const GithubToken(value: '', status: GithubTokenStatus.missing);
    } catch (error, stackTrace) {
      throw ConfigTokenReadError(cause: error, stackTrace: stackTrace);
    }
  }

  @override
  AsyncResult<bool> saveToken(GithubToken token) async {
    try {
      await _source.saveToken(token);
      return true;
    } catch (error, stackTrace) {
      throw ConfigTokenSaveError(cause: error, stackTrace: stackTrace);
    }
  }

  @override
  AsyncResult<bool> clearToken() async {
    try {
      await _source.clearToken();
      return true;
    } catch (error, stackTrace) {
      throw ConfigTokenClearError(cause: error, stackTrace: stackTrace);
    }
  }

  @override
  AsyncResult<TokenValidationResult> validateToken(GithubToken token) async {
    try {
      final TokenValidationResult validationResult = await _source
          .validateToken(token);
      return validationResult;
    } catch (error, stackTrace) {
      throw ConfigTokenValidationError(cause: error, stackTrace: stackTrace);
    }
  }

  @override
  AsyncResult<SyncResult> syncPendingSessions() async {
    try {
      final SyncResult result = await _source.syncPendingSessions();
      return result;
    } catch (error, stackTrace) {
      throw ConfigSessionSyncError(cause: error, stackTrace: stackTrace);
    }
  }
}
