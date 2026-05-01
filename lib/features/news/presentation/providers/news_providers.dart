import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';

import 'package:dio/dio.dart';
import 'package:sport/features/news/data/datasources/external_news_datasource.dart';


import '../../data/datasources/news_remote_datasource.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/repositories/news_repository.dart';

final newsRemoteDataSourceProvider = Provider<NewsRemoteDataSource>((ref) {
  return NewsRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final externalDioProvider = Provider<Dio>((ref) => Dio());

final externalNewsDataSourceProvider = Provider<ExternalNewsRemoteDataSource>((ref) {
  return ExternalNewsRemoteDataSourceImpl(
    ref.watch(externalDioProvider),
    apiKey: 'YOUR_NEWS_API_KEY', // Template value
  );
});


final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(
    remoteDataSource: ref.watch(newsRemoteDataSourceProvider),
    externalDataSource: ref.watch(externalNewsDataSourceProvider),
  );
});


final sportsNewsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final repository = ref.watch(newsRepositoryProvider);
  final result = await repository.getSportsNews();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (news) => news,
  );
});
