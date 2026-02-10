import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sport/features/counter/presentation/providers/counter_providers.dart';
import 'package:sport/features/counter/domain/usecases/increment_counter.dart';
import 'package:sport/core/result/result.dart';

class _MockIncrementCounter extends Mock implements IncrementCounter {}

void main() {
  test('CounterNotifier increment: 0 -> 1', () {
    final mockUsecase = _MockIncrementCounter();
    when(() => mockUsecase.call(0)).thenReturn(const Ok(1));

    final container = ProviderContainer(
      overrides: [incrementCounterProvider.overrideWithValue(mockUsecase)],
    );
    addTearDown(container.dispose);

    expect(container.read(counterProvider), 0);

    container.read(counterProvider.notifier).increment();

    expect(container.read(counterProvider), 1);
    verify(() => mockUsecase.call(0)).called(1);
  });
}
