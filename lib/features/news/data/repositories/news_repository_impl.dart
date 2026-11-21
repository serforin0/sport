import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/result/result.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_datasource.dart';
import '../datasources/external_news_datasource.dart';


class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final ExternalNewsRemoteDataSource externalDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.externalDataSource,
  });


  @override
  Future<Result<List<NewsArticle>>> getSportsNews({String? sportId}) async {
    try {
      if (sportId != null && sportId.isNotEmpty) {
        final internal = await remoteDataSource.getSportsNews(sportId: sportId);
        return Ok(List<NewsArticle>.from(internal));
      }

      final results = await Future.wait([
        remoteDataSource.getSportsNews(),
        externalDataSource.getTopHeadlines(),
      ]);

      final internalNews = results[0] as List<NewsArticle>;
      final externalNews = results[1] as List<NewsArticle>;
      final combined = [...internalNews, ...externalNews];
      combined.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      return Ok(combined);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

}
