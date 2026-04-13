import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kronos/features/history/presenter/logic/history_bloc.dart';
import 'package:kronos/features/history/presenter/logic/history_event.dart';
import 'package:kronos/features/history/presenter/logic/history_state.dart';

void main() {
  group('HistoryBloc', () {
    test('estado inicial e HistoryInitial', () {
      final bloc = HistoryBloc();

      expect(bloc.state, isA<HistoryInitial>());
      bloc.close();
    });

    blocTest<HistoryBloc, HistoryState>(
      'caso de sucesso: sem eventos permanece sem novas emissoes',
      build: HistoryBloc.new,
      expect: () => <HistoryState>[],
    );

    blocTest<HistoryBloc, HistoryState>(
      'caso de erro: adicionar evento sem handler gera StateError',
      build: HistoryBloc.new,
      act: (bloc) => bloc.add(const HistoryStarted()),
      expect: () => <HistoryState>[],
      errors: () => <Matcher>[isA<StateError>()],
    );
  });
}
