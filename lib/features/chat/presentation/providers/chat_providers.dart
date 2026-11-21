import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepositoryImpl(
    ref.watch(apiClientProvider),
    ref.watch(sharedPreferencesProvider),
  ),
);

final conversationsProvider = FutureProvider<List<ChatConversation>>((ref) {
  return ref.watch(chatRepositoryProvider).getConversations();
});

final messagesProvider =
    FutureProvider.family<List<ChatMessage>, String>((ref, conversationId) {
  return ref.watch(chatRepositoryProvider).getMessages(conversationId);
});

/// Notifier para la lista en vivo de mensajes de una conversación
class MessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final ChatRepository _repo;
  final String conversationId;

  MessagesNotifier(this._repo, this.conversationId)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final msgs = await _repo.getMessages(conversationId);
      state = AsyncValue.data(List.from(msgs));
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<String?> send(String text) async {
    final result = await _repo.sendMessage(conversationId, text);
    state.whenData((list) {
      state = AsyncValue.data([...list, result.message]);
    });
    return result.scamWarning;
  }
}

final messagesNotifierProvider = StateNotifierProvider.family<
    MessagesNotifier, AsyncValue<List<ChatMessage>>, String>(
  (ref, id) => MessagesNotifier(ref.watch(chatRepositoryProvider), id),
);
