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
  final bool demoPreview;
  final Map<String, bool> featureFlags;

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
    this.demoPreview = false,
    this.featureFlags = const {},
    this.connectionStatus,
    this.stats,
  });

  final String? connectionStatus;
  final List<dynamic>? stats;

  bool canAccessDemoFeature(String feature) {
    if (!demoPreview) return false;
    return featureFlags[feature] ?? false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          photoUrl == other.photoUrl &&
          demoPreview == other.demoPreview &&
          _mapsEqual(featureFlags, other.featureFlags);

  @override
  int get hashCode {
    final featureKeys = featureFlags.keys.toList(growable: false)..sort();
    return Object.hash(
      id,
      email,
      name,
      photoUrl,
      demoPreview,
      Object.hashAll(
        featureKeys.map((key) => Object.hash(key, featureFlags[key])),
      ),
    );
  }

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
    int? postsCount,
    int? followersCount,
    int? followingCount,
    bool? demoPreview,
    Map<String, bool>? featureFlags,
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
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      demoPreview: demoPreview ?? this.demoPreview,
      featureFlags: featureFlags ?? this.featureFlags,
      connectionStatus: connectionStatus,
      stats: stats,
    );
  }
}

bool _mapsEqual(Map<String, bool> first, Map<String, bool> second) {
  if (identical(first, second)) return true;
  if (first.length != second.length) return false;
  return first.entries.every((entry) => second[entry.key] == entry.value);
}
