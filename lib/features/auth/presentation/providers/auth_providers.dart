import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';

import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/features/auth/data/repositories/auth_repository_impl.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(prefs, apiClient);
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
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repository.signInWithEmailAndPassword(
      email,
      password,
    );
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signInAsDemoUser() async {
    state = const AsyncValue.loading();
    final result = await _repository.signInAsDemoUser();
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signUp({
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
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      countryId: countryId,
      city: city,
      sportId: sportId,
      profileType: profileType,
      phone: phone,
      birthDate: birthDate,
      position: position,
      sportLevel: sportLevel,
      currentTeam: currentTeam,
      socialLinks: socialLinks,
      avatarPath: avatarPath,
    );
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final result = await _repository.signOut();
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }

  Future<void> updateProfile({
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
    final currentUser = state.value;
    if (currentUser == null) return;

    state = const AsyncValue.loading();
    final result = await _repository.updateProfile(
      userId: currentUser.id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      sportId: sportId,
      countryId: countryId,
      city: city,
      profileType: profileType,
      birthDate: birthDate,
      position: position,
      sportLevel: sportLevel,
      currentTeam: currentTeam,
      socialLinks: socialLinks,
      bio: bio,
    );

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthController(repository);
    });

// Forgot Password Flow
final forgotPasswordNotifierProvider =
    StateNotifierProvider<ForgotPasswordNotifier, AsyncValue<String?>>((ref) {
      return ForgotPasswordNotifier(ref.watch(authRepositoryProvider));
    });

class ForgotPasswordNotifier extends StateNotifier<AsyncValue<String?>> {
  final AuthRepository _repository;
  ForgotPasswordNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> sendCode(String email) async {
    state = const AsyncValue.loading();
    final result = await _repository.forgotPassword(email);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (message) {
        state = AsyncValue.data(message);
        return true;
      },
    );
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.resetPassword(
      email: email,
      code: code,
      password: password,
    );
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data('Éxito');
        return true;
      },
    );
  }
}
