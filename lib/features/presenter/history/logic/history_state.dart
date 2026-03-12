import 'package:kronos/features/domain/entities/study_session.dart';

/// Estados da página de Histórico.
///
/// Representa os diferentes estados que o gerenciador (Cubit)
/// pode emitir ao carregar o histórico de sessões.

/// Estado base para todos os estados do Histórico.
abstract class HistoryState {}

/// Estado inicial - dados ainda não carregados.
class HistoryInitial extends HistoryState {}

/// Estado de carregamento - buscando sessões do banco.
class HistoryLoading extends HistoryState {}

/// Estado após carregamento bem-sucedido.
class HistoryLoaded extends HistoryState {
  /// Lista de todas as sessões de estudo encontradas.
  final List<StudySession> sessions;

  HistoryLoaded(this.sessions);
}

/// Estado de erro durante carregamento.
class HistoryError extends HistoryState {
  /// Mensagem descrevendo o erro ocorrido.
  final String message;

  HistoryError(this.message);
}
