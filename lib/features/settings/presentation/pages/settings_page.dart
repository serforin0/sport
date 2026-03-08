import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Fondo oscuro premium
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
            fontSize: 18,
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
            const _SettingsHeader(title: 'CUENTA'),
            _SettingsTile(
              icon: Icons.person_outline,
              title: 'Editar perfil',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.email_outlined,
              title: 'Correo electrónico',
              subtitle: 'miguel.ovalles@email.com',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: 'Cambiar contraseña',
              onTap: () {},
            ),

            const _SettingsHeader(title: 'NOTIFICACIONES'),
            _SettingsSwitchTile(
              icon: Icons.notifications_none,
              title: 'Notificaciones Push',
              value: true,
              onChanged: (val) {},
            ),
            _SettingsSwitchTile(
              icon: Icons.mail_outline,
              title: 'Notificaciones por correo',
              value: false,
              onChanged: (val) {},
            ),

            const _SettingsHeader(title: 'PRIVACIDAD Y SEGURIDAD'),
            _SettingsTile(
              icon: Icons.visibility_outlined,
              title: 'Visibilidad del perfil',
              subtitle: 'Público',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.block_outlined,
              title: 'Usuarios bloqueados',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.verified_user_outlined,
              title: 'Autenticación de dos pasos',
              onTap: () {},
            ),

            const _SettingsHeader(title: 'AYUDA Y SOPORTE'),
            _SettingsTile(
              icon: Icons.help_outline,
              title: 'Centro de ayuda / FAQ',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.contact_support_outlined,
              title: 'Contáctanos',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Términos y condiciones',
              onTap: () {},
            ),

            const _SettingsHeader(title: 'ACERCA DE'),
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'Versión de la aplicación',
              subtitle: '1.0.0 (Build 42)',
              showArrow: false,
              onTap: () {},
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
