import 'package:dio/dio.dart';
import '../models/match_result_model.dart';

abstract class ExternalResultsRemoteDataSource {
  Future<List<MatchResultModel>> getLiveScores();
}

class ExternalResultsRemoteDataSourceImpl implements ExternalResultsRemoteDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://www.thesportsdb.com/api/v1/json/1';

  ExternalResultsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<MatchResultModel>> getLiveScores() async {
    try {
      // TheSportsDB free tier (/eventspastleague.php?id=4328 is English Premier League)
      // We can use several leagues or a general endpoint if available in paid, 
      // but for "1" we are limited. Let's try to get some events.
      final response = await _dio.get('$_baseUrl/eventspastleague.php?id=4328');

      if (response.statusCode == 200) {
        final List<dynamic> events = response.data['events'] ?? [];
        return events
            .map((json) => MatchResultModel.fromTheSportsDB(Map<String, dynamic>.from(json)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
