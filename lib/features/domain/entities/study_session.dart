/// Entidade central do Kronos.
///
/// Representa uma sessão de estudo — pode estar em andamento ([endTime] == null)
/// ou concluída ([endTime] != null).
class StudySession {
  final String id;

  /// Assunto / área de estudo (ex: 'Flutter', 'Inglês', 'LLMs').
  final String subject;

  final DateTime startTime;

  /// Nulo enquanto a sessão estiver em andamento.
  final DateTime? endTime;

  /// Controla se a sessão já foi sincronizada com a API remota (GitHub Gists).
  final bool isSynced;

  final String? notes;

  const StudySession({
    required this.id,
    required this.subject,
    required this.startTime,
    this.endTime,
    this.isSynced = false,
    this.notes,
  });

  /// Duração real da sessão. Retorna null se ainda estiver em andamento.
  Duration? get duration =>
      endTime?.difference(startTime);

  /// Duração parcial — usa DateTime.now() se a sessão ainda não foi finalizada.
  Duration get elapsed => (endTime ?? DateTime.now()).difference(startTime);

  bool get isCompleted => endTime != null;

  StudySession copyWith({
    String? id,
    String? subject,
    DateTime? startTime,
    DateTime? endTime,
    bool? isSynced,
    String? notes,
  }) {
    return StudySession(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isSynced: isSynced ?? this.isSynced,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudySession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'StudySession(id: $id, subject: $subject, '
      'started: $startTime, ended: $endTime, synced: $isSynced)';
}
