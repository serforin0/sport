import '../../domain/repositories/counter_repository.dart';
import '../../../../core/result/result.dart';

class CounterRepositoryImpl implements CounterRepository {
  @override
  Result<int> increment(int current) => Ok(current + 1);
}
