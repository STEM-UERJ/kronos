import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kronos/features/domain/usecases/get_local_study_history_use_case.dart';
import 'package:kronos/features/domain/usecases/use_case.dart';
import 'package:kronos/features/presenter/home/logic/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetLocalStudyHistoryUseCase _getLocalHistory;

  HomeCubit({required GetLocalStudyHistoryUseCase getLocalHistory})
      : _getLocalHistory = getLocalHistory,
        super(HomeInitial());

  Future<void> loadSummary() async {
    //TODO: Implementar carregamento do resumo
  }
}
