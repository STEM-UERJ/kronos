# Kronos

> App Flutter **offline-first** para rastrear hábitos de estudo e foco. Construído com arquitetura em camadas (feature-first), BLoC para estado, GoRouter para navegação e GetIt para injeção de dependências.

---

## Sumário

1. [Arquitetura do App](#1-arquitetura-do-app)
2. [Domínio: Entidades e Relações](#2-domínio-entidades-e-relações)
3. [Casos de Uso por Feature](#3-casos-de-uso-por-feature)
4. [Fluxo de Trabalho Git (dev/main)](#4-fluxo-de-trabalho-git-devmain)
5. [Modelagem do Banco de Dados (produção)](#5-modelagem-do-banco-de-dados-produção)

---

## 1. Arquitetura do App

### Visão Geral

O projeto segue uma arquitetura **feature-first** com separação em camadas, favorecendo baixo acoplamento e alta testabilidade:

- **Presenter**: telas e gerenciamento de estado com BLoC.
- **Domain**: entidades, contratos de repositório e casos de uso.
- **Data**: implementações de repositórios e fontes de dados (local/remota/segura).
- **Core**: infraestrutura compartilhada (DI, router, contracts, storage, database, theme).

### Estrutura de Pastas (macro)

```text
lib/
  core/
    contracts/
    di/
    router/
    sql/
    storage/
    theme/
  features/
    home/
    timer/
    history/
    config/
      data/
      domain/
      presenter/
      di/
      route/
```

### Fluxo de Dependências

As dependências sempre apontam para dentro (camadas mais externas dependem das internas):

```text
UI/Page -> Bloc -> UseCase -> Repository (contrato) -> RepositoryImpl -> Source -> Infra (DB/Storage/API)
```

Retorno do fluxo:

```text
Infra -> Source -> RepositoryImpl -> UseCase -> Bloc (State) -> UI
```

### Bootstrap da Aplicação

No startup, a aplicação:

1. Inicializa o Flutter binding.
2. Executa `setupLocator()` para registrar dependências globais e por feature.
3. Sobe o `MaterialApp.router` com `AppRouter.router`.

### Injeção de Dependências (GetIt)

- O service locator global fica em `core/di/getit.dart` (`sl = GetIt.instance`).
- O `setupLocator` registra serviços core e chama o setup de cada feature.
- Exemplo completo: a feature **Config** registra cadeia inteira: `SecureStorageWrapper -> ConfigSource -> ConfigRepository -> UseCases -> ConfigBloc`.
- Features `home`, `timer` e `history` já possuem DI de BLoC e estão prontas para expansão incremental das camadas internas.

### Navegação (GoRouter)

- Roteamento central em `core/router/router.dart`.
- Uso de `StatefulShellRoute.indexedStack` para manter estado por aba.
- Quatro branches principais: `home`, `timer`, `history` e `settings`.
- Cada rota da feature injeta seu BLoC via `sl<FeatureBloc>()` e dispara evento inicial `*Started`.

### Contratos de Casos de Uso

- Base em `core/contracts/use_case_contract.dart`.
- Padrão de retorno assíncrono:
  - `AsyncResult<T> = Future<T>` para operações assíncronas.
  - `Result<T> = T` para operações síncronas.
- Repositórios de domínio e use cases seguem esse contrato de forma consistente.

### Persistência e Segurança

- Persistência local centralizada em `DatabaseService` (`core/sql/database.dart`).
- Armazenamento seguro encapsulado por `SecureStorageWrapper` em `core/storage/storage.dart`.
- A feature de configuração usa esse wrapper para gerenciar token com isolamento de infraestrutura.

---

## 2. Domínio: Entidades e Relações

Seguindo os princípios da Clean Architecture, a camada de domínio concentra regras de negócio e contratos, sem acoplamento com frameworks de UI, banco ou HTTP.

### Entidades (Entities)

As entidades atuais do app são organizadas por feature:

```dart
// Home
HomeDashboard {
  greeting,
  todayTotalMinutes,
  todaySessionsCount,
  syncStatus: HomeSyncStatus,
  weeklyProgress: List<WeeklyStudyPoint>
}

// Timer
TimerSession {
  id,
  subject,
  notes,
  elapsedSeconds,
  status: TimerSessionStatus
}

TimerSessionSummary {
  id,
  subject,
  totalSeconds,
  notes
}

// History
HistoryQuery { filter: HistoryFilterType }

HistorySession {
  id,
  subject,
  startTime,
  endTime,
  durationInMinutes,
  isSynced
}

HistorySessionDetails {
  session: HistorySession,
  notes
}

// Config
GithubToken { value, status: GithubTokenStatus }
TokenValidationResult { status: TokenValidationStatus, message }
SyncResult { synchronizedCount, failedCount, message }
```

### Como as entidades estão relacionadas no app

As relações mais importantes entre entidades são:

1. `HomeDashboard` agrega dados calculados de sessões e progresso semanal (`WeeklyStudyPoint`).
2. `TimerSession` representa a sessão ativa durante o cronômetro; ao finalizar, gera `TimerSessionSummary`.
3. `HistorySession` representa sessão persistida para consulta histórica; `HistorySessionDetails` compõe `HistorySession` + notas detalhadas.
4. O `id` de sessão conecta o ciclo Timer -> History: a sessão iniciada/encerrada no Timer é a mesma sessão consultada no Histórico.
5. `HomeSyncStatus` representa o estado de sincronização exibido na Home e é impactado pelos resultados de sync (`SyncResult`) e pelo estado de configuração.
6. `GithubToken` e `TokenValidationResult` modelam autorização e validade de credenciais; essas entidades influenciam se a sincronização pode ocorrer.

Visão do fluxo de entidade no produto:

```text
TimerSession (execucao)
  -> TimerSessionSummary (encerramento)
  -> HistorySession / HistorySessionDetails (persistencia e consulta)
  -> HomeDashboard (agregacao para visao resumida)

Config (GithubToken, TokenValidationResult)
  -> SyncResult
  -> HomeSyncStatus exibido na Home
```

---

## 3. Casos de Uso por Feature

### Home

| Caso de Uso | Retorno | Objetivo |
|---|---|---|
| `GetHomeDashboardUseCase` | `HomeDashboard` | Carregar painel inicial |
| `RefreshHomeDashboardUseCase` | `HomeDashboard` | Atualizar dados do painel |
| `GetHomeSyncStatusUseCase` | `HomeSyncStatus` | Obter status de sincronização |

### Timer

| Caso de Uso | Retorno | Objetivo |
|---|---|---|
| `StartTimerSessionUseCase` | `TimerSession` | Iniciar sessão |
| `PauseTimerSessionUseCase` | `TimerSession` | Pausar sessão |
| `ResumeTimerSessionUseCase` | `TimerSession` | Retomar sessão |
| `TickTimerSessionUseCase` | `TimerSession` | Atualizar tempo decorrido |
| `FinishTimerSessionUseCase` | `TimerSessionSummary` | Encerrar sessão |
| `GetLastTimerSessionUseCase` | `TimerSessionSummary?` | Buscar última sessão |

### History

| Caso de Uso | Retorno | Objetivo |
|---|---|---|
| `GetHistorySessionsUseCase` | `List<HistorySession>` | Listar sessões por filtro |
| `GetHistorySessionDetailsUseCase` | `HistorySessionDetails` | Detalhar sessão |
| `UpdateHistorySessionNotesUseCase` | `void` | Atualizar notas da sessão |
| `DeleteHistorySessionUseCase` | `void` | Remover sessão |

### Config

| Caso de Uso | Retorno | Objetivo |
|---|---|---|
| `SaveGithubTokenUseCase` | `bool` | Salvar token |
| `GetSavedGithubTokenUseCase` | `GithubToken` | Ler token salvo |
| `ClearGithubTokenUseCase` | `bool` | Limpar token |
| `ValidateGithubTokenUseCase` | `TokenValidationResult` | Validar token |
| `SyncPendingSessionsUseCase` | `SyncResult` | Sincronizar pendências |

---

## 4. Fluxo de Trabalho Git (dev/main)

Este projeto usa duas branches principais:

- `main`: somente versões estáveis (produção/release).
- `dev`: integração contínua das features aprovadas.

Todas as features nascem de `dev` e retornam para `dev` via Pull Request. A `main` recebe mudanças apenas a partir de `dev`.

### 4.1 Configuração do Projeto (repositório)

Configuração recomendada para evitar sobrescrita de código entre features:

1. Proteger `main`:
- bloquear push direto.
- exigir PR com checks obrigatórios.
- exigir pelo menos 1 review.
- bloquear merge com conflitos.

2. Proteger `dev`:
- bloquear push direto (ou restringir ao head).
- exigir PR para entrada de `feat/*`, `fix/*`, `refactor/*`.
- exigir branch atualizada com `dev` antes do merge.

3. Política de merge:
- usar merge commit ou squash no PR (padronizar um só).
- desabilitar force push em `dev` e `main`.

4. Convenção de branch:
- `feat/nome-feature`
- `fix/nome-correcao`
- `refactor/nome-ajuste`

### 4.2 O que cada dev faz para pegar e desenvolver uma feature

Passo a passo padrão:

```bash
git clone <url-do-repo>
cd kronos

git fetch origin
git switch dev
git pull --rebase origin dev

git switch -c feat/minha-feature
```

Durante o desenvolvimento:

```bash
git add .
git commit -m "feat: implementa <descricao>"
git push -u origin feat/minha-feature
```

Antes de abrir PR para `dev`:

```bash
git fetch origin
git switch feat/minha-feature
git rebase origin/dev
git push --force-with-lease
```

Depois abrir PR: `feat/minha-feature` -> `dev`.

### 4.3 Como pegar a feature de outra pessoa para testar localmente

Se precisar revisar/testar a branch de outro dev:

```bash
git fetch origin
git switch -c review/nome-feature origin/feat/nome-feature
```

Para voltar ao fluxo normal:

```bash
git switch dev
git pull --rebase origin dev
```

### 4.4 O que o head faz para mesclar todas as features sem sobrescrever outras

Processo seguro de integração:

1. Mantém `dev` sempre atualizado e integra uma feature por vez.
2. Exige que cada PR esteja atualizado com `origin/dev` (rebase feito pelo autor).
3. Valida conflitos arquivo a arquivo, sem usar resolução global automática.
4. Em conflito, resolve junto com o dono da feature para preservar intenção de negócio.
5. Roda build/testes após cada merge em `dev`.
6. Só depois de `dev` estabilizado abre PR de release: `dev` -> `main`.

Comandos úteis do head para integração:

```bash
git fetch origin
git switch dev
git pull --rebase origin dev

# opcional: inspecionar diferenças da feature
git log --oneline origin/dev..origin/feat/nome-feature
git diff --name-only origin/dev...origin/feat/nome-feature
```

### 4.5 Regras práticas para não substituir código de outras features

1. Nunca fazer merge de PR com conflito sem revisar cada bloco.
2. Nunca usar force push em `dev` ou `main`.
3. Evitar PRs gigantes; preferir PRs pequenos por feature.
4. Separar responsabilidade por pasta/feature sempre que possível.
5. Rebase frequente da feature com `origin/dev` para reduzir conflito tardio.
6. Se duas features mexem no mesmo arquivo, alinhar ordem de merge e dono da decisão final naquele ponto.

---

## 5. Modelagem do Banco de Dados (produção)

Como o app já está em produção e a estratégia atual não usa migração por versão de schema, o banco foi modelado para autoajuste em runtime:

1. versão fixa do banco (`version = 1`).
2. ao abrir (`onOpen`), o app verifica tabela/colunas/índices obrigatórios.
3. se faltar coluna, executa `ALTER TABLE`.
4. normaliza dados legados (status, timestamps e campos nulos).

### 5.1 Tabela central persistida

Uma única tabela concentra o estado persistente de sessão:

- tabela: `study_sessions`
- chave: `id`
- campos principais:
  - `subject`, `notes`
  - `start_time`, `end_time`
  - `status` (`running`, `paused`, `finished`)
  - `elapsed_seconds`
  - `is_synced`, `sync_attempts`, `last_sync_error`
  - `created_at`, `updated_at`, `deleted_at`

### 5.2 Relação entre entidades e banco

Entidades que viram persistência direta:

1. `TimerSession`
2. `TimerSessionSummary`
3. `HistorySession`
4. `HistorySessionDetails`

Entidades que são projeções/regras (não tabela própria):

1. `HomeDashboard`
2. `WeeklyStudyPoint`
3. `HomeSyncStatus`
4. `TokenValidationResult`
5. `SyncResult`

### 5.3 Como cada feature consome a mesma tabela

1. Timer:
- cria sessão (`running`), pausa/retoma (`status`), atualiza tempo (`elapsed_seconds`) e finaliza (`finished`, `end_time`).

2. History:
- lista sessões finalizadas, detalha por `id`, atualiza `notes` e remove por soft delete (`deleted_at`).

3. Home:
- calcula agregados (minutos do dia, quantidade de sessões, progresso semanal) a partir das sessões persistidas.

4. Config/Sync:
- consulta pendências por `is_synced = 0`, marca sincronizadas e registra falhas em `sync_attempts` e `last_sync_error`.

### 5.4 Índices para performance

Índices aplicados:

1. `idx_sessions_status`
2. `idx_sessions_start_time`
3. `idx_sessions_sync`
4. `idx_sessions_deleted_at`

Esse desenho permite evoluir as features sem criar tabelas duplicadas para cada visão, mantendo consistência em um único estado de sessão.