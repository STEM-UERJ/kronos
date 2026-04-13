import '../../domain/entities/home_entities.dart';

sealed class HomeState {
  const HomeState();
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  final HomeDashboard dashboard;

  const HomeLoaded({required this.dashboard});
}

final class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);
}
