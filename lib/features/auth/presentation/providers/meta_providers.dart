import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/core/errors/failures.dart';
import 'package:sport/features/auth/domain/entities/meta.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final metaRepositoryProvider = Provider<MetaRepository>((ref) {
  return MetaRepository(ref.watch(apiClientProvider));
});

class MetaRepository {
  final ApiClient apiClient;
  MetaRepository(this.apiClient);

  Future<Result<List<Sport>>> getSports() async {
    try {
      final response = await apiClient.get('/sport');
      final data = response.data['data'] as List;
      return Ok(data.map((e) => Sport.fromMap(Map<String, dynamic>.from(e))).toList());
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  Future<Result<List<Country>>> getCountries() async {
    try {
      final response = await apiClient.get('/meta/countries');
      final data = response.data['data'] as List;
      return Ok(data.map((e) => Country.fromMap(Map<String, dynamic>.from(e))).toList());
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }
}

final sportsProvider = FutureProvider<List<Sport>>((ref) {
  return ref.watch(metaRepositoryProvider).getSports().then((res) => res.fold((f) => throw f, (s) => s));
});

final countriesProvider = FutureProvider<List<Country>>((ref) {
  return ref.watch(metaRepositoryProvider).getCountries().then((res) => res.fold((f) => throw f, (c) => c));
});
