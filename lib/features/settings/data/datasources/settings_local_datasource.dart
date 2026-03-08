import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

abstract class SettingsLocalDataSource {
  Future<UserProfileModel?> getProfile();
  Future<void> cacheProfile(UserProfileModel profile);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _profileKey = 'CACHED_USER_PROFILE';

  SettingsLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<UserProfileModel?> getProfile() async {
    final jsonString = sharedPreferences.getString(_profileKey);
    if (jsonString != null) {
      return UserProfileModel.fromMap(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> cacheProfile(UserProfileModel profile) async {
    await sharedPreferences.setString(
      _profileKey,
      json.encode(profile.toMap()),
    );
  }
}
