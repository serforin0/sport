import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/features/settings/domain/entities/user_profile.dart';
import 'package:sport/features/settings/domain/repositories/settings_repository.dart';
import 'package:sport/features/settings/presentation/pages/settings_page.dart';
import 'package:sport/features/settings/presentation/providers/profile_providers.dart';
import 'package:sport/core/result/result.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
  });

  Widget createTestableWidget() {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: const MaterialApp(
        home: SettingsPage(),
      ),
    );
  }

  const tUserProfile = UserProfile(
    firstName: 'Lewis',
    lastName: 'Hamilton',
    birthDate: '07/01/1985',
    profileType: 'Deportista',
    sport: 'Automovilismo',
    position: 'Piloto',
    bio: '7-time Formula 1 World Champion.',
  );

  testWidgets('Muestra la información del perfil correctamente', (tester) async {
    // arrange
    when(() => mockRepository.getProfile()).thenAnswer((_) async => const Ok(tUserProfile));

    // act
    await tester.pumpWidget(createTestableWidget());

    // assert initially loading or similar if implemented
    // but here we wait for data
    await tester.pumpAndSettle();

    // assert profile info in subtitle of "Editar perfil"
    expect(find.text('Lewis Hamilton'), findsOneWidget);
    expect(find.text('Editar perfil'), findsOneWidget);
  });

  testWidgets('Navega a editar perfil al tocar el tile', (tester) async {
    // arrange
    when(() => mockRepository.getProfile()).thenAnswer((_) async => const Ok(tUserProfile));

    // act
    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Editar perfil'));
    await tester.pumpAndSettle();

    // assert we are on EditProfilePage (check for a specific text on that page)
    expect(find.text('EDITAR PERFIL'), findsOneWidget);
  });
}
