import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/features/chat/domain/entities/chat_conversation.dart';
import 'package:sport/features/chat/domain/repositories/chat_repository.dart';
import 'package:sport/features/chat/presentation/pages/chat_list_page.dart';
import 'package:sport/features/chat/presentation/providers/chat_providers.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository chat;

  setUp(() {
    chat = MockChatRepository();
    when(() => chat.getConversations()).thenAnswer(
      (_) async => [
        ChatConversation(
          id: 'c1',
          contactName: 'Laura Coach',
          contactAvatar: '',
          lastMessage: 'Nos vemos',
          lastMessageTime: DateTime.now(),
          contactUserId: 'u2',
        ),
      ],
    );
  });

  testWidgets('flujo lista de chat muestra conversaciones', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [chatRepositoryProvider.overrideWithValue(chat)],
        child: const MaterialApp(home: ChatListPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mensajes'), findsOneWidget);
    expect(find.text('Laura Coach'), findsOneWidget);
    expect(find.textContaining('Nos vemos'), findsOneWidget);
  });
}
