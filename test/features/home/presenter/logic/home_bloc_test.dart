import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kronos/features/home/presenter/logic/home_bloc.dart';
import 'package:kronos/features/home/presenter/logic/home_event.dart';
import 'package:kronos/features/home/presenter/logic/home_state.dart';

void main() {
  group('HomeBloc', () {
    test('estado inicial e HomeInitial', () {
      final bloc = HomeBloc();

      expect(bloc.state, isA<HomeInitial>());
      bloc.close();
    });

    blocTest<HomeBloc, HomeState>(
      'caso de sucesso: sem eventos permanece sem novas emissoes',
      build: HomeBloc.new,
      expect: () => <HomeState>[],
    );

    blocTest<HomeBloc, HomeState>(
      'caso de erro: adicionar evento sem handler gera StateError',
      build: HomeBloc.new,
      act: (bloc) => bloc.add(const HomeStarted()),
      expect: () => <HomeState>[],
      errors: () => <Matcher>[isA<StateError>()],
    );
  });
}
