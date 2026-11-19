import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/events/presentation/pages/events_list_page.dart';
import 'package:sport/features/feed/presentation/pages/create_post_page.dart';
import 'package:sport/features/feed/presentation/pages/feed_page.dart';
import 'package:sport/features/people/presentation/pages/people_page.dart';
import 'package:sport/features/jobs/presentation/pages/jobs_list_page.dart';

/// Contenedor principal: Inicio, Personas, +, Trabajo, Eventos.
/// Chat vive en la barra superior del feed (junto a notificaciones).
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          FeedPage(),
          PeoplePage(),
          SizedBox.shrink(),
          JobsListPage(),
          EventsListPage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final posted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostPage()),
          );
          if (!context.mounted || posted != true) return;
          setState(() => _index = 0);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFFF5C1A),
              content: const Text(
                'Publicación Exitosa',
                style: TextStyle(color: Colors.white),
              ),
              action: SnackBarAction(
                label: 'Ver publicación',
                textColor: Colors.white,
                onPressed: () => setState(() => _index = 0),
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        height: 56,
        color: const Color(0xFF0F172A),
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BarItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Inicio',
              selected: _index == 0,
              onTap: () => setState(() => _index = 0),
            ),
            _BarItem(
              icon: Icons.person_search_outlined,
              activeIcon: Icons.person_search,
              label: 'Personas',
              selected: _index == 1,
              onTap: () => setState(() => _index = 1),
            ),
            const SizedBox(width: 44),
            _BarItem(
              icon: Icons.work_outline_rounded,
              activeIcon: Icons.work_rounded,
              label: 'Trabajo',
              selected: _index == 3,
              onTap: () => setState(() => _index = 3),
            ),
            _BarItem(
              icon: Icons.event_outlined,
              activeIcon: Icons.event,
              label: 'Eventos',
              selected: _index == 4,
              onTap: () => setState(() => _index = 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = selected ? const Color(0xFF3B82F6) : Colors.white38;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: c, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
