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
  });

  factory SportEventModel.fromApi(Map<String, dynamic> json) {
    final sport = json['sport'];
    final dateRaw = json['event_date'] ?? json['date'];

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
      participantsCount: int.tryParse((json['participants_count'] ?? 0).toString()) ?? 0,
      photoUrl: UrlUtils.resolve(json['photo_url']?.toString()),
    );
  }
}
