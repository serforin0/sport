import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/features/chat/domain/entities/chat_conversation.dart';
import 'package:sport/features/chat/domain/entities/chat_message.dart';
import 'package:sport/features/chat/domain/repositories/chat_repository.dart';
import 'package:sport/features/chat/presentation/pages/conversation_page.dart';
import 'package:sport/features/chat/presentation/providers/chat_providers.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository chat;

  final conversation = ChatConversation(
    id: 'conv1',
    contactName: 'Laura Coach',
    contactAvatar: '',
    lastMessage: '',
    lastMessageTime: DateTime(2026, 1, 1),
    contactUserId: 'u2',
  );

  setUp(() {
    chat = MockChatRepository();
    when(() => chat.getMessages('conv1')).thenAnswer((_) async => []);
    when(() => chat.sendMessage('conv1', 'Hola Laura')).thenAnswer(
      (_) async => ChatMessage(
        id: 'm1',
        text: 'Hola Laura',
        senderId: 'me',
        timestamp: DateTime(2026, 1, 1, 12),
      ),
    );
  });

  testWidgets('flujo enviar mensaje en conversación', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [chatRepositoryProvider.overrideWithValue(chat)],
        child: MaterialApp(home: ConversationPage(conversation: conversation)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Laura Coach'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'Hola Laura');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    verify(() => chat.sendMessage('conv1', 'Hola Laura')).called(1);
    expect(find.text('Hola Laura'), findsWidgets);
  });
}
