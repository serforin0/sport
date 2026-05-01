import 'package:sport/core/result/result.dart';
import '../../domain/entities/match_result.dart';

abstract class ResultsRepository {
  Future<Result<List<MatchResult>>> getRecentResults();
}
