sealed class ConfigEvent {
  const ConfigEvent();
}

final class ConfigStarted extends ConfigEvent {
  const ConfigStarted();
}

final class ConfigSaveTokenRequested extends ConfigEvent {
  final String token;

  const ConfigSaveTokenRequested(this.token);
}

final class ConfigValidateTokenRequested extends ConfigEvent {
  final String token;

  const ConfigValidateTokenRequested(this.token);
}

final class ConfigClearTokenRequested extends ConfigEvent {
  const ConfigClearTokenRequested();
}

final class ConfigSyncRequested extends ConfigEvent {
  const ConfigSyncRequested();
}
