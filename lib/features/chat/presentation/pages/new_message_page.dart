import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/connections/domain/entities/connected_contact.dart';
import 'package:sport/features/connections/presentation/providers/connections_providers.dart';

import '../providers/chat_providers.dart';
import 'conversation_page.dart';

/// Selector de contacto para iniciar un chat (`GET /connections` + abrir hilo).
class NewMessagePage extends ConsumerStatefulWidget {
  const NewMessagePage({super.key});

  @override
  ConsumerState<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends ConsumerState<NewMessagePage> {
  final _searchCtrl = TextEditingController();
  String? _openingUserId;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ConnectedContact> _filter(List<ConnectedContact> all, String q) {
    if (q.trim().isEmpty) return all;
    final lower = q.toLowerCase();
    return all
        .where((c) {
          final n = c.person.user.name?.toLowerCase() ?? '';
          final e = c.person.user.email.toLowerCase();
          final d = c.person.detailLine.toLowerCase();
          return n.contains(lower) || e.contains(lower) || d.contains(lower);
        })
        .toList();
  }

  Future<void> _openChat(ConnectedContact c) async {
    final uid = c.person.user.id;
    if (uid.isEmpty) return;
    setState(() => _openingUserId = uid);
    try {
      final repo = ref.read(chatRepositoryProvider);
      final name = c.person.user.name ?? c.person.user.email;
      final avatar = c.person.user.photoUrl ?? '';
      final conv = await repo.ensureDirectChat(
        otherUserId: uid,
        contactName: name,
        contactAvatar: avatar,
        contactSubtitle: c.person.detailLine,
      );
      ref.invalidate(conversationsProvider);
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ConversationPage(conversation: conv),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e is DioException
          ? (e.response?.data?.toString() ?? e.message ?? 'Error de red')
          : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el chat: $msg')),
      );
    } finally {
      if (mounted) setState(() => _openingUserId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(acceptedConnectionsProvider);

    return Scaffold(
      key: const Key('chat_new_message_page'),
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        toolbarHeight: 86,
        backgroundColor: const Color(0xFF0F2A5B),
        elevation: 0,
        leadingWidth: 70,
        leading: IconButton(
          icon: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: const Color(0xFF9B4DFF), width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nuevo mensaje',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                hintText: 'Mensaje para...',
                hintStyle: TextStyle(color: Color(0xFF8FA8C4)),
                prefixIcon: Icon(Icons.search, color: Colors.white, size: 28),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No se pudieron cargar tus contactos.\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              data: (list) {
                final filtered = _filter(list, _searchCtrl.text);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text(
                          list.isEmpty
                              ? 'Añade contactos en Personas para chatear'
                              : 'Sin resultados',
                          style: const TextStyle(color: Colors.white54, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(22, 14, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 0,
                    color: Colors.transparent,
                  ),
                  itemBuilder: (context, i) {
                    final c = filtered[i];
                    final busy = _openingUserId == c.person.user.id;
                    return InkWell(
                      onTap: busy ? null : () => _openChat(c),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white12,
                              backgroundImage: c.person.user.photoUrl != null
                                  ? NetworkImage(c.person.user.photoUrl!)
                                  : null,
                              child: c.person.user.photoUrl == null
                                  ? const Icon(Icons.person, color: Colors.white38)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.person.user.name ?? c.person.user.email,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    c.person.detailLine,
                                    style: const TextStyle(
                                      color: Color(0xFF2CB5FF),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (busy)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
