import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kronos/features/presenter/history/logic/history_cubit.dart';
import 'package:kronos/features/presenter/history/logic/history_state.dart';

/// Página de histórico de sessões de estudo.
///
/// [HistoryPage] exibe:
/// - Lista de todas as sessões de estudo registradas
/// - Duração, assunto e data de cada sessão
/// - Opções de filtro e busca
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study History')),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          return switch (state) {
            HistoryInitial() || HistoryLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            HistoryEmpty() => const Center(
                child: Text('Nenhuma sessão registrada ainda. Inicie sua primeira sessão!'),
              ),
            HistoryError(:final message) => Center(
                child: Text('Erro ao carregar histórico: $message'),
              ),
            HistoryLoaded(:final sessions) => ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  final duration = session.endTime != null
                      ? '${session.endTime!.difference(session.startTime).inMinutes} min'
                      : 'Em andamento';

                  return ListTile(
                    title: Text(session.subject),
                    subtitle: Text(
                      '${session.startTime.day.toString().padLeft(2, '0')}/${session.startTime.month.toString().padLeft(2, '0')}/${session.startTime.year} - $duration',
                    ),
                    trailing: Icon(
                      session.isSynced ? Icons.cloud_done : Icons.cloud_upload,
                      color: session.isSynced ? Colors.green : Colors.grey,
                    ),
                  );
                },
              ),
          };
        },
      ),
    );
  }
}
