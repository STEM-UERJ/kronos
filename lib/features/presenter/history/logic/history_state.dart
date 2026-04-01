import 'package:equatable/equatable.dart';
import 'package:kronos/features/domain/entities/study_session.dart';

/// Estados da página de Histórico.
///
/// Representa os diferentes estados que o gerenciador (Cubit)
/// pode emitir ao carregar o histórico de sessões.

/// Estado base para todos os estados do Histórico.
sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

final class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

final class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

final class HistoryEmpty extends HistoryState {
  const HistoryEmpty();
}

final class HistoryLoaded extends HistoryState {
  final List<StudySession> sessions;

  const HistoryLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

final class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
