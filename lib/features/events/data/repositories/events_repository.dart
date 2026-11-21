import 'package:sport/core/config/api_config.dart';
import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/events/data/models/sport_event_model.dart';
import 'package:sport/features/events/domain/entities/sport_event.dart';

class EventsRepository {
  final ApiClient apiClient;

  EventsRepository(this.apiClient);

  Future<Result<List<SportEvent>>> getEvents() async {
    try {
      final response = await apiClient.get('/events');
      final list = unwrapDataList(response.data);
      final events = list
          .whereType<Map>()
          .map((e) => SportEventModel.fromApi(Map<String, dynamic>.from(e)))
          .toList();

      return Ok(events);
    } catch (e) {
      return Err(ServerFailure('Error al cargar eventos: $e'));
    }
  }

  Future<Result<SportEvent>> getEvent(String eventId) async {
    try {
      final response = await apiClient.get('/events/$eventId');
      final map = unwrapDataMap(response.data) ??
          (response.data is Map
              ? Map<String, dynamic>.from(response.data as Map)
              : null);
      if (map == null) {
        return const Err(ServerFailure('Evento no encontrado'));
      }
      return Ok(SportEventModel.fromApi(map));
    } catch (e) {
      return Err(ServerFailure('Error al cargar evento: $e'));
    }
  }

  Future<Result<bool>> participate(String eventId) async {
    try {
      await apiClient.post('/events/$eventId/participate');
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure('Error al inscribirse: $e'));
    }
  }

  Future<Result<bool>> leave(String eventId) async {
    try {
      await apiClient.delete('/events/$eventId/participate');
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure('Error al cancelar inscripción: $e'));
    }
  }

  Future<Result<bool>> linkActivity({
    required String eventId,
    required String activityUrl,
    String? note,
  }) async {
    try {
      await apiClient.post(
        '/events/$eventId/participants/me/activity',
        data: {
          'activity_url': activityUrl,
          if (note != null && note.isNotEmpty) 'activity_note': note,
        },
      );
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure('Error al vincular actividad: $e'));
    }
  }

  String calendarUrl(String eventId) =>
      '${kApiBaseUrl.replaceAll(RegExp(r'/+$'), '')}/events/$eventId/calendar.ics';

  Future<Result<bool>> save(String eventId) async {
    try {
      await apiClient.post('/events/$eventId/save');
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure('Error al guardar evento: $e'));
    }
  }

  Future<Result<SportEvent>> createEvent(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/events', data: data);
      final map = unwrapDataMap(response.data) ??
          (response.data is Map
              ? Map<String, dynamic>.from(response.data as Map)
              : null);
      if (map == null) {
        return const Err(ServerFailure('Respuesta inválida al crear evento'));
      }

      return Ok(SportEventModel.fromApi(map));
    } catch (e) {
      return Err(ServerFailure('Error al crear evento: $e'));
    }
  }
}
