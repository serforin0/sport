import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/feed/presentation/widgets/post_card.dart';
import 'package:sport/features/profile/presentation/pages/user_profile_page.dart';
import 'package:sport/features/jobs/presentation/pages/job_detail_page.dart';
import '../../../../core/widgets/skeleton_base.dart';
import 'package:sport/features/auth/domain/entities/meta.dart';
import 'package:sport/features/auth/presentation/providers/meta_providers.dart';
import 'package:sport/features/search/data/search_remote_datasource.dart';
import '../providers/search_providers.dart';


class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  final _cityController = TextEditingController();
  SearchFilters? _activeFilters;
  String? _selectedProfileType;
  Sport? _selectedSport;
  Country? _selectedCountry;
  String? _selectedSportLevel;
  String? _selectedOpportunityType;
  bool _talentSearch = false;
  bool _verifiedOnly = false;

  @override
  void dispose() {
    _controller.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _runSearch() {
    final submitted = _controller.text.trim();
    setState(() {
      _activeFilters = SearchFilters(
        query: submitted,
        profileType: _selectedProfileType,
        sportId: _selectedSport?.id,
        countryId: _selectedCountry?.id,
        city: _cityController.text.trim(),
        sportLevel: _selectedSportLevel,
        opportunityType: _selectedOpportunityType,
        talent: _talentSearch,
        verifiedOnly: _verifiedOnly,
      );
    });
  }

  bool get _hasActiveSearch {
    final filters = _activeFilters;
    if (filters == null) return false;
    return filters.toQueryParameters().isNotEmpty;
  }

  void _clearFilters() {
    setState(() {
      _selectedProfileType = null;
      _selectedSport = null;
      _selectedCountry = null;
      _selectedSportLevel = null;
      _selectedOpportunityType = null;
      _talentSearch = false;
      _verifiedOnly = false;
      _cityController.clear();
      _activeFilters = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authControllerProvider).valueOrNull?.id ?? '';
    final async = !_hasActiveSearch
        ? null
        : ref.watch(searchResultsProvider(_activeFilters!));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          cursorColor: const Color(0xFF3B82F6),
          decoration: const InputDecoration(
            hintText: 'Buscar usuarios y publicaciones…',
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
            isDense: true,
          ),
          onSubmitted: (_) => _runSearch(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF3B82F6)),
            onPressed: _runSearch,
          ),
        ],
      ),
      body: !_hasActiveSearch
          ? _buildDiscoverSection(context)
          : async!.when(

              loading: () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 10,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SkeletonBase(width: 40, height: 40, borderRadius: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBase(width: 150, height: 14),
                            SizedBox(height: 6),
                            SkeletonBase(width: 100, height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              error: (e, _) => Center(
                child: Text('Error: $e', style: const TextStyle(color: Colors.white54)),
              ),
              data: (data) {
                if (data.users.isEmpty && data.posts.isEmpty && data.opportunities.isEmpty && data.events.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildFiltersSection(),
                      const SizedBox(height: 32),
                      const Center(
                        child: Text('Sin resultados', style: TextStyle(color: Colors.white54)),
                      ),
                    ],
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildFiltersSection(),
                    const SizedBox(height: 20),
                    if (data.users.isNotEmpty) ...[
                      const Text(
                        'Usuarios',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...data.users.map(
                        (u) => ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => UserProfilePage(userId: u.id)),
                          ),
                          contentPadding: EdgeInsets.zero,
                          leading: Hero(
                            tag: 'profile_avatar_${u.id}',
                            child: CircleAvatar(
                              backgroundColor: Colors.white12,
                              backgroundImage: u.photoUrl != null
                                  ? CachedNetworkImageProvider(u.photoUrl!)
                                  : null,
                              child: u.photoUrl == null
                                  ? const Icon(Icons.person, color: Colors.white38)
                                  : null,
                            ),
                          ),
                          title: Text(
                            u.name ?? u.email,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            [
                              if ((u.profileType ?? '').isNotEmpty) _profileTypeLabel(u.profileType),
                              if ((u.mainSport ?? '').isNotEmpty) u.mainSport!,
                              if ((u.city ?? '').isNotEmpty) u.city!,
                            ].join(' • ').isEmpty ? u.email : [
                              if ((u.profileType ?? '').isNotEmpty) _profileTypeLabel(u.profileType),
                              if ((u.mainSport ?? '').isNotEmpty) u.mainSport!,
                              if ((u.city ?? '').isNotEmpty) u.city!,
                            ].join(' • '),
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                    if (data.opportunities.isNotEmpty) ...[
                      const Text(
                        'Oportunidades',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...data.opportunities.map(
                        (job) => Card(
                          color: Colors.white.withValues(alpha: 0.05),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => JobDetailPage(job: job)),
                            ),
                            title: Text(
                              job.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              '${job.company} • ${job.location}',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                            trailing: const Icon(Icons.work_outline, color: Color(0xFF3B82F6)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (data.posts.isNotEmpty) ...[
                      const Text(
                        'Publicaciones',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...data.posts.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PostCard(post: p, currentUserId: userId),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
    );
  }

  Widget _buildDiscoverSection(BuildContext context) {
    final sports = [
      {'name': 'Fútbol', 'icon': Icons.sports_soccer, 'color': Colors.green},
      {'name': 'Básquet', 'icon': Icons.sports_basketball, 'color': Colors.orange},
      {'name': 'Tenis', 'icon': Icons.sports_tennis, 'color': Colors.lime},
      {'name': 'Natación', 'icon': Icons.pool, 'color': Colors.blue},
      {'name': 'Vóley', 'icon': Icons.sports_volleyball, 'color': Colors.amber},
      {'name': 'Béisbol', 'icon': Icons.sports_baseball, 'color': Colors.red},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFiltersSection(),
          const SizedBox(height: 28),
          const Text(
            'Descubrir',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explora por categoría o deporte favorito',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: sports.length,
            itemBuilder: (context, index) {
              final sport = sports[index];
              return InkWell(
                onTap: () {
                  _controller.text = sport['name'] as String;
                  _runSearch();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Icon(
                          sport['icon'] as IconData,
                          size: 80,
                          color: (sport['color'] as Color).withValues(alpha: 0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              sport['icon'] as IconData,
                              color: sport['color'] as Color,
                              size: 24,
                            ),
                            const Spacer(),
                            Text(
                              sport['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Populares ahora',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentSearchItem('Entrenamientos en Madrid'),
          _buildRecentSearchItem('Torneos de Verano 2024'),
          _buildRecentSearchItem('Mejores Jugadas del Mes'),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    final countriesAsync = ref.watch(countriesProvider);
    final sportsAsync = ref.watch(sportsProvider);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Filtros de búsqueda',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Limpiar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SearchDropdown<String>(
            label: 'Tipo de perfil',
            value: _selectedProfileType,
            items: const {
              'athlete': 'Atleta',
              'coach': 'Entrenador',
              'recruiter': 'Reclutador',
              'sponsor': 'Marca / Patrocinador',
              'event_organizer': 'Organizador de eventos',
              'fan': 'Fanático',
            },
            onChanged: (value) => setState(() => _selectedProfileType = value),
          ),
          const SizedBox(height: 10),
          sportsAsync.when(
            data: (sports) => _ObjectDropdown<Sport>(
              label: 'Deporte',
              value: _selectedSport,
              items: sports,
              itemLabel: (sport) => sport.name,
              onChanged: (value) => setState(() => _selectedSport = value),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('No se pudieron cargar deportes', style: TextStyle(color: Colors.redAccent)),
          ),
          const SizedBox(height: 10),
          countriesAsync.when(
            data: (countries) => _ObjectDropdown<Country>(
              label: 'País',
              value: _selectedCountry,
              items: countries,
              itemLabel: (country) => country.name,
              onChanged: (value) => setState(() => _selectedCountry = value),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('No se pudieron cargar países', style: TextStyle(color: Colors.redAccent)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _cityController,
            style: const TextStyle(color: Colors.white),
            decoration: _filterDecoration('Ciudad'),
            onSubmitted: (_) => _runSearch(),
          ),
          const SizedBox(height: 10),
          _SearchDropdown<String>(
            label: 'Nivel deportivo',
            value: _selectedSportLevel,
            items: const {
              'beginner': 'Principiante',
              'amateur': 'Amateur',
              'semi_pro': 'Semiprofesional',
              'professional': 'Profesional',
              'elite': 'Élite',
            },
            onChanged: (value) => setState(() => _selectedSportLevel = value),
          ),
          const SizedBox(height: 10),
          _SearchDropdown<String>(
            label: 'Tipo de oportunidad',
            value: _selectedOpportunityType,
            items: const {
              'job': 'Trabajo deportivo',
            },
            onChanged: (value) => setState(() => _selectedOpportunityType = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Búsqueda de talento',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            subtitle: const Text(
              'Solo atletas (entrenadores/reclutadores)',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            value: _talentSearch,
            activeColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() {
              _talentSearch = v;
              if (!v) _verifiedOnly = false;
            }),
          ),
          if (_talentSearch)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Solo verificados',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              value: _verifiedOnly,
              activeColor: const Color(0xFF22C55E),
              onChanged: (v) => setState(() => _verifiedOnly = v),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _runSearch,
              icon: const Icon(Icons.search),
              label: const Text('Aplicar filtros'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _filterDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      isDense: true,
    );
  }

  String _profileTypeLabel(String? value) {
    return switch (value) {
      'athlete' => 'Atleta',
      'coach' => 'Entrenador',
      'recruiter' => 'Reclutador',
      'sponsor' => 'Patrocinador',
      'event_organizer' => 'Organizador',
      'fan' => 'Fanático',
      _ => value ?? '',
    };
  }

  Widget _buildRecentSearchItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _controller.text = text;
          _runSearch();
        },
        child: Row(
          children: [
            const Icon(Icons.history, color: Colors.white24, size: 18),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  const _SearchDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      dropdownColor: const Color(0xFF1E293B),
      decoration: _decoration(label),
      style: const TextStyle(color: Colors.white),
      items: items.entries
          .map((entry) => DropdownMenuItem<T>(
                value: entry.key,
                child: Text(entry.value),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _ObjectDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;

  const _ObjectDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      dropdownColor: const Color(0xFF1E293B),
      decoration: _decoration(label),
      style: const TextStyle(color: Colors.white),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

InputDecoration _decoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: const Color(0xFF1E293B),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    isDense: true,
  );
}

