import '../../../../core/result/result.dart';
import '../entities/user_profile.dart';

abstract class SettingsRepository {
  Future<Result<UserProfile>> getProfile();
  Future<Result<void>> updateProfile(UserProfile profile);
}
