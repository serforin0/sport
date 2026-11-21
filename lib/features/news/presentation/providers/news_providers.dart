import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/feed/presentation/providers/feed_providers.dart';
import 'package:sport/features/news/data/datasources/external_news_datasource.dart';
import 'package:sport/features/news/data/datasources/news_remote_datasource.dart';
import 'package:sport/features/news/data/repositories/news_repository_impl.dart';
import 'package:sport/features/news/domain/entities/news_article.dart';
import 'package:sport/features/news/domain/repositories/news_repository.dart';

final newsRemoteDataSourceProvider = Provider<NewsRemoteDataSource>((ref) {
  return NewsRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final externalDioProvider = Provider<Dio>((ref) => Dio());

final externalNewsDataSourceProvider = Provider<ExternalNewsRemoteDataSource>((ref) {
  return ExternalNewsRemoteDataSourceImpl(
    ref.watch(externalDioProvider),
    apiKey: 'YOUR_NEWS_API_KEY',
  );
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(
    remoteDataSource: ref.watch(newsRemoteDataSourceProvider),
    externalDataSource: ref.watch(externalNewsDataSourceProvider),
  );
});

final sportsNewsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  ref.watch(feedSportScopeProvider);
  final scope = ref.read(feedSportScopeProvider);
  final user = ref.watch(authControllerProvider).value;
  final sportId =
      scope == 'my_sport' ? user?.sportId : null;

  final repository = ref.watch(newsRepositoryProvider);
  final result = await repository.getSportsNews(sportId: sportId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (news) => news,
  );
});
