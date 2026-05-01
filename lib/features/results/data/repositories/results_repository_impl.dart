import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/result/result.dart';
import '../../domain/entities/match_result.dart';
import '../../domain/repositories/results_repository.dart';
import '../datasources/results_datasource.dart';
import '../datasources/external_results_datasource.dart';


class ResultsRepositoryImpl implements ResultsRepository {
  final ResultsDataSource _dataSource;
  final ExternalResultsRemoteDataSource _externalDataSource;

  ResultsRepositoryImpl(this._dataSource, this._externalDataSource);


  @override
  Future<Result<List<MatchResult>>> getRecentResults() async {
    try {
      // Fetch both in parallel
      final responses = await Future.wait([
        _dataSource.getRecentResults(),
        _externalDataSource.getLiveScores(),
      ]);

      final internalResults = responses[0] as List<MatchResult>;
      final externalResults = responses[1] as List<MatchResult>;

      // Combine and sort by date descending
      final combined = [...internalResults, ...externalResults];
      combined.sort((a, b) => b.date.compareTo(a.date));

      return Ok(combined);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

}
