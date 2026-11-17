import 'package:sport/features/people/domain/people_list_user.dart';

/// Amigo aceptado (`GET /connections`).
class ConnectedContact {
  final String connectionId;
  final PeopleListUser person;

  const ConnectedContact({
    required this.connectionId,
    required this.person,
  });

  factory ConnectedContact.fromApi(Map<String, dynamic> json, {String? viewerId}) {
    final connectionId = json['id']?.toString() ?? '';
    final userMap = peerUserMap(json, viewerId) ?? Map<String, dynamic>.from(json);
    return ConnectedContact(
      connectionId: connectionId,
      person: PeopleListUser.fromApiMap(userMap),
    );
  }

  static Map<String, dynamic>? peerUserMap(Map<String, dynamic> json, String? viewerId) {
    for (final key in ['user', 'connected_user', 'friend']) {
      final raw = json[key];
      if (raw is Map) return Map<String, dynamic>.from(raw);
    }
    final sender = json['sender'];
    final recipient = json['recipient'];
    final senderMap = sender is Map ? Map<String, dynamic>.from(sender) : null;
    final recipientMap = recipient is Map ? Map<String, dynamic>.from(recipient) : null;
    if (viewerId != null && viewerId.isNotEmpty) {
      if (senderMap != null && senderMap['id']?.toString() != viewerId) {
        return senderMap;
      }
      if (recipientMap != null && recipientMap['id']?.toString() != viewerId) {
        return recipientMap;
      }
    }
    return recipientMap ?? senderMap;
  }
}
