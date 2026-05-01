import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/events/domain/entities/sport_event.dart';
import 'package:sport/features/events/presentation/pages/create_event_page.dart';
import 'package:sport/features/events/presentation/pages/event_detail_page.dart';
import 'package:sport/features/events/presentation/providers/events_providers.dart';

class EventsListPage extends ConsumerWidget {
  const EventsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        leading: const BackButton(color: Colors.white),
        title: const Text('Eventos deportivos', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateEventPage()),
            ),
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(
              child: Text('No hay eventos disponibles todavía', style: TextStyle(color: Colors.white54)),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(eventsListProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) => _EventCard(event: events[index]),
            ),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          itemBuilder: (_, __) => const _EventSkeleton(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error al cargar eventos', style: TextStyle(color: Colors.white70)),
              TextButton(
                onPressed: () => ref.read(eventsListProvider.notifier).refresh(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final SportEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: event.photoUrl?.isNotEmpty == true
                  ? CachedNetworkImage(imageUrl: event.photoUrl!, fit: BoxFit.cover)
                  : Container(
                      color: Colors.white10,
                      child: const Icon(Icons.event, color: Colors.white24, size: 48),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                  const SizedBox(height: 6),
                  Text(
                    [
                      event.sportName,
                      '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                      event.city ?? event.location,
                    ].where((item) => item?.isNotEmpty == true).join(' • '),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.group, color: Color(0xFF2CB5FF), size: 16),
                      const SizedBox(width: 6),
                      Text('${event.participantsCount} participantes', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.white30),
                    ],
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

class _EventSkeleton extends StatelessWidget {
  const _EventSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}
