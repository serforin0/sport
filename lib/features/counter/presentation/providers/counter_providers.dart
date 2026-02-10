import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/increment_counter.dart';
import '../../domain/repositories/counter_repository.dart';
import '../../../counter/data/repositories/counter_repository_impl.dart';
import '../../../../core/result/result.dart';

// DI
final counterRepositoryProvider = Provider<CounterRepository>((ref) {
  return CounterRepositoryImpl();
});

final incrementCounterProvider = Provider<IncrementCounter>((ref) {
  final repo = ref.watch(counterRepositoryProvider);
  return IncrementCounter(repo);
});

// State
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() {
    final usecase = ref.read(incrementCounterProvider);
    final result = usecase(state);

    switch (result) {
      case Ok<int>(value: final v):
        state = v;
      case Err<int>():
        // En app real: manejar error (otro estado/provider)
        state = state;
    }
  }
}

final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);
