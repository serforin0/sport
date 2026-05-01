class ChatConversation {
  final String id;
  final String contactName;
  final String contactAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  /// Id del otro usuario (si el API lo expone), para reutilizar hilos al abrir desde contactos.
  final String? contactUserId;

  /// Línea tipo «Deportista · Atletismo · Estados Unidos» (desde `other_user` / perfil).
  final String contactSubtitle;

  const ChatConversation({
    required this.id,
    required this.contactName,
    required this.contactAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.contactUserId,
    this.contactSubtitle = '',
  });
}
