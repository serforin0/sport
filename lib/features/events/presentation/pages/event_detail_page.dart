import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/events/domain/entities/sport_event.dart';
import 'package:sport/features/events/presentation/providers/events_providers.dart';

class EventDetailPage extends ConsumerWidget {
  final SportEvent event;

  const EventDetailPage({super.key, required this.event});

  String get _dateLabel => '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        leading: const BackButton(color: Colors.white),
        title: const Text('Detalle del evento', style: TextStyle(color: Colors.white)),
        centerTitle: true,
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
                      ? CachedNetworkImage(imageUrl: event.photoUrl!, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFF1E293B),
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
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Pill(icon: Icons.sports, label: event.sportName ?? 'Deporte'),
                          _Pill(icon: Icons.calendar_today, label: _dateLabel),
                          if (event.eventTime?.isNotEmpty == true) _Pill(icon: Icons.schedule, label: event.eventTime!),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _InfoRow(icon: Icons.location_on, title: 'Lugar', value: [event.location, event.city, event.country].where((e) => e?.isNotEmpty == true).join(', ')),
                      const SizedBox(height: 12),
                      _InfoRow(icon: Icons.person, title: 'Organizador', value: event.organizerName),
                      const SizedBox(height: 12),
                      _InfoRow(icon: Icons.group, title: 'Participantes', value: '${event.participantsCount} inscritos'),
                      const SizedBox(height: 28),
                      const Text('Descripción', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 28),
                      const Text('Contacto del organizador', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(event.organizerContact, style: const TextStyle(color: Colors.white70)),
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
              color: const Color(0xFF0F172A),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final ok = await ref.read(eventsListProvider.notifier).save(event.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(ok ? 'Evento guardado' : 'No se pudo guardar')),
                          );
                        },
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54)),
                        child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final ok = await ref.read(eventsListProvider.notifier).participate(event.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(ok ? 'Inscripción realizada' : 'No se pudo inscribir')),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
                        child: const Text('Participar'),
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

  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2CB5FF)),
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

  const _InfoRow({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF2CB5FF), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(value.isEmpty ? 'No especificado' : value, style: const TextStyle(color: Colors.white60)),
            ],
          ),
        ),
      ],
    );
  }
}
