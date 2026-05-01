enum NotificationType {
  comment,
  like,
  eventInvite,
  groupPost,
  newPost,
  connectionRequest,
}

class AppNotification {
  final String id;
  final String authorName;
  final String? authorPhotoUrl;
  final String authorRole;
  final NotificationType type;
  final String? targetTitle; // Event name, group name, etc.
  final DateTime createdAt;
  final bool isRead;
  final String? relatedId; // ID of the post, event, etc.

  const AppNotification({
    required this.id,
    required this.authorName,
    this.authorPhotoUrl,
    this.authorRole = 'Deportista',
    required this.type,
    this.targetTitle,
    required this.createdAt,
    this.isRead = false,
    this.relatedId,
  });

  String get message {
    switch (type) {
      case NotificationType.comment:
        return 'ha comentado tu publicación.';
      case NotificationType.like:
        return 'ha dado me gusta a tu publicación.';
      case NotificationType.eventInvite:
        return 'te ha invitado al evento "${targetTitle ?? 'un evento'}".';
      case NotificationType.groupPost:
        return 'ha publicado en el grupo "${targetTitle ?? 'un grupo'}".';
      case NotificationType.newPost:
        return 'ha realizado una publicación.';
      case NotificationType.connectionRequest:
        return 'te envió una solicitud de conexión.';
    }
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      authorRole: authorRole,
      type: type,
      targetTitle: targetTitle,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId,
    );
  }
}

class ConnectionRequest {
  final String id;
  final String name;
  final String? photoUrl;
  final String role;

  const ConnectionRequest({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.role,
  });
}
