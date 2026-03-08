import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider(null));

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
                error: (_, __) => 'Información básica',
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
                MaterialPageRoute(builder: (_) => const EditProfilePage()), // Apunta a la misma por ahora
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
                MaterialPageRoute(builder: (_) => const NotificationSettingsPage()),
              ),
            ),

            const _SettingsHeader(title: 'SUSCRIPCIONES'),
            _SettingsTile(
              icon: Icons.star_outline,
              title: 'HubSport Premium',
              subtitle: 'Gestionar mi plan actual',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BillingSettingsPage()),
              ),
            ),
            _SettingsTile(
              icon: Icons.credit_card_outlined,
              title: 'Métodos de pago',
              subtitle: 'Tarjetas y facturación',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BillingSettingsPage()),
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
                onPressed: () {},
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
  final bool showArrow;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null 
          ? Text(subtitle!, style: const TextStyle(color: Colors.white38, fontSize: 13)) 
          : null,
      trailing: showArrow ? const Icon(Icons.chevron_right, color: Colors.white24) : null,
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF3B82F6),
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.white12,
    );
  }
}
