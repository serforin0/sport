import 'package:sport/core/result/result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> signInWithEmailAndPassword(String email, String password);
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
    String? position,
    String? sportLevel,
    String? currentTeam,
    Map<String, String>? socialLinks,
    String? avatarPath,
  });
  Future<Result<void>> signOut();
  Future<Result<User?>> getCurrentUser();
  Future<Result<String>> forgotPassword(String email);
  Future<Result<void>> resetPassword({required String email, required String code, required String password});
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
  });
  Future<Result<User>> getProfile(String userId);
}


