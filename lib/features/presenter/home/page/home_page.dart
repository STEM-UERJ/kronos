import 'package:flutter/material.dart';

/// Página inicial do aplicativo Kronos.
///
/// [HomePage] exibe a interface principal onde o usuário pode:
/// - Visualizar resumo de sessões recentes
/// - Acessar o timer para iniciar uma nova sessão
/// - Ver estatísticas gerais de estudo
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implementar UI da página inicial
    // - Exibir widgets com resumo de estudos
    // - Mostrar sessões recentes
    // - Adicionar botão para iniciar sessão
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Page')),
    );
  }
}
