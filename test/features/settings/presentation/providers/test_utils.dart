import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/features/settings/domain/entities/user_profile.dart';
import 'package:sport/features/settings/domain/repositories/settings_repository.dart';
import 'package:sport/features/settings/presentation/providers/profile_providers.dart';
import 'package:sport/core/result/result.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

/// Helper to wrap widgets with ProviderScope and necessary overrides for testing
Widget createTestableWidget({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: child,
  );
}

const tUserProfile = UserProfile(
  firstName: 'Test',
  lastName: 'User',
  birthDate: '01/01/2000',
  profileType: 'Deportista',
  sport: 'Fútbol',
  position: 'Delantero',
  bio: 'Test Bio',
);
