import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/features/connections/data/datasources/connections_remote_datasource.dart'
    show ConnectionConflictException;
import 'package:sport/features/connections/presentation/providers/connections_providers.dart';
import 'package:sport/features/people/domain/people_list_user.dart';
import 'package:sport/features/search/presentation/pages/search_page.dart';
import 'package:sport/features/search/presentation/providers/search_providers.dart';
import 'my_contacts_page.dart';

/// Hub **Personas**: contactos, búsqueda y sugerencias.
class PeoplePage extends ConsumerWidget {
  const PeoplePage({super.key});

  static Future<void> _sendRequest(WidgetRef ref, BuildContext context, PeopleListUser row) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final token = prefs.getString('auth_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para conectar')),
      );
      return;
    }
    final uid = row.user.id;
    if (uid.isEmpty) return;

    try {
      await ref.read(connectionsRemoteDataSourceProvider).sendRequest(token, uid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Solicitud enviada a ${row.user.name ?? row.user.email}')),
        );
      }
    } on ConnectionConflictException catch (e) {
      if (!context.mounted) return;
      final accept = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Solicitud pendiente', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Esa persona ya te envió una solicitud. ¿Quieres aceptarla?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Aceptar')),
          ],
        ),
      );
      if (accept == true && context.mounted) {
        await ref.read(incomingConnectionsProvider.notifier).accept(e.connectionId);
        ref.invalidate(acceptedConnectionsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Conectados!')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(acceptedConnectionsCountProvider);
    final suggestionsAsync = ref.watch(peopleSuggestionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF072353),
      appBar: AppBar(
        backgroundColor: const Color(0xFF072353),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Personas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF2CB5FF),
        backgroundColor: const Color(0xFF1E293B),
        onRefresh: () async {
          ref.invalidate(acceptedConnectionsProvider);
          ref.invalidate(peopleSuggestionsProvider);
          await ref.read(acceptedConnectionsProvider.future);
          await ref.read(peopleSuggestionsProvider.future);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _NavTile(
              label: count > 0 ? 'Ver mis contactos ($count)' : 'Ver mis contactos',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyContactsPage()),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                ),
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF15427D)),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFFE4F0FF), size: 30),
                      const SizedBox(width: 12),
                      const Text(
                        'Buscar personas',
                        style: TextStyle(color: Color(0xFF8FA8C4), fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 90),
            suggestionsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF2CB5FF))),
              ),
              error: (e, _) => Text(
                'No se cargaron sugerencias.\n$e',
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
              data: (rows) {
                if (rows.isEmpty) {
                  return const _PeopleEmptyState();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sugerencias para ti',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final row in rows)
                      _SuggestionTile(
                        row: row,
                        onConnect: () => _sendRequest(ref, context, row),
                      ),
                  ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF007BFF),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeopleEmptyState extends StatelessWidget {
  const _PeopleEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.manage_search, color: Color(0xFF9BB1CB), size: 132),
        SizedBox(height: 18),
        Text('Sin resultados', style: TextStyle(color: Colors.white, fontSize: 17)),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final PeopleListUser row;
  final VoidCallback onConnect;

  const _SuggestionTile({required this.row, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white12,
                backgroundImage:
                    row.user.photoUrl != null ? NetworkImage(row.user.photoUrl!) : null,
                child: row.user.photoUrl == null
                    ? const Icon(Icons.person, color: Colors.white38)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.user.name ?? row.user.email,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      row.detailLine,
                      style: const TextStyle(color: Color(0xFF2CB5FF), fontSize: 13),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onConnect,
                child: const Text('Conectar', style: TextStyle(color: Color(0xFF2CB5FF))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
