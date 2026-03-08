import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';
import 'package:sport/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // SharedPreferences is initialized in main and overridden
  throw UnimplementedError('Override authRepositoryProvider in ProviderScope');
});

// Auth state notifier
class AuthController extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.loading()) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final result = await _repository.getCurrentUser();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repository.signInWithEmailAndPassword(email, password);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
    );
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final result = await _repository.signOut();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});
