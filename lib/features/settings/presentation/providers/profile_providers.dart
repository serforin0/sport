import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:sport/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:sport/features/settings/domain/entities/user_profile.dart';
import 'package:sport/features/settings/domain/repositories/settings_repository.dart';

// Provides the repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('Initialize SharedPreferences in main and override this');
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
