import 'package:sport/features/settings/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.firstName,
    required super.lastName,
    required super.birthDate,
    required super.profileType,
    required super.sport,
    required super.position,
    required super.bio,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      birthDate: map['birthDate'] ?? '',
      profileType: map['profileType'] ?? '',
      sport: map['sport'] ?? '',
      position: map['position'] ?? '',
      bio: map['bio'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate,
      'profileType': profileType,
      'sport': sport,
      'position': position,
      'bio': bio,
    };
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      firstName: entity.firstName,
      lastName: entity.lastName,
      birthDate: entity.birthDate,
      profileType: entity.profileType,
      sport: entity.sport,
      position: entity.position,
      bio: entity.bio,
    );
  }

  /// `GET /user/me` y estructuras tipo UserResource + profile anidado.
  factory UserProfileModel.fromApiUser(Map<String, dynamic> json) {
    final profile = json['profile'];
    Map<String, dynamic>? p;
    if (profile is Map) {
      p = Map<String, dynamic>.from(profile);
    }

    String fn = p?['first_name']?.toString() ?? json['first_name']?.toString() ?? '';
    String ln = p?['last_name']?.toString() ?? json['last_name']?.toString() ?? '';
    if (fn.isEmpty && ln.isEmpty) {
      final name = json['name']?.toString() ?? '';
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        fn = parts.first;
        if (parts.length > 1) ln = parts.sublist(1).join(' ');
      }
    }

    return UserProfileModel(
      firstName: fn,
      lastName: ln,
      birthDate: p?['birth_date']?.toString() ?? p?['birthDate']?.toString() ?? json['birth_date']?.toString() ?? '',
      profileType: p?['profile_type']?.toString() ?? p?['profileType']?.toString() ?? json['profile_type']?.toString() ?? 'Deportista',
      sport: p?['sport']?.toString() ?? json['sport']?.toString() ?? '',
      position: p?['position']?.toString() ?? json['position']?.toString() ?? '',
      bio: p?['bio']?.toString() ?? json['bio']?.toString() ?? '',
    );
  }

  /// Cuerpo para `PUT /user/{user}` (Laravel / UpdateUserRequest).
  Map<String, dynamic> toApiUpdateBody() {
    final profileTypeValue = switch (profileType.toLowerCase()) {
      'deportista' || 'atleta' => 'athlete',
      'entrenador' => 'coach',
      'reclutador' => 'recruiter',
      'patrocinador' || 'marca / patrocinador' => 'sponsor',
      'organizador de eventos' => 'event_organizer',
      'fanático del deporte' || 'fanatico del deporte' => 'fan',
      _ => profileType,
    };

    return {
      'first_name': firstName,
      'last_name': lastName,
      'profile': {
        'first_name': firstName,
        'last_name': lastName,
        'birth_date': birthDate,
        'profile_type': profileTypeValue,
        'sport': sport,
        'position': position,
        'bio': bio,
      },
    };
  }
}
