import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/result/result.dart';

class ReportsRepository {
  final ApiClient apiClient;

  ReportsRepository(this.apiClient);

  Future<Result<String>> submit({
    String? targetUserId,
    int? conversationId,
    required String reason,
    String? details,
  }) async {
    try {
      final response = await apiClient.post(
        '/reports',
        data: {
          if (targetUserId != null) 'target_user_id': targetUserId,
          if (conversationId != null) 'conversation_id': conversationId,
          'reason': reason,
          if (details != null && details.trim().isNotEmpty)
            'details': details.trim(),
        },
      );
      final body = response.data;
      String message = 'Reporte enviado';
      if (body is Map) {
        final meta = body['meta'];
        if (meta is Map && meta['message'] != null) {
          message = meta['message'].toString();
        }
      }
      return Ok(message);
    } catch (e) {
      return Err(ServerFailure('No se pudo enviar el reporte'));
    }
  }
}
