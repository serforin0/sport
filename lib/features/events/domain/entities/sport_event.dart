import 'package:equatable/equatable.dart';

class SportEvent extends Equatable {
  final String id;
  final String name;
  final String description;
  final String location;
  final String? city;
  final String? country;
  final String? sportName;
  final DateTime eventDate;
  final String? eventTime;
  final String organizerName;
  final String organizerContact;
  final int participantsCount;
  final String? photoUrl;

  const SportEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.eventDate,
    required this.organizerName,
    required this.organizerContact,
    this.city,
    this.country,
    this.sportName,
    this.eventTime,
    this.participantsCount = 0,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        location,
        city,
        country,
        sportName,
        eventDate,
        eventTime,
        organizerName,
        organizerContact,
        participantsCount,
        photoUrl,
      ];
}
