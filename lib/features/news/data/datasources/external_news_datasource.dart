import 'package:dio/dio.dart';
import '../models/news_article_model.dart';

abstract class ExternalNewsRemoteDataSource {
  Future<List<NewsArticleModel>> getTopHeadlines();
}

class ExternalNewsRemoteDataSourceImpl implements ExternalNewsRemoteDataSource {
  final Dio _dio;
  final String _apiKey;

  ExternalNewsRemoteDataSourceImpl(this._dio, {required String apiKey}) : _apiKey = apiKey;

  @override
  Future<List<NewsArticleModel>> getTopHeadlines() async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_NEWS_API_KEY') {
      return []; // Silently fail or return empty if no key
    }

    try {
      final response = await _dio.get(
        'https://newsapi.org/v2/top-headlines',
        queryParameters: {
          'category': 'sports',
          'language': 'es', // Or prefer user locale
          'apiKey': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> articles = response.data['articles'] ?? [];
        return articles
            .map((json) => NewsArticleModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
      return [];
    } catch (e) {
      // Log error but return empty to not crash the combined feed
      return [];
    }
  }
}
