import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/feed/presentation/providers/feed_providers.dart';
import 'package:sport/features/feed/presentation/widgets/post_card.dart';
import 'package:sport/features/settings/presentation/pages/settings_page.dart';
import 'package:sport/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:sport/features/profile/presentation/pages/statistics_page.dart';
import 'package:sport/features/scout_metrics/presentation/pages/scout_metrics_page.dart';
import 'package:sport/features/connections/presentation/pages/connection_circle_page.dart';
import 'package:sport/features/auth/domain/entities/user.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.valueOrNull;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _ProfileContent(user: user),
    );
  }
}

class _ProfileContent extends ConsumerStatefulWidget {
  final User user;
  const _ProfileContent({required this.user});

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent> {
  int _activeTab = 0; // 0: Experiencia, 1: Logros, 2: Publicaciones

  String _profileTypeLabel(String? value) {
    return switch (value) {
      'athlete' => 'Atleta',
      'coach' => 'Entrenador',
      'recruiter' => 'Reclutador',
      'sponsor' => 'Marca / Patrocinador',
      'event_organizer' => 'Organizador de eventos',
      'fan' => 'Fanático del deporte',
      _ => value?.isNotEmpty == true ? value! : 'Perfil deportivo',
    };
  }

  String _detailLine(User user) {
    final parts = [
      _profileTypeLabel(user.profileType),
      if ((user.position ?? '').isNotEmpty) user.position!,
      if ((user.mainSport ?? '').isNotEmpty) user.mainSport!,
      if ((user.country ?? '').isNotEmpty) user.country!,
    ];
    return parts.where((part) => part.trim().isNotEmpty).join(' • ');
  }

  String _dateLine(User user) {
    if ((user.birthDate ?? '').isEmpty) return '';
    return 'F. de Nac. ${user.birthDate}';
  }

  void _showContactModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Teléfono',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Text(
              widget.user.phoneNumber?.isNotEmpty == true
                  ? widget.user.phoneNumber!
                  : 'No disponible',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            const Text(
              'Correo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Text(
              widget.user.email,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = widget.user;

    return Stack(
      children: [
        // Background Image Header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: size.height * 0.45,
          child: Hero(
            tag: 'profile_image_${user.id}',
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                      ? NetworkImage(user.photoUrl!)
                      : const NetworkImage(
                          'https://images.unsplash.com/photo-1542362567-b055002b91f4?q=80&w=2070&auto=format&fit=crop',
                        ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFF0F172A),
                      Colors.transparent.withValues(alpha: 0.1),
                    ],
                    stops: const [0.0, 0.4],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Custom App Bar Elements
        Positioned(
          top: 50,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleIcon(
                icon: Icons.chevron_left,
                onTap: () => Navigator.pop(context),
              ),
              Row(
                children: [
                  _CircleIcon(
                    icon: Icons.logout,
                    onTap: () =>
                        ref.read(authControllerProvider.notifier).signOut(),
                  ),
                  const SizedBox(width: 12),
                  _CircleIcon(
                    icon: Icons.settings_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Profile Content Scrollable
        Positioned.fill(
          top: size.height * 0.28,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Info Card
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E4572),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      Text(
                        user.name ?? 'Usuario',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user.handle != null && user.handle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.handle!,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        _detailLine(user),
                        style: TextStyle(
                          color: Colors.blueAccent.shade100,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      if (_dateLine(user).isNotEmpty)
                        Text(
                          _dateLine(user),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConnectionCirclePage(
                              userId: user.id,
                              userName: user.name,
                            ),
                          ),
                        ),
                        child: Text(
                          '${user.connectionsCount} conexiones',
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: _GradientButton(
                              label: 'Contacto',
                              onTap: _showContactModal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _OutlinedButton(
                              label: 'Editar perfil',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfilePage(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (user.accountStatus == 'pending_guardian') ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF78350F).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Cuenta pendiente de confirmación del tutor. Hasta entonces no podrás publicar ni chatear.',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      const _SectionHeader(title: 'Acerca de'),
                      const SizedBox(height: 12),
                      Text(
                        user.bio?.trim().isNotEmpty == true
                            ? user.bio!
                            : 'Aún no has agregado una biografía. Completa tu perfil para que otros usuarios conozcan tu trayectoria deportiva.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),
                      const _SectionHeader(title: 'Estadísticas'),
                      const SizedBox(height: 16),
                      _DetailedStatsGrid(stats: user.stats),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ScoutMetricsPage(),
                            ),
                          ),
                          child: const Text(
                            'Perfil scout (físico y métricas) →',
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StatisticsPage(
                                userName: user.name ?? 'Usuario',
                                userRole: _profileTypeLabel(user.profileType),
                                userLocation: [user.city, user.country]
                                    .where((item) => item?.isNotEmpty == true)
                                    .join(', '),
                                photoUrl:
                                    (user.photoUrl != null &&
                                        user.photoUrl!.isNotEmpty)
                                    ? user.photoUrl
                                    : null,
                                stats: user.stats,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Mostrar más estadísticas →',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Custom Tabs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _PillTab(
                            label: 'Experiencia',
                            isActive: _activeTab == 0,
                            onTap: () => setState(() => _activeTab = 0),
                          ),
                          _PillTab(
                            label: 'Logros',
                            isActive: _activeTab == 1,
                            onTap: () => setState(() => _activeTab = 1),
                          ),
                          _PillTab(
                            label: 'Publicaciones',
                            isActive: _activeTab == 2,
                            onTap: () => setState(() => _activeTab = 2),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _buildTabContent(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return _ExperienceContent(user: widget.user);
      case 1:
        return _AchievementsContent(user: widget.user);
      case 2:
        return _PostsContent(userId: widget.user.id);
      default:
        return const SizedBox.shrink();
    }
  }
}

// Components copied from UserProfilePage for UI consistency

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DetailedStatsGrid extends StatelessWidget {
  final List<dynamic>? stats;

  const _DetailedStatsGrid({this.stats});

  List<Map<String, String>> _items() {
    final parsed = (stats ?? [])
        .whereType<Map>()
        .map(
          (item) => {
            'value': (item['value'] ?? '').toString(),
            'label': (item['label'] ?? '').toString(),
          },
        )
        .where((item) => item['value']!.isNotEmpty || item['label']!.isNotEmpty)
        .toList();
    if (parsed.isNotEmpty) return parsed;

    return const [
      {'value': '0', 'label': 'Publicaciones'},
      {'value': '0', 'label': 'Seguidores'},
      {'value': '0', 'label': 'Conexiones'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _items();
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: items
          .take(6)
          .map(
            (item) => _StatBox(
              value: item['value'] ?? '0',
              label: item['label'] ?? 'Dato',
            ),
          )
          .toList(),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _PillTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF9441) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ExperienceContent extends StatelessWidget {
  final User user;

  const _ExperienceContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final items = (user.experience ?? []).whereType<Map>().toList();
    if (items.isEmpty) {
      return const _ProfileEmptyState(
        title: 'Sin experiencia registrada',
        message:
            'Agrega tu equipo actual, trayectoria o torneos desde Editar perfil.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información deportiva',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < items.length; i++)
          _TimelineItem(
            title:
                (items[i]['title'] ??
                        items[i]['role'] ??
                        'Experiencia deportiva')
                    .toString(),
            subtitle:
                (items[i]['subtitle'] ??
                        items[i]['team'] ??
                        user.currentTeam ??
                        '')
                    .toString(),
            date: (items[i]['date'] ?? items[i]['period'] ?? '').toString(),
            description: (items[i]['description'] ?? '').toString(),
            trainer: (items[i]['trainer'] ?? items[i]['coach'] ?? '')
                .toString(),
            isFirst: i == 0,
            isLast: i == items.length - 1,
          ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String description;
  final String trainer;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.description,
    required this.trainer,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: Colors.white24)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF2CB5FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                if (date.isNotEmpty)
                  Text(
                    date,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
                if (trainer.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Entrenador: $trainer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsContent extends StatelessWidget {
  final User user;

  const _AchievementsContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final items = (user.achievements ?? []).whereType<Map>().toList();
    if (items.isEmpty) {
      return const _ProfileEmptyState(
        title: 'Sin logros registrados',
        message:
            'Agrega premios, torneos o fotografías deportivas desde Editar perfil.',
      );
    }

    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          _TimelineAchievement(
            title: (items[i]['title'] ?? items[i]['name'] ?? 'Logro deportivo')
                .toString(),
            date: (items[i]['date'] ?? items[i]['year'] ?? '').toString(),
            images: (items[i]['images'] is List)
                ? (items[i]['images'] as List)
                      .map((image) => image.toString())
                      .where((image) => image.isNotEmpty)
                      .toList()
                : null,
            isCert:
                items[i]['is_cert'] == true ||
                items[i]['type'] == 'certificate',
            isFirst: i == 0,
            isLast: i == items.length - 1,
          ),
      ],
    );
  }
}

class _TimelineAchievement extends StatelessWidget {
  final String title;
  final String date;
  final List<String>? images;
  final bool isCert;
  final bool isFirst;
  final bool isLast;

  const _TimelineAchievement({
    required this.title,
    required this.date,
    this.images,
    this.isCert = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: Colors.white24)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF2CB5FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (date.isNotEmpty)
                  Text(
                    date,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                const SizedBox(height: 12),
                if (images != null)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images!.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            images![i],
                            width: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (isCert)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 180,
                      height: 120,
                      color: Colors.white.withValues(alpha: 0.08),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.workspace_premium_outlined,
                        color: Colors.white38,
                        size: 42,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEmptyState extends StatelessWidget {
  final String title;
  final String message;

  const _ProfileEmptyState({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostsContent extends ConsumerWidget {
  final String userId;
  const _PostsContent({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(userPostsProvider(userId));

    return Column(
      children: [
        postsAsync.when(
          data: (posts) {
            if (posts.isEmpty) {
              return const Center(
                child: Text(
                  'No hay publicaciones',
                  style: TextStyle(color: Colors.white38),
                ),
              );
            }
            return Column(
              children: [
                if (posts.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _PostGridImage(
                          url:
                              (posts[0].imageUrl != null &&
                                  posts[0].imageUrl!.isNotEmpty)
                              ? posts[0].imageUrl!
                              : 'https://images.unsplash.com/photo-1542362567-b055002b91f4?q=80&w=2070&auto=format&fit=crop',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PostGridImage(
                          url:
                              (posts.length > 1 &&
                                  posts[1].imageUrl != null &&
                                  posts[1].imageUrl!.isNotEmpty)
                              ? posts[1].imageUrl!
                              : '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _PostGridImage(
                    url:
                        (posts.length > 2 &&
                            posts[2].imageUrl != null &&
                            posts[2].imageUrl!.isNotEmpty)
                        ? posts[2].imageUrl!
                        : '',
                    height: 180,
                  ),
                  const SizedBox(height: 12),
                  PostCard(post: posts[0]),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
            child: Text(
              'Error cargando posts',
              style: TextStyle(color: Colors.white38),
            ),
          ),
        ),
      ],
    );
  }
}

class _PostGridImage extends StatelessWidget {
  final String url;
  final double height;
  const _PostGridImage({required this.url, this.height = 120});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => Container(
          color: Colors.white.withValues(alpha: 0.05),
          child: const Icon(Icons.image, color: Colors.white12),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A8BF5), Color(0xFF2C65E1)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlinedButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white70),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
