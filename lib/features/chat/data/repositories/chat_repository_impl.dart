import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import 'package:sport/features/people/domain/people_list_user.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/send_message_result.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ApiClient apiClient;
  final SharedPreferences prefs;

  ChatRepositoryImpl(this.apiClient, this.prefs);

  static const _tokenKey = 'auth_token';
  static const _userKey = 'cached_user';

  String? get _token => prefs.getString(_tokenKey);

  String get _myUserId {
    final raw = prefs.getString(_userKey);
    if (raw == null) return '';
    try {
      final m = json.decode(raw) as Map<String, dynamic>;
      return m['id']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Options _auth() => Options(headers: {'Authorization': 'Bearer ${_token!}'});

  Map<String, dynamic>? _contactMap(Map<String, dynamic> m) {
    final direct = m['other_user'] ?? m['contact'] ?? m['participant'];
    if (direct is Map) return Map<String, dynamic>.from(direct);
    final users = m['users'];
    if (users is List) {
      for (final u in users) {
        if (u is! Map) continue;
        final map = Map<String, dynamic>.from(u);
        if (map['id']?.toString() != _myUserId) return map;
      }
      if (users.isNotEmpty && users.first is Map) {
        return Map<String, dynamic>.from(users.first as Map);
      }
    }
    final user = m['user'];
    if (user is Map) return Map<String, dynamic>.from(user);
    return null;
  }

  String _nestedAvatar(Map<String, dynamic> map) {
    final avatar = map['avatar'];
    if (avatar is Map) {
      return avatar['url']?.toString() ?? '';
    }
    return map['avatar']?.toString() ??
        map['avatar_url']?.toString() ??
        map['photo_url']?.toString() ??
        '';
  }

  String _contactName(Map<String, dynamic> m) {
    final map = _contactMap(m);
    if (map != null) {
      final n = map['name']?.toString();
      if (n != null && n.isNotEmpty) return n;
      final fn = map['first_name']?.toString() ?? '';
      final ln = map['last_name']?.toString() ?? '';
      final combined = '$fn $ln'.trim();
      if (combined.isNotEmpty) return combined;
    }
    return m['title']?.toString() ?? 'Chat';
  }

  String _contactAvatar(Map<String, dynamic> m) {
    final map = _contactMap(m);
    if (map == null) return '';
    return _nestedAvatar(map);
  }

  String? _contactUserId(Map<String, dynamic> m) {
    final map = _contactMap(m);
    final id = map?['id']?.toString();
    if (id != null && id.isNotEmpty) return id;
    return null;
  }

  String _contactSubtitle(Map<String, dynamic> m) {
    final map = _contactMap(m);
    if (map == null) return '';
    return PeopleListUser.formatDetailLine(map);
  }

  ChatConversation _conversationFromMap(Map<String, dynamic> m) {
    return ChatConversation(
      id: m['id']?.toString() ?? '',
      contactName: _contactName(m),
      contactAvatar: _contactAvatar(m),
      lastMessage: _lastMessageText(m),
      lastMessageTime: _lastMessageTime(m),
      unreadCount:
          int.tryParse(
            (m['unread_count'] ?? m['unreadCount'] ?? 0).toString(),
          ) ??
          0,
      isOnline: m['is_online'] == true || m['online'] == true,
      contactUserId: _contactUserId(m),
      contactSubtitle: _contactSubtitle(m),
    );
  }

  String _lastMessageText(Map<String, dynamic> m) {
    final lm = m['last_message'] ?? m['lastMessage'] ?? m['preview'];
    if (lm is Map) {
      return (lm['content'] ?? lm['body'] ?? lm['text'] ?? '').toString();
    }
    return lm?.toString() ?? '';
  }

  DateTime _lastMessageTime(Map<String, dynamic> m) {
    final lm = m['last_message'] ?? m['lastMessage'];
    dynamic raw = m['updated_at'] ?? m['last_message_at'];
    if (lm is Map) {
      raw = lm['created_at'] ?? lm['sent_at'] ?? raw;
    }
    if (raw == null) return DateTime.now();
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  Future<List<ChatConversation>> getConversations() async {
    if (_token == null) return [];
    try {
      final response = await apiClient.get('/chat', options: _auth());
      final list = unwrapDataList(response.data);
      return list
          .whereType<Map>()
          .map((e) => _conversationFromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<Map<String, dynamic>> _messagesFromResponse(dynamic body) {
    final direct = unwrapDataList(body);
    if (direct.isNotEmpty) {
      return direct
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (body is Map) {
      final data = body['data'];
      if (data is Map && data['messages'] is List) {
        return (data['messages'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return [];
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    if (_token == null) return [];
    try {
      final response = await apiClient.get(
        '/chat/$conversationId',
        options: _auth(),
      );
      final myId = _myUserId;
      return _messagesFromResponse(response.data).map((json) {
        final senderRaw =
            json['user_id'] ?? json['sender_id'] ?? json['from_id'];
        final senderId = senderRaw?.toString() ?? '';
        final isMe = myId.isNotEmpty && senderId == myId;
        return ChatMessage(
          id: json['id']?.toString() ?? '',
          text: (json['content'] ?? json['body'] ?? json['text'] ?? '')
              .toString(),
          senderId: isMe ? 'me' : senderId,
          timestamp: _parseTs(json['created_at'] ?? json['sent_at']),
          isRead: json['read_at'] != null || json['is_read'] == true,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  DateTime _parseTs(dynamic v) {
    if (v == null) return DateTime.now();
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  Future<SendMessageResult> sendMessage(
    String conversationId,
    String text,
  ) async {
    if (_token == null) {
      throw StateError('Sin sesión');
    }
    final response = await apiClient.post(
      '/chat/$conversationId/messages',
      data: {'text': text},
      options: _auth(),
    );
    final map =
        unwrapDataMap(response.data) ??
        (response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : null);
    String? scamWarning;
    final body = response.data;
    if (body is Map) {
      final meta = body['meta'];
      if (meta is Map && meta['scam_warning'] == true) {
        scamWarning = meta['scam_message']?.toString() ??
            'HubSport nunca te pedirá dinero por chat.';
      }
    }
    if (map == null) {
      return SendMessageResult(
        message: ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          senderId: 'me',
          timestamp: DateTime.now(),
        ),
        scamWarning: scamWarning,
      );
    }
    return SendMessageResult(
      message: ChatMessage(
        id: map['id']?.toString() ?? '',
        text: (map['text'] ?? map['content'] ?? map['body'] ?? text).toString(),
        senderId: 'me',
        timestamp: _parseTs(map['created_at'] ?? map['sent_at']),
      ),
      scamWarning: scamWarning,
    );
  }

  Map<String, dynamic>? _unwrapConversationBody(dynamic raw) {
    var m = unwrapDataMap(raw);
    if (m == null && raw is Map) {
      m = Map<String, dynamic>.from(raw);
    }
    return m;
  }

  ChatConversation _directChatForUser(
    Map<String, dynamic> m,
    String otherUserId,
    String contactName,
    String contactAvatar,
    String subtitleFallback,
  ) {
    final conv = _conversationFromMap(m);
    final subtitle = subtitleFallback.isNotEmpty
        ? subtitleFallback
        : conv.contactSubtitle;
    return ChatConversation(
      id: conv.id.isNotEmpty ? conv.id : (m['id']?.toString() ?? ''),
      contactName: contactName,
      contactAvatar: contactAvatar.isNotEmpty
          ? contactAvatar
          : conv.contactAvatar,
      lastMessage: conv.lastMessage,
      lastMessageTime: conv.lastMessageTime,
      unreadCount: conv.unreadCount,
      isOnline: conv.isOnline,
      contactUserId: otherUserId,
      contactSubtitle: subtitle,
    );
  }

  Future<ChatConversation> _postDirectChat(
    String otherUserId,
    String contactName,
    String contactAvatar,
    String contactSubtitle,
    Map<String, dynamic> body,
  ) async {
    final response = await apiClient.post(
      '/chat',
      data: body,
      options: _auth(),
    );
    final m = _unwrapConversationBody(response.data);
    if (m == null) {
      throw StateError('Respuesta de chat inválida');
    }
    return _directChatForUser(
      m,
      otherUserId,
      contactName,
      contactAvatar,
      contactSubtitle,
    );
  }

  @override
  Future<ChatConversation> ensureDirectChat({
    required String otherUserId,
    required String contactName,
    required String contactAvatar,
    String contactSubtitle = '',
  }) async {
    if (_token == null) {
      throw StateError('Sin sesión');
    }
    if (otherUserId.isEmpty) {
      throw ArgumentError('otherUserId vacío');
    }

    final existing = await getConversations();
    for (final c in existing) {
      if (c.contactUserId == otherUserId) {
        return c;
      }
    }

    try {
      return await _postDirectChat(
        otherUserId,
        contactName,
        contactAvatar,
        contactSubtitle,
        {'user_id': otherUserId},
      );
    } on DioException catch (e) {
      try {
        return await _postDirectChat(
          otherUserId,
          contactName,
          contactAvatar,
          contactSubtitle,
          {'recipient_id': otherUserId},
        );
      } on DioException {
        throw e;
      }
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    if (_token == null) {
      throw StateError('Sin sesión');
    }
    if (conversationId.isEmpty) {
      throw ArgumentError('conversationId vacío');
    }
    await apiClient.delete('/chat/$conversationId', options: _auth());
  }

  @override
  Future<void> blockUser(String userId) async {
    if (_token == null) {
      throw StateError('Sin sesión');
    }
    if (userId.isEmpty) {
      throw ArgumentError('userId vacío');
    }
    try {
      await apiClient.post('/user/$userId/block', options: _auth());
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 404 || code == 405) {
        await apiClient.post(
          '/blocks',
          data: {'user_id': userId},
          options: _auth(),
        );
      } else {
        rethrow;
      }
    }
  }
}
