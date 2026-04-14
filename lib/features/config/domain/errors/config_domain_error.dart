sealed class ConfigDomainError implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const ConfigDomainError({required this.message, this.cause, this.stackTrace});

  @override
  String toString() => message;
}

final class ConfigTokenReadError extends ConfigDomainError {
  const ConfigTokenReadError({super.cause, super.stackTrace})
    : super(
        message: 'Nao foi possivel ler o token salvo.',
      );
}

final class ConfigTokenSaveError extends ConfigDomainError {
  const ConfigTokenSaveError({super.cause, super.stackTrace})
    : super(
        message: 'Nao foi possivel salvar o token.',
      );
}

final class ConfigTokenClearError extends ConfigDomainError {
  const ConfigTokenClearError({super.cause, super.stackTrace})
    : super(
        message: 'Nao foi possivel remover o token.',
      );
}

final class ConfigTokenValidationError extends ConfigDomainError {
  const ConfigTokenValidationError({super.cause, super.stackTrace})
    : super(
        message: 'Nao foi possivel validar o token.',
      );
}

final class ConfigSessionSyncError extends ConfigDomainError {
  const ConfigSessionSyncError({super.cause, super.stackTrace})
    : super(
        message: 'Nao foi possivel sincronizar as sessoes pendentes.',
      );
}
