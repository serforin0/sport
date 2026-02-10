import '../../../../core/result/result.dart';

abstract class CounterRepository {
  Result<int> increment(int current);
}
