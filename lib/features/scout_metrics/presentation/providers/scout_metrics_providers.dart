import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/scout_metrics/data/repositories/scout_metrics_repository.dart';
import 'package:sport/features/scout_metrics/domain/entities/scout_metric.dart';

final scoutMetricsRepositoryProvider = Provider<ScoutMetricsRepository>((ref) {
  return ScoutMetricsRepository(ref.watch(apiClientProvider));
});

final scoutMetricsProvider =
    FutureProvider.autoDispose.family<ScoutMetricsSnapshot, String>((
  ref,
  sportId,
) async {
  final result =
      await ref.watch(scoutMetricsRepositoryProvider).loadForSport(sportId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (snapshot) => snapshot,
  );
});
