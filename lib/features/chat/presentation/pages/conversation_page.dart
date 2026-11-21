import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sport/features/safety/presentation/pages/report_user_page.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_providers.dart';
import '../widgets/message_bubble.dart';

class ConversationPage extends ConsumerStatefulWidget {
  final ChatConversation conversation;

  const ConversationPage({super.key, required this.conversation});

  @override
  ConsumerState<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends ConsumerState<ConversationPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _wasEmpty = true;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final warning = await ref
        .read(messagesNotifierProvider(widget.conversation.id).notifier)
        .send(text);
    _scheduleScrollToBottom();
    if (!mounted) return;
    if (warning != null && warning.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(warning),
          backgroundColor: const Color(0xFFB45309),
        ),
      );
    }
  }

  void _scheduleScrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showOptionsMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF163A73),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.white),
              title: const Text('Eliminar conversación', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _handleDeleteChat();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.white),
              title: const Text('Bloquear usuario', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _handleBlockUser();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.white),
              title: const Text('Reportar', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportUserPage(
                      targetUserId: widget.conversation.contactUserId,
                      conversationId: int.tryParse(widget.conversation.id),
                      targetName: widget.conversation.contactName,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDeleteChat() async {
    try {
      await ref.read(chatRepositoryProvider).deleteConversation(widget.conversation.id);
      ref.invalidate(conversationsProvider);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la conversación')),
      );
    }
  }

  Future<void> _handleBlockUser() async {
    final userId = widget.conversation.contactUserId;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar al usuario')),
      );
      return;
    }
    try {
      await ref.read(chatRepositoryProvider).blockUser(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario bloqueado')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo bloquear al usuario')),
      );
    }
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Esta opción estará disponible próximamente'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      messagesNotifierProvider(widget.conversation.id),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F2A5B),
      // Let keyboard resize the body
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 86,
        backgroundColor: const Color(0xFF0F2A5B),
        elevation: 0,
        titleSpacing: 0,
        leadingWidth: 70,
        leading: IconButton(
          icon: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 22,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.conversation.contactName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.conversation.contactSubtitle.trim().isNotEmpty)
                    Text(
                      widget.conversation.contactSubtitle,
                      style: const TextStyle(
                        color: Color(0xFF2CB5FF),
                        fontSize: 11,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      widget.conversation.isOnline
                          ? 'En línea'
                          : 'Desconectado',
                      style: TextStyle(
                        color: widget.conversation.isOnline
                            ? const Color(0xFF22C55E)
                            : Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('chat_conversation_menu'),
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 30),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (_wasEmpty && messages.isNotEmpty) {
                  _wasEmpty = false;
                  _scheduleScrollToBottom();
                }
                if (messages.isEmpty) {
                  return _EmptyConversationProfile(
                    conversation: widget.conversation,
                  );
                }
                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: _messageListWithDateChips(messages),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
              ),
              error: (_, _) => const Center(
                child: Text(
                  'Error cargando mensajes',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ),
          ),

          // Input bar — uses SafeArea + padding for keyboard
          SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(color: Colors.transparent),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF506B99),
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('chat_message_input'),
                        controller: _controller,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 4,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Mensaje',
                          hintStyle: TextStyle(
                            color: Color(0xFF9AB0CC),
                            fontSize: 14,
                          ),
                          contentPadding: EdgeInsets.fromLTRB(16, 12, 8, 12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _showComingSoon,
                      icon: const Icon(
                        Icons.attach_file,
                        color: Colors.white54,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                    IconButton(
                      onPressed: _showComingSoon,
                      icon: const Icon(
                        Icons.image_outlined,
                        color: Colors.white54,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _controller,
                      builder: (_, value, _) {
                        final hasText = value.text.trim().isNotEmpty;
                        if (!hasText) return const SizedBox(width: 4);
                        return IconButton(
                          key: const Key('chat_send_button'),
                          onPressed: _send,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Color(0xFF19B5FF),
                            size: 28,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _messageListWithDateChips(List<ChatMessage> messages) {
    final sorted = List<ChatMessage>.from(messages)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final items = <Widget>[];
    DateTime? lastDay;
    for (final m in sorted) {
      final d = DateTime(m.timestamp.year, m.timestamp.month, m.timestamp.day);
      final prev = lastDay;
      if (prev == null ||
          d.year != prev.year ||
          d.month != prev.month ||
          d.day != prev.day) {
        lastDay = d;
        items.add(_ChatDateChip(label: _chatDateLabel(d)));
      }
      items.add(
        MessageBubble(
          message: m,
          peerAvatarUrl: widget.conversation.contactAvatar,
        ),
      );
    }
    return items;
  }

  String _chatDateLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return 'Hoy';
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == yesterday) return 'Ayer';
    try {
      return DateFormat('d MMM', 'es').format(day);
    } catch (_) {
      return '${day.day}/${day.month}/${day.year}';
    }
  }
}

class _ChatDateChip extends StatelessWidget {
  final String label;

  const _ChatDateChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0B3A6E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyConversationProfile extends StatelessWidget {
  final ChatConversation conversation;

  const _EmptyConversationProfile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = conversation.contactAvatar.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 58,
              backgroundColor: Colors.white12,
              backgroundImage: hasAvatar
                  ? NetworkImage(conversation.contactAvatar)
                  : null,
              child: hasAvatar
                  ? null
                  : const Icon(Icons.person, color: Colors.white54, size: 58),
            ),
            const SizedBox(height: 18),
            Text(
              conversation.contactName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (conversation.contactSubtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                conversation.contactSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF19B5FF), fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
