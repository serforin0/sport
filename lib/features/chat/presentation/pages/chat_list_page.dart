import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/chat/domain/entities/chat_conversation.dart';
import 'package:sport/features/chat/presentation/providers/chat_providers.dart';
import 'package:sport/features/chat/presentation/widgets/conversation_tile.dart';
import 'package:sport/features/chat/presentation/pages/conversation_page.dart';
import 'new_message_page.dart';
import '../../../../core/widgets/skeleton_base.dart';



class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ChatConversation> _filter(List<ChatConversation> all, String q) {
    if (q.trim().isEmpty) return all;
    final lower = q.trim().toLowerCase();
    return all.where((c) {
      final name = c.contactName.toLowerCase();
      final last = c.lastMessage.toLowerCase();
      final sub = c.contactSubtitle.toLowerCase();
      return name.contains(lower) || last.contains(lower) || sub.contains(lower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        toolbarHeight: 88,
        backgroundColor: const Color(0xFF0F2A5B),
        elevation: 0,
        leadingWidth: 70,
        leading: IconButton(
          icon: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        automaticallyImplyLeading: false,
        title: const Text(
          'Mensajes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
              onPressed: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const NewMessagePage()),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 56,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF1C4B8F)),
                bottom: BorderSide(color: Color(0xFF1C4B8F)),
              ),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Buscar',
                hintStyle: TextStyle(color: Color(0xFF8FA8C4)),
                prefixIcon: Icon(Icons.search, color: Colors.white, size: 28),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          Expanded(
            child: conversationsAsync.when(
              data: (conversations) {
                if (conversations.isEmpty) {
                  return _EmptyState();
                }
                final filtered = _filter(conversations, _searchCtrl.text);
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Sin resultados',
                      style: TextStyle(color: Colors.white38, fontSize: 15),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: const Color(0xFF3B82F6),
                  backgroundColor: const Color(0xFF0F2A5B),
                  onRefresh: () => ref.refresh(conversationsProvider.future),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final conv = filtered[index];
                      return ConversationTile(
                        conversation: conv,
                        onTap: () => _openConversation(context, conv),
                      );
                    },
                  ),
                );

              },
              loading: () => _buildSkeletonList(),
              error: (_, _) => const Center(
                child: Text(
                  'Error cargando mensajes',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openConversation(BuildContext context, ChatConversation conv) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ConversationPage(conversation: conv),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      itemCount: 6,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 72),
      itemBuilder: (_, _) => const _ConversationSkeleton(),
    );
  }
}

class _ConversationSkeleton extends StatelessWidget {
  const _ConversationSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SkeletonBase(width: 52, height: 52, borderRadius: 26),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBase(width: 120, height: 14),
                SizedBox(height: 8),
                SkeletonBase(width: double.infinity, height: 12),
              ],
            ),
          ),
        ],
      ),
    );

  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.forum_outlined, color: Color(0xFF9BB1CB), size: 116),
          const SizedBox(height: 20),
          const Text(
            'No tienes nuevos mensajes en este\nmomento. Sigue explorando y\nconectándote!',
            style: TextStyle(color: Colors.white, fontSize: 15, height: 1.35),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
