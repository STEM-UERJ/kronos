import 'package:bloc/bloc.dart';
import 'package:kronos/core/contracts/use_case_contract.dart';

import '../../domain/usecases/home_usecase_contracts.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeDashboardUseCase _getHomeDashboardUseCase;
  final RefreshHomeDashboardUseCase _refreshHomeDashboardUseCase;

  HomeBloc({
    required GetHomeDashboardUseCase getHomeDashboardUseCase,
    required RefreshHomeDashboardUseCase refreshHomeDashboardUseCase,
  }) : _getHomeDashboardUseCase = getHomeDashboardUseCase,
       _refreshHomeDashboardUseCase = refreshHomeDashboardUseCase,
       super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshRequested>(_onRefreshRequested);
  }

  /*Never _notImplemented() {
    final bool hasAnyDependency =
        _getHomeDashboardUseCase != null ||
        _refreshHomeDashboardUseCase != null;
    if (hasAnyDependency) {
      // no-op
    }
    throw UnimplementedError();
  }*/

  void _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());

    final result = await _getHomeDashboardUseCase(const NoParams());

    result.fold((dashboard) => emit(HomeLoaded(dashboard: dashboard)), (error) {
      final message = error.toString().replaceAll('Exception: ', '');
      emit(HomeFailure(message));
    });
  }

  void _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final result = await _refreshHomeDashboardUseCase(const NoParams());

    result.fold((dashboard) => emit(HomeLoaded(dashboard: dashboard)), (error) {
      final message = error.toString().replaceAll('Exception: ', '');
      emit(HomeFailure(message));
    });
  }
}
