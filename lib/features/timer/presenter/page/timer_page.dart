import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kronos/core/theme/app_colors.dart';
import 'package:kronos/features/timer/domain/entities/timer_entities.dart';
import 'package:kronos/features/timer/presenter/logic/timer_bloc.dart';
import 'package:kronos/features/timer/presenter/logic/timer_event.dart';
import 'package:kronos/features/timer/presenter/logic/timer_state.dart';
import 'package:result_dart/result_dart.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<TimerBloc, TimerState>(
        listenWhen: (previous, current) =>
            current is TimerFinished || current is TimerFailure,

        buildWhen: (previous, current) =>
            current is! TimerFailure && current is! TimerFinished,

        listener: (context, state) {
          if (state is TimerFinished) {
            _showFinishedModal(context, state.summary);
          } else if (state is TimerFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },

        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _builderBody(context, state),
          );
        },
      ),
    );
  }

  Widget _builderBody(BuildContext context, TimerState state) {
    if (state is TimerIdle || state is TimerInitial) {
      final lastSession = state is TimerIdle ? state.lastSession : null;

      return _TimerIdleView(
        key: const ValueKey('idle'),
        lastSession: lastSession,
      );
    } else if (state is TimerRunning) {
      return _TimerActiveView(
        key: const ValueKey('active'),
        session: state.session,
        isRunning: true,
      );
    } else if (state is TimerPaused) {
      return _TimerActiveView(
        key: const ValueKey('active'),
        session: state.session,
        isRunning: false,
      );
    } else {
      return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }

  void _showFinishedModal(BuildContext context, TimerSessionSummary summary) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Session Finished!',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: AppColors.teal),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subject',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          summary.subject,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Total time',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          _formatTime(summary.totalSeconds),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        if (summary.notes != null &&
                            summary.notes!.trim().isNotEmpty) ...[
                          const SizedBox(height: 16),

                          Text(
                            'Notes',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Text(
                            summary.notes!.trim(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                FilledButton(
                  onPressed: () {
                    Navigator.of(bottomSheetContext).pop();
                    context.read<TimerBloc>().add(const TimerStarted());
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimerIdleView extends StatefulWidget {
  final TimerSessionSummary? lastSession;

  const _TimerIdleView({super.key, this.lastSession});

  @override
  State<_TimerIdleView> createState() => _TimerIdleViewState();
}

class _TimerIdleViewState extends State<_TimerIdleView> {
  final TextEditingController _subjectController = TextEditingController();

  // TODO: pegar as sugestões do histórico de sessões
  final List<String> _suggestions = [
    'Flutter',
    'Dart',
    'English',
    'LLMs',
    'SOLID',
    'C#',
    'SQL',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New Session',
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 24),

          TextField(
            style: Theme.of(context).textTheme.bodyLarge,
            controller: _subjectController,
            decoration: const InputDecoration(
              hintText: 'What are you studying?',
            ),
          ),

          const SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _suggestions.map((suggestion) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(suggestion),
                    onPressed: () {
                      _subjectController.text = suggestion;
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const Spacer(),

          FloatingActionButton.large(
            shape: const CircleBorder(),
            onPressed: () {
              final subject = _subjectController.text.trim();
              if (subject.isNotEmpty) {
                context.read<TimerBloc>().add(
                  TimerPlayRequested(subject: subject),
                );
              }
            },
            child: const Icon(Icons.play_arrow, size: 48),
          ),

          const Spacer(),

          // exibe a last session
          if (widget.lastSession != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // uma row com uma column (texto + label) e o tempo da sessão
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Session',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariantDark,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),

                          // espaçamento entre as rows
                          const SizedBox(height: 2),

                          Text(
                            widget.lastSession!.subject,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.onSurfaceDark,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),

                    // espaçamento entre texto e tempo
                    const SizedBox(width: 16),

                    Text(
                      _formatShortTime(widget.lastSession!.totalSeconds),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceVariantDark,
                        textStyle: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimerActiveView extends StatefulWidget {
  final TimerSession session;
  final bool isRunning;

  const _TimerActiveView({
    super.key,
    required this.session,
    required this.isRunning,
  });

  @override
  State<_TimerActiveView> createState() => _TimerActiveViewState();
}

class _TimerActiveViewState extends State<_TimerActiveView> {
  final TextEditingController _notesController = TextEditingController();
  late int _localElapsedSeconds;
  Timer? _visualTimer;

  @override
  void initState() {
    super.initState();
    if (widget.session.notes != null) {
      _notesController.text = widget.session.notes!;
    }
    _localElapsedSeconds = widget.session.elapsedSeconds;
    _startOrStopTimer();
  }

  @override
  void didUpdateWidget(covariant _TimerActiveView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _localElapsedSeconds = widget.session.elapsedSeconds;
    if (oldWidget.isRunning != widget.isRunning) {
      _startOrStopTimer();
    }
  }

  void _startOrStopTimer() {
    _visualTimer?.cancel();
    if (widget.isRunning) {
      _visualTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _localElapsedSeconds++;
        });
      });
    }
  }

  @override
  void dispose() {
    _visualTimer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // status conexão (online/offline)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                widget.session.isSynced ? Icons.cloud : Icons.cloud_off,
                size: 16,
                color: widget.session.isSynced
                    ? AppColors.success
                    : AppColors.warning,
              ),
              const SizedBox(width: 8),
              Text(
                widget.session.isSynced ? 'Online' : 'Offline',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: widget.session.isSynced
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // badge (live + sessão)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.session.subject,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.violetLight,
                ),
              ),

              const SizedBox(height: 12),

              const Badge(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 10, color: AppColors.teal),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: AppColors.tealLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.tealContainer,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              ),
            ],
          ),

          const Spacer(),

          // timer
          Center(
            child: Text(
              _formatTime(_localElapsedSeconds),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 64,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceDark,
                textStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),

          const Spacer(),

          // botões pause/resume e finish
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.violetLight,
                    side: const BorderSide(color: AppColors.outlineDark),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (widget.isRunning) {
                      context.read<TimerBloc>().add(
                        TimerPauseRequested(
                          elapsedSeconds: _localElapsedSeconds,
                        ),
                      );
                    } else {
                      context.read<TimerBloc>().add(
                        const TimerResumeRequested(),
                      );
                    }
                  },

                  icon: Icon(
                    widget.isRunning
                        ? Icons.pause_outlined
                        : Icons.play_arrow_outlined,
                    size: 28,
                    color: AppColors.violet,
                  ),
                  label: Text(widget.isRunning ? 'Pause' : 'Resume'),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: AppColors.tealContainer,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    final notes = _notesController.text.trim();
                    context.read<TimerBloc>().add(
                      TimerFinishRequested(
                        notes: notes.isEmpty ? null : notes,
                        elapsedSeconds: _localElapsedSeconds,
                      ),
                    );
                  },
                  icon: const Icon(Icons.stop_rounded, size: 28),
                  label: Text(
                    'Finish',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.tealContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // notas
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Add notes ... (optional)',
            ),
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

String _formatTime(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String _formatShortTime(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  final h = duration.inHours;
  final m = duration.inMinutes.remainder(60);
  return '${h}h ${m}m';
}
