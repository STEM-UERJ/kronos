import 'package:flutter/material.dart';

/// Página principal de gerenciamento do timer de estudo.
///
/// [TimerPage] exibe a interface do usuário para:
/// - Iniciar uma nova sessão de estudo
/// - Pausar/Retomar a sessão em andamento
/// - Finalizar a sessão e salvar notas
class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implementar UI da página de timer
    // - Exibir timer em tempo real
    // - Selecionar assunto de estudo
    // - Botões para pausar/retomar/finalizar
    // - Campo de entrada para notas
    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: const Center(child: Text('Timer Page')),
    );
  }
}
