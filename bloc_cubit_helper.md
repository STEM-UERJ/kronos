# Bloc / Cubit Helper — Kronos

> Kronos usa **flutter_bloc** com **Cubit** como padrão de estado.
> Cubit é um subconjunto do Bloc: sem eventos explícitos, apenas métodos que chamam `emit()`.
> Use Bloc (com eventos) apenas quando a lógica de transição de estado for complexa o suficiente para exigir `on<Event>`.

---

## 1. Dependência

```yaml
# pubspec.yaml
dependencies:
  flutter_bloc: ^9.x.x
  equatable: ^2.x.x   # para comparação de estados por valor
```

---

## 2. Anatomia de um Cubit

```
feature/
└── presenter/
    └── timer/
        └── vm/
            ├── timer_cubit.dart   ← lógica + emit
            └── timer_state.dart   ← estados imutáveis
```

---

## 3. Estado — `timer_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/study_session.dart';

sealed class TimerState extends Equatable {
  const TimerState();
}

/// Tela idle — nenhuma sessão ativa.
final class TimerIdle extends TimerState {
  const TimerIdle();
  @override List<Object?> get props => [];
}

/// Sessão em andamento — cronômetro rodando.
final class TimerRunning extends TimerState {
  final StudySession session;
  final Duration elapsed;
  final bool isPaused;

  const TimerRunning({
    required this.session,
    required this.elapsed,
    this.isPaused = false,
  });

  TimerRunning copyWith({Duration? elapsed, bool? isPaused}) => TimerRunning(
        session: session,
        elapsed: elapsed ?? this.elapsed,
        isPaused: isPaused ?? this.isPaused,
      );

  @override
  List<Object?> get props => [session, elapsed, isPaused];
}

/// Sessão finalizada com sucesso.
final class TimerFinished extends TimerState {
  final StudySession completedSession;
  const TimerFinished(this.completedSession);
  @override List<Object?> get props => [completedSession];
}

/// Erro durante start ou finish.
final class TimerError extends TimerState {
  final String message;
  const TimerError(this.message);
  @override List<Object?> get props => [message];
}
```

**Regras:**
- Estados são **`sealed`** → o compilador força a cobertura de todos os casos no `switch`.
- Estados são **imutáveis** — nunca mutá-los, sempre emitir um novo objeto.
- Use `Equatable` para que `BlocBuilder` só re-construa quando o estado mudar de valor.

---

## 4. Cubit — `timer_cubit.dart`

```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/study_session.dart';
import '../../../domain/usecases/finish_and_save_session_locally_use_case.dart';
import '../../../domain/usecases/start_study_session_use_case.dart';
import 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  final StartStudySessionUseCase _startSession;
  final FinishAndSaveSessionLocallyUseCase _finishSession;

  Timer? _ticker;

  TimerCubit({
    required StartStudySessionUseCase startSession,
    required FinishAndSaveSessionLocallyUseCase finishSession,
  })  : _startSession = startSession,
        _finishSession = finishSession,
        super(const TimerIdle());

  // ── Ações públicas ────────────────────────────────────────────────────────

  Future<void> start(String subject) async {
    try {
      final session = await _startSession(StartSessionParams(subject: subject));
      emit(TimerRunning(session: session, elapsed: Duration.zero));
      _startTicker(session);
    } catch (e) {
      emit(TimerError(e.toString()));
    }
  }

  void togglePause() {
    final current = state;
    if (current is! TimerRunning) return;

    if (current.isPaused) {
      _startTicker(current.session);
      emit(current.copyWith(isPaused: false));
    } else {
      _ticker?.cancel();
      emit(current.copyWith(isPaused: true));
    }
  }

  Future<void> finish({String? notes}) async {
    final current = state;
    if (current is! TimerRunning) return;
    _ticker?.cancel();

    try {
      final saved = await _finishSession(
        FinishSessionParams(activeSession: current.session, notes: notes),
      );
      emit(TimerFinished(saved));
    } catch (e) {
      emit(TimerError(e.toString()));
    }
  }

  void reset() => emit(const TimerIdle());

  // ── Internals ─────────────────────────────────────────────────────────────

  void _startTicker(StudySession session) {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (current is TimerRunning && !current.isPaused) {
        emit(current.copyWith(elapsed: current.elapsed + const Duration(seconds: 1)));
      }
    });
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
```

**Regras:**
- Cancele sempre o `Timer` no `close()` — evita memory leaks.
- Nunca chame `emit()` após `close()`.
- Métodos do Cubit são **verbos de ação** (`start`, `finish`, `reset`) — não expõem estado interno.

---

## 5. Fornecimento via DI — `di/` da feature

```dart
// features/presenter/timer/di/timer_providers.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';

import '../vm/timer_cubit.dart';
// importe as dependências resolvidas pelo seu DI global (get_it, etc.)
import '../../../../core/di/service_locator.dart';

/// BlocProvider para ser inserido acima do TimerPage na árvore de widgets.
BlocProvider<TimerCubit> timerCubitProvider({required Widget child}) =>
    BlocProvider(
      create: (_) => TimerCubit(
        startSession: sl(),
        finishSession: sl(),
      ),
      child: child,
    );
```

Na rota:
```dart
// timer_route.dart
final timerRoute = GoRoute(
  path: Routes.timer,
  builder: (context, state) => BlocProvider(
    create: (_) => TimerCubit(
      startSession: sl(),
      finishSession: sl(),
    ),
    child: const TimerPage(),
  ),
);
```

---

## 6. Consumindo na View

```dart
// BlocBuilder — reconstrói o widget quando o estado muda
BlocBuilder<TimerCubit, TimerState>(
  builder: (context, state) {
    return switch (state) {
      TimerIdle()      => const TimerIdleView(),
      TimerRunning()   => TimerRunningView(state: state),
      TimerFinished()  => TimerFinishedView(session: state.completedSession),
      TimerError()     => ErrorView(message: state.message),
    };
  },
)

// BlocListener — reage a efeitos colaterais (navegação, snackbar) sem rebuild
BlocListener<TimerCubit, TimerState>(
  listenWhen: (prev, curr) => curr is TimerFinished,
  listener: (context, state) {
    if (state is TimerFinished) {
      context.go(Routes.history);
    }
  },
  child: ...,
)

// Disparar ação
context.read<TimerCubit>().start('Flutter');
context.read<TimerCubit>().togglePause();
context.read<TimerCubit>().finish(notes: 'Revisei Streams');
```

**Regras:**
- Use `BlocBuilder` para **UI**.
- Use `BlocListener` para **efeitos colaterais** (navegação, dialogs, snackbars).
- Use `BlocConsumer` quando precisar de ambos no mesmo widget.
- `context.read<>()` fora do `build` (ex: callbacks); `context.watch<>()` dentro do `build`.
- Nunca use `context.watch<>()` fora do `build` — causa erros.

---

## 7. Bloc (com eventos) — quando usar

Use **Bloc** quando o estado depender de múltiplas fontes de evento que precisam de transformação (debounce, switchMap, etc.):

```dart
// Evento
sealed class HistoryEvent {}
final class HistoryLoaded extends HistoryEvent {}
final class HistoryFilterChanged extends HistoryEvent {
  final String filter;
  const HistoryFilterChanged(this.filter);
}

// Bloc
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc(this._getHistory) : super(const HistoryInitial()) {
    on<HistoryLoaded>(_onLoaded);
    on<HistoryFilterChanged>(
      _onFilterChanged,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
  }

  Future<void> _onLoaded(HistoryLoaded event, Emitter<HistoryState> emit) async {
    emit(const HistoryLoading());
    try {
      final sessions = await _getHistory(const NoParams());
      emit(HistoryLoaded(sessions));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
```
