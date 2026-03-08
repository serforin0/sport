import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:sport/features/settings/domain/entities/user_profile.dart';
import 'package:sport/features/settings/domain/repositories/settings_repository.dart';
import 'package:sport/features/settings/data/models/user_profile_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<Result<UserProfile>> getProfile() async {
    try {
      final profile = await localDataSource.getProfile();
      if (profile != null) {
        return Ok(profile);
      } else {
        // Perfil por defecto
        return const Ok(UserProfile(
          firstName: 'Lewis',
          lastName: 'Hamilton',
          birthDate: '07/01/1985',
          profileType: 'Deportista',
          sport: 'Automovilismo',
          position: 'Piloto',
          bio: '7-time Formula 1 World Champion.',
        ));
      }
    } catch (e) {
      return const Err(CacheFailure());
    }
  }

  @override
  Future<Result<void>> updateProfile(UserProfile profile) async {
    try {
      await localDataSource.cacheProfile(UserProfileModel.fromEntity(profile));
      return const Ok(null);
    } catch (e) {
      return const Err(CacheFailure());
    }
  }
}
