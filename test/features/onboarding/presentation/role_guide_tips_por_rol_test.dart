import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/onboarding/presentation/pages/role_guide_page.dart';
import 'package:sport/features/onboarding/presentation/providers/onboarding_providers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  Future<void> pumpFor(WidgetTester tester, String profileType) async {
    SharedPreferences.setMockInitialValues({});
    final auth = MockAuthRepository();
    final user = User(
      id: 'u1',
      email: 'u@test.com',
      name: 'User',
      profileType: profileType,
    );
    when(() => auth.getCurrentUser()).thenAnswer((_) async => Ok(user));
    final controller = AuthController(auth)..state = AsyncValue.data(user);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          authControllerProvider.overrideWith((ref) => controller),
          sharedPrefsInitProvider.overrideWith(
            (ref) async => SharedPreferences.getInstance(),
          ),
        ],
        child: const MaterialApp(home: RoleGuidePage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tips coach', (tester) async {
    await pumpFor(tester, 'coach');
    expect(find.textContaining('entrenadores'), findsOneWidget);
    expect(find.textContaining('Verifica marcas'), findsOneWidget);
  });

  testWidgets('tips sponsor', (tester) async {
    await pumpFor(tester, 'sponsor');
    expect(find.textContaining('organizaciones'), findsOneWidget);
    expect(find.textContaining('Revisión de cuenta'), findsOneWidget);
  });

  testWidgets('tips event_organizer', (tester) async {
    await pumpFor(tester, 'event_organizer');
    expect(find.textContaining('organizadores'), findsOneWidget);
    expect(find.textContaining('Moderación'), findsOneWidget);
  });
}
