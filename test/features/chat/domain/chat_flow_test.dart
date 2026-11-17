import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/features/chat/domain/entities/chat_conversation.dart';
import 'package:sport/features/chat/domain/entities/chat_message.dart';
import 'package:sport/features/chat/domain/repositories/chat_repository.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository chat;

  setUp(() {
    chat = MockChatRepository();
  });

  test('flujo abrir chat → enviar → listar mensajes', () async {
    final conversation = ChatConversation(
      id: 'conv1',
      contactName: 'Peer',
      contactAvatar: '',
      lastMessage: '',
      lastMessageTime: DateTime(2026, 1, 1),
      contactUserId: 'u2',
    );
    final sent = ChatMessage(
      id: 'm1',
      text: 'Hola',
      senderId: 'u1',
      timestamp: DateTime(2026, 1, 1, 12),
    );

    when(
      () => chat.ensureDirectChat(
        otherUserId: 'u2',
        contactName: 'Peer',
        contactAvatar: '',
      ),
    ).thenAnswer((_) async => conversation);
    when(() => chat.sendMessage('conv1', 'Hola')).thenAnswer((_) async => sent);
    when(() => chat.getMessages('conv1')).thenAnswer((_) async => [sent]);
    when(() => chat.getConversations()).thenAnswer((_) async => [conversation]);

    final opened = await chat.ensureDirectChat(
      otherUserId: 'u2',
      contactName: 'Peer',
      contactAvatar: '',
    );
    expect(opened.id, 'conv1');

    final message = await chat.sendMessage(opened.id, 'Hola');
    expect(message.text, 'Hola');

    final messages = await chat.getMessages(opened.id);
    expect(messages, hasLength(1));

    final threads = await chat.getConversations();
    expect(threads.single.id, 'conv1');
  });
}
