import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import '../models/news_article_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsArticleModel>> getSportsNews();
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final ApiClient _apiClient;

  NewsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<NewsArticleModel>> getSportsNews() async {
    final response = await _apiClient.get('/sport/news');
    final list = unwrapDataList(response.data);
    return list
        .whereType<Map>()
        .map((e) => NewsArticleModel.fromHubApi(Map<String, dynamic>.from(e)))
        .toList();
  }
}
