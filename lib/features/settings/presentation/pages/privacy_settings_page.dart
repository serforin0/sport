import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _publicProfile = true;
  bool _showStats = true;
  bool _allowMessagesFromAnyone = false;

  @override
  Widget build(BuildContext context) {
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
          'PRIVACIDAD',
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
            const _sectionHeader('VISIBILIDAD'),
            _PrivacySwitchTile(
              title: 'Perfil público',
              subtitle: 'Cualquier usuario puede ver tu perfil y publicaciones',
              value: _publicProfile,
              onChanged: (val) => setState(() => _publicProfile = val),
            ),
            _PrivacySwitchTile(
              title: 'Mostrar estadísticas',
              subtitle: 'Tus seguidores podrán ver tu rendimiento y medallas',
              value: _showStats,
              onChanged: (val) => setState(() => _showStats = val),
            ),
            const Divider(color: Colors.white12, height: 32, indent: 20, endIndent: 20),
            const _sectionHeader('INTERACCIONES'),
            _PrivacySwitchTile(
              title: 'Mensajes de desconocidos',
              subtitle: 'Permitir que personas que no sigues te envíen mensajes',
              value: _allowMessagesFromAnyone,
              onChanged: (val) => setState(() => _allowMessagesFromAnyone = val),
            ),
            _PrivacyLinkTile(
              title: 'Usuarios bloqueados',
              trailingText: '12 usuarios',
              onTap: () {},
            ),
            _PrivacyLinkTile(
              title: 'Eliminar mi cuenta',
              textColor: Colors.redAccent,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _sectionHeader extends StatelessWidget {
  final String title;
  const _sectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF3B82F6),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _PrivacySwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivacySwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 13)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF3B82F6),
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.white12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}

class _PrivacyLinkTile extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback onTap;
  final Color? textColor;

  const _PrivacyLinkTile({
    required this.title,
    this.trailingText,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText!, style: const TextStyle(color: Colors.white24, fontSize: 13)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
