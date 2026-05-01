import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/features/settings/data/datasources/profile_remote_datasource.dart';
import 'package:sport/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:sport/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:sport/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:sport/features/settings/domain/entities/account_session.dart';
import 'package:sport/features/settings/domain/entities/user_profile.dart';
import 'package:sport/features/settings/domain/entities/user_settings.dart';
import 'package:sport/features/settings/domain/repositories/settings_repository.dart';

// Provides the repository
final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  throw UnimplementedError(); // Overridden in main.dart
});

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SettingsRemoteDataSourceImpl(apiClient);
});

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final local = ref.watch(settingsLocalDataSourceProvider);
  final remote = ref.watch(settingsRemoteDataSourceProvider);
  final profileRemote = ref.watch(profileRemoteDataSourceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepositoryImpl(local, remote, profileRemote, prefs);
});

// A proper AsyncNotifier for the Profile
class ProfileController extends FamilyAsyncNotifier<UserProfile, void> {
  @override
  Future<UserProfile> build(void arg) async {
    final repository = ref.watch(settingsRepositoryProvider);
    final result = await repository.getProfile();
    return result.fold(
      (failure) => throw failure.message,
      (profile) => profile,
    );
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = const AsyncValue.loading();
    final repository = ref.read(settingsRepositoryProvider);
    final result = await repository.updateProfile(profile);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = AsyncValue.data(profile),
    );
  }
}

final profileControllerProvider = AsyncNotifierProviderFamily<ProfileController, UserProfile, void>(
  ProfileController.new,
);

class SettingsController extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    final result = await ref.watch(settingsRepositoryProvider).getSettings();
    return result.fold((failure) => throw failure.message, (settings) => settings);
  }

  Future<void> updateSettings(UserSettings settings) async {
    state = AsyncValue.data(settings);
    final result = await ref.read(settingsRepositoryProvider).updateSettings(settings);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = AsyncValue.data(settings),
    );
  }
}

final settingsControllerProvider = AsyncNotifierProvider<SettingsController, UserSettings>(
  SettingsController.new,
);

final accountSessionsProvider = FutureProvider.autoDispose<List<AccountSession>>((ref) async {
  final result = await ref.watch(settingsRepositoryProvider).getSessions();
  return result.fold((failure) => throw Exception(failure.message), (sessions) => sessions);
});
