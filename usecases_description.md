# Casos de Uso do App Kronos

Este documento descreve todos os casos de uso do app com base nos contratos da camada de dominio.

## Visao geral

O app esta organizado por features:
- Home
- Timer
- History
- Config

Total de casos de uso mapeados: 18

## Home

### UC-HOME-01 - Obter dashboard inicial
- Nome tecnico: GetHomeDashboardUseCase
- Objetivo: carregar o resumo principal da tela Home.
- Entrada: NoParams
- Saida: HomeDashboard
- Dados principais retornados:
  - saudacao (greeting)
  - minutos totais de hoje
  - quantidade de sessoes de hoje
  - status de sincronizacao
  - progresso semanal
- Acionamento esperado: abertura da tela Home.

### UC-HOME-02 - Atualizar dashboard
- Nome tecnico: RefreshHomeDashboardUseCase
- Objetivo: atualizar os dados do dashboard da Home.
- Entrada: NoParams
- Saida: HomeDashboard
- Acionamento esperado: gesto de refresh ou recarga manual da Home.

### UC-HOME-03 - Obter status de sincronizacao
- Nome tecnico: GetHomeSyncStatusUseCase
- Objetivo: consultar o estado atual de sincronizacao exibido na Home.
- Entrada: NoParams
- Saida: HomeSyncStatus (synced, pending, error)
- Acionamento esperado: composicao da Home e atualizacoes de status.

## Timer

### UC-TIMER-01 - Iniciar sessao de estudo
- Nome tecnico: StartTimerSessionUseCase
- Objetivo: criar e iniciar uma nova sessao de timer.
- Entrada: StartTimerSessionParams
  - subject (obrigatorio)
  - notes (opcional)
- Saida: TimerSession
- Acionamento esperado: acao de play/start na tela Timer.

### UC-TIMER-02 - Pausar sessao
- Nome tecnico: PauseTimerSessionUseCase
- Objetivo: pausar uma sessao ativa.
- Entrada: SessionIdParams
  - sessionId
- Saida: TimerSession
- Acionamento esperado: botao de pausa na tela Timer.

### UC-TIMER-03 - Retomar sessao
- Nome tecnico: ResumeTimerSessionUseCase
- Objetivo: retomar uma sessao pausada.
- Entrada: SessionIdParams
  - sessionId
- Saida: TimerSession
- Acionamento esperado: botao de resume na tela Timer.

### UC-TIMER-04 - Atualizar progresso da sessao (tick)
- Nome tecnico: TickTimerSessionUseCase
- Objetivo: atualizar tempo decorrido da sessao.
- Entrada: TickTimerSessionParams
  - sessionId
  - elapsedSeconds
- Saida: TimerSession
- Acionamento esperado: ciclo de atualizacao do cronometro.

### UC-TIMER-05 - Finalizar sessao
- Nome tecnico: FinishTimerSessionUseCase
- Objetivo: encerrar sessao ativa e gerar resumo.
- Entrada: FinishTimerSessionParams
  - sessionId
  - notes (opcional)
- Saida: TimerSessionSummary
- Acionamento esperado: botao de finalizar na tela Timer.

### UC-TIMER-06 - Obter ultima sessao
- Nome tecnico: GetLastTimerSessionUseCase
- Objetivo: recuperar o ultimo resumo de sessao.
- Entrada: NoParams
- Saida: TimerSessionSummary? (pode ser nulo)
- Acionamento esperado: carregamento inicial da tela Timer.

## History

### UC-HISTORY-01 - Listar sessoes do historico
- Nome tecnico: GetHistorySessionsUseCase
- Objetivo: buscar sessoes de estudo para listagem.
- Entrada: GetHistorySessionsParams
  - query: HistoryQuery (all, thisWeek, unsynced)
- Saida: List<HistorySession>
- Acionamento esperado: abertura da tela History e mudanca de filtro.

### UC-HISTORY-02 - Obter detalhes de sessao
- Nome tecnico: GetHistorySessionDetailsUseCase
- Objetivo: carregar detalhes de uma sessao selecionada.
- Entrada: SessionDetailsParams
  - sessionId
- Saida: HistorySessionDetails
- Acionamento esperado: selecao de item no historico.

### UC-HISTORY-03 - Atualizar notas da sessao
- Nome tecnico: UpdateHistorySessionNotesUseCase
- Objetivo: editar notas de uma sessao existente.
- Entrada: UpdateSessionNotesParams
  - sessionId
  - notes
- Saida: void
- Acionamento esperado: salvar alteracao de anotacoes na tela de detalhes.

### UC-HISTORY-04 - Excluir sessao
- Nome tecnico: DeleteHistorySessionUseCase
- Objetivo: remover uma sessao do historico.
- Entrada: DeleteSessionParams
  - sessionId
- Saida: void
- Acionamento esperado: acao de exclusao no item de historico/detalhes.

## Config

### UC-CONFIG-01 - Salvar token GitHub
- Nome tecnico: SaveGithubTokenUseCase
- Objetivo: persistir token de acesso para integracao remota.
- Entrada: SaveGithubTokenParams
  - token
- Saida: bool (true em sucesso)
- Acionamento esperado: salvar token na tela de configuracoes.

### UC-CONFIG-02 - Obter token salvo
- Nome tecnico: GetSavedGithubTokenUseCase
- Objetivo: recuperar token armazenado.
- Entrada: NoParams
- Saida: GithubToken
  - status esperado: configured ou missing
- Acionamento esperado: inicializacao da tela de configuracoes.

### UC-CONFIG-03 - Limpar token salvo
- Nome tecnico: ClearGithubTokenUseCase
- Objetivo: remover token persistido.
- Entrada: NoParams
- Saida: bool (true em sucesso)
- Acionamento esperado: acao de limpar/remover token na configuracao.

### UC-CONFIG-04 - Validar token GitHub
- Nome tecnico: ValidateGithubTokenUseCase
- Objetivo: verificar validade do token informado.
- Entrada: ValidateGithubTokenParams
  - token
- Saida: TokenValidationResult
  - status: valid, invalid, unknown
  - message: mensagem de retorno da validacao
- Acionamento esperado: acao de validar token na configuracao.

### UC-CONFIG-05 - Sincronizar sessoes pendentes
- Nome tecnico: SyncPendingSessionsUseCase
- Objetivo: sincronizar dados locais pendentes com backend remoto.
- Entrada: NoParams
- Saida: SyncResult
  - synchronizedCount
  - failedCount
  - message
- Acionamento esperado: acao manual de sync na tela de configuracao.

## Mapa resumido por camada

Para cada caso de uso, o fluxo arquitetural esperado e:
- Source (data bruta)
- Repository (contrato de dominio e normalizacao)
- UseCase (regra de aplicacao)
- Bloc (orquestracao de estado para UI)
- Page/Components (interface)

## Observacao

Este documento lista os casos de uso existentes no dominio atualmente. A implementacao de parte deles pode estar em estado de esqueleto (UnimplementedError) ate a conclusao das features.