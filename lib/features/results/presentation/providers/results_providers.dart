import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:sport/features/results/data/datasources/external_results_datasource.dart';
import 'package:sport/features/news/presentation/providers/news_providers.dart';


import '../../data/datasources/results_datasource.dart';
import '../../data/repositories/results_repository_impl.dart';
import '../../domain/entities/match_result.dart';
import '../../domain/repositories/results_repository.dart';

/// Pestaña de deporte seleccionada en resultados
final selectedSportProvider = StateProvider<String>((_) => 'Todos');

final resultsDataSourceProvider = Provider<ResultsDataSource>((ref) {
  return ResultsDataSourceImpl(ref.watch(apiClientProvider));
});

final externalResultsDataSourceProvider = Provider<ExternalResultsRemoteDataSource>((ref) {
  return ExternalResultsRemoteDataSourceImpl(ref.watch(externalDioProvider));
});


final resultsRepositoryProvider = Provider<ResultsRepository>((ref) {

  return ResultsRepositoryImpl(
    ref.watch(resultsDataSourceProvider),
    ref.watch(externalResultsDataSourceProvider),
  );
});


final recentResultsProvider = FutureProvider<List<MatchResult>>((ref) async {
  final repo = ref.watch(resultsRepositoryProvider);
  final result = await repo.getRecentResults();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (results) => results,
  );
});
