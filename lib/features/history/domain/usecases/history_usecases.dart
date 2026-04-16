import 'package:result_dart/result_dart.dart';

import '../entities/history_entities.dart';
import '../repositories/history_repository.dart';
import 'history_usecase_contracts.dart';

final class GetHistorySessionsUseCaseImpl implements GetHistorySessionsUseCase {
  final HistoryRepository _repository;

  GetHistorySessionsUseCaseImpl({required HistoryRepository repository})
    : _repository = repository;

  Never _notImplemented() {
    final _ = _repository;
    throw UnimplementedError();
  }

  @override
  AsyncResult<List<HistorySession>> call(GetHistorySessionsParams params) {
    return _notImplemented();
  }
}

final class GetHistorySessionDetailsUseCaseImpl
    implements GetHistorySessionDetailsUseCase {
  final HistoryRepository _repository;

  GetHistorySessionDetailsUseCaseImpl({required HistoryRepository repository})
    : _repository = repository;

  Never _notImplemented() {
    final _ = _repository;
    throw UnimplementedError();
  }

  @override
  AsyncResult<HistorySessionDetails> call(SessionDetailsParams params) {
    return _notImplemented();
  }
}

final class UpdateHistorySessionNotesUseCaseImpl
    implements UpdateHistorySessionNotesUseCase {
  final HistoryRepository _repository;

  UpdateHistorySessionNotesUseCaseImpl({required HistoryRepository repository})
    : _repository = repository;

  Never _notImplemented() {
    final _ = _repository;
    throw UnimplementedError();
  }

  @override
  AsyncResult<Unit> call(UpdateSessionNotesParams params) {
    return _notImplemented();
  }
}

final class DeleteHistorySessionUseCaseImpl
    implements DeleteHistorySessionUseCase {
  final HistoryRepository _repository;

  DeleteHistorySessionUseCaseImpl({required HistoryRepository repository})
    : _repository = repository;

  Never _notImplemented() {
    final _ = _repository;
    throw UnimplementedError();
  }

  @override
  AsyncResult<Unit> call(DeleteSessionParams params) {
    return _notImplemented();
  }
}
