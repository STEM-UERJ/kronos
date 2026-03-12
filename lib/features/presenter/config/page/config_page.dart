import 'package:flutter/material.dart';

/// Página de configurações da aplicação.
///
/// [ConfigPage] permite ao usuário:
/// - Configurar preferências de tema
/// - Definir metas de estudo
/// - Gerenciar sincronização com nuvem
/// - Acessar informações e sobre
class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implementar UI da página de configurações
    // - Seletor de tema (claro/escuro)
    // - Definição de metas de estudo
    // - Opções de sincronização
    // - Informações sobre o app
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Config Page')),
    );
  }
}
