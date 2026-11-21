import 'package:sport/core/network/url_utils.dart';
import '../../domain/entities/sport_event.dart';

class SportEventModel extends SportEvent {
  const SportEventModel({
    required super.id,
    required super.name,
    required super.description,
    required super.location,
    required super.eventDate,
    required super.organizerName,
    required super.organizerContact,
    super.city,
    super.country,
    super.sportName,
    super.eventTime,
    super.participantsCount,
    super.photoUrl,
    super.eventType,
    super.routeText,
    super.capacity,
    super.spotsLeft,
    super.isFull,
    super.isParticipating,
    super.isSaved,
    super.participants,
  });

  factory SportEventModel.fromApi(Map<String, dynamic> json) {
    final sport = json['sport'];
    final dateRaw = json['event_date'] ?? json['date'];
    final rawParticipants = json['participants'];
    final participants = <EventParticipantSummary>[];
    if (rawParticipants is List) {
      for (final item in rawParticipants) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final user = map['user'] is Map
            ? Map<String, dynamic>.from(map['user'] as Map)
            : <String, dynamic>{};
        final first = user['first_name']?.toString() ?? '';
        final last = user['last_name']?.toString() ?? '';
        final full = '$first $last'.trim();
        participants.add(
          EventParticipantSummary(
            id: map['id']?.toString() ?? user['id']?.toString() ?? '',
            name: full.isNotEmpty
                ? full
                : (user['name']?.toString() ?? 'Participante'),
            avatarUrl: UrlUtils.resolve(user['avatar_url']?.toString()),
            status: map['status']?.toString(),
            activityUrl: map['activity_url']?.toString(),
          ),
        );
      }
    }

    return SportEventModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Evento deportivo',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      sportName: sport is Map ? sport['name']?.toString() : sport?.toString(),
      eventDate: DateTime.tryParse(dateRaw?.toString() ?? '') ?? DateTime.now(),
      eventTime: json['event_time']?.toString(),
      organizerName: json['organizer_name']?.toString() ?? 'Organizador',
      organizerContact: json['organizer_contact']?.toString() ?? '',
      participantsCount:
          int.tryParse((json['participants_count'] ?? 0).toString()) ?? 0,
      photoUrl: UrlUtils.resolve(json['photo_url']?.toString()),
      eventType: json['event_type']?.toString(),
      routeText: json['route_text']?.toString(),
      capacity: int.tryParse((json['capacity'] ?? '').toString()),
      spotsLeft: int.tryParse((json['spots_left'] ?? '').toString()),
      isFull: json['is_full'] == true,
      isParticipating: json['is_participating'] == true,
      isSaved: json['is_saved'] == true,
      participants: participants,
    );
  }
}
