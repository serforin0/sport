import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/support/presentation/providers/support_providers.dart';
import 'contact_support_page.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

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
          'AYUDA Y SOPORTE',
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Cómo podemos ayudarte?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Contenido desde el servidor (GET /help) y contacto (POST /contact).',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _SupportOptionTile(
              icon: Icons.help_outline,
              title: 'Centro de Ayuda / FAQ',
              subtitle: 'Desde el API',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpApiContentPage()),
              ),
            ),
            _SupportOptionTile(
              icon: Icons.support_agent_outlined,
              title: 'Contactar Soporte',
              subtitle: 'Ticket por correo',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactSupportPage()),
              ),
            ),
            _SupportOptionTile(
              icon: Icons.bug_report_outlined,
              title: 'Reportar un problema',
              subtitle: 'Ayúdanos a mejorar la app',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactSupportPage()),
              ),
            ),
            _SupportOptionTile(
              icon: Icons.description_outlined,
              title: 'Términos y condiciones',
              onTap: () {},
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.star_outline, color: Color(0xFF3B82F6), size: 32),
                  const SizedBox(height: 12),
                  const Text(
                    '¿Te gusta HubSport?',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Danos tu opinión en la App Store para seguir creciendo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('CALIFICAR AHORA'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contenido de `GET /v1/help`.
class HelpApiContentPage extends ConsumerWidget {
  const HelpApiContentPage({super.key});

  static String _formatHelp(dynamic d) {
    if (d == null) return 'Sin contenido.';
    if (d is String) return d;
    if (d is Map) {
      final buf = StringBuffer();
      for (final e in d.entries) {
        buf.writeln('${e.key}: ${e.value}');
      }
      return buf.toString();
    }
    if (d is List) {
      return d.map((e) => e.toString()).join('\n\n');
    }
    return d.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(helpContentProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ayuda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white54))),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SelectableText(
            _formatHelp(data),
            style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
          ),
        ),
      ),
    );
  }
}

class _SupportOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SupportOptionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: Colors.white38, fontSize: 13))
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}
