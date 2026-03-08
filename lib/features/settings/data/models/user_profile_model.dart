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
}
