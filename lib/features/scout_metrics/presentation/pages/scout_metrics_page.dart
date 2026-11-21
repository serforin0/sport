import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/core/theme/app_colors.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/scout_metrics/domain/entities/scout_metric.dart';
import 'package:sport/features/scout_metrics/presentation/providers/scout_metrics_providers.dart';

class ScoutMetricsPage extends ConsumerStatefulWidget {
  const ScoutMetricsPage({super.key});

  @override
  ConsumerState<ScoutMetricsPage> createState() => _ScoutMetricsPageState();
}

class _ScoutMetricsPageState extends ConsumerState<ScoutMetricsPage> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _wingspanController = TextEditingController();
  final _teamController = TextEditingController();
  final _videoTitleCtrl = TextEditingController();
  final _videoUrlCtrl = TextEditingController();
  String _laterality = 'right';
  final Map<String, TextEditingController> _metricControllers = {};
  bool _physicalSeeded = false;
  bool _saving = false;
  List<Map<String, dynamic>> _videos = [];
  bool _videosLoaded = false;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _wingspanController.dispose();
    _teamController.dispose();
    _videoTitleCtrl.dispose();
    _videoUrlCtrl.dispose();
    for (final c in _metricControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVideos());
  }

  Future<void> _loadVideos() async {
    final result = await ref.read(scoutMetricsRepositoryProvider).listVideos();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _videosLoaded = true),
      (list) => setState(() {
        _videos = list;
        _videosLoaded = true;
      }),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'federation_verified' || 'coach_verified' => AppColors.statusGreen,
      _ => Colors.white54,
    };
  }

  void _seedPhysical(User user) {
    if (_physicalSeeded) return;
    _heightController.text = user.heightCm?.toString() ?? '';
    _weightController.text = user.weightKg?.toString() ?? '';
    _wingspanController.text = user.wingspanCm?.toString() ?? '';
    _teamController.text = user.currentTeam ?? '';
    _laterality = _normalizeLaterality(user.laterality);
    _physicalSeeded = true;
  }

  String _normalizeLaterality(String? value) {
    const allowed = {'right', 'left', 'both'};
    if (value == null || value.isEmpty) return 'right';
    if (allowed.contains(value)) return value;
    if (value.contains('left')) return 'left';
    if (value.contains('right')) return 'right';
    return 'right';
  }

  double? _parseNum(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  TextEditingController _controllerFor(String definitionId, String? seed) {
    return _metricControllers.putIfAbsent(definitionId, () {
      return TextEditingController(text: seed ?? '');
    });
  }

  Future<void> _save(User user) async {
    if (user.sportId == null || user.sportId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un deporte en tu perfil primero'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(scoutMetricsRepositoryProvider);

    final physical = await repo.updatePhysicalProfile(
      userId: user.id,
      heightCm: _parseNum(_heightController.text),
      weightKg: _parseNum(_weightController.text),
      wingspanCm: _parseNum(_wingspanController.text),
      laterality: _laterality,
      currentTeam: _teamController.text.trim().isEmpty
          ? null
          : _teamController.text.trim(),
    );

    Result<bool> metrics = const Ok(true);
    final metricsPayload = <Map<String, dynamic>>[];
    for (final entry in _metricControllers.entries) {
      final raw = entry.value.text.trim();
      if (raw.isEmpty) continue;
      final numeric = _parseNum(raw);
      metricsPayload.add({
        'definition_id': entry.key,
        if (numeric != null) 'value_numeric': numeric,
        if (numeric == null) 'value_text': raw,
        'source': 'self_reported',
      });
    }
    if (metricsPayload.isNotEmpty) {
      metrics = await repo.upsertMetrics(metricsPayload);
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (physical.isFailure || metrics.isFailure) {
      final msg = physical.fold(
            (f) => f.message,
            (_) => metrics.fold((f) => f.message, (_) => 'Error al guardar'),
          );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      if (physical.isSuccess) {
        await ref.read(authControllerProvider.notifier).refreshUser();
      }
      return;
    }

    ref.invalidate(scoutMetricsProvider(user.sportId!));
    await ref.read(authControllerProvider.notifier).refreshUser();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil scout actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.valueOrNull;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
        ),
      );
    }

    _seedPhysical(user);
    final sportId = user.sportId;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Perfil scout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: sportId == null || sportId.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Asigna un deporte a tu perfil para cargar métricas verificables.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          : ref.watch(scoutMetricsProvider(sportId)).when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
              ),
              error: (e, _) => Center(
                child: Text(
                  '$e',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
              data: (snapshot) => _buildBody(user, snapshot),
            ),
    );
  }

  Widget _buildBody(User user, ScoutMetricsSnapshot snapshot) {
    final groups = snapshot.groupedDefinitions.entries.toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          user.mainSport ?? 'Deporte',
          style: const TextStyle(
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        if (user.sportLockedAt != null && user.sportLockedAt!.isNotEmpty) ...[
          const SizedBox(height: 6),
          const Text(
            'Deporte fijo. Para cambiarlo contacta al equipo HubSport.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
        const SizedBox(height: 24),
        const _SectionTitle('Perfil físico'),
        const SizedBox(height: 12),
        _Field(
          label: 'Altura (cm)',
          controller: _heightController,
          keyboard: TextInputType.number,
        ),
        _Field(
          label: 'Peso (kg)',
          controller: _weightController,
          keyboard: TextInputType.number,
        ),
        _Field(
          label: 'Envergadura (cm)',
          controller: _wingspanController,
          keyboard: TextInputType.number,
        ),
        _Field(label: 'Equipo / club', controller: _teamController),
        const SizedBox(height: 8),
        const Text(
          'Lateralidad',
          style: TextStyle(
            color: Color(0xFF3B82F6),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _laterality,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(),
          items: const [
            DropdownMenuItem(value: 'right', child: Text('Derecha')),
            DropdownMenuItem(value: 'left', child: Text('Izquierda')),
            DropdownMenuItem(value: 'both', child: Text('Ambas')),
          ],
          onChanged: (v) => setState(() => _laterality = v ?? 'right'),
        ),
        const SizedBox(height: 28),
        const _SectionTitle('Métricas'),
        const SizedBox(height: 8),
        if (snapshot.empty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              snapshot.invite ?? 'Agrega tu primera métrica verificable',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        if (groups.isEmpty)
          const Text(
            'No hay catálogo de métricas para este deporte.',
            style: TextStyle(color: Colors.white54),
          )
        else
          ...groups.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Text(
                    entry.key.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ...entry.value.map((def) {
                  final existing = snapshot.valueFor(def.id);
                  final controller = _controllerFor(
                    def.id,
                    existing?.valueNumeric?.toString() ?? existing?.valueText,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                def.unit == null
                                    ? def.label
                                    : '${def.label} (${def.unit})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (existing != null)
                              Text(
                                existing.verificationLabel,
                                style: TextStyle(
                                  color: _statusColor(
                                    existing.verificationStatus,
                                  ),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            color: AppColors.performanceGold,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: _inputDecoration(hint: 'Valor'),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }),
        const SizedBox(height: 28),
        const _SectionTitle('Videos'),
        const SizedBox(height: 8),
        if (!_videosLoaded)
          const LinearProgressIndicator(color: AppColors.brand)
        else if (_videos.isEmpty)
          const Text(
            'Agrega clips de juego, técnica o marcas.',
            style: TextStyle(color: Colors.white54),
          )
        else
          ..._videos.map(
            (video) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                video['title']?.toString() ?? 'Video',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                video['video_url']?.toString() ?? '',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white54),
                onPressed: () async {
                  final id = video['id']?.toString();
                  if (id == null) return;
                  final ok = await ref
                      .read(scoutMetricsRepositoryProvider)
                      .deleteVideo(id);
                  if (!mounted) return;
                  ok.fold(
                    (f) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(f.message)),
                    ),
                    (_) => setState(() {
                      _videos = _videos
                          .where((v) => v['id']?.toString() != id)
                          .toList();
                    }),
                  );
                },
              ),
            ),
          ),
        _Field(label: 'Título del video', controller: _videoTitleCtrl),
        _Field(label: 'URL del video', controller: _videoUrlCtrl),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () async {
              final title = _videoTitleCtrl.text.trim();
              final url = _videoUrlCtrl.text.trim();
              if (title.isEmpty || url.isEmpty) return;
              final ok = await ref.read(scoutMetricsRepositoryProvider).addVideo(
                    title: title,
                    videoUrl: url,
                  );
              if (!mounted) return;
              ok.fold(
                (f) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(f.message)),
                ),
                (_) {
                  _videoTitleCtrl.clear();
                  _videoUrlCtrl.clear();
                  setState(() => _videosLoaded = false);
                  _loadVideos();
                },
              );
            },
            icon: const Icon(Icons.video_call_outlined, color: AppColors.brand),
            label: const Text('Agregar video'),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _saving ? null : () => _save(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Guardar perfil scout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;

  const _Field({
    required this.label,
    required this.controller,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
