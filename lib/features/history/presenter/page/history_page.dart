import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/history_entities.dart';
import '../logic/history_bloc.dart';
import '../logic/history_event.dart';
import '../logic/history_state.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HistoryBloc, HistoryState>(
      listenWhen: (previous, current) => current is HistoryDetailsLoaded || current is HistoryFailure,
      listener: (context, state) {
        if (state is HistoryDetailsLoaded) {
          _showSessionDetailsBottomSheet(context, state.details);
        } else if (state is HistoryFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('History'),
          ),
          body: Column(
            children: [
              _buildFilterChips(context, state.currentFilter),
              Expanded(
                child: _buildBody(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips(BuildContext context, HistoryFilterType currentFilter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: HistoryFilterType.values.map((filter) {
          final label = switch (filter) {
            HistoryFilterType.all => 'All',
            HistoryFilterType.thisWeek => 'This Week',
            HistoryFilterType.unsynced => 'Unsynced',
          };
          return ChoiceChip(
            label: Text(label),
            selected: currentFilter == filter,
            onSelected: (selected) {
              if (selected) {
                context.read<HistoryBloc>().add(HistoryFilterChanged(filter));
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HistoryState state) {
    if (state is HistoryLoading || state is HistoryInitial) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is HistoryLoaded) {
      if (state.sessions.isEmpty) {
        return const Center(child: Text('No sessions found.'));
      }
      return ListView.builder(
        itemCount: state.sessions.length,
        itemBuilder: (context, index) {
          final session = state.sessions[index];
          return ListTile(
            title: Text(session.subject),
            subtitle: Text(
              '${session.durationInMinutes} min • '
              '${session.startTime.month}/${session.startTime.day} '
              '${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')}',
            ),
            trailing: session.isSynced
                ? Icon(Icons.cloud_done, color: Theme.of(context).colorScheme.primary)
                : Icon(Icons.cloud_off, color: Theme.of(context).colorScheme.error),
            onTap: () {
              context.read<HistoryBloc>().add(HistorySessionSelected(session.id));
            },
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  void _showSessionDetailsBottomSheet(BuildContext context, HistorySessionDetails details) {
    final bloc = context.read<HistoryBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return _SessionDetailsSheet(details: details, bloc: bloc);
      },
    );
  }
}

class _SessionDetailsSheet extends StatefulWidget {
  final HistorySessionDetails details;
  final HistoryBloc bloc;

  const _SessionDetailsSheet({required this.details, required this.bloc});

  @override
  State<_SessionDetailsSheet> createState() => _SessionDetailsSheetState();
}

class _SessionDetailsSheetState extends State<_SessionDetailsSheet> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.details.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.details.session.subject,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: ${widget.details.session.durationInMinutes} minutes',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                widget.bloc.add(
                  HistoryNotesUpdated(
                    sessionId: widget.details.session.id,
                    notes: _notesController.text,
                  ),
                );
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Notes'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                widget.bloc.add(
                  HistorySessionDeleted(widget.details.session.id),
                );
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete Session'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
