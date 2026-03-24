import 'package:kronos/features/domain/entities/study_session.dart';

/// Modelo de dados para serialização com Sqflite.
///
/// [StudySessionModel] estende [StudySession] e adiciona funcionalidades
/// para converter dados entre a camada de domínio e o banco de dados local.
class StudySessionModel extends StudySession {
  const StudySessionModel({
    required String id,
    required String subject,
    required DateTime startTime,
    DateTime? endTime,
    bool isSynced = false,
    String? notes,
  }) : super(
         id: id,
         subject: subject,
         startTime: startTime,
         endTime: endTime,
         isSynced: isSynced,
         notes: notes,
       );

  /// Converte um mapa do Sqflite em uma instância de [StudySessionModel].
  ///
  /// Implementação esperada:
  /// - Extrair valores do mapa
  /// - Converter timestamps (int) para DateTime
  /// - Retornar nova instância de StudySessionModel
  factory StudySessionModel.fromMap(Map<String, dynamic> map) {
    final startTimeRaw = map['start_time'] ?? map['startTime'];
    final endTimeRaw = map['end_time'] ?? map['endTime'];
    final isSyncedRaw = map['is_synced'] ?? map['isSynced'];

    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value);
      throw FormatException('Formato de data inválido: $value');
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return false;
    }

    return StudySessionModel(
      id: map['id'] as String,
      subject: map['subject'] as String,
      startTime: parseDateTime(startTimeRaw)!,
      endTime: parseDateTime(endTimeRaw),
      isSynced: parseBool(isSyncedRaw),
      notes: map['notes'] as String?,
    );
  }

  /// Converte [StudySessionModel] em um mapa para armazenar no Sqflite.
  ///
  /// Implementação esperada:
  /// - Converter todos os campos para tipos compatíveis com Sqflite
  /// - Converter DateTime para timestamp (milliseconds)
  /// - Converter bool isSynced para int (0/1)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'notes': notes,
    };
  }

  /// Converte uma [StudySession] em [StudySessionModel].
  ///
  /// Implementação esperada:
  /// - Copiar todos os campos da entidade
  /// - Retornar nova instância de StudySessionModel
  factory StudySessionModel.fromEntity(StudySession entity) {
    return StudySessionModel(
      id: entity.id,
      subject: entity.subject,
      startTime: entity.startTime,
      endTime: entity.endTime,
      isSynced: entity.isSynced,
      notes: entity.notes,
    );
  }
}
