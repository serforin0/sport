class User {
  final String id;
  final String email;
  final String? name;
  final String? bio;
  final String? photoUrl;
  final String? phoneNumber;
  final String? profileType;
  final String? country;
  final String? city;
  final String? mainSport;
  final String? sportLevel;
  final String? currentTeam;
  final String? birthDate;
  final String? position;
  final List<dynamic>? experience;
  final List<dynamic>? achievements;
  final List<dynamic>? education;
  final Map<String, dynamic>? socialLinks;
  final bool verifiedBadge;
  final bool isEmailVerified;
  final String? verificationStatus;
  final int postsCount;
  final int followersCount;
  final int followingCount;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.bio,
    this.photoUrl,
    this.phoneNumber,
    this.profileType,
    this.country,
    this.city,
    this.mainSport,
    this.sportLevel,
    this.currentTeam,
    this.birthDate,
    this.position,
    this.experience,
    this.achievements,
    this.education,
    this.socialLinks,
    this.verifiedBadge = false,
    this.isEmailVerified = false,
    this.verificationStatus,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.connectionStatus,
    this.stats,
  });


  final String? connectionStatus;
  final List<dynamic>? stats;



  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ name.hashCode ^ photoUrl.hashCode;

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? bio,
    String? photoUrl,
    String? phoneNumber,
    String? profileType,
    String? country,
    String? city,
    String? mainSport,
    String? sportLevel,
    String? currentTeam,
    String? birthDate,
    String? position,
    List<dynamic>? experience,
    List<dynamic>? achievements,
    List<dynamic>? education,
    Map<String, dynamic>? socialLinks,
    bool? verifiedBadge,
    bool? isEmailVerified,
    String? verificationStatus,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileType: profileType ?? this.profileType,
      country: country ?? this.country,
      city: city ?? this.city,
      mainSport: mainSport ?? this.mainSport,
      sportLevel: sportLevel ?? this.sportLevel,
      currentTeam: currentTeam ?? this.currentTeam,
      birthDate: birthDate ?? this.birthDate,
      position: position ?? this.position,
      experience: experience ?? this.experience,
      achievements: achievements ?? this.achievements,
      education: education ?? this.education,
      socialLinks: socialLinks ?? this.socialLinks,
      verifiedBadge: verifiedBadge ?? this.verifiedBadge,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }

}
