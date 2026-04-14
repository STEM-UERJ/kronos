final class GithubTokenModel {
  final String token;

  const GithubTokenModel({required this.token});
}

final class SyncResultModel {
  final int synchronizedCount;
  final int failedCount;
  final String message;

  const SyncResultModel({
    required this.synchronizedCount,
    required this.failedCount,
    required this.message,
  });
}
