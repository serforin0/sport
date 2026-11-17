import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/references/data/models/reference_request_model.dart';
import 'package:sport/features/references/data/models/sports_reference_model.dart';
import 'package:sport/features/references/domain/entities/reference_request.dart';
import 'package:sport/features/references/domain/entities/sports_reference.dart';

class ReferencesRepository {
  final ApiClient apiClient;

  ReferencesRepository(this.apiClient);

  Future<Result<ReferencesInbox>> getInbox() async {
    try {
      final response = await apiClient.get('/references');
      final data = unwrapDataMap(response.data) ?? {};
      final received = (data['received'] is List ? data['received'] as List : const [])
          .whereType<Map>()
          .map((e) => ReferenceRequestModel.fromApi(Map<String, dynamic>.from(e)))
          .toList();
      final sent = (data['sent'] is List ? data['sent'] as List : const [])
          .whereType<Map>()
          .map((e) => ReferenceRequestModel.fromApi(Map<String, dynamic>.from(e)))
          .toList();

      return Ok(ReferencesInbox(received: received, sent: sent));
    } catch (e) {
      return Err(ServerFailure('Error al cargar referencias: $e'));
    }
  }

  Future<Result<List<SportsReference>>> getPublishedForUser(String userId) async {
    try {
      final response = await apiClient.get('/references/users/$userId');
      final references = unwrapDataList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(SportsReferenceModel.fromApi)
          .toList();

      return Ok(references);
    } catch (e) {
      return Err(ServerFailure('Error al cargar referencias públicas: $e'));
    }
  }

  Future<Result<bool>> requestReference({
    required String recipientId,
    required String relationshipType,
    String? message,
  }) async {
    try {
      await apiClient.post('/references/requests', data: {
        'recipient_id': recipientId,
        'relationship_type': relationshipType,
        if (message?.trim().isNotEmpty == true) 'message': message!.trim(),
      });
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure('Error al solicitar referencia: $e'));
    }
  }

  Future<Result<bool>> acceptRequest(String id) => _postAction('/references/requests/$id/accept');
  Future<Result<bool>> rejectRequest(String id) => _postAction('/references/requests/$id/reject');
  Future<Result<bool>> confirmReference(String id) => _postAction('/references/requests/$id/confirm');

  Future<Result<bool>> writeReference(String id, String body) async {
    try {
      await apiClient.post('/references/requests/$id/write', data: {'body': body});
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure('Error al escribir referencia: $e'));
    }
  }

  Future<Result<bool>> _postAction(String path) async {
    try {
      await apiClient.post(path);
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure('Error al actualizar referencia: $e'));
    }
  }
}
