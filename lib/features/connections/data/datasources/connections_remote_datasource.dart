import 'package:dio/dio.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import 'package:sport/features/connections/domain/entities/connected_contact.dart';
import 'package:sport/features/people/domain/people_list_user.dart';
import '../../domain/entities/pending_connection.dart';

class ConnectionConflictException implements Exception {
  final String connectionId;
  ConnectionConflictException(this.connectionId);
}

class ConnectionsRemoteDataSource {
  final ApiClient apiClient;

  ConnectionsRemoteDataSource(this.apiClient);

  Options _auth(String token) => Options(headers: {'Authorization': 'Bearer $token'});

  /// Amigos / conexiones aceptadas.
  Future<List<ConnectedContact>> fetchAcceptedConnections(String token) async {
    final response = await apiClient.get('/connections', options: _auth(token));
    final list = unwrapDataList(response.data);
    return list.whereType<Map>().map((e) => _parseAccepted(Map<String, dynamic>.from(e))).toList();
  }

  ConnectedContact _parseAccepted(Map<String, dynamic> json) {
    final connectionId = json['id']?.toString() ?? '';
    final userRaw = json['user'] ?? json['connected_user'] ?? json['friend'];
    Map<String, dynamic> userMap;
    if (userRaw is Map) {
      userMap = Map<String, dynamic>.from(userRaw);
    } else {
      userMap = Map<String, dynamic>.from(json);
    }
    return ConnectedContact(
      connectionId: connectionId,
      person: PeopleListUser.fromApiMap(userMap),
    );
  }

  Future<List<PendingConnection>> fetchIncoming(String token) async {
    final response = await apiClient.get(
      '/connections/requests/incoming',
      options: _auth(token),
    );
    final list = unwrapDataList(response.data);
    return list.whereType<Map>().map((e) => _parseIncoming(Map<String, dynamic>.from(e))).toList();
  }

  PendingConnection _parseIncoming(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? json['connection_id']?.toString() ?? '';
    final user = json['user'] ?? json['from_user'] ?? json['sender'];
    String name = 'Usuario';
    String? photo;
    String userId = '';
    if (user is Map) {
      final u = Map<String, dynamic>.from(user);
      userId = u['id']?.toString() ?? '';
      name = u['name']?.toString() ??
          '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim();
      if (name.isEmpty) name = 'Usuario';
      photo = u['avatar']?.toString() ?? u['avatar_url']?.toString() ?? u['photo_url']?.toString();
    }
    final role = json['role']?.toString() ??
        (user is Map ? Map<String, dynamic>.from(user)['role']?.toString() : null) ??
        'Deportista';
    return PendingConnection(
      connectionId: id,
      userId: userId,
      name: name,
      photoUrl: photo,
      roleLabel: role,
    );
  }

  Future<void> accept(String token, String connectionId) async {
    await apiClient.post('/connections/$connectionId/accept', options: _auth(token));
  }

  Future<void> reject(String token, String connectionId) async {
    await apiClient.post('/connections/$connectionId/reject', options: _auth(token));
  }

  Future<void> deleteConnection(String token, String connectionId) async {
    await apiClient.delete('/connections/$connectionId', options: _auth(token));
  }

  /// Envía solicitud. Si el otro ya envió, el servidor puede responder 409 con `connection_id`.
  Future<void> sendRequest(String token, String connectedUserId) async {
    try {
      await apiClient.post(
        '/connections',
        data: {'connected_user_id': connectedUserId},
        options: _auth(token),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        final data = e.response?.data;
        String? cid;
        if (data is Map) {
          cid = data['connection_id']?.toString() ?? data['data']?['connection_id']?.toString();
        }
        if (cid != null && cid.isNotEmpty) {
          throw ConnectionConflictException(cid);
        }
      }
      rethrow;
    }
  }
}
