enum GithubTokenStatus { configured, missing }

enum TokenValidationStatus { valid, invalid, unknown }

final class GithubToken {
  final String value;
  final GithubTokenStatus status;

  const GithubToken({required this.value, required this.status});
}

final class TokenValidationResult {
  final TokenValidationStatus status;
  final String message;

  const TokenValidationResult({required this.status, required this.message});
}

final class SyncResult {
  final int synchronizedCount;
  final int failedCount;
  final String message;

  const SyncResult({
    required this.synchronizedCount,
    required this.failedCount,
    required this.message,
  });
}
