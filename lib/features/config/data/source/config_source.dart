import 'package:kronos/core/storage/storage.dart';

import '../../domain/entities/config_entities.dart';

abstract interface class ConfigSource {
  Future<GithubToken?> getSavedToken();

  Future<void> saveToken(GithubToken token);

  Future<void> clearToken();

  Future<TokenValidationResult> validateToken(GithubToken token);

  Future<SyncResult> syncPendingSessions();
}

final class SecureConfigSource implements ConfigSource {
  static const String githubTokenKey = 'github_token';

  final SecureStorageWrapper _storage;

  SecureConfigSource({required SecureStorageWrapper storage})
    : _storage = storage;

  @override
  Future<GithubToken?> getSavedToken() async {
    final String? token = await _storage.read(key: githubTokenKey);
    if (token == null || token.isEmpty) {
      return null;
    }

    return GithubToken(value: token, status: GithubTokenStatus.configured);
  }

  @override
  Future<void> saveToken(GithubToken token) {
    return _storage.write(key: githubTokenKey, value: token.value);
  }

  @override
  Future<void> clearToken() {
    return _storage.delete(key: githubTokenKey);
  }

  @override
  Future<TokenValidationResult> validateToken(GithubToken token) async {
    return const TokenValidationResult(
      status: TokenValidationStatus.unknown,
      message: 'Token validation is not implemented yet.',
    );
  }

  @override
  Future<SyncResult> syncPendingSessions() async {
    return const SyncResult(
      synchronizedCount: 0,
      failedCount: 0,
      message: 'Sync is not implemented yet.',
    );
  }
}
