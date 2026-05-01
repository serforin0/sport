import 'package:dio/dio.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/settings/data/models/account_session_model.dart';
import '../models/user_settings_model.dart';

abstract class SettingsRemoteDataSource {
  Future<UserSettingsModel> getSettings(String token);
  Future<UserSettingsModel> updateSettings(String token, Map<String, dynamic> settings);
  Future<void> changePassword(String token, String currentPassword, String password, String confirmation);
  Future<List<AccountSessionModel>> getSessions(String token);
  Future<void> closeSession(String token, String sessionId);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final ApiClient apiClient;

  SettingsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserSettingsModel> getSettings(String token) async {
    final response = await apiClient.get(
      '/user/settings',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return UserSettingsModel.fromMap(response.data['data']);
  }

  @override
  Future<UserSettingsModel> updateSettings(String token, Map<String, dynamic> settings) async {
    final response = await apiClient.patch(
      '/user/settings',
      data: settings,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return UserSettingsModel.fromMap(response.data['data']);
  }

  @override
  Future<void> changePassword(String token, String currentPassword, String password, String confirmation) async {
    await apiClient.post(
      '/user/settings/change-password',
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': confirmation,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  @override
  Future<List<AccountSessionModel>> getSessions(String token) async {
    final response = await apiClient.get(
      '/user/settings/sessions',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final list = response.data is Map && response.data['data'] is List ? response.data['data'] as List : const [];
    return list
        .whereType<Map>()
        .map((item) => AccountSessionModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> closeSession(String token, String sessionId) async {
    await apiClient.delete(
      '/user/settings/sessions/$sessionId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
