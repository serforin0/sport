import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import '../models/match_result_model.dart';

abstract class ResultsDataSource {
  Future<List<MatchResultModel>> getRecentResults();
}

class ResultsDataSourceImpl implements ResultsDataSource {
  final ApiClient _apiClient;

  ResultsDataSourceImpl(this._apiClient);

  @override
  Future<List<MatchResultModel>> getRecentResults() async {
    final response = await _apiClient.get('/sport/results');
    final list = unwrapDataList(response.data);
    return list
        .whereType<Map>()
        .map((e) => MatchResultModel.fromHubApi(Map<String, dynamic>.from(e)))
        .toList();
  }
}
