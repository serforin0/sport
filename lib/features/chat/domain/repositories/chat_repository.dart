import '../entities/chat_conversation.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatConversation>> getConversations();
  Future<List<ChatMessage>> getMessages(String conversationId);
  Future<ChatMessage> sendMessage(String conversationId, String text);

  /// Abre un chat directo con un usuario (reutiliza conversación existente o `POST /chat`).
  Future<ChatConversation> ensureDirectChat({
    required String otherUserId,
    required String contactName,
    required String contactAvatar,
    String contactSubtitle = '',
  });

  /// Elimina el hilo para ti (`DELETE /chat/{id}`).
  Future<void> deleteConversation(String conversationId);

  /// Bloquea al usuario (`POST /user/{id}/block` o `POST /blocks`).
  Future<void> blockUser(String userId);
}
