import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';
import 'edit_profile_page.dart';
import 'general_settings_page.dart';
import 'notification_settings_page.dart';
import 'privacy_settings_page.dart';
import 'security_settings_page.dart';
import 'social_settings_page.dart';
import 'help_support_page.dart';
import 'contact_support_page.dart';
import 'billing_settings_page.dart';
import 'package:sport/features/demo/presentation/pages/collaborations_showcase_page.dart';
import 'package:sport/features/demo/presentation/pages/groups_showcase_page.dart';
import 'package:sport/features/demo/presentation/pages/sponsorships_showcase_page.dart';
import 'package:sport/features/demo/presentation/pages/store_showcase_page.dart';
import 'package:sport/features/events/presentation/pages/events_list_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider(null));
    final user = ref.watch(authControllerProvider).valueOrNull;

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
          'CONFIGURACIÓN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SettingsHeader(title: 'PERFIL'),
            _SettingsTile(
              icon: Icons.person_outline,
              title: 'Editar perfil',
              subtitle: profileAsync.when(
                data: (p) => '${p.firstName} ${p.lastName}',
                loading: () => 'Cargando...',
                error: (_, _) => 'Información básica',
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              ),
            ),
            _SettingsTile(
              icon: Icons.badge_outlined,
              title: 'Datos adicionales',
              subtitle: 'Categoría, Deporte, Posición',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfilePage(),
                ), // Apunta a la misma por ahora
              ),
            ),

            const _SettingsHeader(title: 'PREFERENCIAS GENERALES'),
            _SettingsTile(
              icon: Icons.language,
              title: 'Idioma y región',
              subtitle: 'Español (España)',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GeneralSettingsPage()),
              ),
            ),
            _SettingsTile(
              icon: Icons.notifications_none,
              title: 'Notificaciones',
              subtitle: 'Push, Correo y Actividad',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsPage(),
                ),
              ),
            ),

            const _SettingsHeader(title: 'PRIVACIDAD Y SEGURIDAD'),
            _SettingsTile(
              icon: Icons.lock_person_outlined,
              title: 'Privacidad',
              subtitle: 'Visibilidad y bloqueos',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacySettingsPage()),
              ),
            ),
            _SettingsTile(
              icon: Icons.security,
              title: 'Seguridad',
              subtitle: 'Contraseña y 2FA',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecuritySettingsPage()),
              ),
            ),
            _SettingsTile(
              icon: Icons.block,
              title: 'Usuarios bloqueados',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SocialSettingsPage()),
              ),
            ),

            if (user?.demoPreview == true) ...[
              const _SettingsHeader(title: 'VISTA DE DEMOSTRACIÓN'),
              if (user!.canAccessDemoFeature('events'))
                _SettingsTile(
                  icon: Icons.event_outlined,
                  title: 'Eventos',
                  subtitle: 'Datos reales del entorno demo',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EventsListPage()),
                  ),
                ),
              if (user.canAccessDemoFeature('sponsorships'))
                _SettingsTile(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Patrocinios',
                  subtitle: 'Vista de demostración',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SponsorshipsShowcasePage(),
                    ),
                  ),
                ),
              if (user.canAccessDemoFeature('groups'))
                _SettingsTile(
                  icon: Icons.groups_outlined,
                  title: 'Grupos',
                  subtitle: 'Vista de demostración',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GroupsShowcasePage(),
                    ),
                  ),
                ),
              if (user.canAccessDemoFeature('collaborations'))
                _SettingsTile(
                  icon: Icons.handshake_outlined,
                  title: 'Colaboración',
                  subtitle: 'Vista de demostración',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CollaborationsShowcasePage(),
                    ),
                  ),
                ),
              if (user.canAccessDemoFeature('store'))
                _SettingsTile(
                  icon: Icons.storefront_outlined,
                  title: 'Tienda',
                  subtitle: 'Vista de demostración',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StoreShowcasePage(),
                    ),
                  ),
                ),
              if (user.canAccessDemoFeature('billing'))
                _SettingsTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Facturación',
                  subtitle: 'Sin cobros ni datos financieros reales',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BillingSettingsPage(),
                    ),
                  ),
                ),
            ],

            const _SettingsHeader(title: 'CUENTA'),
            _SettingsTile(
              icon: Icons.link,
              title: 'Cuentas vinculadas',
              subtitle: 'Google, Facebook, Apple',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SocialSettingsPage()),
              ),
            ),
            _SettingsTile(
              icon: Icons.help_outline,
              title: 'Ayuda y Soporte',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportPage()),
              ),
            ),
            _SettingsTile(
              icon: Icons.contact_support_outlined,
              title: 'Contacta con Hubsport',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactSupportPage()),
              ),
            ),

            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;
  const _SettingsHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF3B82F6), // Azul marca
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    );
  }
}
