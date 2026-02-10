import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sport/features/counter/domain/usecases/increment_counter.dart';
import 'package:sport/features/counter/domain/repositories/counter_repository.dart';
import 'package:sport/core/result/result.dart';

class MockCounterRepository extends Mock implements CounterRepository {}

void main() {
  test('IncrementCounter returns Ok(current + 1)', () {
    final repo = MockCounterRepository();
    final usecase = IncrementCounter(repo);

    when(() => repo.increment(5)).thenReturn(const Ok(6));

    final result = usecase(5);

    expect(result, isA<Ok<int>>());
    expect((result as Ok<int>).value, 6);

    verify(() => repo.increment(5)).called(1);
  });
}
