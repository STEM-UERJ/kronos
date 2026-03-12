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
    // TODO: Implementar conversão do mapa para modelo
    // O mapa contém os seguintes campos:
    // - 'id': String
    // - 'subject': String
    // - 'startTime': int (timestamp em ms)
    // - 'endTime': int? (null se sessão em andamento)
    // - 'isSynced': int (0 ou 1 no Sqflite, deve usar bool)
    // - 'notes': String?
    throw UnimplementedError('fromMap() não implementado');
  }

  /// Converte [StudySessionModel] em um mapa para armazenar no Sqflite.
  ///
  /// Implementação esperada:
  /// - Converter todos os campos para tipos compatíveis com Sqflite
  /// - Converter DateTime para timestamp (milliseconds)
  /// - Converter bool isSynced para int (0/1)
  Map<String, dynamic> toMap() {
    // TODO: Implementar conversão do modelo para mapa
    // Deve retornar um mapa com:
    // - 'id': id
    // - 'subject': subject
    // - 'startTime': startTime.millisecondsSinceEpoch
    // - 'endTime': endTime?.millisecondsSinceEpoch
    // - 'isSynced': isSynced ? 1 : 0 (Sqflite usa int para bool)
    // - 'notes': notes
    throw UnimplementedError('toMap() não implementado');
  }

  /// Converte uma [StudySession] em [StudySessionModel].
  ///
  /// Implementação esperada:
  /// - Copiar todos os campos da entidade
  /// - Retornar nova instância de StudySessionModel
  factory StudySessionModel.fromEntity(StudySession entity) {
    // TODO: Implementar conversão da entidade para modelo
    // Cópiar todos os campos diretos já que StudySessionModel estende StudySession
    throw UnimplementedError('fromEntity() não implementado');
  }
}
