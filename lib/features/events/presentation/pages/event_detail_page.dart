import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/theme/app_colors.dart';
import 'package:sport/features/events/domain/entities/sport_event.dart';
import 'package:sport/features/events/presentation/providers/events_providers.dart';

class EventDetailPage extends ConsumerStatefulWidget {
  final SportEvent event;

  const EventDetailPage({super.key, required this.event});

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage> {
  final _activityCtrl = TextEditingController();

  @override
  void dispose() {
    _activityCtrl.dispose();
    super.dispose();
  }

  String get _dateLabel {
    final e = widget.event;
    return '${e.eventDate.day}/${e.eventDate.month}/${e.eventDate.year}';
  }

  Future<void> _copyCalendar() async {
    final url = ref.read(eventsRepositoryProvider).calendarUrl(widget.event.id);
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enlace .ics copiado (añadir al calendario)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(eventDetailProvider(widget.event.id));
    final event = detailAsync.valueOrNull ?? widget.event;
    final isPast = event.eventDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: const BackButton(color: Colors.white),
        title: const Text('Detalle del evento', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Añadir al calendario',
            icon: const Icon(Icons.event_available, color: Colors.white),
            onPressed: _copyCalendar,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: event.photoUrl?.isNotEmpty == true
                      ? CachedNetworkImage(
                          imageUrl: event.photoUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.event, color: Colors.white24, size: 72),
                          ),
                        )
                      : Container(
                          color: AppColors.surface,
                          child: const Icon(Icons.event, color: Colors.white24, size: 72),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Pill(icon: Icons.sports, label: event.sportName ?? 'Deporte'),
                          _Pill(icon: Icons.calendar_today, label: _dateLabel),
                          if (event.eventTime?.isNotEmpty == true)
                            _Pill(icon: Icons.schedule, label: event.eventTime!),
                          if (event.eventType?.isNotEmpty == true)
                            _Pill(icon: Icons.flag, label: event.eventType!),
                          if (event.capacity != null)
                            _Pill(
                              icon: Icons.groups,
                              label: '${event.participantsCount}/${event.capacity}',
                              gold: true,
                            ),
                          if (event.isFull)
                            const _Pill(
                              icon: Icons.lock,
                              label: 'Cupo lleno',
                              green: false,
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _InfoRow(
                        icon: Icons.location_on,
                        title: 'Lugar',
                        value: [
                          event.location,
                          event.city,
                          event.country,
                        ].where((e) => e?.isNotEmpty == true).join(', '),
                      ),
                      if (event.routeText?.isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.route,
                          title: 'Ruta',
                          value: event.routeText!,
                        ),
                      ],
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.person,
                        title: 'Organizador',
                        value: event.organizerName,
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Quién va',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (detailAsync.isLoading)
                        const LinearProgressIndicator(color: AppColors.brand)
                      else if (event.participants.isEmpty)
                        Text(
                          '${event.participantsCount} inscritos (sin detalle aún)',
                          style: const TextStyle(color: Colors.white60),
                        )
                      else
                        SizedBox(
                          height: 72,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: event.participants.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 12),
                            itemBuilder: (_, i) {
                              final p = event.participants[i];
                              return Column(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: AppColors.surface,
                                    backgroundImage: p.avatarUrl != null
                                        ? CachedNetworkImageProvider(p.avatarUrl!)
                                        : null,
                                    child: p.avatarUrl == null
                                        ? Text(
                                            () {
                                              final n = (p.name ?? '?').trim();
                                              return n.isEmpty ? '?' : n[0].toUpperCase();
                                            }(),
                                            style: const TextStyle(color: Colors.white),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 64,
                                    child: Text(
                                      p.name ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 28),
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      if (isPast && event.isParticipating) ...[
                        const SizedBox(height: 28),
                        const Text(
                          'Vincular actividad del reloj',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pega la URL pública de Strava, Garmin u otra app (sin OAuth).',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _activityCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'https://www.strava.com/activities/...',
                            hintStyle: TextStyle(color: Colors.white38),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () async {
                              final url = _activityCtrl.text.trim();
                              if (url.isEmpty) return;
                              final ok = await ref
                                  .read(eventsListProvider.notifier)
                                  .linkActivity(
                                    eventId: event.id,
                                    activityUrl: url,
                                  );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'Actividad vinculada'
                                        : 'No se pudo vincular',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Guardar actividad'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.background,
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final ok = await ref
                              .read(eventsListProvider.notifier)
                              .save(event.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok ? 'Evento guardado' : 'No se pudo guardar',
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: event.isFull && !event.isParticipating
                            ? null
                            : () async {
                                final notifier =
                                    ref.read(eventsListProvider.notifier);
                                final ok = event.isParticipating
                                    ? await notifier.leave(event.id)
                                    : await notifier.participate(event.id);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ok
                                          ? (event.isParticipating
                                              ? 'Inscripción cancelada'
                                              : 'Inscripción realizada')
                                          : (event.isFull
                                              ? 'Cupo lleno'
                                              : 'No se pudo completar'),
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          event.isParticipating ? 'Cancelar' : 'Participar',
                        ),
                      ),
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

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool gold;
  final bool green;

  const _Pill({
    required this.icon,
    required this.label,
    this.gold = false,
    this.green = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = gold
        ? AppColors.performanceGold
        : green
            ? AppColors.statusGreen
            : AppColors.brandCyan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.brandCyan, size: 20),
        const SizedBox(width: 12),
        Expanded(
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
              Text(
                value.isEmpty ? 'No especificado' : value,
                style: const TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
