import 'package:dio/dio.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getMe(String token);
  Future<void> updateUser(String token, String userId, Map<String, dynamic> body);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl(this.apiClient);

  Options _auth(String token) => Options(headers: {'Authorization': 'Bearer $token'});

  @override
  Future<UserProfileModel> getMe(String token) async {
    final response = await apiClient.get('/user/me', options: _auth(token));
    final map = unwrapDataMap(response.data) ??
        (response.data is Map ? Map<String, dynamic>.from(response.data as Map) : null);
    if (map == null) {
      throw Exception('Respuesta /user/me inválida');
    }
    return UserProfileModel.fromApiUser(map);
  }

  @override
  Future<void> updateUser(String token, String userId, Map<String, dynamic> body) async {
    await apiClient.put(
      '/user/$userId',
      data: body,
      options: _auth(token),
    );
  }
}
