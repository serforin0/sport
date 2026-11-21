import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/features/chat/domain/entities/chat_conversation.dart';
import 'package:sport/features/chat/domain/repositories/chat_repository.dart';
import 'package:sport/features/chat/presentation/pages/conversation_page.dart';
import 'package:sport/features/chat/presentation/providers/chat_providers.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository chat;

  setUpAll(() async {
    await initializeDateFormatting('es');
    await initializeDateFormatting('en');
  });

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
  });

  testWidgets('menú conversación muestra eliminar bloquear reportar', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [chatRepositoryProvider.overrideWithValue(chat)],
        child: MaterialApp(home: ConversationPage(conversation: conversation)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('chat_conversation_menu')));
    await tester.pumpAndSettle();

    expect(find.text('Eliminar conversación'), findsOneWidget);
    expect(find.text('Bloquear usuario'), findsOneWidget);
    expect(find.text('Reportar'), findsOneWidget);
  });
}
