import 'package:sport/core/result/result.dart';
import '../../domain/entities/news_article.dart';

abstract class NewsRepository {
  Future<Result<List<NewsArticle>>> getSportsNews();
}
