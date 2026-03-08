class UserProfile {
  final String firstName;
  final String lastName;
  final String birthDate;
  final String profileType;
  final String sport;
  final String position;
  final String bio;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.profileType,
    required this.sport,
    required this.position,
    required this.bio,
  });

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? birthDate,
    String? profileType,
    String? sport,
    String? position,
    String? bio,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      profileType: profileType ?? this.profileType,
      sport: sport ?? this.sport,
      position: position ?? this.position,
      bio: bio ?? this.bio,
    );
  }
}
