import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/settings/presentation/providers/profile_providers.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(settingsControllerProvider);
    final settings = async.valueOrNull;
    final notifications = settings?.notifications;

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
      body: settings == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader('CANALES PRINCIPALES'),
            _NotificationSwitchTile(
              title: 'Notificaciones Push',
              subtitle: 'Recibe alertas en tu dispositivo',
              value: notifications!.pushEnabled,
              onChanged: (val) => ref.read(settingsControllerProvider.notifier).updateSettings(
                    settings.copyWith(notifications: notifications.copyWith(pushEnabled: val)),
                  ),
            ),
            _NotificationSwitchTile(
              title: 'Correo electrónico',
              subtitle: 'Recibe resúmenes y noticias',
              value: notifications.emailEnabled,
              onChanged: (val) => ref.read(settingsControllerProvider.notifier).updateSettings(
                    settings.copyWith(notifications: notifications.copyWith(emailEnabled: val)),
                  ),
            ),
            const Divider(color: Colors.white12, height: 32, indent: 20, endIndent: 20),
            const _SectionHeader('ACTIVIDAD'),
            _NotificationSwitchTile(
              title: 'Mensajes directos',
              value: notifications.messagesEnabled,
              onChanged: (val) => ref.read(settingsControllerProvider.notifier).updateSettings(
                    settings.copyWith(notifications: notifications.copyWith(messagesEnabled: val)),
                  ),
            ),
            _NotificationSwitchTile(
              title: 'Nuevas oportunidades',
              value: notifications.opportunitiesEnabled,
              onChanged: (val) => ref.read(settingsControllerProvider.notifier).updateSettings(
                    settings.copyWith(notifications: notifications.copyWith(opportunitiesEnabled: val)),
                  ),
            ),
            _NotificationSwitchTile(
              title: 'Consejos de entrenamiento',
              value: notifications.tipsEnabled,
              onChanged: (val) => ref.read(settingsControllerProvider.notifier).updateSettings(
                    settings.copyWith(notifications: notifications.copyWith(tipsEnabled: val)),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

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
      activeThumbColor: const Color(0xFF3B82F6),
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.white12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
