# 📚 Estrutura de Exercício - Kronos App

## ✅ Arquivos Criados para Implementação dos Alunos

Este documento descreve todos os arquivos criados com comentários `TODO` para guiar a implementação.

---

## 🎯 Camada de Apresentação (Presenter)

### Pages (Páginas)
```
lib/features/presenter/
├── home/page/home_page.dart                  ✅ Página inicial
├── timer/page/timer_page.dart                ✅ Página do timer
├── history/page/history_page.dart            ✅ Página de histórico
└── config/page/config_page.dart              ✅ Página de configurações
```

**O que fazer:**
- Implementar a UI de cada página
- Conectar com os respectivos Cubits usando BlocBuilder/BlocListener
- Usar os states emitidos pelo Cubit para controlar a interface

---

### States & Cubits (Lógica)
```
lib/features/presenter/
├── timer/logic/
│   ├── timer_state.dart                      ✅ Estados do Timer
│   └── timer_cubit.dart                      ✅ Lógica do Timer
└── history/logic/
    ├── history_state.dart                    ✅ Estados do Histórico
    └── history_cubit.dart                    ✅ Lógica do Histórico
```

**Arquivos criados com TODO:**

#### [timer_state.dart](lib/features/presenter/timer/logic/timer_state.dart)
- `TimerInitial` - Estado inicial
- `TimerRunning` - Timer em execução
- `TimerPaused` - Timer pausado
- `TimerFinished` - Sessão finalizada
- `TimerError` - Erro

#### [timer_cubit.dart](lib/features/presenter/timer/logic/timer_cubit.dart)
- `startTimer(subject)` - Inicia novo timer
- `pauseTimer()` - Pausa timer
- `resumeTimer()` - Retoma timer
- `finishSession(notes)` - Finaliza e salva sessão

#### [history_state.dart](lib/features/presenter/history/logic/history_state.dart)
- `HistoryInitial` - Sem dados
- `HistoryLoading` - Carregando
- `HistoryLoaded` - Dados carregados
- `HistoryError` - Erro

#### [history_cubit.dart](lib/features/presenter/history/logic/history_cubit.dart)
- `loadHistory()` - Carrega histórico
- `refresh()` - Recarrega histórico

---

## 🏗️ Camada de Domínio (Domain)

### Entities (já existe)
```
lib/features/domain/entities/
└── study_session.dart                        ✅ StudySession (entidade central)
```

**Utilidades:**
- `duration` - Duração total da sessão
- `elapsed` - Tempo decorrido até agora
- `isCompleted` - Se a sessão foi finalizada
- `copyWith()` - Copia com alterações

---

### Use Cases
```
lib/features/domain/usecases/
├── use_case.dart                             ✅ Interface base (já existe)
├── start_study_session_use_case.dart         ✅ COM TODO
├── finish_and_save_session_locally_use_case.dart  ✅ COM TODO
└── get_local_study_history_use_case.dart     ✅ COM TODO
```

**Implementação necessária:**

#### [start_study_session_use_case.dart](lib/features/domain/usecases/start_study_session_use_case.dart)
```dart
// TODO: Gerar ID e criar StudySession com startTime = now(), endTime = null
```

#### [finish_and_save_session_locally_use_case.dart](lib/features/domain/usecases/finish_and_save_session_locally_use_case.dart)
```dart
// TODO: Completar sessão (endTime = now()), salvar no repositório
```

#### [get_local_study_history_use_case.dart](lib/features/domain/usecases/get_local_study_history_use_case.dart)
```dart
// TODO: Recuperar todas as sessões via repositório
```

---

### Repositories (Interface - já existe)
```
lib/features/domain/repositories/
└── study_session_repository.dart             ✅ Interface (já implementada)
```

---

## 💾 Camada de Dados (Data)

### Models
```
lib/features/data/model/
└── study_session_model.dart                  ✅ COM TODO
```

**Implementação necessária:**

#### [study_session_model.dart](lib/features/data/model/study_session_model.dart)
- `fromMap()` - Converte mapa Sqflite → modelo
- `toMap()` - Converte modelo → mapa Sqflite
- `fromEntity()` - Converte entidade → modelo

---

### Data Sources
```
lib/features/data/source/
└── local_study_session_source.dart           ✅ COM TODO
```

**Implementação necessária:**

#### [local_study_session_source.dart](lib/features/data/source/local_study_session_source.dart)

Interface:
```dart
abstract interface class LocalStudySessionSource {
  Future<void> saveSession(StudySessionModel session);
  Future<List<StudySessionModel>> getAllSessions();
  Future<StudySessionModel?> getSessionById(String id);
  Future<void> updateSync(String sessionId, bool isSynced);
  Future<void> deleteSession(String id);
}
```

Implementação (`LocalStudySessionSourceImpl`):
- `initDatabase()` - Criar tabela `study_sessions`
- `saveSession()` - INSERT na tabela
- `getAllSessions()` - SELECT * ORDER BY startTime DESC
- `getSessionById()` - SELECT WHERE id = ?
- `updateSync()` - UPDATE isSynced
- `deleteSession()` - DELETE WHERE id = ?

**Schema da tabela:**
```sql
CREATE TABLE study_sessions (
  id TEXT PRIMARY KEY,
  subject TEXT NOT NULL,
  startTime INTEGER NOT NULL,          -- timestamp em ms
  endTime INTEGER,                      -- null se em andamento
  isSynced INTEGER DEFAULT 0,           -- 0=false, 1=true
  notes TEXT,
  createdAt INTEGER DEFAULT current_timestamp
)
```

---

### Repositories (Implementação)
```
lib/features/data/repositories/
└── study_session_repository_impl.dart        ✅ COM TODO
```

**Implementação necessária:**

#### [study_session_repository_impl.dart](lib/features/data/repositories/study_session_repository_impl.dart)

Implementar interface `StudySessionRepository`:
- `saveSession()` - Delega para localSource.saveSession()
- `getAllSessions()` - Delega para localSource.getAllSessions()
- `getUnsyncedSessions()` - Filtra sessões onde isSynced == false
- `markAsSynced()` - Delega para localSource.updateSync()

---

## 🔄 Fluxo de Dados

```
┌─────────────────────────────────────────────────────────┐
│                    APLICAÇÃO                            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Page (UI)                                              │
│    ↕ BlocBuilder                                        │
│  Cubit (Lógica)                                         │
│    ↕ call()                                             │
│  Use Case (Regra de Negócio)                            │
│    ↕ call()                                             │
│  Repository (Interface)                                 │
│    ↕ implementação                                      │
│  Repository Impl (Coordenação)                          │
│    ↕ delegação                                          │
│  Data Source (Banco Local - Sqflite)                    │
│    ↕ I/O                                                │
│  Banco de Dados SQLite                                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 📝 Ordem Sugerida de Implementação

1. ✅ **Models** (`StudySessionModel`)
   - `fromMap()` - converter banco → objeto
   - `toMap()` - converter objeto → banco
   - `fromEntity()` - converter entidade → modelo

2. ✅ **Data Source** (`LocalStudySessionSourceImpl`)
   - `initDatabase()` - criar tabela
   - `saveSession()` - INSERT
   - `getAllSessions()` - SELECT com ordenação
   - `getSessionById()` - SELECT por ID
   - `updateSync()` - UPDATE
   - `deleteSession()` - DELETE

3. ✅ **Repository** (`StudySessionRepositoryImpl`)
   - Implementar interface delegando para data source

4. ✅ **Use Cases** (domínio)
   - `StartStudySessionUseCase` - criar sessão
   - `FinishAndSaveSessionLocallyUseCase` - salvar sessão
   - `GetLocalStudyHistoryUseCase` - recuperar histórico

5. ✅ **States & Cubits** (apresentação)
   - `TimerState` + `TimerCubit`
   - `HistoryState` + `HistoryCubit`

6. ✅ **Pages** (UI)
   - Conectar Cubits com Pages usando BlocBuilder
   - Implementar interface visual

---

## 🔧 Dependencies Utilizadas

No projeto já estão configuradas:
- **flutter_bloc** - Gerenciamento de estado (BLoC pattern)
- **sqflite** - Banco de dados local SQLite
- **get_it** - Service Locator (injeção de dependência)
- **flutter** - Framework

---

## 📚 Referências Úteis

- [Clean Architecture no Flutter](https://resocoder.com/flutter-clean-architecture-tdd)
- [BLoC Pattern Documentation](https://bloclibrary.dev/)
- [Sqflite Documentation](https://pub.dev/packages/sqflite)
- [GetIt Service Locator](https://pub.dev/packages/get_it)
- [Dart DateTime](https://dart.dev/guides/libraries/library-tour#dartcore---numbers-strings-collections-utilities-and-more)

---

## ⚠️ Pontos Importantes

1. **StudySession é imutável** - Use `copyWith()` para modificar
2. **Timestamps em Sqflite** - Use `millisecondsSinceEpoch` ou segundos, NÃO DateTime direto
3. **Bools em Sqflite** - Store como INTEGER (0 = false, 1 = true)
4. **IDs únicos** - Use `DateTime.now().microsecondsSinceEpoch.toString()` ou package `uuid`
5. **Ordenação** - getAllSessions() deve retornar em ordem DECRESCENTE (mais recentes primeiro)

---

**Boa sorte com a implementação!** 🚀

Qualquer dúvida sobre a arquitetura ou sobre o que implementar em cada arquivo, consulte os comentários `TODO` dentro dos arquivos.
