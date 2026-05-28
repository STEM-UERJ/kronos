import 'package:kronos/core/contracts/use_case_contract.dart';
import 'package:result_dart/result_dart.dart';

import '../entities/history_entities.dart';

final class GetHistorySessionsParams extends UseCaseParams {
  final HistoryQuery query;

  const GetHistorySessionsParams({required this.query});
}

final class SessionDetailsParams extends UseCaseParams {
  final String sessionId;

  const SessionDetailsParams({required this.sessionId});
}

final class UpdateSessionNotesParams extends UseCaseParams {
  final String sessionId;
  final String notes;

  const UpdateSessionNotesParams({
    required this.sessionId,
    required this.notes,
  });
}

final class DeleteSessionParams extends UseCaseParams {
  final String sessionId;

  const DeleteSessionParams({required this.sessionId});
}

abstract interface class GetHistorySessionsUseCase
    implements UseCase<List<HistorySession>, GetHistorySessionsParams> {}

abstract interface class GetHistorySessionDetailsUseCase
    implements UseCase<HistorySessionDetails, SessionDetailsParams> {}

abstract interface class UpdateHistorySessionNotesUseCase
    implements UseCase<Unit, UpdateSessionNotesParams> {}

abstract interface class DeleteHistorySessionUseCase
    implements UseCase<Unit, DeleteSessionParams> {}
