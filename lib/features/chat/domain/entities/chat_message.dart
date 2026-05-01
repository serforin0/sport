class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    this.isRead = false,
  });

  bool get isSentByMe => senderId == 'me';
}
