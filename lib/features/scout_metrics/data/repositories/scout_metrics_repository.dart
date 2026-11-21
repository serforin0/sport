import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/scout_metrics/domain/entities/scout_metric.dart';

class ScoutMetricsRepository {
  final ApiClient apiClient;

  ScoutMetricsRepository(this.apiClient);

  Future<Result<ScoutMetricsSnapshot>> loadForSport(String sportId) async {
    try {
      final defsResponse =
          await apiClient.get('/sport/$sportId/metric-definitions');
      final valuesResponse = await apiClient.get('/user/me/metrics');

      final definitions = unwrapDataList(defsResponse.data)
          .whereType<Map>()
          .map((e) => _definitionFromApi(Map<String, dynamic>.from(e)))
          .toList();

      final valuesBody = valuesResponse.data;
      final values = unwrapDataList(valuesBody)
          .whereType<Map>()
          .map((e) => _valueFromApi(Map<String, dynamic>.from(e)))
          .toList();

      String? invite;
      bool empty = values.isEmpty;
      if (valuesBody is Map) {
        final meta = valuesBody['meta'];
        if (meta is Map) {
          empty = meta['empty'] == true || values.isEmpty;
          invite = meta['invite']?.toString();
        }
      }

      return Ok(
        ScoutMetricsSnapshot(
          definitions: definitions,
          values: values,
          empty: empty,
          invite: invite,
        ),
      );
    } catch (e) {
      return Err(ServerFailure('Error al cargar métricas scout: $e'));
    }
  }

  Future<Result<bool>> upsertMetrics(
    List<Map<String, dynamic>> metrics,
  ) async {
    try {
      await apiClient.put('/user/me/metrics', data: {'metrics': metrics});
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure('Error al guardar métricas: $e'));
    }
  }

  Future<Result<bool>> updatePhysicalProfile({
    required String userId,
    double? heightCm,
    double? weightKg,
    double? wingspanCm,
    String? laterality,
    String? currentTeam,
  }) async {
    try {
      await apiClient.put(
        '/user/$userId',
        data: {
          'profile': {
            if (heightCm != null) 'height_cm': heightCm,
            if (weightKg != null) 'weight_kg': weightKg,
            if (wingspanCm != null) 'wingspan_cm': wingspanCm,
            if (laterality != null) 'laterality': laterality,
            if (currentTeam != null) 'current_team': currentTeam,
          },
        },
      );
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure('Error al guardar perfil físico: $e'));
    }
  }

  Future<Result<List<Map<String, dynamic>>>> listVideos() async {
    try {
      final response = await apiClient.get('/user/me/videos');
      final list = unwrapDataList(response.data)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      return Ok(list);
    } catch (e) {
      return Err(ServerFailure('Error al cargar videos: $e'));
    }
  }

  Future<Result<bool>> addVideo({
    required String title,
    required String videoUrl,
    String kind = 'game',
  }) async {
    try {
      await apiClient.post(
        '/user/me/videos',
        data: {
          'title': title,
          'video_url': videoUrl,
          'kind': kind,
        },
      );
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure('Error al guardar video: $e'));
    }
  }

  Future<Result<bool>> deleteVideo(String videoId) async {
    try {
      await apiClient.delete('/user/me/videos/$videoId');
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure('Error al eliminar video: $e'));
    }
  }

  Future<Result<bool>> verifyMetric({
    required String athleteUserId,
    required String metricValueId,
    required String status,
  }) async {
    try {
      await apiClient.patch(
        '/user/$athleteUserId/metrics/$metricValueId/verify',
        data: {'verification_status': status},
      );
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure('Error al verificar métrica: $e'));
    }
  }

  SportMetricDefinition _definitionFromApi(Map<String, dynamic> json) {
    return SportMetricDefinition(
      id: json['id']?.toString() ?? '',
      sportId: json['sport_id']?.toString() ?? '',
      metricGroup: json['metric_group']?.toString() ?? 'General',
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      unit: json['unit']?.toString(),
      lowerIsBetter: json['lower_is_better'] == true,
      sortOrder: json['sort_order'] is int ? json['sort_order'] as int : 0,
    );
  }

  AthleteMetricValue _valueFromApi(Map<String, dynamic> json) {
    SportMetricDefinition? definition;
    final rawDef = json['definition'];
    if (rawDef is Map) {
      definition = _definitionFromApi(Map<String, dynamic>.from(rawDef));
    }
    final numeric = json['value_numeric'];
    return AthleteMetricValue(
      id: json['id']?.toString() ?? '',
      definitionId: json['definition_id']?.toString() ?? '',
      valueNumeric: numeric == null
          ? null
          : double.tryParse(numeric.toString()),
      valueText: json['value_text']?.toString(),
      recordedAt: json['recorded_at']?.toString(),
      source: json['source']?.toString() ?? 'self_reported',
      verificationStatus:
          json['verification_status']?.toString() ?? 'self_reported',
      definition: definition,
    );
  }
}
