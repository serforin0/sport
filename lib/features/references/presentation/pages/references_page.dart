import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/references/domain/entities/reference_request.dart';
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
                  ],
                ),
                const SizedBox(height: 12),
                Text('Relación: ${request.relationshipType}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                if (request.message?.isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  Text(request.message!, style: const TextStyle(color: Colors.white70, height: 1.4)),
                ],
                if (request.reference != null) ...[
                  const SizedBox(height: 10),
                  Text(request.reference!.body, style: const TextStyle(color: Colors.white, height: 1.4)),
                  if (request.reference!.isSuspicious)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Referencia sospechosa: ${request.reference!.suspiciousReason ?? 'Patrón inusual'}',
                        style: const TextStyle(color: Color(0xFFFFB547), fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
                const SizedBox(height: 12),
                _Actions(request: request, isReceived: isReceived),
              ],
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

class _Actions extends ConsumerWidget {
  final ReferenceRequestEntity request;
  final bool isReceived;

  const _Actions({required this.request, required this.isReceived});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isReceived && request.status == 'pending') {
      return Row(
        children: [
          Expanded(child: _ActionButton(label: 'Rechazar', outlined: true, onTap: () => _run(context, ref, () => ref.read(referencesRepositoryProvider).rejectRequest(request.id)))),
          const SizedBox(width: 10),
          Expanded(child: _ActionButton(label: 'Aceptar', onTap: () => _run(context, ref, () => ref.read(referencesRepositoryProvider).acceptRequest(request.id)))),
        ],
      );
    }

    if (isReceived && (request.status == 'accepted' || request.status == 'pending_confirmation')) {
      return _ActionButton(label: request.reference == null ? 'Escribir referencia' : 'Actualizar referencia', onTap: () => _showWriteSheet(context, ref));
    }

    if (!isReceived && request.status == 'pending_confirmation') {
      return _ActionButton(label: 'Confirmar y publicar', onTap: () => _run(context, ref, () => ref.read(referencesRepositoryProvider).confirmReference(request.id)));
    }

    return const SizedBox.shrink();
  }

  Future<void> _showWriteSheet(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController(text: request.reference?.body ?? '');
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Escribir referencia', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D))),
              const SizedBox(height: 12),
              TextFormField(
                controller: ctrl,
                maxLines: 5,
                validator: (value) => (value ?? '').trim().length < 20 ? 'Escribe al menos 20 caracteres' : null,
                decoration: const InputDecoration(hintText: 'Describe la relación deportiva y tu recomendación...'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() != true) return;
                    Navigator.pop(context);
                    _run(context, ref, () => ref.read(referencesRepositoryProvider).writeReference(request.id, ctrl.text.trim()));
                  },
                  child: const Text('Guardar referencia'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _run(BuildContext context, WidgetRef ref, Future<dynamic> Function() action) async {
    final result = await action();
    if (!context.mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ref.invalidate(referencesInboxProvider);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Referencia actualizada')));
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  const _ActionButton({required this.label, required this.onTap, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton(onPressed: onTap, child: Text(label));
    }
    return ElevatedButton(onPressed: onTap, child: Text(label));
  }
}
