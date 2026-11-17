import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/profile/presentation/pages/profile_page.dart';
import 'package:sport/features/references/presentation/pages/references_page.dart';
import 'package:sport/features/settings/presentation/pages/settings_page.dart';
import 'package:sport/features/demo/presentation/pages/collaborations_showcase_page.dart';
import 'package:sport/features/demo/presentation/pages/groups_showcase_page.dart';
import 'package:sport/features/demo/presentation/pages/sponsorships_showcase_page.dart';
import 'package:sport/features/demo/presentation/pages/store_showcase_page.dart';
import 'package:sport/features/events/presentation/pages/events_list_page.dart';
import 'package:sport/features/settings/presentation/pages/billing_settings_page.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final isDemo = user?.demoPreview == true;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
      child: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // Blue Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(
                  0xFFE0F2FE,
                ), // Very light blue for header background
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: user?.photoUrl != null
                        ? CachedNetworkImageProvider(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? const Icon(Icons.person, size: 30, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Usuario',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            // Navigate to edit profile (can be a specific page or the profile page)
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfilePage(),
                              ),
                            );
                          },
                          child: const Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 14,
                                color: Color(0xFF3B82F6),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Editar perfil',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF3B82F6),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Ver mi perfil',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Eventos',
                    subtitle: isDemo ? 'Vista de demostración' : 'Próximamente',
                    onTap: () {
                      Navigator.pop(context);
                      if (user?.canAccessDemoFeature('events') == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EventsListPage(),
                          ),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Eventos estará disponible próximamente',
                          ),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.groups_outlined,
                    label: 'Grupos',
                    subtitle: isDemo ? 'Vista de demostración' : 'Próximamente',
                    onTap: () {
                      Navigator.pop(context);
                      if (user?.canAccessDemoFeature('groups') == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GroupsShowcasePage(),
                          ),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Grupos estará disponible próximamente',
                          ),
                        ),
                      );
                    },
                  ),
                  if (isDemo) ...[
                    if (user?.canAccessDemoFeature('sponsorships') == true)
                      _DrawerItem(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Patrocinios',
                        subtitle: 'Vista de demostración',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SponsorshipsShowcasePage(),
                            ),
                          );
                        },
                      ),
                    if (user?.canAccessDemoFeature('collaborations') == true)
                      _DrawerItem(
                        icon: Icons.handshake_outlined,
                        label: 'Colaboración',
                        subtitle: 'Vista de demostración',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const CollaborationsShowcasePage(),
                            ),
                          );
                        },
                      ),
                    if (user?.canAccessDemoFeature('store') == true)
                      _DrawerItem(
                        icon: Icons.storefront_outlined,
                        label: 'Tienda',
                        subtitle: 'Vista de demostración',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StoreShowcasePage(),
                            ),
                          );
                        },
                      ),
                    if (user?.canAccessDemoFeature('billing') == true)
                      _DrawerItem(
                        icon: Icons.receipt_long_outlined,
                        label: 'Facturación',
                        subtitle: 'Vista de demostración',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BillingSettingsPage(),
                            ),
                          );
                        },
                      ),
                  ],
                  _DrawerItem(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Referencias',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReferencesPage(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Configuración',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(authControllerProvider.notifier).signOut();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: Color(0xFFE11D48),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF334155), size: 28),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          color: Color(0xFF334155),
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
