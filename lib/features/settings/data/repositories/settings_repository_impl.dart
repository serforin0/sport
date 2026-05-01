import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/result/result.dart';
import 'dart:convert';
import 'package:sport/features/settings/data/datasources/profile_remote_datasource.dart';
import 'package:sport/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:sport/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:sport/features/settings/domain/entities/user_profile.dart';
import 'package:sport/features/settings/domain/entities/account_session.dart';
import 'package:sport/features/settings/domain/entities/user_settings.dart';
import 'package:sport/features/settings/domain/repositories/settings_repository.dart';
import 'package:sport/features/settings/data/models/user_profile_model.dart';
import 'package:sport/features/settings/data/models/user_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  final SettingsRemoteDataSource remoteDataSource;
  final ProfileRemoteDataSource profileRemoteDataSource;
  final SharedPreferences sharedPreferences;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'cached_user';

  SettingsRepositoryImpl(
    this.localDataSource,
    this.remoteDataSource,
    this.profileRemoteDataSource,
    this.sharedPreferences,
  );

  @override
  Future<Result<UserProfile>> getProfile() async {
    try {
      final token = sharedPreferences.getString(_tokenKey);
      if (token != null) {
        try {
          final remote = await profileRemoteDataSource.getMe(token);
          await localDataSource.cacheProfile(remote);
          return Ok(remote);
        } catch (_) {
          // Continuar con caché local
        }
      }
      final profile = await localDataSource.getProfile();
      if (profile != null) {
        return Ok(profile);
      }
      return const Ok(UserProfile(
        firstName: 'Lewis',
        lastName: 'Hamilton',
        birthDate: '07/01/1985',
        profileType: 'Deportista',
        sport: 'Automovilismo',
        position: 'Piloto',
        bio: '7-time Formula 1 World Champion.',
      ));
    } catch (e) {
      return const Err(CacheFailure());
    }
  }

  @override
  Future<Result<void>> updateProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      await localDataSource.cacheProfile(model);

      final token = sharedPreferences.getString(_tokenKey);
      final userJson = sharedPreferences.getString(_userKey);
      if (token != null && userJson != null) {
        try {
          final map = json.decode(userJson) as Map<String, dynamic>;
          final userId = map['id']?.toString();
          if (userId != null && userId.isNotEmpty) {
            await profileRemoteDataSource.updateUser(token, userId, model.toApiUpdateBody());
          }
        } catch (_) {
          return Err(ServerFailure('No se pudo sincronizar el perfil con el servidor'));
        }
      }
      return const Ok(null);
    } catch (e) {
      return const Err(CacheFailure());
    }
  }

  @override
  Future<Result<UserSettings>> getSettings() async {
    try {
      final token = sharedPreferences.getString(_tokenKey);
      if (token != null) {
        try {
          final remoteSettings = await remoteDataSource.getSettings(token);
          await localDataSource.cacheSettings(remoteSettings);
          return Ok(remoteSettings);
        } catch (_) {
          // Continuar con caché local
        }
      }
      final settings = await localDataSource.getSettings();
      if (settings != null) {
        return Ok(settings);
      }
      return const Ok(UserSettings.defaultSettings);
    } catch (e) {
      return const Err(CacheFailure());
    }
  }

  @override
  Future<Result<void>> updateSettings(UserSettings settings) async {
    try {
      await localDataSource.cacheSettings(UserSettingsModel.fromEntity(settings));
      
      final token = sharedPreferences.getString(_tokenKey);
      if (token != null) {
        try {
          await remoteDataSource.updateSettings(token, UserSettingsModel.fromEntity(settings).toMap());
        } catch (_) {
          // Cola o reintento en otro momento
        }
      }
      
      return const Ok(null);
    } catch (e) {
      return const Err(CacheFailure());
    }
  }

  @override
  Future<Result<void>> changePassword(String currentPassword, String password, String confirmation) async {
    try {
      final token = sharedPreferences.getString(_tokenKey);
      if (token == null) return const Err(ServerFailure('Sesión no disponible'));
      await remoteDataSource.changePassword(token, currentPassword, password, confirmation);
      return const Ok(null);
    } catch (e) {
      return Err(ServerFailure('No se pudo cambiar la contraseña: $e'));
    }
  }

  @override
  Future<Result<List<AccountSession>>> getSessions() async {
    try {
      final token = sharedPreferences.getString(_tokenKey);
      if (token == null) return const Err(ServerFailure('Sesión no disponible'));
      final sessions = await remoteDataSource.getSessions(token);
      return Ok(sessions);
    } catch (e) {
      return Err(ServerFailure('No se pudieron cargar las sesiones: $e'));
    }
  }

  @override
  Future<Result<void>> closeSession(String sessionId) async {
    try {
      final token = sharedPreferences.getString(_tokenKey);
      if (token == null) return const Err(ServerFailure('Sesión no disponible'));
      await remoteDataSource.closeSession(token, sessionId);
      return const Ok(null);
    } catch (e) {
      return Err(ServerFailure('No se pudo cerrar la sesión: $e'));
    }
  }
}
