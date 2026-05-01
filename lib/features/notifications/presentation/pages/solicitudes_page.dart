import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/connections/domain/entities/pending_connection.dart';
import 'package:sport/features/connections/presentation/providers/connections_providers.dart';

class SolicitudesPage extends ConsumerWidget {
  const SolicitudesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(incomingConnectionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF072353),
      appBar: AppBar(
        backgroundColor: const Color(0xFF072353),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Solicitudes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => ref.read(incomingConnectionsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2CB5FF))),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No se pudieron cargar las solicitudes.\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
        ),
        data: (requests) => requests.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.people_outline, color: Colors.white24, size: 36),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sin solicitudes pendientes',
                      style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: requests.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.white.withOpacity(0.07),
                  height: 1,
                  indent: 80,
                ),
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return _ConnectionRequestTile(
                    request: req,
                    onAccept: () async {
                      try {
                        await ref.read(incomingConnectionsProvider.notifier).accept(req.connectionId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Conectado con ${req.name}'),
                              backgroundColor: const Color(0xFF007BFF),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    onReject: () {
                      ref.read(incomingConnectionsProvider.notifier).reject(req.connectionId);
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _ConnectionRequestTile extends StatelessWidget {
  final PendingConnection request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ConnectionRequestTile({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: request.photoUrl != null ? NetworkImage(request.photoUrl!) : null,
            backgroundColor: Colors.white12,
            child: request.photoUrl == null
                ? const Icon(Icons.person, color: Colors.white38, size: 24)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  request.roleLabel,
                  style: const TextStyle(
                    color: Color(0xFF2CB5FF),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text('Aceptar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 100,
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF007BFF),
                    side: const BorderSide(color: Color(0xFF007BFF)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Rechazar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
