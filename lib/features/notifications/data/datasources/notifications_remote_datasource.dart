import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import '../../domain/entities/notification.dart';

class NotificationsRemoteDataSource {
  final ApiClient apiClient;
  final SharedPreferences prefs;

  NotificationsRemoteDataSource(this.apiClient, this.prefs);

  static const _tokenKey = 'auth_token';

  String? get _token => prefs.getString(_tokenKey);

  Options? _auth() {
    final t = _token;
    if (t == null) return null;
    return Options(headers: {'Authorization': 'Bearer $t'});
  }

  NotificationType _parseType(dynamic raw) {
    final s = raw?.toString().toLowerCase() ?? '';
    if (s.contains('comment')) return NotificationType.comment;
    if (s.contains('like')) return NotificationType.like;
    if (s.contains('invite') || s.contains('event')) return NotificationType.eventInvite;
    if (s.contains('group')) return NotificationType.groupPost;
    if (s.contains('connect') || s.contains('request')) return NotificationType.connectionRequest;
    return NotificationType.newPost;
  }

  AppNotification _fromJson(Map<String, dynamic> m) {
    final from = m['from_user'] ?? m['user'] ?? m['author'];
    String authorName = 'Usuario';
    String? photo;
    String role = 'Deportista';
    if (from is Map) {
      final fm = Map<String, dynamic>.from(from);
      authorName = fm['name']?.toString() ??
          '${fm['first_name'] ?? ''} ${fm['last_name'] ?? ''}'.trim();
      if (authorName.isEmpty) authorName = 'Usuario';
      photo = fm['avatar']?.toString() ?? fm['avatar_url']?.toString() ?? fm['photo_url']?.toString();
      role = fm['role']?.toString() ?? 'Deportista';
    }

    final read = m['read_at'] != null || m['is_read'] == true || m['read'] == true;

    return AppNotification(
      id: m['id']?.toString() ?? '',
      authorName: authorName,
      authorPhotoUrl: photo,
      authorRole: role,
      type: _parseType(m['type'] ?? m['notification_type']),
      targetTitle: m['target_title']?.toString() ?? m['title']?.toString(),
      createdAt: _parseDate(m['created_at'] ?? m['sent_at']),
      isRead: read,
      relatedId: m['related_id']?.toString() ?? m['post_id']?.toString() ?? m['event_id']?.toString() ?? m['subject_id']?.toString(),
    );
  }

  DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<List<AppNotification>> fetchNotifications() async {
    final auth = _auth();
    if (auth == null) return [];
    final response = await apiClient.get('/user/notifications', options: auth);
    final list = unwrapDataList(response.data);
    return list.whereType<Map>().map((e) => _fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> markAsRead(String id) async {
    final auth = _auth();
    if (auth == null) return;
    await apiClient.patch('/user/notifications/$id/read', options: auth);
  }

  Future<void> markAllAsRead() async {
    final auth = _auth();
    if (auth == null) return;
    await apiClient.post('/user/notifications/read-all', options: auth);
  }
}
