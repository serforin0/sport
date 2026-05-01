import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';
import '../models/user_settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<UserProfileModel?> getProfile();
  Future<void> cacheProfile(UserProfileModel profile);

  Future<UserSettingsModel?> getSettings();
  Future<void> cacheSettings(UserSettingsModel settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _profileKey = 'CACHED_USER_PROFILE';

  static const String _settingsKey = 'CACHED_USER_SETTINGS';

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

  @override
  Future<UserSettingsModel?> getSettings() async {
    final jsonString = sharedPreferences.getString(_settingsKey);
    if (jsonString != null) {
      return UserSettingsModel.fromMap(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> cacheSettings(UserSettingsModel settings) async {
    await sharedPreferences.setString(
      _settingsKey,
      json.encode(settings.toMap()),
    );
  }
}
