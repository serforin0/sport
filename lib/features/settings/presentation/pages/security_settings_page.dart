import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/settings/domain/entities/account_session.dart';
import 'package:sport/features/settings/presentation/providers/profile_providers.dart';

class SecuritySettingsPage extends ConsumerWidget {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    final sessionsAsync = ref.watch(accountSessionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SEGURIDAD',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SecurityHeader(title: 'ACCESO'),
            _SecurityTile(
              icon: Icons.vpn_key_outlined,
              title: 'Cambiar contraseña',
              onTap: () => _showPasswordSheet(context, ref),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              secondary: const Icon(Icons.phonelink_lock_outlined, color: Colors.white),
              title: const Text('Verificación en dos pasos', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
              subtitle: const Text('Preparado para la siguiente fase', style: TextStyle(color: Colors.white38, fontSize: 13)),
              value: settings?.security.is2FAEnabled ?? false,
              activeThumbColor: const Color(0xFF3B82F6),
              onChanged: settings == null
                  ? null
                  : (value) => ref.read(settingsControllerProvider.notifier).updateSettings(
                        settings.copyWith(security: settings.security.copyWith(is2FAEnabled: value)),
                      ),
            ),
            const SizedBox(height: 16),
            const _SecurityHeader(title: 'SESIONES ACTIVAS'),
            sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No hay sesiones registradas.', style: TextStyle(color: Colors.white70)),
                  );
                }
                return Column(
                  children: sessions.map((session) => _SessionTile(session: session)).toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: LinearProgressIndicator(),
              ),
              error: (_, _) => Padding(
                padding: const EdgeInsets.all(20),
                child: TextButton(
                  onPressed: () => ref.invalidate(accountSessionsProvider),
                  child: const Text('Reintentar cargar sesiones'),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.shield_outlined, color: Color(0xFF3B82F6), size: 48),
                    SizedBox(height: 16),
                    Text('Tu cuenta está protegida', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      'Mantén tu contraseña actualizada y revisa tus sesiones activas periódicamente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPasswordSheet(BuildContext context, WidgetRef ref) async {
    final currentCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
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
              const Text('Cambiar contraseña', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D))),
              const SizedBox(height: 16),
              TextFormField(
                controller: currentCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña actual'),
                validator: (value) => (value ?? '').isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nueva contraseña'),
                validator: (value) => (value ?? '').length < 8 ? 'Mínimo 8 caracteres' : null,
              ),
              TextFormField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
                validator: (value) => value != passwordCtrl.text ? 'Las contraseñas no coinciden' : null,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) return;
                    final result = await ref.read(settingsRepositoryProvider).changePassword(
                          currentCtrl.text,
                          passwordCtrl.text,
                          confirmCtrl.text,
                        );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    result.fold(
                      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
                      (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña actualizada'))),
                    );
                  },
                  child: const Text('Guardar contraseña'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionTile extends ConsumerWidget {
  final AccountSession session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.devices_outlined, color: Colors.white),
      title: Text(session.isCurrent ? 'Sesión actual' : 'Dispositivo conectado', style: const TextStyle(color: Colors.white, fontSize: 15)),
      subtitle: Text(
        '${session.ipAddress ?? 'IP desconocida'} · ${_formatDate(session.lastActivity)}\n${session.userAgent ?? 'Dispositivo desconocido'}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing: session.isCurrent
          ? const Text('Actual', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold))
          : TextButton(
              onPressed: () async {
                final result = await ref.read(settingsRepositoryProvider).closeSession(session.id);
                if (!context.mounted) return;
                result.fold(
                  (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
                  (_) {
                    ref.invalidate(accountSessionsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
                  },
                );
              },
              child: const Text('Cerrar'),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _SecurityHeader extends StatelessWidget {
  final String title;
  const _SecurityHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.1),
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SecurityTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    );
  }
}
