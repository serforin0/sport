import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/core/network/url_utils.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.bio,
    super.photoUrl,
    super.phoneNumber,
    super.profileType,
    super.country,
    super.city,
    super.mainSport,
    super.sportId,
    super.sportLockedAt,
    super.sportLevel,
    super.currentTeam,
    super.birthDate,
    super.accountStatus,
    super.isMinor,
    super.slug,
    super.handle,
    super.connectionsCount,
    super.mutualConnectionsCount,
    super.position,
    super.heightCm,
    super.weightKg,
    super.wingspanCm,
    super.laterality,
    super.experience,
    super.achievements,
    super.education,
    super.socialLinks,
    super.verifiedBadge,
    super.isEmailVerified,
    super.verificationStatus,
    super.postsCount,
    super.followersCount,
    super.followingCount,
    super.demoPreview,
    super.featureFlags,
    super.connectionStatus,
    super.stats,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final profile = map['profile'];
    String? name = map['name']?.toString();
    if (name == null || name.isEmpty) {
      if (profile is Map) {
        final fn = profile['first_name']?.toString() ?? '';
        final ln = profile['last_name']?.toString() ?? '';
        final combined = '$fn $ln'.trim();
        if (combined.isNotEmpty) name = combined;
      }
    }
    final avatar = map['avatar'];
    String? photoUrl =
        map['photoUrl']?.toString() ??
        map['photo_url']?.toString() ??
        (avatar is Map ? avatar['url']?.toString() : avatar?.toString()) ??
        map['avatar_url']?.toString();
    if (photoUrl == null && profile is Map) {
      photoUrl =
          profile['avatar']?.toString() ?? profile['avatar_url']?.toString();
    }
    String? countryName;
    String? sportName;
    String? sportId;
    if (profile is Map) {
      final country = profile['country'];
      final sport = profile['sport'];
      countryName = country is Map
          ? country['name']?.toString()
          : country?.toString();
      sportName = sport is Map ? sport['name']?.toString() : sport?.toString();
      sportId = profile['sport_id']?.toString() ??
          (sport is Map ? sport['id']?.toString() : null);
    }
    Map<String, dynamic>? socialLinks;
    if (profile is Map && profile['social_links'] is Map) {
      socialLinks = Map<String, dynamic>.from(profile['social_links'] as Map);
    }
    final featureFlags = <String, bool>{};
    final rawFeatureFlags = map['feature_flags'] ?? map['featureFlags'];
    if (rawFeatureFlags is Map) {
      for (final entry in rawFeatureFlags.entries) {
        if (entry.value is bool) {
          featureFlags[entry.key.toString()] = entry.value as bool;
        }
      }
    }
    return UserModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: name,
      bio: profile is Map ? profile['bio']?.toString() : map['bio']?.toString(),
      photoUrl: UrlUtils.resolve(photoUrl),
      phoneNumber: profile is Map
          ? profile['phone_number']?.toString()
          : map['phone_number']?.toString(),
      profileType: profile is Map
          ? profile['profile_type']?.toString()
          : map['profile_type']?.toString(),
      country: countryName ?? map['country']?.toString(),
      city: profile is Map
          ? profile['city']?.toString()
          : map['city']?.toString(),
      mainSport: sportName ?? map['main_sport']?.toString(),
      sportId: sportId,
      sportLockedAt: profile is Map
          ? profile['sport_locked_at']?.toString()
          : null,
      sportLevel: profile is Map
          ? profile['sport_level']?.toString()
          : map['sport_level']?.toString(),
      currentTeam: profile is Map
          ? profile['current_team']?.toString()
          : map['current_team']?.toString(),
      birthDate: profile is Map
          ? profile['birth_date']?.toString()
          : map['birth_date']?.toString(),
      accountStatus: profile is Map
          ? profile['account_status']?.toString()
          : map['account_status']?.toString(),
      isMinor: profile is Map ? profile['is_minor'] == true : false,
      slug: map['slug']?.toString(),
      handle: map['handle']?.toString() ??
          (map['slug'] != null ? '@${map['slug']}' : null),
      connectionsCount: map['connections_count'] is int
          ? map['connections_count'] as int
          : int.tryParse('${map['connections_count'] ?? 0}') ?? 0,
      mutualConnectionsCount: map['mutual_connections_count'] is int
          ? map['mutual_connections_count'] as int
          : int.tryParse('${map['mutual_connections_count'] ?? 0}') ?? 0,
      position: profile is Map
          ? profile['position']?.toString()
          : map['position']?.toString(),
      heightCm: profile is Map
          ? double.tryParse(profile['height_cm']?.toString() ?? '')
          : null,
      weightKg: profile is Map
          ? double.tryParse(profile['weight_kg']?.toString() ?? '')
          : null,
      wingspanCm: profile is Map
          ? double.tryParse(profile['wingspan_cm']?.toString() ?? '')
          : null,
      laterality: profile is Map ? profile['laterality']?.toString() : null,
      experience: profile is Map && profile['experience'] is List
          ? List<dynamic>.from(profile['experience'] as List)
          : null,
      achievements: profile is Map && profile['achievements'] is List
          ? List<dynamic>.from(profile['achievements'] as List)
          : null,
      education: profile is Map && profile['education'] is List
          ? List<dynamic>.from(profile['education'] as List)
          : null,
      socialLinks: socialLinks,
      verifiedBadge: profile is Map
          ? profile['verified_badge'] == true
          : map['verified_badge'] == true,
      isEmailVerified:
          map['is_email_verified'] == true || map['email_verified_at'] != null,
      verificationStatus: profile is Map
          ? profile['verification_status']?.toString()
          : map['verification_status']?.toString(),
      postsCount: map['posts_count'] is int ? map['posts_count'] as int : 0,
      followersCount: map['followers_count'] is int
          ? map['followers_count'] as int
          : 0,
      followingCount: map['following_count'] is int
          ? map['following_count'] as int
          : 0,
      demoPreview: map['demo_preview'] == true || map['demoPreview'] == true,
      featureFlags: featureFlags,
      connectionStatus: map['connection_status']?.toString(),
      stats: map['stats'] is List
          ? List<dynamic>.from(map['stats'] as List)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'bio': bio,
      'photoUrl': photoUrl,
      'phone_number': phoneNumber,
      'profile_type': profileType,
      'country': country,
      'city': city,
      'main_sport': mainSport,
      'sport_level': sportLevel,
      'current_team': currentTeam,
      'birth_date': birthDate,
      'position': position,
      'experience': experience,
      'achievements': achievements,
      'education': education,
      'social_links': socialLinks,
      'verified_badge': verifiedBadge,
      'is_email_verified': isEmailVerified,
      'verification_status': verificationStatus,
      'posts_count': postsCount,
      'followers_count': followersCount,
      'following_count': followingCount,
      'demo_preview': demoPreview,
      'feature_flags': featureFlags,
      'profile': {
        'bio': bio,
        'phone_number': phoneNumber,
        'profile_type': profileType,
        'country': country,
        'city': city,
        'sport_id': sportId,
        'sport': mainSport == null ? null : {'id': sportId, 'name': mainSport},
        'sport_locked_at': sportLockedAt,
        'sport_level': sportLevel,
        'current_team': currentTeam,
        'birth_date': birthDate,
        'position': position,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'wingspan_cm': wingspanCm,
        'laterality': laterality,
        'experience': experience,
        'achievements': achievements,
        'education': education,
        'social_links': socialLinks,
        'verified_badge': verifiedBadge,
        'verification_status': verificationStatus,
      },
    };
  }
}
