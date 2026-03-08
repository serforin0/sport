import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';
import 'package:sport/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences sharedPreferences;
  static const String _userKey = 'cached_user';

  AuthRepositoryImpl(this.sharedPreferences);

  @override
  Future<Result<User>> signInWithEmailAndPassword(String email, String password) async {
    // Simulación de autenticación (Hardcoded credentials requested in Figmas/Logic)
    if (email == 'yordyespinossa@gmail.com' && password == '12345678') {
      final user = UserModel(
        id: '1',
        email: email,
        name: 'Yordy Espinosa',
      );
      await _cacheUser(user);
      return Ok(user);
    } else {
      return const Err(ValidationFailure(message: 'Credenciales inválidas. Prueba con yordyespinossa@gmail.com / 12345678'));
    }
  }

  @override
  Future<Result<User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
    );
    await _cacheUser(user);
    return Ok(user);
  }

  @override
  Future<Result<void>> signOut() async {
    await sharedPreferences.remove(_userKey);
    return const Ok(null);
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    final userStr = sharedPreferences.getString(_userKey);
    if (userStr != null) {
      return Ok(UserModel.fromMap(json.decode(userStr)));
    }
    return const Ok(null);
  }

  Future<void> _cacheUser(UserModel user) async {
    await sharedPreferences.setString(_userKey, json.encode(user.toMap()));
  }
}
