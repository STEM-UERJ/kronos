import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kronos/features/timer/presenter/logic/timer_bloc.dart';
import 'package:kronos/features/timer/presenter/logic/timer_event.dart';
import 'package:kronos/features/timer/presenter/logic/timer_state.dart';

void main() {
  group('TimerBloc', () {
    test('estado inicial e TimerInitial', () {
      final bloc = TimerBloc();

      expect(bloc.state, isA<TimerInitial>());
      bloc.close();
    });

    blocTest<TimerBloc, TimerState>(
      'caso de sucesso: sem eventos permanece sem novas emissoes',
      build: TimerBloc.new,
      expect: () => <TimerState>[],
    );

    blocTest<TimerBloc, TimerState>(
      'caso de erro: adicionar evento sem handler gera StateError',
      build: TimerBloc.new,
      act: (bloc) => bloc.add(const TimerStarted()),
      expect: () => <TimerState>[],
      errors: () => <Matcher>[isA<StateError>()],
    );
  });
}
