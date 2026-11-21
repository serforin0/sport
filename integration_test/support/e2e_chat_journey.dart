import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/chat/presentation/pages/chat_list_page.dart';
import 'package:sport/features/chat/presentation/pages/conversation_page.dart';
import 'package:sport/features/chat/presentation/pages/new_message_page.dart';

import 'e2e_harness.dart';

/// Chat E2E: feed → lista → hilo (existente o nuevo) → enviar → menú → Reportar.
Future<void> e2eChatCompleteJourney(WidgetTester tester) async {
  final chatBtn = find.byKey(const Key('feed_chat_button'));
  await e2eWaitForAny(tester, [chatBtn], timeout: const Duration(seconds: 30));
  await tester.tap(chatBtn);
  await tester.pumpAndSettle(const Duration(seconds: 3));

  expect(find.byType(ChatListPage), findsOneWidget);
  expect(find.text('Mensajes'), findsOneWidget);

  await e2eWaitForAny(
    tester,
    [
      find.byType(InkWell),
      find.textContaining('No tienes nuevos mensajes'),
      find.text('Error cargando mensajes'),
      find.byKey(const Key('chat_new_message_button')),
    ],
    timeout: const Duration(seconds: 45),
  );

  final tiles = find.byWidgetPredicate(
    (w) =>
        w is InkWell &&
        w.key is ValueKey<String> &&
        (w.key as ValueKey<String>).value.startsWith('chat_conversation_tile_'),
  );

  if (tiles.evaluate().isNotEmpty) {
    await tester.tap(tiles.first);
    await tester.pump();
  } else {
    await tester.tap(find.byKey(const Key('chat_new_message_button')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(NewMessagePage), findsOneWidget);
    await e2eWaitForAny(
      tester,
      [
        find.byType(ListTile),
        find.textContaining('Añade contactos'),
      ],
      timeout: const Duration(seconds: 45),
    );
    if (find.byType(ListTile).evaluate().isEmpty) {
      fail('Demo sin contactos accepted para abrir chat nuevo');
    }
    await tester.tap(find.byType(ListTile).first);
    await tester.pump();
  }

  await e2eWaitForAny(
    tester,
    [
      find.byType(ConversationPage),
      find.byKey(const Key('chat_message_input')),
    ],
    timeout: const Duration(seconds: 45),
  );
  expect(find.byType(ConversationPage), findsOneWidget);
  expect(find.byKey(const Key('chat_message_input')), findsOneWidget);

  final msg = 'E2E chat ${DateTime.now().millisecondsSinceEpoch}';
  await tester.enterText(find.byKey(const Key('chat_message_input')), msg);
  await tester.pump();
  await tester.tap(find.byKey(const Key('chat_send_button')));
  await tester.pump();
  await e2eWaitForAny(
    tester,
    [find.text(msg), find.byType(SnackBar)],
    timeout: const Duration(seconds: 45),
  );
  expect(find.text(msg), findsWidgets);

  await tester.tap(find.byKey(const Key('chat_conversation_menu')));
  await tester.pumpAndSettle();
  expect(find.text('Eliminar conversación'), findsOneWidget);
  expect(find.text('Bloquear usuario'), findsOneWidget);
  expect(find.text('Reportar'), findsOneWidget);

  // Abrir flujo reportar (no hace falta completar el submit).
  await tester.tap(find.text('Reportar'));
  await tester.pumpAndSettle(const Duration(seconds: 2));
  expect(
    find.textContaining('Reportar').evaluate().isNotEmpty ||
        find.textContaining('Motivo').evaluate().isNotEmpty ||
        find.byType(TextField).evaluate().isNotEmpty,
    isTrue,
    reason: 'Reportar no abrió pantalla usable',
  );

  // Volver a conversación → lista → feed
  final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
  if (nav.canPop()) {
    nav.pop();
    await tester.pumpAndSettle();
  }
  if (nav.canPop()) {
    nav.pop();
    await tester.pumpAndSettle();
  }
  if (nav.canPop()) {
    nav.pop();
    await tester.pumpAndSettle();
  }
}
