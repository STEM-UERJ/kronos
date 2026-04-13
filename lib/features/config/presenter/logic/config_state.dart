import '../../domain/entities/config_entities.dart';

sealed class ConfigState {
  const ConfigState();
}

final class ConfigInitial extends ConfigState {
  const ConfigInitial();
}

final class ConfigLoading extends ConfigState {
  const ConfigLoading();
}

final class ConfigLoaded extends ConfigState {
  final GithubToken? token;
  final TokenValidationResult? validation;
  final SyncResult? lastSyncResult;

  const ConfigLoaded({this.token, this.validation, this.lastSyncResult});
}

final class ConfigFailure extends ConfigState {
  final String message;

  const ConfigFailure(this.message);
}
