import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';
import 'package:sport/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;
  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'auth_token';

  AuthRepositoryImpl(this.sharedPreferences, this.apiClient);

  @override
  Future<Result<User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final body = response.data;
      if (body is! Map) {
        return Err(ValidationFailure('Respuesta de login inválida'));
      }
      final userRaw = body['data'];
      final token = body['token'];
      if (userRaw is! Map || token == null) {
        return Err(ValidationFailure('Respuesta de login inválida'));
      }

      final user = UserModel.fromMap(Map<String, dynamic>.from(userRaw));
      await _cacheSession(user, token.toString());

      return Ok(user);
    } catch (e) {
      return Err(ValidationFailure('Error al iniciar sesión: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User>> signInAsDemoUser() async {
    try {
      final response = await apiClient.post('/auth/demo-login');
      final body = response.data;
      if (body is! Map) {
        return Err(ValidationFailure('Respuesta de acceso demo inválida'));
      }
      final userRaw = body['data'];
      final token = body['token'];
      if (userRaw is! Map || token == null || token.toString().isEmpty) {
        return Err(ValidationFailure('Respuesta de acceso demo inválida'));
      }

      final user = UserModel.fromMap(Map<String, dynamic>.from(userRaw));
      await _cacheSession(user, token.toString());
      return Ok(user);
    } on Exception {
      return Err(
        ValidationFailure(
          'No se pudo iniciar la demostración. Inténtalo de nuevo.',
        ),
      );
    }
  }

  @override
  Future<Result<User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String countryId,
    required String city,
    required String sportId,
    required String profileType,
    String? phone,
    String? birthDate,
    String? guardianEmail,
    String? position,
    String? sportLevel,
    String? currentTeam,
    String? organizationName,
    String? rnc,
    String? organizationDocumentUrl,
    String? organizationWebsite,
    Map<String, String>? socialLinks,
    String? avatarPath,
  }) async {
    try {
      final validAvatarPath =
          avatarPath != null &&
              avatarPath.isNotEmpty &&
              await File(avatarPath).exists()
          ? avatarPath
          : null;
      final trimmed = name.trim();
      final parts = trimmed.split(RegExp(r'\s+'));
      final firstName = parts.isNotEmpty ? parts.first : trimmed;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      final profile = <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'country_id': countryId,
        'city': city,
        'sport_id': sportId,
        'profile_type': profileType,
        if (phone != null && phone.isNotEmpty) 'phone_number': phone,
        if (birthDate != null && birthDate.isNotEmpty) 'birth_date': birthDate,
        if (guardianEmail != null && guardianEmail.isNotEmpty)
          'guardian_email': guardianEmail,
        if (position != null && position.isNotEmpty) 'position': position,
        if (sportLevel != null && sportLevel.isNotEmpty)
          'sport_level': sportLevel,
        if (currentTeam != null && currentTeam.isNotEmpty)
          'current_team': currentTeam,
        if (organizationName != null && organizationName.isNotEmpty)
          'organization_name': organizationName,
        if (rnc != null && rnc.isNotEmpty) 'rnc': rnc,
        if (organizationDocumentUrl != null &&
            organizationDocumentUrl.isNotEmpty)
          'organization_document_url': organizationDocumentUrl,
        if (organizationWebsite != null && organizationWebsite.isNotEmpty)
          'organization_website': organizationWebsite,
        if (socialLinks != null && socialLinks.isNotEmpty)
          'social_links': socialLinks,
      };

      dynamic data = {
        'email': email,
        'password': password,
        'password_confirmation': password,
        'name': trimmed,
        'profile': profile,
      };

      if (validAvatarPath != null) {
        data = FormData.fromMap({
          'email': email,
          'password': password,
          'password_confirmation': password,
          'name': trimmed,
          for (final entry in profile.entries)
            if (entry.key != 'social_links')
              'profile[${entry.key}]': entry.value,
          if (socialLinks != null)
            for (final entry in socialLinks.entries)
              'profile[social_links][${entry.key}]': entry.value,
          'avatar': await MultipartFile.fromFile(validAvatarPath),
        });
      }

      final response = await apiClient.post('/auth/register', data: data);

      final body = response.data;
      if (body is! Map) {
        return Err(ValidationFailure('Respuesta de registro inválida'));
      }
      final userRaw = body['data'];
      final token = body['token'];
      if (userRaw is! Map || token == null) {
        return Err(ValidationFailure('Respuesta de registro inválida'));
      }

      final user = UserModel.fromMap(Map<String, dynamic>.from(userRaw));
      await _cacheSession(user, token.toString());

      return Ok(user);
    } catch (e) {
      return Err(ValidationFailure('Error al registrarse: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    final token = sharedPreferences.getString(_tokenKey);
    if (token != null) {
      try {
        await apiClient.delete(
          '/auth/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } catch (_) {
        // Invalidar sesión local aunque falle la red
      }
    }
    await sharedPreferences.remove(_userKey);
    await sharedPreferences.remove(_tokenKey);
    return const Ok(null);
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    final userStr = sharedPreferences.getString(_userKey);
    final token = sharedPreferences.getString(_tokenKey);

    if (userStr == null || token == null || token.isEmpty) {
      await sharedPreferences.remove(_userKey);
      await sharedPreferences.remove(_tokenKey);
      return const Ok(null);
    }

    try {
      final response = await apiClient.get(
        '/user/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final body = response.data;
      final userRaw = body is Map ? body['data'] : null;
      if (userRaw is Map) {
        final user = UserModel.fromMap(Map<String, dynamic>.from(userRaw));
        await _cacheUser(user);
        return Ok(user);
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        await sharedPreferences.remove(_userKey);
        await sharedPreferences.remove(_tokenKey);
        return const Ok(null);
      }
    }

    return Ok(UserModel.fromMap(json.decode(userStr) as Map<String, dynamic>));
  }

  @override
  Future<Result<String>> forgotPassword(String email) async {
    try {
      final response = await apiClient.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      final message = response.data['message'] ?? 'Código enviado';
      return Ok(message);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    try {
      await apiClient.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'code': code,
          'password': password,
          'password_confirmation': password,
        },
      );
      return Ok(null);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<User>> getProfile(String userId) async {
    try {
      final response = await apiClient.get('/user/$userId');
      final user = UserModel.fromMap(response.data['data']);
      return Ok(user);
    } catch (e) {
      return Err(ServerFailure('Error al obtener perfil: $e'));
    }
  }

  @override
  Future<Result<User>> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? sportId,
    String? countryId,
    String? city,
    String? profileType,
    String? birthDate,
    String? position,
    String? sportLevel,
    String? currentTeam,
    Map<String, String>? socialLinks,
    String? bio,
  }) async {
    try {
      final profileData = <String, dynamic>{};
      if (firstName != null) profileData['first_name'] = firstName;
      if (lastName != null) profileData['last_name'] = lastName;
      if (phone != null) profileData['phone_number'] = phone;
      if (sportId != null) profileData['sport_id'] = sportId;
      if (countryId != null) profileData['country_id'] = countryId;
      if (city != null) profileData['city'] = city;
      if (profileType != null) profileData['profile_type'] = profileType;
      if (birthDate != null) profileData['birth_date'] = birthDate;
      if (position != null) profileData['position'] = position;
      if (sportLevel != null) profileData['sport_level'] = sportLevel;
      if (currentTeam != null) profileData['current_team'] = currentTeam;
      if (socialLinks != null) profileData['social_links'] = socialLinks;
      if (bio != null) profileData['bio'] = bio;

      final response = await apiClient.put(
        '/user/$userId',
        data: {'profile': profileData},
      );

      final user = UserModel.fromMap(response.data['data']);
      await _cacheUser(user);
      return Ok(user);
    } catch (e) {
      return Err(ServerFailure('Error al actualizar perfil: $e'));
    }
  }

  Future<void> _cacheUser(UserModel user) async {
    await sharedPreferences.setString(_userKey, json.encode(user.toMap()));
  }

  Future<void> _cacheSession(UserModel user, String token) async {
    await _cacheUser(user);
    await sharedPreferences.setString(_tokenKey, token);
  }
}
