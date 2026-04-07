import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kronos/features/domain/usecases/get_local_study_history_use_case.dart';
import 'package:kronos/features/domain/usecases/use_case.dart';
import 'package:kronos/features/presenter/history/logic/history_state.dart';

/// Cubit responsável por gerenciar o estado do histórico de estudo.
///
/// Coordena:
/// - Carregamento de sessões armazenadas localmente
/// - Ordenação e filtro de sessões
/// - Atualização da lista quando novas sessões são adicionadas
class HistoryCubit extends Cubit<HistoryState> {
  /// Use case para recuperar o histórico de sessões locais.
  final GetLocalStudyHistoryUseCase getHistoryUseCase;

  HistoryCubit({required this.getHistoryUseCase})
    : super(const HistoryInitial());

  /// Carrega o histórico de sessões de estudo do banco local.
  ///
  /// Implementação esperada:
  /// - Emitir [HistoryLoading] no início
  /// - Chamar getHistoryUseCase
  /// - Ordenar sessões por data (decrescente)
  /// - Emitir [HistoryLoaded] com a lista
  /// - Emitir [HistoryError] se falhar
  Future<void> loadHistory() async {
    // TODO: Implementar carregamento do histórico
    // 1. Emitir HistoryLoading()
    emit(const HistoryLoading());

    try {
      // 2. Tentar chamar getHistoryUseCase.call(NoParams())
      // 3. Receber lista de StudySession
      final sessions = await getHistoryUseCase(NoParams());

      // 4. Verificar se a lista está vazia
      if (sessions.isEmpty) {
        emit(const HistoryEmpty());
        return;
      }

      // 5. Ordenar por startTime (mais recentes primeiro)
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));

      // 6. Emitir HistoryLoaded(sessions)
      emit(HistoryLoaded(sessions));
    } catch (e) {
      // 7. Catch de exceções emitir HistoryError(message)
      emit(HistoryError('Erro ao carregar histórico'));
    }
  }

  /// Recarrega o histórico (útil após novas sessões serem salvas).
  Future<void> refresh() async {
    // TODO: Implementar refresh do histórico
    // - Chamar loadHistory() novamente
    await loadHistory();
  }
}
