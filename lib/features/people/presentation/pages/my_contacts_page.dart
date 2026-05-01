import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/connections/domain/entities/connected_contact.dart';
import 'package:sport/features/connections/presentation/providers/connections_providers.dart';

/// Pantalla **Mis contactos** — lista desde `GET /connections` con filtro local.
class MyContactsPage extends ConsumerStatefulWidget {
  const MyContactsPage({super.key});

  @override
  ConsumerState<MyContactsPage> createState() => _MyContactsPageState();
}

class _MyContactsPageState extends ConsumerState<MyContactsPage> {
  final _searchCtrl = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(acceptedConnectionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF072353),
      appBar: AppBar(
        backgroundColor: const Color(0xFF072353),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mis Contactos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 1, color: const Color(0xFF15427D)),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2CB5FF))),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No se pudieron cargar los contactos.\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              data: (list) {
                final filtered = _filter(list, _searchCtrl.text);
                if (filtered.isEmpty) {
                  return _ContactsEmptyState(
                    message: list.isEmpty ? 'Actualmente no posee contactos' : 'Sin resultados',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                  itemBuilder: (context, i) {
                    final c = filtered[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white12,
                        backgroundImage:
                            c.person.user.photoUrl != null ? NetworkImage(c.person.user.photoUrl!) : null,
                        child: c.person.user.photoUrl == null
                            ? const Icon(Icons.person, color: Colors.white38)
                            : null,
                      ),
                      title: Text(
                        c.person.user.name ?? c.person.user.email,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          c.person.detailLine,
                          style: const TextStyle(color: Color(0xFF2CB5FF), fontSize: 13),
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

class _ContactsEmptyState extends StatelessWidget {
  final String message;

  const _ContactsEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 128, color: const Color(0xFF9BB1CB).withValues(alpha: 0.95)),
          const SizedBox(height: 22),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
        ],
      ),
    );
  }
}
