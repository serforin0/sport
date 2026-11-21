import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport/features/profile/presentation/providers/profile_providers.dart';
import 'package:sport/features/connections/presentation/providers/connections_providers.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/profile/presentation/pages/statistics_page.dart';
import 'package:sport/features/feed/presentation/widgets/post_card.dart';
import 'package:sport/features/feed/presentation/providers/feed_providers.dart';
import 'package:sport/features/chat/presentation/providers/chat_providers.dart';
import 'package:sport/features/chat/presentation/pages/conversation_page.dart';
import 'package:sport/features/references/presentation/providers/references_providers.dart';
import 'package:sport/features/safety/presentation/pages/report_user_page.dart';
import 'package:sport/features/connections/presentation/pages/connection_circle_page.dart';

class UserProfilePage extends ConsumerWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(userId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: profileAsync.when(
        data: (user) => _UserProfileContent(user: user),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF2CB5FF)),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white38, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Usuario no disponible en este momento',
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: () => ref.invalidate(profileProvider(userId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserProfileContent extends ConsumerStatefulWidget {
  final User user;
  const _UserProfileContent({required this.user});

  @override
  ConsumerState<_UserProfileContent> createState() =>
      _UserProfileContentState();
}

class _UserProfileContentState extends ConsumerState<_UserProfileContent> {
  int _activeTab = 0; // 0: Experiencia, 1: Logros, 2: Publicaciones

  Future<void> _handleConnect() async {
    final status = widget.user.connectionStatus ?? 'none';
    if (status == 'none') {
      try {
        await ref
            .read(connectionsRemoteDataSourceProvider)
            .sendRequest(
              ref.read(sharedPreferencesProvider).getString('auth_token') ?? '',
              widget.user.id,
            );
        ref.invalidate(profileProvider(widget.user.id));
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Solicitud enviada')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _handleMessage() async {
    try {
      final conversation = await ref
          .read(chatRepositoryProvider)
          .ensureDirectChat(
            otherUserId: widget.user.id,
            contactName: widget.user.name ?? widget.user.email,
            contactAvatar: widget.user.photoUrl ?? '',
            contactSubtitle: _detailLine(widget.user),
          );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConversationPage(conversation: conversation),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo abrir el chat: $e')));
    }
  }

  Future<void> _showReferenceRequestSheet() async {
    final messageCtrl = TextEditingController();
    String relationshipType = 'Entrenador';
    final parentContext = context;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            18,
            24,
            MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Solicitar referencia',
                style: TextStyle(
                  color: Color(0xFF2D2D2D),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Pídele a ${widget.user.name ?? widget.user.email} que valide su relación deportiva contigo.',
                style: const TextStyle(color: Color(0xFF606060), height: 1.4),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: relationshipType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de relación',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Entrenador',
                    child: Text('Entrenador'),
                  ),
                  DropdownMenuItem(
                    value: 'Compañero de equipo',
                    child: Text('Compañero de equipo'),
                  ),
                  DropdownMenuItem(
                    value: 'Organización',
                    child: Text('Organización'),
                  ),
                ],
                onChanged: (value) => setSheetState(
                  () => relationshipType = value ?? relationshipType,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mensaje opcional',
                  hintText:
                      'Ej: ¿Puedes validar que entrenamos juntos esta temporada?',
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await ref
                        .read(referencesRepositoryProvider)
                        .requestReference(
                          recipientId: widget.user.id,
                          relationshipType: relationshipType,
                          message: messageCtrl.text,
                        );
                    if (!context.mounted || !parentContext.mounted) return;
                    Navigator.pop(context);
                    result.fold(
                      (failure) => ScaffoldMessenger.of(
                        parentContext,
                      ).showSnackBar(SnackBar(content: Text(failure.message))),
                      (_) {
                        ref.invalidate(
                          publishedReferencesProvider(widget.user.id),
                        );
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(
                            content: Text('Solicitud de referencia enviada'),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('Enviar solicitud'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  String _sportLevelLabel(String? value) {
    return switch (value) {
      'beginner' => 'Principiante',
      'amateur' => 'Amateur',
      'semi_pro' => 'Semiprofesional',
      'professional' => 'Profesional',
      'elite' => 'Élite',
      _ => value ?? '',
    };
  }

  String _detailLine(User user) {
    final parts = [
      _profileTypeLabel(user.profileType),
      if ((user.position ?? '').isNotEmpty) user.position!,
      if ((user.mainSport ?? '').isNotEmpty) user.mainSport!,
      if ((user.city ?? '').isNotEmpty) user.city!,
      if ((user.country ?? '').isNotEmpty) user.country!,
    ];
    return parts.where((part) => part.trim().isNotEmpty).join(' • ');
  }

  String _dateLine(User user) {
    if ((user.birthDate ?? '').isEmpty) return '';
    return 'F. de Nac. ${user.birthDate}';
  }

  String _connectLabel(String? status) {
    return switch (status) {
      'accepted' => 'Conectado',
      'pending_outgoing' => 'Solicitud enviada',
      'pending_incoming' => 'Responder solicitud',
      _ => 'Conectar',
    };
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Esta opción estará disponible próximamente'),
      ),
    );
  }

  void _showContactModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 14, 28, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Teléfono',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.user.phoneNumber?.isNotEmpty == true
                    ? widget.user.phoneNumber!
                    : 'No disponible',
                style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 24),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(height: 1),
              ),
              const Text(
                'Correo',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.user.email,
                style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 22),
              ),
            ],
          ),
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
                  image: NetworkImage(
                    user.photoUrl ??
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
              _CircleIcon(icon: Icons.more_vert, onTap: _showComingSoon),
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
                      if (user.verifiedBadge || user.isEmailVerified) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF2CB5FF)),
                          ),
                          child: const Text(
                            'Perfil verificado',
                            style: TextStyle(
                              color: Color(0xFF2CB5FF),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
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
                          user.mutualConnectionsCount > 0
                              ? '${user.connectionsCount} conexiones · ${user.mutualConnectionsCount} en común'
                              : '${user.connectionsCount} conexiones',
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                      if ((user.currentTeam ?? '').isNotEmpty ||
                          (user.sportLevel ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          [
                            if ((user.currentTeam ?? '').isNotEmpty)
                              'Equipo: ${user.currentTeam}',
                            if ((user.sportLevel ?? '').isNotEmpty)
                              'Nivel: ${_sportLevelLabel(user.sportLevel)}',
                          ].join(' • '),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),

                      if (user.connectionStatus == 'accepted')
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
                                label: 'Enviar mensaje',
                                icon: Icons.chat_bubble_outline,
                                onTap: _handleMessage,
                              ),
                            ),
                          ],
                        )
                      else
                        _OutlinedButton(
                          label: _connectLabel(user.connectionStatus),
                          onTap: user.connectionStatus == 'none'
                              ? _handleConnect
                              : _showComingSoon,
                        ),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportUserPage(
                                targetUserId: user.id,
                                targetName: user.name,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.flag_outlined, color: Colors.white54, size: 16),
                          label: const Text(
                            'Reportar perfil',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ),
                      ),
                      if (user.connectionStatus == 'accepted') ...[
                        const SizedBox(height: 12),
                        _OutlinedButton(
                          label: 'Solicitar referencia',
                          icon: Icons.workspace_premium_outlined,
                          onTap: _showReferenceRequestSheet,
                        ),
                      ],
                      const SizedBox(height: 32),
                      const _SectionHeader(title: 'Acerca de'),
                      const SizedBox(height: 12),
                      Text(
                        user.bio?.isNotEmpty == true
                            ? user.bio!
                            : 'Este usuario todavía no ha agregado una biografía.',
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
                      const SizedBox(height: 24),
                      _ReferencesPreview(userId: user.id),
                      const SizedBox(height: 16),
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
                                photoUrl: user.photoUrl,
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

class _ReferencesPreview extends ConsumerWidget {
  final String userId;

  const _ReferencesPreview({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(publishedReferencesProvider(userId));

    return async.when(
      data: (references) {
        if (references.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(title: 'Referencias'),
            const SizedBox(height: 12),
            for (final reference in references.take(3))
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            reference.author?.name ??
                                reference.author?.email ??
                                'Referencia',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (reference.isSuspicious)
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFFFB547),
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reference.relationshipType,
                      style: const TextStyle(
                        color: Color(0xFF19B5FF),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reference.body,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    if (reference.isSuspicious) ...[
                      const SizedBox(height: 8),
                      Text(
                        reference.suspiciousReason ?? 'Referencia sospechosa',
                        style: const TextStyle(
                          color: Color(0xFFFFB547),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
  final IconData? icon;
  final VoidCallback onTap;
  const _OutlinedButton({required this.label, this.icon, required this.onTap});

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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
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

  String _value(Map<String, dynamic> item, List<String> keys, String fallback) {
    for (final key in keys) {
      final value = item[key]?.toString();
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final experiences = (user.experience ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final education = (user.education ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

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
        if (experiences.isEmpty)
          const Text(
            'Este usuario todavía no ha agregado experiencia deportiva.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          )
        else
          ...experiences.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _TimelineItem(
              title: _value(item, [
                'title',
                'role',
                'position',
              ], 'Experiencia deportiva'),
              subtitle: _value(item, [
                'team',
                'club',
                'organization',
              ], user.currentTeam ?? 'Equipo no especificado'),
              date: _value(item, ['date', 'period', 'period_label', 'year'], ''),
              description: _value(item, ['description', 'summary'], ''),
              trainer: _value(item, ['trainer', 'coach'], ''),
              isFirst: index == 0,
              isLast: index == experiences.length - 1,
            );
          }),
        const SizedBox(height: 16),
        const SizedBox(height: 32),
        const Text(
          'Educación',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 16),
        if (education.isEmpty)
          const Text(
            'Este usuario todavía no ha agregado educación o certificaciones.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          )
        else
          ...education.map(
            (item) => _EducationCard(
              title: _value(item, [
                'title',
                'institution',
                'school',
              ], 'Educación'),
              subtitle: _value(item, ['subtitle', 'degree', 'program'], ''),
              date: _value(item, ['date', 'period', 'period_label', 'year'], ''),
            ),
          ),
      ],
    );
  }
}

class _AchievementsContent extends StatelessWidget {
  final User user;

  const _AchievementsContent({required this.user});

  String _value(Map<String, dynamic> item, List<String> keys, String fallback) {
    for (final key in keys) {
      final value = item[key]?.toString();
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final achievements = (user.achievements ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return Column(
      children: [
        if (achievements.isEmpty)
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Este usuario todavía no ha agregado logros, torneos o premios.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          )
        else
          ...achievements.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final imagesRaw = item['images'];
            final images = imagesRaw is List
                ? imagesRaw.map((e) => e.toString()).toList()
                : null;
            return _TimelineAchievement(
              title: _value(item, [
                'title',
                'name',
                'award',
              ], 'Logro deportivo'),
              date: _value(item, ['date', 'date_label', 'year', 'period', 'period_label'], ''),
              images: images,
              isFirst: index == 0,
              isLast: index == achievements.length - 1,
            );
          }),
      ],
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
                // Displaying first post with images as seen in mockup
                if (posts.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _PostGridImage(
                          url:
                              posts[0].imageUrl ??
                              'https://images.unsplash.com/photo-1542362567-b055002b91f4?q=80&w=2070&auto=format&fit=crop',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PostGridImage(
                          url: posts.length > 1
                              ? posts[1].imageUrl ?? ''
                              : 'https://images.unsplash.com/photo-1542362567-b055002b91f4?q=80&w=2070&auto=format&fit=crop',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _PostGridImage(
                    url: posts.length > 2
                        ? posts[2].imageUrl ?? ''
                        : 'https://images.unsplash.com/photo-1502472545331-6415bf30960a?q=80&w=1932&auto=format&fit=crop',
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
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                if (trainer.isNotEmpty)
                  Text(
                    'Entrenador: $trainer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineAchievement extends StatelessWidget {
  final String title;
  final String date;
  final List<String>? images;
  final bool isFirst;
  final bool isLast;

  const _TimelineAchievement({
    required this.title,
    required this.date,
    this.images,
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;

  const _EducationCard({
    required this.title,
    required this.subtitle,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
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
        ],
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
