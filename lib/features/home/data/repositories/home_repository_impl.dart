import 'package:result_dart/result_dart.dart';

import '../../domain/entities/home_entities.dart';
import '../../domain/repositories/home_repository.dart';
import '../source/home_source.dart';

final class HomeRepositoryImpl implements HomeRepository {
  final HomeSource _source;

  HomeRepositoryImpl({required HomeSource source}) : _source = source;

  @override
  AsyncResult<HomeDashboard> getDashboard() async {
    try {
      final result = await _source.getDashboard();
      return Success(result);
    } on Exception {
      return Failure(
        Exception(
          'Não foi possível carregar o resumo de hoje. Tente novamente.',
        ),
      );
    }
  }

  @override
  AsyncResult<HomeDashboard> refreshDashboard() async {
    try {
      final result = await _source.refreshDashboard();
      return Success(result);
    } on Exception {
      return Failure(
        Exception(
          'Erro ao atualizar os dados. Verifique o aplicativo e tente novamente.',
        ),
      );
    }
  }

  @override
  AsyncResult<HomeSyncStatus> getSyncStatus() async {
    try {
      final result = await _source.getSyncStatus();
      return Success(result);
    } on Exception {
      return Failure(Exception('Falha ao verificar status de sincronização.'));
    }
  }
}
