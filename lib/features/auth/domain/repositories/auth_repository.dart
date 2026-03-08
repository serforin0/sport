import 'package:sport/core/result/result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> signInWithEmailAndPassword(String email, String password);
  Future<Result<User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });
  Future<Result<void>> signOut();
  Future<Result<User?>> getCurrentUser();
}
