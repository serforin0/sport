import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/references/domain/entities/reference_request.dart';
import 'package:sport/features/references/presentation/pages/reference_detail_page.dart';
import 'package:sport/features/references/presentation/providers/references_providers.dart';

class ReferencesPage extends ConsumerStatefulWidget {
  const ReferencesPage({super.key});

  @override
  ConsumerState<ReferencesPage> createState() => _ReferencesPageState();
}

class _ReferencesPageState extends ConsumerState<ReferencesPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(referencesInboxProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        toolbarHeight: 86,
        backgroundColor: const Color(0xFF0F2A5B),
        leading: const BackButton(color: Colors.white),
        title: const Text('Referencias', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorColor: const Color(0xFFFF7A1A),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Recibidas'),
            Tab(text: 'Enviadas'),
          ],
        ),
      ),
      body: async.when(
        data: (inbox) => TabBarView(
          controller: _tabController,
          children: [
            _ReferenceRequestList(requests: inbox.received, isReceived: true),
            _ReferenceRequestList(requests: inbox.sent, isReceived: false),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se pudieron cargar referencias', style: TextStyle(color: Colors.white70)),
              TextButton(onPressed: () => ref.invalidate(referencesInboxProvider), child: const Text('Reintentar')),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferenceRequestList extends ConsumerWidget {
  final List<ReferenceRequestEntity> requests;
  final bool isReceived;

  const _ReferenceRequestList({required this.requests, required this.isReceived});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          isReceived ? 'No tienes solicitudes de referencia' : 'No has solicitado referencias',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        final user = isReceived ? request.requester : request.recipient;

        return Card(
          color: Colors.white.withValues(alpha: 0.08),
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ReferenceDetailPage(request: request, isReceived: isReceived),
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: user?.photoUrl == null ? null : NetworkImage(user!.photoUrl!),
                      child: user?.photoUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.name ?? user?.email ?? 'Usuario', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                          Text(_statusLabel(request.status), style: const TextStyle(color: Color(0xFF19B5FF), fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white30),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Relación: ${request.relationshipType}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                if (request.message?.isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  Text(request.message!, style: const TextStyle(color: Colors.white70, height: 1.4)),
                ],
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      'pending' => 'Pendiente',
      'accepted' => 'Aceptada',
      'pending_confirmation' => 'Pendiente de confirmación',
      'completed' => 'Publicada',
      'rejected' => 'Rechazada',
      _ => status,
    };
  }
}

