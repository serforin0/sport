import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/demo/data/models/demo_showcase_model.dart';
import 'package:sport/features/demo/domain/entities/demo_showcase.dart';
import 'package:sport/features/demo/domain/repositories/demo_showcase_repository.dart';

class DemoShowcaseRepositoryImpl implements DemoShowcaseRepository {
  final ApiClient apiClient;

  const DemoShowcaseRepositoryImpl(this.apiClient);

  @override
  Future<Result<DemoShowcase>> getShowcase() async {
    try {
      final response = await apiClient.get('/demo/showcase');
      final body = response.data;
      final rawData = body is Map ? body['data'] : null;
      if (rawData is! Map) {
        return Err(ValidationFailure('Respuesta de showcase inválida'));
      }
      return Ok(DemoShowcaseModel.fromMap(Map<String, dynamic>.from(rawData)));
    } on Exception {
      return Err(ServerFailure('No se pudo cargar la vista de demostración'));
    }
  }

  @override
  Future<Result<void>> joinGroup(String groupId) =>
      _post('/demo/groups/$groupId/join');

  @override
  Future<Result<void>> leaveGroup(String groupId) =>
      _post('/demo/groups/$groupId/leave');

  @override
  Future<Result<void>> postInGroup(String groupId, String body) =>
      _post('/demo/groups/$groupId/posts', data: {'body': body});

  @override
  Future<Result<Map<String, dynamic>>> checkout({
    required String productId,
    required String variant,
    required String recipientName,
    required String city,
    required String address,
  }) async {
    try {
      final response = await apiClient.post(
        '/demo/store/checkout',
        data: {
          'product_id': productId,
          'variant': variant,
          'recipient_name': recipientName,
          'city': city,
          'address': address,
        },
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! Map) {
        return Err(ValidationFailure('Respuesta de pedido inválida'));
      }
      return Ok(Map<String, dynamic>.from(data));
    } on Exception {
      return Err(ServerFailure('No se pudo confirmar el pedido'));
    }
  }

  @override
  Future<Result<void>> applySponsorship(
    String sponsorshipId, {
    String? message,
  }) => _post(
    '/demo/sponsorships/$sponsorshipId/apply',
    data: {
      if (message != null && message.trim().isNotEmpty)
        'message': message.trim(),
    },
  );

  Future<Result<void>> _post(String path, {Map<String, dynamic>? data}) async {
    try {
      await apiClient.post(path, data: data);
      return const Ok(null);
    } on Exception {
      return Err(ServerFailure('No se pudo completar la acción'));
    }
  }
}
