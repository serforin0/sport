import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/settings/domain/entities/user_profile.dart';
import 'package:sport/features/settings/domain/entities/user_settings.dart';
import 'package:sport/features/settings/domain/repositories/settings_repository.dart';
import 'package:sport/features/settings/presentation/providers/profile_providers.dart';
import 'test_prefs.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class SeededSettingsController extends SettingsController {
  @override
  Future<UserSettings> build() async => UserSettings.defaultSettings;
}

Widget wrapSettings(
  Widget child, {
  SettingsRepository? settingsRepository,
  AuthRepository? authRepository,
  UserProfile? profile,
}) {
  registerFallbackValue(UserSettings.defaultSettings);

  final settings = settingsRepository ?? MockSettingsRepository();
  final auth = authRepository ?? MockAuthRepository();
  final prefs = createMockPrefs();
  const user = User(id: 'u1', email: 'a@test.com', name: 'Ana');
  final resolvedProfile = profile ??
      const UserProfile(
        firstName: 'Lewis',
        lastName: 'Hamilton',
        birthDate: '07/01/1985',
        profileType: 'Deportista',
        sport: 'Automovilismo',
        position: 'Piloto',
        bio: '7-time Formula 1 World Champion.',
      );

  if (settings is MockSettingsRepository) {
    when(() => settings.getProfile()).thenAnswer((_) async => Ok(resolvedProfile));
    when(() => settings.getSettings())
        .thenAnswer((_) async => const Ok(UserSettings.defaultSettings));
    when(() => settings.updateSettings(any()))
        .thenAnswer((_) async => const Ok(UserSettings.defaultSettings));
    when(() => settings.getSessions()).thenAnswer((_) async => const Ok([]));
  }
  if (auth is MockAuthRepository) {
    when(() => auth.getCurrentUser()).thenAnswer((_) async => const Ok(user));
  }

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      settingsRepositoryProvider.overrideWithValue(settings),
      authRepositoryProvider.overrideWithValue(auth),
      settingsControllerProvider.overrideWith(SeededSettingsController.new),
    ],
    child: MaterialApp(home: child),
  );
}
