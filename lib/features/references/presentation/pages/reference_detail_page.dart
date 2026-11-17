import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/references/domain/entities/reference_request.dart';
import 'package:sport/features/references/presentation/providers/references_providers.dart';

class ReferenceDetailPage extends ConsumerWidget {
  final ReferenceRequestEntity request;
  final bool isReceived;

  const ReferenceDetailPage({
    super.key,
    required this.request,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = isReceived ? request.requester : request.recipient;
    final suspicious = request.reference?.isSuspicious == true;

    return Scaffold(
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2A5B),
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Detalle de referencia',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: user?.photoUrl == null ? null : NetworkImage(user!.photoUrl!),
                child: user?.photoUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? user?.email ?? 'Usuario',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    Text(_statusLabel(request.status), style: const TextStyle(color: Color(0xFF19B5FF))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Relación: ${request.relationshipType}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          if (request.message?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(request.message!, style: const TextStyle(color: Colors.white70, height: 1.4)),
          ],
          if (request.reference != null) ...[
            const SizedBox(height: 16),
            const Text('Texto de la referencia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(request.reference!.body, style: const TextStyle(color: Colors.white, height: 1.45)),
          ],
          if (suspicious)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Semantics(
                label: 'Aviso de referencia sospechosa',
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFB547),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFB547)),
                  ),
                  child: Text(
                    'Referencia sospechosa: ${request.reference!.suspiciousReason ?? 'Patrón inusual'}',
                    style: const TextStyle(color: Color(0xFFFFB547), fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          _ReferenceActions(request: request, isReceived: isReceived),
        ],
      ),
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

class _ReferenceActions extends ConsumerWidget {
  final ReferenceRequestEntity request;
  final bool isReceived;

  const _ReferenceActions({required this.request, required this.isReceived});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isReceived && request.status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _run(context, ref, () => ref.read(referencesRepositoryProvider).rejectRequest(request.id)),
              child: const Text('Rechazar'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _run(context, ref, () => ref.read(referencesRepositoryProvider).acceptRequest(request.id)),
              child: const Text('Aceptar'),
            ),
          ),
        ],
      );
    }

    if (isReceived && (request.status == 'accepted' || request.status == 'pending_confirmation')) {
      return ElevatedButton(
        onPressed: () => _showWriteSheet(context, ref),
        child: Text(request.reference == null ? 'Escribir referencia' : 'Actualizar referencia'),
      );
    }

    if (!isReceived && request.status == 'pending_confirmation') {
      return ElevatedButton(
        onPressed: () => _run(context, ref, () => ref.read(referencesRepositoryProvider).confirmReference(request.id)),
        child: const Text('Confirmar y publicar'),
      );
    }

    return const Text(
      'Esta referencia no tiene acciones pendientes.',
      style: TextStyle(color: Colors.white54),
    );
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Referencia actualizada')));
      },
    );
  }
}
