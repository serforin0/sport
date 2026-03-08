import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _messagesEnabled = true;
  bool _eventsEnabled = true;
  bool _tipsEnabled = true;

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
          'NOTIFICACIONES',
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
            const _sectionHeader('CANALES PRINCIPALES'),
            _NotificationSwitchTile(
              title: 'Notificaciones Push',
              subtitle: 'Recibe alertas en tu dispositivo',
              value: _pushEnabled,
              onChanged: (val) => setState(() => _pushEnabled = val),
            ),
            _NotificationSwitchTile(
              title: 'Correo electrónico',
              subtitle: 'Recibe resúmenes y noticias',
              value: _emailEnabled,
              onChanged: (val) => setState(() => _emailEnabled = val),
            ),
            const Divider(color: Colors.white12, height: 32, indent: 20, endIndent: 20),
            const _sectionHeader('ACTIVIDAD'),
            _NotificationSwitchTile(
              title: 'Mensajes directos',
              value: _messagesEnabled,
              onChanged: (val) => setState(() => _messagesEnabled = val),
            ),
            _NotificationSwitchTile(
              title: 'Nuevos eventos',
              value: _eventsEnabled,
              onChanged: (val) => setState(() => _eventsEnabled = val),
            ),
            _NotificationSwitchTile(
              title: 'Consejos de entrenamiento',
              value: _tipsEnabled,
              onChanged: (val) => setState(() => _tipsEnabled = val),
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

class _NotificationSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationSwitchTile({
    required this.title,
    this.subtitle,
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
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: Colors.white38, fontSize: 13))
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF3B82F6),
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.white12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
