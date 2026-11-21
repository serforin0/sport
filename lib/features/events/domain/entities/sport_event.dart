import 'package:equatable/equatable.dart';

class EventParticipantSummary extends Equatable {
  final String id;
  final String? name;
  final String? avatarUrl;
  final String? status;
  final String? activityUrl;

  const EventParticipantSummary({
    required this.id,
    this.name,
    this.avatarUrl,
    this.status,
    this.activityUrl,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl, status, activityUrl];
}

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
  final String? eventType;
  final String? routeText;
  final int? capacity;
  final int? spotsLeft;
  final bool isFull;
  final bool isParticipating;
  final bool isSaved;
  final List<EventParticipantSummary> participants;

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
    this.eventType,
    this.routeText,
    this.capacity,
    this.spotsLeft,
    this.isFull = false,
    this.isParticipating = false,
    this.isSaved = false,
    this.participants = const [],
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
        eventType,
        routeText,
        capacity,
        spotsLeft,
        isFull,
        isParticipating,
        isSaved,
        participants,
      ];
}
