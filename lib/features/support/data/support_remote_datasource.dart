import 'package:dio/dio.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';

/// `GET /help` (público), `POST /contact`, `GET /billing/summary` (Sanctum).
class SupportRemoteDataSource {
  final ApiClient apiClient;

  SupportRemoteDataSource(this.apiClient);

  /// Respuesta cruda para mostrar en UI (texto, FAQ, etc.).
  Future<dynamic> fetchHelp() async {
    final response = await apiClient.get('/help');
    return unwrapDataMap(response.data) ?? response.data;
  }

  Future<void> submitContact({
    String? token,
    required String subject,
    required String message,
    String? email,
  }) async {
    final body = <String, dynamic>{
      'subject': subject,
      'message': message,
      if (email != null && email.isNotEmpty) 'email': email,
    };
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;
    await apiClient.post('/contact', data: body, options: options);
  }

  Future<Map<String, dynamic>> fetchBillingSummary(String token) async {
    final response = await apiClient.get(
      '/billing/summary',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final map = unwrapDataMap(response.data);
    if (map != null) return map;
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    return {};
  }
}
