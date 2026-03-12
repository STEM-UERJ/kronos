import 'package:flutter/material.dart';

/// Página de histórico de sessões de estudo.
///
/// [HistoryPage] exibe:
/// - Lista de todas as sessões de estudo registradas
/// - Duração, assunto e data de cada sessão
/// - Opções de filtro e busca
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implementar UI da página de histórico
    // - Exibir lista de sessões em ordem decrescente de data
    // - Mostrar duração total de cada sessão
    // - Adicionar filtros por assunto/data
    // - Implementar busca
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: const Center(child: Text('History Page')),
    );
  }
}
