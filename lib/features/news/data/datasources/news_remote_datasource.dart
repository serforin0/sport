import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import '../models/news_article_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsArticleModel>> getSportsNews({String? sportId});
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final ApiClient _apiClient;

  NewsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<NewsArticleModel>> getSportsNews({String? sportId}) async {
    final response = await _apiClient.get(
      '/sport/news',
      queryParameters: {
        if (sportId != null && sportId.isNotEmpty) 'sport_id': sportId,
      },
    );
    final list = unwrapDataList(response.data);
    return list
        .whereType<Map>()
        .map((e) => NewsArticleModel.fromHubApi(Map<String, dynamic>.from(e)))
        .toList();
  }
}
