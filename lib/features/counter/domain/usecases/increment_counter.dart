import '../repositories/counter_repository.dart';
import '../../../../core/result/result.dart';

class IncrementCounter {
  final CounterRepository repo;
  IncrementCounter(this.repo);

  Result<int> call(int current) => repo.increment(current);
}
