import 'package:flutter/material.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

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
          'GENERAL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'PREFERENCIAS',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.language, color: Colors.white, size: 20),
            ),
            title: const Text(
              'Idioma de la aplicación',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Español (España)', style: TextStyle(color: Colors.white38, fontSize: 13)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
            onTap: () {
              // Mostrar selector de idioma
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Opacity(
                opacity: 0.5,
                child: Column(
                  children: [
                    Image.network(
                      'https://cdn-icons-png.flaticon.com/512/2921/2921222.png', // Un icono de app placeholder
                      width: 60,
                      height: 60,
                      color: Colors.white,
                      errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer, color: Colors.white, size: 60),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'HubSport v1.0.0',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Hecho con ❤️ para deportistas',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
