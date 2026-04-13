import 'package:bloc/bloc.dart';

import '../../domain/usecases/home_usecase_contracts.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeDashboardUseCase? _getHomeDashboardUseCase;
  final RefreshHomeDashboardUseCase? _refreshHomeDashboardUseCase;

  HomeBloc({
    GetHomeDashboardUseCase? getHomeDashboardUseCase,
    RefreshHomeDashboardUseCase? refreshHomeDashboardUseCase,
  }) : _getHomeDashboardUseCase = getHomeDashboardUseCase,
       _refreshHomeDashboardUseCase = refreshHomeDashboardUseCase,
       super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshRequested>(_onRefreshRequested);
  }

  Never _notImplemented() {
    final bool hasAnyDependency =
        _getHomeDashboardUseCase != null ||
        _refreshHomeDashboardUseCase != null;
    if (hasAnyDependency) {
      // no-op
    }
    throw UnimplementedError();
  }

  void _onStarted(HomeStarted event, Emitter<HomeState> emit) {
    _notImplemented();
  }

  void _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) {
    _notImplemented();
  }
}
