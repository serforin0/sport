import 'package:sport/core/result/result.dart';
import 'package:sport/features/settings/domain/entities/account_session.dart';
import '../entities/user_profile.dart';
import '../entities/user_settings.dart';

abstract class SettingsRepository {
  Future<Result<UserProfile>> getProfile();
  Future<Result<void>> updateProfile(UserProfile profile);

  Future<Result<UserSettings>> getSettings();
  Future<Result<void>> updateSettings(UserSettings settings);
  Future<Result<void>> changePassword(String currentPassword, String password, String confirmation);
  Future<Result<List<AccountSession>>> getSessions();
  Future<Result<void>> closeSession(String sessionId);
}
